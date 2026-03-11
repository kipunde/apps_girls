import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

Widget mlBackToPreviousIcon(BuildContext context, Color color) {
  return Align(
    alignment: Alignment.topLeft,
    child: Icon(Icons.arrow_back_ios_outlined, color: color, size: 18),
  ).onTap(() {
    finish(context);
  });
}

void changeStatusColor(Color color) async {
  setStatusBarColor(color);
}