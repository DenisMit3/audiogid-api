import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_flutter/data/services/download_service.dart';
import 'package:mobile_flutter/data/local/app_database.dart';
import 'package:mobile_flutter/data/services/storage_manager.dart';
import 'package:mobile_flutter/presentation/widgets/offline_progress_indicator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:mobile_flutter/core/constants/offline_constants.dart';
import 'dart:io';

class OfflineManagerScreen extends ConsumerWidget {
  const OfflineManagerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cityDao = ref.watch(appDatabaseProvider).cityDao;
    
    return Scaffold(
      appBar: AppBar(title: const Text('Offline Manager')),
      body: StreamBuilder<List<City>>(
        stream: cityDao.watchAllCities(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final cities = snapshot.data!;
          
          return CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: _StorageHeader()),
              SliverList(delegate: SliverChildBuilderDelegate(
                (context, index) {
                   final city = cities[index];
                   return _CityDownloadTile(city: city);
                },
                childCount: cities.length,
              )),
            ],
          );
        }
      )
    );
  }
}

class _StorageHeader extends ConsumerWidget {
  const _StorageHeader();
  
  Future<Map<String, int>> _getStorageInfo(WidgetRef ref) async {
     final manager = ref.read(storageManagerProvider.notifier);
     final free = await manager.getFreeDiskSpace();
     
     final appDocDir = await getApplicationDocumentsDirectory();
     final offlineDir = Directory(p.join(appDocDir.path, OfflineConstants.offlineDir));
     final used = await manager.getDirectorySize(offlineDir);
     
     return {'free': free, 'used': used};
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
     return FutureBuilder<Map<String, int>>(
       future: _getStorageInfo(ref),
       builder: (context, snapshot) {
         final free = snapshot.data?['free'] ?? 0;
         final used = snapshot.data?['used'] ?? 0;
         final hasData = snapshot.hasData;

         return Card(
           margin: const EdgeInsets.all(16),
           child: Padding(
             padding: const EdgeInsets.all(16),
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Text('Storage Usage', style: Theme.of(context).textTheme.titleMedium),
                 const SizedBox(height: 16),
                 Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                     Text('Used by App: ${hasData ? _formatBytes(used) : '...'}'),
                     Text('Free: ${hasData ? _formatBytes(free) : '...'}'),
                   ],
                 ),
                 if (hasData && (free + used) > 0)
                   Padding(
                     padding: const EdgeInsets.only(top: 8.0),
                     child: LinearProgressIndicator(value: used / (free + used + 1), backgroundColor: Colors.grey[200]),
                   )
               ],
             ),
           )
         );
       }
     );
  }
}

class _CityDownloadTile extends ConsumerWidget {
   final City city;
   const _CityDownloadTile({required this.city});
   
   @override
   Widget build(BuildContext context, WidgetRef ref) {
      final downloadedListAsync = ref.watch(downloadedCitiesProvider);
      final downloadState = ref.watch(downloadServiceProvider);
      
      final isActive = downloadState.containsKey(city.slug);
      final status = downloadState[city.slug];
      
      final isDownloaded = downloadedListAsync.value?.contains(city.slug) ?? false;
      
      Widget trailing;
      if (isActive && status != null) {
         if (status.stage == DownloadStage.failed) {
            trailing = Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Failed", style: TextStyle(color: Colors.red)),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    ref.read(downloadServiceProvider.notifier).startDownload(city.slug);
                  },
                ),
              ],
            );
         } else if (status.stage == DownloadStage.completed) {
            // Should be handled by isDownloaded usually, but just in case check logic
            trailing = IconButton(
               icon: const Icon(Icons.delete_outline),
               onPressed: () => _confirmDelete(context, ref)
            );
         } else {
           trailing = SizedBox(
             width: 100,
             child: OfflineProgressIndicator(
               progress: status.progress, 
               label: status.stage.name.split('.').last
             )
           );
         }
      } else if (isDownloaded) {
         trailing = Row(
           mainAxisSize: MainAxisSize.min,
           children: [
             IconButton(
               icon: const Icon(Icons.refresh),
               tooltip: 'Re-download',
               onPressed: () => _confirmRedownload(context, ref)
             ),
             IconButton(
               icon: const Icon(Icons.delete_outline),
               onPressed: () => _confirmDelete(context, ref)
             ),
           ],
         );
      } else {
         trailing = IconButton(
           icon: const Icon(Icons.download_for_offline),
           onPressed: () {
             ref.read(downloadServiceProvider.notifier).startDownload(city.slug);
           }
         );
      }
      
      return ListTile(
        title: Text(city.nameRu),
        subtitle: isActive && status?.error != null ? Text(status!.error!, style: const TextStyle(color: Colors.red)) : null,
        trailing: trailing,
      );
   }

   void _confirmDelete(BuildContext context, WidgetRef ref) {
      showDialog(context: context, builder: (c) => AlertDialog(
       title: const Text('Delete Bundle?'),
       content: Text('Remove offline content for ${city.nameRu}?'),
       actions: [
         TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
         TextButton(onPressed: () {
           Navigator.pop(c);
           ref.read(downloadServiceProvider.notifier).deleteBundle(city.slug);
         }, child: const Text('Delete')),
       ],
     ));
   }

   void _confirmRedownload(BuildContext context, WidgetRef ref) {
      showDialog(context: context, builder: (c) => AlertDialog(
       title: const Text('Re-download Bundle?'),
       content: Text('Update offline content for ${city.nameRu}?'),
       actions: [
         TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
         TextButton(onPressed: () {
           Navigator.pop(c);
           // Delete first, then download
           ref.read(downloadServiceProvider.notifier).deleteBundle(city.slug)
             .then((_) => ref.read(downloadServiceProvider.notifier).startDownload(city.slug));
         }, child: const Text('Re-download')),
       ],
     ));
   }
}
