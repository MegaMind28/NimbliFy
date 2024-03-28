import 'package:flutter/material.dart';

const darkThemeColor = Color(0xFF202020);
const lightThemeColor = Color(0xFFfee394);
const lightYellow = Color(0xFFfff4db);

Widget customSizedBox({
  double? width,
  double? height,
}) {
  return SizedBox(
    width: width,
    height: height,
  );
}

TextStyle customTextStyle({
  Color? color = Colors.black,
  double? fontSize = 16,
  FontWeight? fontWeight = FontWeight.normal,
}) {
  return TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontFamily: 'Sans');
}