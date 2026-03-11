import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:nb_utils/nb_utils.dart';

import '../components/HomeTopComponent.dart';

class MainDashboard extends StatefulWidget{
  static String tag = "/MainDashboard";

  const MainDashboard({super.key});

  @override
  MainDashboardState  createState() => MainDashboardState();


}

class MainDashboardState extends State<MainDashboard>{

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context){
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
         children: [
            HomeTopComponent(),
          16.height,
         ]
        ),
      ),
    );
  }

}