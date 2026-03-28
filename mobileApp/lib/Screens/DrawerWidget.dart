import 'package:esrs_eqa_app/Screens/HomeScreen.dart';
import 'package:flutter/material.dart';
import '../Services/AuthService.dart';
import '../Screens/SignInScreen.dart';
import 'ContactUsPage.dart';
import 'HelpSupportPage.dart';
import 'MyCoursesPage.dart';
import 'MyModulesPage.dart';
import 'MaterialsPage.dart';
import 'LiveClassPage.dart';
import 'AboutPage.dart';
import 'QuizResultPage.dart'; // make sure the path is correct

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({super.key});

  @override
  _DrawerWidgetState createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  final AuthService authService = AuthService();
  String userName = "WomenBiz User";
  String userEmail = "user@email.com";

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await authService.getUserAccessDetails();
    if (user != null) {
      setState(() {
        userName = user.name ?? "WomenBiz User";
        userEmail = user.email ?? "user@email.com";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          /// HEADER
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xffe91e63),
            ),
            accountName: Text(
              userName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(userEmail),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                Icons.person,
                size: 35,
                color: Color(0xffe91e63),
              ),
            ),
          ),

          /// MENU ITEMS
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                drawerItem(
                  icon: Icons.home,
                  title: "Home",
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => HomeScreen()),
                  ),
                ),

                drawerItem(
                  icon: Icons.live_tv,
                  title: "Live Class",
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => LiveClassPage()),
                  ),
                ),

                drawerItem(
                  icon: Icons.school,
                  title: "My Courses",
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => MyCoursesPage()),
                  ),
                ),

                drawerItem(
                  icon: Icons.menu_book,
                  title: "My Modules",
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => MyModulesPage()),
                  ),
                ),

                drawerItem(
                  icon: Icons.folder,
                  title: "Materials",
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => MaterialsPage()),
                  ),
                ),

                drawerItem(
                icon: Icons.bar_chart,
                title: "My Quiz Results",
                onTap: () {
                // Example: navigate to a page showing quiz results
                // You can pass userId here or fetch it inside QuizResultPage
                Navigator.push(
                context,
                MaterialPageRoute(
                builder: (_) => QuizResultPage(
                userId: 20,      // replace with dynamic userId from authService
                moduleId: 4,     // optional: you can allow the user to select module
                quizId: 1,       // optional: you can allow user to select quiz
                ),
                ),
                );
                },
                ),

                const Divider(),

                drawerItem(
                  icon: Icons.info_outline,
                  title: "About Us",
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AboutPage()),
                  ),
                ),

                drawerItem(
                  icon: Icons.phone,
                  title: "Contact Us",
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ContactUsPage()),
                  ),
                ),

                drawerItem(
                  icon: Icons.help_outline,
                  title: "Help & Support",
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => HelpSupportPage()),
                  ),
                ),

                const Divider(),

                /// LOGOUT
              drawerItem(
              icon: Icons.logout,
              title: "Logout",
              onTap: () async {
              await authService.logout(); // clear session
              Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => SignInScreen()), // remove const here
              (route) => false,
              );
              },
              ),
              ],
            ),
          ),

          /// FOOTER
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              "WomenBiz 360 v1.0",
              style: TextStyle(color: Colors.grey),
            ),
          )
        ],
      ),
    );
  }

  /// Drawer Item Widget
  Widget drawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xffe91e63)),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16),
      ),
      onTap: onTap,
    );
  }
}