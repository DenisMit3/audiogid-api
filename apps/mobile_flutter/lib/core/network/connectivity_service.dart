import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ConnectionStatus {
  online,
  offline,
}

class ConnectivityService extends StateNotifier<ConnectionStatus> {
  final Connectivity _connectivity = Connectivity();

  ConnectivityService() : super(ConnectionStatus.online) {
    _init();
  }

  void _init() async {
    final result = await _connectivity.checkConnectivity();
    _updateStatus(result);

    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
       // connectivity_plus v6 emits list
      _updateStatus(results);
    });
  }

  void _updateStatus(List<ConnectivityResult> results) {
     if (results.contains(ConnectivityResult.none) && results.length == 1) {
       state = ConnectionStatus.offline;
     } else {
       state = ConnectionStatus.online;
     }
  }
}

final connectivityServiceProvider = StateNotifierProvider<ConnectivityService, ConnectionStatus>((ref) {
  return ConnectivityService();
});
