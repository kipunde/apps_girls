import 'package:esrs_eqa_app/Models/MLServicesData.dart';
import 'package:esrs_eqa_app/utils/DataProvider.dart';
import 'package:esrs_eqa_app/utils/EQAString.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../main.dart';
import '../utils/Images.dart';
import '../utils/MLColors.dart';

class HomeTopComponent extends StatefulWidget {
  static String tag = "/HomeTopComponent";

  @override
  _HomeTopComponentState createState() => _HomeTopComponentState();
}

class _HomeTopComponentState extends State<HomeTopComponent> {
  int counter = 2;
  List<MLServicesData> data = mlServiceDataList();

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    //
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 700,
      width: context.width(),
      margin: EdgeInsets.only(bottom: 16.0),
      decoration: boxDecorationWithRoundedCorners(
        backgroundColor: mlColorDarkBlue,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.elliptical(MediaQuery.of(context).size.width, 80.0),
        ),
      ),
      child: Column(
        children: [
          16.height,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    child: Image.asset(ml_ic_profile_picture!),
                    radius: 22,
                    backgroundColor: mlColorCyan,
                  ),
                  8.width,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ✅ Display dynamic user name here
                      Text(appStore.userName, style: boldTextStyle(color: whiteColor)),
                      4.height,
                      Text(s_welcome!, style: secondaryTextStyle(color: white.withOpacity(0.7))),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.search, color: white, size: 24),
                  10.width,
                  Stack(
                    children: [
                      Icon(Icons.shopping_bag_outlined, color: white, size: 24),
                      Positioned(
                        top: 0.0,
                        right: 0.0,
                        child: Container(
                          padding: EdgeInsets.all(2),
                          decoration: boxDecorationWithRoundedCorners(
                            backgroundColor: mlColorRed,
                          ),
                          constraints: BoxConstraints(minWidth: 12, minHeight: 12),
                          child: Text(
                            counter.toString(),
                            style: boldTextStyle(size: 8, color: white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ).onTap(() {}),
                ],
              ),
            ],
          ).paddingOnly(right: 16.0, left: 16.0),
          Container(
            margin: EdgeInsets.only(right: 16.0, left: 16.0),
            transform: Matrix4.translationValues(0, 16.0, 0),
            alignment: Alignment.center,
            //decoration: boxDecorationRoundedWithShadow(12, backgroundColor: context.cardColor),
            /*
            child: Wrap(
              alignment: WrapAlignment.center,
              direction: Axis.horizontal,
              spacing: 8.0,
              children: data.map((e) {
                return Container(
                  constraints: BoxConstraints(minWidth: context.width() * 0.25),
                  padding: EdgeInsets.only(top: 20, bottom: 20.0),
                  child: Column(
                    children: [
                      Image.asset(e.image!, width: 28, height: 28, fit: BoxFit.fill),
                      8.height,
                      Text(e.title.toString(), style: boldTextStyle(size: 12), textAlign: TextAlign.center),
                    ],
                  ),
                ).onTap(() {
                  e.widget.launch(context);
                });
              }).toList(),
            ), */
              child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.all(2),
              crossAxisSpacing: 20,  // 🔹 space between items horizontally
              mainAxisSpacing: 30,   // 🔹 space between rows vertically
              childAspectRatio: 1.3,
              children: data.map((e) {
                return Container(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  decoration: boxDecorationRoundedWithShadow(
                    12,
                    backgroundColor: context.cardColor,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(e.image!, width: 60, height: 60),
                      8.height,
                      Text(
                        e.title.toString(),
                        style: boldTextStyle(size: 12),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ).onTap(() {
                  e.widget.launch(context);
                });
              }).toList(),
            ),
                      ),
        ],
      ),
    );
  }
}
