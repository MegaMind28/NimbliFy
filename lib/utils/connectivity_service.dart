import 'package:connectivity_plus/connectivity_plus.dart';
import 'logger_helper.dart';

class ConnectivityService {
  static Future<bool> isConnectedToInternet() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    LoggerHelper.showSuccessLog( text:  "connection : $connectivityResult");
    connectivityResult.remove(ConnectivityResult.none);
    if (connectivityResult.isNotEmpty){
      return true;
    } else {
      return false;
    }
  }
}
