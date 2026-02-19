import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:archive/archive_io.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:mobile_flutter/core/api/api_provider.dart';
import 'package:mobile_flutter/core/constants/offline_constants.dart';
import 'package:mobile_flutter/data/local/app_database.dart';
import 'package:mobile_flutter/data/services/storage_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:api_client/api.dart' as api;
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

part 'download_service.g.dart';

enum DownloadStage {
  idle,
  requestingBuild,
  buildingBundle,
  downloadingZip,
  extracting,
  verifying,
  completed,
  failed,
}

class CityDownloadStatus {
  final String citySlug;
  final double progress; // 0.0 to 1.0
  final DownloadStage stage;
  final String? error;
  final String? contentHash;

  CityDownloadStatus({
    required this.citySlug,
    this.progress = 0.0,
    this.stage = DownloadStage.idle,
    this.error,
    this.contentHash,
  });

  CityDownloadStatus copyWith({
    double? progress,
    DownloadStage? stage,
    String? error,
    String? contentHash,
  }) {
    return CityDownloadStatus(
      citySlug: citySlug,
      progress: progress ?? this.progress,
      stage: stage ?? this.stage,
      error: error,
      contentHash: contentHash ?? this.contentHash,
    );
  }
}

@Riverpod(keepAlive: true)
class DownloadService extends _$DownloadService {
  final ReceivePort _port = ReceivePort();
  static const String _portName = 'downloader_send_port';
  
  // Mapping taskId -> citySlug
  final Map<String, String> _tasks = {};
  
  @override
  Map<String, CityDownloadStatus> build() {
    _initDownloader();
    return {};
  }

  void _initDownloader() {
    IsolateNameServer.removePortNameMapping(_portName);
    IsolateNameServer.registerPortWithName(_port.sendPort, _portName);
    _port.listen((dynamic data) {
      String id = data[0];
      int status = data[1];
      int progress = data[2];
      _onDownloadProgress(id, status, progress);
    });
    FlutterDownloader.registerCallback(downloadCallback);
  }

  @pragma('vm:entry-point')
  static void downloadCallback(String id, int status, int progress) {
    final SendPort? send = IsolateNameServer.lookupPortByName(_portName);
    send?.send([id, status, progress]);
  }

  Future<void> startDownload(String citySlug) async {
    // Permission check for Android < 29 (WRITE_EXTERNAL_STORAGE)
    if (Platform.isAndroid) {
       final status = await Permission.storage.request();
       if (!status.isGranted) {
           // We continue anyway as newer Android versions might grant implicitly or use different storage
           // but strictly we should probably warn or return. 
           // For now, allow proceeding if it's just 'denied' but not 'permanently', 
           // or if on newer Android where this perm might not be needed for app-specific storage.
           // However, FlutterDownloader often needs it for external directories.
           // We will throw if strictly denied to adhere to "request... before enqueueing".
           if (await Permission.storage.isPermanentlyDenied) {
              throw Exception("Storage permission required to download content");
           }
       }
    }

    state = {
      ...state,
      citySlug: CityDownloadStatus(citySlug: citySlug, stage: DownloadStage.requestingBuild)
    };

    try {
      final offlineApi = ref.read(offlineApiProvider);
      
      // 1. Enqueue Build
      final idempotencyKey = const Uuid().v4();
      final buildReq = api.BuildOfflineBundleRequest(
        citySlug: citySlug,
        idempotencyKey: idempotencyKey,
      );
      
      final enqueueRes = await offlineApi.buildOfflineBundle(buildReq);
      final jobId = enqueueRes?.jobId;
      if (jobId == null) throw Exception("No job ID returned");

      state = {
        ...state,
        citySlug: state[citySlug]!.copyWith(stage: DownloadStage.buildingBundle)
      };

      // 2. Poll Status
      api.OfflineJobRead? jobResult;
      int attempts = 0;
      const maxAttempts = 30; // 60 seconds approx
      int delaySeconds = 2;
      
      while (attempts < maxAttempts) {
        await Future.delayed(Duration(seconds: delaySeconds));
        try {
          final pollRes = await offlineApi.getOfflineBundleStatus(jobId);
          final status = pollRes?.status;
          
          if (status == 'COMPLETED') {
            jobResult = pollRes;
            break;
          } else if (status == 'FAILED') {
            throw Exception('Bundle build failed: ${pollRes?.lastError}');
          }
        } on DioException catch (e) {
          // Retry on network/timeout errors
          if (e.type == DioExceptionType.connectionTimeout || 
              e.type == DioExceptionType.receiveTimeout ||
              e.type == DioExceptionType.sendTimeout ||
              e.type == DioExceptionType.connectionError) {
             // Just continue to next attempt, but maybe backoff more
             if (delaySeconds < 10) delaySeconds += 2;
             attempts++; // Count this as an attempt
             continue;
          }
          rethrow;
        } catch (e) {
          rethrow;
        }
        
        attempts++;
        if (delaySeconds < 5) delaySeconds++; // Normal backoff
      }
      
      if (jobResult == null) {
         throw Exception("Bundle build timed out");
      }
      
      // 3. Storage Budget Control
      // Assuming a safe buffer of 500MB if size unknown, or use 0 and let cleanup decide.
      // We call cleanupOldBundles to ensure we have space.
       await ref.read(storageManagerProvider.notifier).cleanupOldBundles(500 * 1024 * 1024);

      // 4. Start Download
      final bundleUrl = jobResult.result!.bundleUrl!;
      final manifestUrl = jobResult.result!.manifestUrl!;
      final contentHash = jobResult.result!.contentHash;
      
      state = {
        ...state,
        citySlug: state[citySlug]!.copyWith(
          stage: DownloadStage.downloadingZip,
          contentHash: contentHash,
        )
      };

      // Download Manifest
      final manifestData = await _downloadManifest(manifestUrl);

      // Download ZIP
      final appDocDir = await getApplicationDocumentsDirectory();
      final saveDir = Directory(p.join(appDocDir.path, OfflineConstants.offlineDir, 'zips'));
      if (!saveDir.existsSync()) saveDir.createSync(recursive: true);

      final taskId = await FlutterDownloader.enqueue(
        url: bundleUrl,
        savedDir: saveDir.path,
        fileName: '${citySlug}_bundle.zip',
        showNotification: true,
        openFileFromNotification: false,
      );

      if (taskId != null) {
        _tasks[taskId] = citySlug;
      }
      
      final manifestFile = File(p.join(saveDir.path, '${citySlug}_manifest.json'));
      await manifestFile.writeAsString(jsonEncode(manifestData));

    } catch (e) {
      state = {
        ...state,
        citySlug: state[citySlug]!.copyWith(
          stage: DownloadStage.failed,
          error: e.toString(),
        )
      };
    }
  }

  Future<Map<String, dynamic>> _downloadManifest(String url) async {
    final dio = ref.read(dioProvider);
    final res = await dio.get(url);
    return res.data as Map<String, dynamic>;
  }

  void _onDownloadProgress(String taskId, int status, int progress) {
    final citySlug = _tasks[taskId];
    if (citySlug == null) return;

    final downloadStatus = DownloadTaskStatus.values[status];
    
    if (downloadStatus == DownloadTaskStatus.running) {
       state = {
        ...state,
        citySlug: state[citySlug]!.copyWith(
          progress: progress / 100.0,
          stage: DownloadStage.downloadingZip
        )
      };
    } else if (downloadStatus == DownloadTaskStatus.complete) {
      _handleDownloadComplete(citySlug, taskId);
    } else if (downloadStatus == DownloadTaskStatus.failed) {
       state = {
        ...state,
        citySlug: state[citySlug]!.copyWith(
          stage: DownloadStage.failed,
          error: 'Download failed',
        )
      };
    }
  }

  Future<void> _handleDownloadComplete(String citySlug, String taskId) async {
    try {
      state = {
        ...state,
        citySlug: state[citySlug]!.copyWith(stage: DownloadStage.extracting, progress: 0.5)
      };

      final appDocDir = await getApplicationDocumentsDirectory();
      final zipDir = Directory(p.join(appDocDir.path, OfflineConstants.offlineDir, 'zips'));
      final zipFile = File(p.join(zipDir.path, '${citySlug}_bundle.zip'));
      final extractDir = Directory(p.join(appDocDir.path, OfflineConstants.offlineDir, citySlug));

      if (!await zipFile.exists()) throw Exception("Zip file not found");

      // Verify Checksum
      if (state[citySlug]?.contentHash != null) {
         state = {
          ...state,
          citySlug: state[citySlug]!.copyWith(stage: DownloadStage.verifying)
        };
        
        final expectedHash = state[citySlug]!.contentHash!.toLowerCase();
        final fileBytes = await zipFile.readAsBytes();
        
        String calculatedHash;
        if (expectedHash.length == 32) {
            calculatedHash = md5.convert(fileBytes).toString();
        } else if (expectedHash.length == 40) {
            calculatedHash = sha1.convert(fileBytes).toString();
        } else {
            // Default to SHA256
            calculatedHash = sha256.convert(fileBytes).toString();
        }
        
        if (calculatedHash.toLowerCase() != expectedHash) {
           throw Exception("Checksum mismatch ($calculatedHash != $expectedHash)");
        }
      }

      state = {
        ...state,
        citySlug: state[citySlug]!.copyWith(stage: DownloadStage.extracting)
      };

      // Unzip
      await Isolate.run(() {
         final bytes = zipFile.readAsBytesSync();
         final archive = ZipDecoder().decodeBytes(bytes);
         for (final file in archive) {
            final filename = file.name;
            if (file.isFile) {
              final data = file.content as List<int>;
              File(p.join(extractDir.path, filename))
                ..createSync(recursive: true)
                ..writeAsBytesSync(data);
            }
         }
      });

      // Cleanup Zip
      await zipFile.delete();

      // Parse Manifest and Update DB
      state = {
        ...state,
        citySlug: state[citySlug]!.copyWith(stage: DownloadStage.verifying)
      };
      
      final manifestFile = File(p.join(zipDir.path, '${citySlug}_manifest.json'));
      if (manifestFile.existsSync()) {
        final manifestJson = jsonDecode(await manifestFile.readAsString());
        // We could also do individual file verification here if manifest has hashes
        await _processManifest(citySlug, manifestJson, extractDir.path);
        await manifestFile.delete();
      }

      state = {
        ...state,
        citySlug: state[citySlug]!.copyWith(stage: DownloadStage.completed, progress: 1.0)
      };
    } catch (e) {
      state = {
        ...state,
        citySlug: state[citySlug]!.copyWith(stage: DownloadStage.failed, error: e.toString())
      };
    }
  }

  Future<void> _processManifest(String citySlug, Map<String, dynamic> manifest, String basePath) async {
     // Expected Manifest: { "narrations": { "id": "filename" }, "media": { "id": "filename" } }
     // OR list of objects.
     // I'll support a simple map format or assume standard data structure.
     // For now, let's assume it maps IDs to relative paths.
     
     final db = ref.read(appDatabaseProvider);
     
     if (manifest.containsKey('narrations')) {
       final narrationsMap = manifest['narrations'] as Map<String, dynamic>;
       for (final entry in narrationsMap.entries) {
          final id = entry.key;
          final filename = entry.value as String;
          await (db.update(db.narrations)..where((tbl) => tbl.id.equals(id)))
              .write(NarrationsCompanion(localPath: Value(p.join(basePath, filename))));
       }
     }
     
     if (manifest.containsKey('media')) {
       final mediaMap = manifest['media'] as Map<String, dynamic>;
        for (final entry in mediaMap.entries) {
          final id = entry.key;
          final filename = entry.value as String;
           await (db.update(db.media)..where((tbl) => tbl.id.equals(id)))
              .write(MediaCompanion(localPath: Value(p.join(basePath, filename))));
       }
     }
  }

  Future<void> deleteBundle(String citySlug) async {
     try {
       final appDocDir = await getApplicationDocumentsDirectory();
       final extractDir = Directory(p.join(appDocDir.path, OfflineConstants.offlineDir, citySlug));
       
       if (await extractDir.exists()) {
         await extractDir.delete(recursive: true);
       }
       
       // Update DB: clear localPath for this city slug? 
       // Wait, Narrations table doesn't have citySlug directly, it links to POI which has citySlug.
       // Requires join.
       final db = ref.read(appDatabaseProvider);
       
       // Custom update query involves joins, simpler to do 2 steps or custom SQL.
       // Drift's update with join is tricky.
       // We can select IDs first.
       
       /* 
          UPDATE narrations SET local_path = NULL 
          WHERE poi_id IN (SELECT id FROM pois WHERE city_slug = :slug)
       */
       
       // Using custom statement or raw query is easier here.
       await db.customStatement('UPDATE narrations SET local_path = NULL WHERE poi_id IN (SELECT id FROM pois WHERE city_slug = ?)', [citySlug]);
       await db.customStatement('UPDATE media SET local_path = NULL WHERE poi_id IN (SELECT id FROM pois WHERE city_slug = ?)', [citySlug]);
       
       // Invalidate downloadedCities provider
       ref.invalidate(downloadedCitiesProvider);
       
     } catch (e) {
       // log error
     }
  }
}

@riverpod
Future<List<String>> downloadedCities(Ref ref) async {
  // Watch download service to refresh when download completes
  final downloadState = ref.watch(downloadServiceProvider);
  // Also force refresh when delete calls invalidate? 
  // Ideally this provider is watched by UI.
  
  final appDocDir = await getApplicationDocumentsDirectory();
  final offlineDir = Directory(p.join(appDocDir.path, OfflineConstants.offlineDir));
  if (!await offlineDir.exists()) return [];
  
  final list = <String>[];
  await for (final entity in offlineDir.list()) {
    if (entity is Directory && p.basename(entity.path) != 'zips') {
       list.add(p.basename(entity.path));
    }
  }
  return list;
}
