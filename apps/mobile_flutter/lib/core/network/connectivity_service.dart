import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connectivity_service.g.dart';

enum ConnectionStatus {
  online,
  offline,
}

@riverpod
class ConnectivityService extends _$ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  @override
  ConnectionStatus build() {
    _init();
    return ConnectionStatus.online;
  }

  void _init() async {
    final result = await _connectivity.checkConnectivity();
    _updateStatus(result);

    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
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
