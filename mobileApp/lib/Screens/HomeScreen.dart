import 'package:flutter/material.dart';
import 'DrawerWidget.dart';
import 'dart:io'; // for exit()

class HomeScreen extends StatefulWidget {
  static String tag = "HomeScreen";

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        /// Drawer menu
        drawer: DrawerWidget(),

        /// TOP HEADER
        appBar: AppBar(
          backgroundColor: Color(0xffe91e63),
          elevation: 0,
          centerTitle: true,

          /// LEFT BACK ARROW
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              exit(0); // exits the app
            },
          ),

          /// TITLE
          title: Text(
            "WomenBiz 360",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          /// RIGHT MENU
          actions: [
            Builder(
              builder: (context) => IconButton(
                icon: Icon(Icons.menu, color: Colors.white),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
            ),
          ],
        ),

        /// MAIN BODY
        body: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // TOP BANNER
                Container(
                  height: 150, // fixed height
                  width: double.infinity, // full width
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: AssetImage("images/banner.png"),
                      fit: BoxFit.cover, // fills the width and crops height if necessary
                    ),
                  ),
                ),

                SizedBox(height: 25),

                /// SECTION TITLE
                Text(
                  "Explore Our Course",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 10),

                Text(
                  "Gain essential business, finance, and digital market skills through our expert courses tailored for women entrepreneur",
                  style: TextStyle(
                    color: Colors.grey[700],
                  ),
                ),

                SizedBox(height: 20),

                /// COURSE CARDS
                Row(
                  children: [

                    /// CARD 1
                    Expanded(
                      child: courseCard(
                        icon: Icons.business_center,
                        title: "Business, Finance & Digital Training",
                        description:
                        "3 Modules learn to run & manage your business",
                        button: "Join Now",
                      ),
                    ),

                    SizedBox(width: 12),

                    /// CARD 2
                    Expanded(
                      child: courseCard(
                        icon: Icons.public,
                        title: "Export & Import Readiness",
                        description:
                        "Learn how to prepare your business for international trade",
                        button: "Enroll",
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// COURSE CARD WIDGET
  Widget courseCard({
    required IconData icon,
    required String title,
    required String description,
    required String button,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xfff3dede),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [

          Icon(icon, size: 40, color: Colors.blue),

          SizedBox(height: 10),

          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 10),

          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12),
          ),

          SizedBox(height: 12),

          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(button),
          )
        ],
      ),
    );
  }
}