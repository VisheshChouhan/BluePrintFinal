import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  // Check current connectivity status
  Future<bool> isConnected() async {
    var connectivityResult = await _connectivity.checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  // Stream to listen for connectivity changes
  Stream<ConnectivityResult> get connectivityStream => _connectivity.onConnectivityChanged;
}
