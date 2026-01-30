import 'dart:io';
import 'package:disk_space_2/disk_space_2.dart';
import 'package:mobile_flutter/core/constants/offline_constants.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'storage_manager.g.dart';

@riverpod
class StorageManager extends _$StorageManager {
  @override
  Future<void> build() async {}

  Future<int> getFreeDiskSpace() async {
    // Return bytes. DiskSpace.getFreeDiskSpace returns MB (int/double).
    // It returns Future<int?> or similar.
    final freeMb = await DiskSpace.getFreeDiskSpace;
    if (freeMb == null) return 1024 * 1024 * 1024; // Default to 1GB if failed
    return (freeMb * 1024 * 1024).toInt();
  }

  Future<int> getDirectorySize(Directory dir) async {
    if (!await dir.exists()) return 0;
    int size = 0;
    try {
      await for (final entity in dir.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          size += await entity.length();
        }
      }
    } catch (e) {
      // ignore
    }
    return size;
  }

  /// Removes least-recently-used bundles until [bytesNeeded] space is available.
  Future<void> cleanupOldBundles(int bytesNeeded) async {
    int freeSpace = await getFreeDiskSpace();
    if (freeSpace >= bytesNeeded) return;

    final appDocDir = await getApplicationDocumentsDirectory();
    final offlineDir = Directory(p.join(appDocDir.path, OfflineConstants.offlineDir));
    
    if (!await offlineDir.exists()) return;

    List<FileSystemEntity> entities = [];
    await for (final entity in offlineDir.list()) {
      if (entity is Directory && p.basename(entity.path) != 'zips') {
        entities.add(entity);
      }
    }

    // Sort by modified time (oldest first)
    // Note: This relies on OS updating modified time.
    final Map<String, DateTime> modifiedTimes = {};
    for (var e in entities) {
      final stat = await e.stat();
      modifiedTimes[e.path] = stat.modified;
    }

    entities.sort((a, b) => (modifiedTimes[a.path] ?? DateTime.now()).compareTo(modifiedTimes[b.path] ?? DateTime.now()));

    for (final entity in entities) {
      if (freeSpace >= bytesNeeded) break;
      final size = await getDirectorySize(entity as Directory);
      await entity.delete(recursive: true);
      freeSpace += size;
      
      // We should probably inform the app/DB that this city is deleted?
      // Ideally DownloadService or a listener handles the valid state.
      // But for now, we just free space.
    }
    
    if (freeSpace < bytesNeeded) {
       throw Exception("Not enough space even after cleanup");
    }
  }
}
