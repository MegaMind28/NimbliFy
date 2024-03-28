import 'package:assignment/utils/constants.dart';
import 'package:fluttertoast/fluttertoast.dart';

void showToast({
  required String toastMsg
}){
  Fluttertoast.showToast(
      msg: toastMsg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 5,
      backgroundColor: darkThemeColor,
      textColor: lightYellow,
      fontSize: 16.0
  );
}