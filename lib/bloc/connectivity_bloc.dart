import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';

class ConnectivityBloc extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  ConnectivityResult connectivityResult = ConnectivityResult.none;

  ConnectivityBloc() {
    checkConnectivity();
    _connectivity.onConnectivityChanged.listen((event) {
      connectivityResult = event;
      notifyListeners();
    });
    notifyListeners();
  }

  Future checkConnectivity() async {
   await _connectivity.checkConnectivity().then((value) {
      connectivityResult = value;
      notifyListeners();
    });
  }
}
