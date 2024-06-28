import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:my_people/utility/debug_print.dart';

Future<bool> isConnected() async {
  var connectivityResult = await Connectivity().checkConnectivity();

  if (connectivityResult.first == ConnectivityResult.mobile ||
      connectivityResult.first == ConnectivityResult.wifi) {
    DebugPrint.log(
      'Internet is connected',
      tag: 'InternetConnectivityHelper',
      color: DebugColor.green,
    );
    return true;
  } else {
    DebugPrint.log(
      'Internet is not connected',
      tag: 'InternetConnectivityHelper',
      color: DebugColor.red,
    );
    return false;
  }
}
