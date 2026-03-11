import 'package:esrs_eqa_app/Screens/ReceivedSampleScreen.dart';
import 'package:esrs_eqa_app/Screens/ResultToReviewScreen.dart';
import 'package:esrs_eqa_app/Screens/SampleReceivingScreen.dart';
import 'package:esrs_eqa_app/utils/AppWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:nb_utils/nb_utils.dart';

import '../Models/CategoryModel.dart';
import '../Models/TrackingIDResponseModel.dart';
import '../Services/EQADataService.dart';
import '../main.dart';
import '../utils/AppColors.dart';
import '../utils/DataProvider.dart';

class DashboardWidget extends StatefulWidget{
  static String tag = "/DashboardWidget";

  @override
  DashboardWidgetState  createState() => DashboardWidgetState();
}

class DashboardWidgetState extends State<DashboardWidget>{
  PageController pageController = PageController();
  List<Widget> pages = [];
  List<CategoryModel> categories = [];

  int selectedIndex = 0;

  final List trackingIDs  = [];
  int currentPage = 1;
  bool isLoading = false;
  bool hasMore = true;

  final eqaService = EQADataService();
  final ScrollController _scrollController = ScrollController();

  void handleGetTrackingID() async {

    setState(() {
      isLoading = true;
    });
    try{
       TrackingIDResponseModel?  samples = await eqaService.getTrackingIdSamples();
      if(samples!=null){
        setState(() {
          currentPage++;
          trackingIDs.addAll(samples.trackingIDModel as Iterable);
          hasMore = samples.nextPageUrl != null;
          isLoading = false;
        });

      }else{
        setState(() {
          isLoading = false;
        });
      }


    }catch(e){
      print("get tracking errors $e");
      setState(() {
        isLoading = false;
      });
    }

  }

  @override
  void initState(){
    super.initState();
    init();

    handleGetTrackingID();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200 &&
          !isLoading &&
          hasMore) {
        handleGetTrackingID();
      }
    });
  }

  init() async{
    categories.add(CategoryModel(id: 1,name: 'Received', icon: 'images/defaultTheme/category/electronics.png'));
    categories.add(CategoryModel(id:2,name: 'Result to review', icon: 'images/defaultTheme/category/Tv.png'));
    categories.add(CategoryModel(id:3,name: 'Submitted Results', icon: 'images/defaultTheme/category/Man.png'));
    categories.add(CategoryModel(id:4,name: 'Reports', icon: 'images/defaultTheme/category/women.png'));

    setState(() {});
  }


  @override
  void setState(fn){
    if(mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context){
    Widget searchTxt() {
      return Container(
        width: dynamicWidth(context),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: viewLineColor),
          color: context.scaffoldBackgroundColor,
        ),
        margin: EdgeInsets.all(8),
        child: Row(
          children: [
            Icon(AntDesign.search1, color: appStore.textSecondaryColor),
            10.width,
            Text('Search', style: boldTextStyle(color: appStore.textSecondaryColor)),
          ],
        ),
        padding: EdgeInsets.all(10),
      ).onTap(() {
        //DTSearchScreen().launch(context);
      });
    }

    Widget horizontalList() {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.only(right: 8, top: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: categories.map((e) {
            return Container(
              width: isMobile ? 100 : 120,
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Container(
                  //   padding: EdgeInsets.all(8),
                  //   decoration: BoxDecoration(shape: BoxShape.circle, color: appColorPrimary),
                  //   child: Image.asset(e.icon!, height: 30, width: 30, color: white),
                  // ),
                  4.height,
                  Text(e.name!, style: primaryTextStyle(size: 12), maxLines: 1, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
                ],
              ),
            ).onTap(() {
              //DTCategoryDetailScreen().launch(context);
              switch(e.id){
                case 1:
                  ReceivedSampleScreen().launch(context);
                  break;
                case 2:
                    ResultToReviewScreen().launch(context);
                  break;
                case 3:
                  break;
                case 4:
                  break;
                default:
                  break;
              }

            });
          }).toList(),
        ),
      );
    }

    Widget mobileWidget() {
      return Container(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                children: [
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      color: appColorPrimary,
                      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
                    ),
                  ).visible(false),
                  Column(
                    children: [
                      10.height,
                      searchTxt(),

                    ],
                  ),
                ],
              ),
              10.height,
              Text('Sections', style: boldTextStyle()).paddingAll(8),
              horizontalList(),
              20.height,
              Text('New Tracking Ids', style: boldTextStyle()).paddingAll(8),
              ListView.builder(
                  shrinkWrap: true,
                 controller: _scrollController,
                  itemCount: trackingIDs.length + (isLoading? 1: 0),
                  itemBuilder: (context, index){
                    if(index < trackingIDs.length){
                      final sample = trackingIDs[index];
                      return Container(
                        decoration: boxDecorationRoundedWithShadow(8, backgroundColor: appStore.appBarColor??Colors.white70,),
                        margin: EdgeInsets.all(8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                            Container(
                              height: 20,
                              width: 5,
                              child: Stack(
                                  children: [
                                    Positioned(
                                      right: 10,
                                      top: 10,
                                      child: Icon(Icons.add_circle, color: Colors.white54, size: 16) ,
                                    ),
                                  ]
                              )
                            ),
                              8.width,
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Track Id:  ${sample.trackId!}', style: primaryTextStyle(), maxLines: 1, overflow: TextOverflow.ellipsis),

                                4.height,
                                Row(
                                  children: [
                                    Text('Round ${sample.roundCode}, Scheme: ${sample.schemeName}', style: secondaryTextStyle(size: 12)),
                                    8.width,
                                  //  priceWidget(data.price, applyStrike: true),
                                  ],
                                ),
                                4.height,
                                Row(
                                  children: [

                                    Text('End Date: ${sample.endDate}, Status: ${trackingIdStatus(sample.statusId)}', style: secondaryTextStyle(size: 12)),
                                  ],
                                ),
                              ],
                            ).paddingAll(8).expand(),
                            ]
                          ).onTap(() async {
                                 int? index = await SampleReceivingScreen(trackingIDModel: sample).launch(context);
                                //if (index != null) appStore.setDrawerItemIndex(index);

                              }
                      )
                      );
                    }else{
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(child: CircularProgressIndicator(),),


                      );
                    }
                  }
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: ContainerX(
        mobile: mobileWidget(),
        web: mobileWidget(),
      ),
    );



  }
}

