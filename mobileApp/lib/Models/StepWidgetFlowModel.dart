import 'package:flutter/material.dart';

class StepWidgetFlowModel{
  int? id;
  String?  title;
  Widget? widget;
  double? progress;

  StepWidgetFlowModel({this.id,this.title, this.widget, this.progress});
}