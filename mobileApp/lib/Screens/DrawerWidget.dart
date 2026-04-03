import 'package:flutter/material.dart';
import '../Services/AuthService.dart';
import '../Screens/HomeScreen.dart';
import '../Screens/SignInScreen.dart';
import 'ContactUsPage.dart';
import 'HelpSupportPage.dart';
import 'MyCoursesPage.dart';
import 'MyModulesPage.dart';
import 'MaterialsPage.dart';
import 'LiveClassPage.dart';
import 'AboutPage.dart';
import 'QuizResultPage.dart'; // ✅ NEW PAGE (list of quizzes)

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({super.key});

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  final AuthService authService = AuthService();

  String userName = "WomenBiz User";
  String userEmail = "user@email.com";
  int userId = 0; // ✅ dynamic userId

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
        userId = int.tryParse(user.id ?? '0') ?? 0; // ✅ FIXED
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          /// ================= HEADER =================
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

          /// ================= MENU =================
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                /// HOME
                drawerItem(
                  icon: Icons.home,
                  title: "Home",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => HomeScreen()),
                    );
                  },
                ),

                /// LIVE CLASS
                drawerItem(
                  icon: Icons.live_tv,
                  title: "Live Class",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => LiveClassPage()),
                    );
                  },
                ),

                /// MY COURSES
                drawerItem(
                  icon: Icons.school,
                  title: "My Courses",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => MyCoursesPage()),
                    );
                  },
                ),

                /// MY MODULES
                drawerItem(
                  icon: Icons.menu_book,
                  title: "My Modules",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => MyModulesPage()),
                    );
                  },
                ),

                /// MATERIALS
                drawerItem(
                  icon: Icons.folder,
                  title: "Materials",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => MaterialsPage()),
                    );
                  },
                ),

                /// ================= QUIZ RESULTS =================
                drawerItem(
                  icon: Icons.bar_chart,
                  title: "My Quiz Results",
                  onTap: () {
                    if (userId == 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("User not loaded yet"),
                        ),
                      );
                      return;
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => QuizResultPage(
                          userId: userId,
                        ),
                      ),
                    );
                  },
                ),

                const Divider(),

                /// ABOUT
                drawerItem(
                  icon: Icons.info_outline,
                  title: "About Us",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AboutPage()),
                    );
                  },
                ),

                /// CONTACT
                drawerItem(
                  icon: Icons.phone,
                  title: "Contact Us",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ContactUsPage()),
                    );
                  },
                ),

                /// HELP
                drawerItem(
                  icon: Icons.help_outline,
                  title: "Help & Support",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => HelpSupportPage()),
                    );
                  },
                ),

                const Divider(),

                /// LOGOUT
                drawerItem(
                  icon: Icons.logout,
                  title: "Logout",
                  onTap: () async {
                    await authService.logout();

                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => SignInScreen()),
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          ),

          /// ================= FOOTER =================
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              "WomenBiz 360 v1.0.2",
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  /// ================= DRAWER ITEM =================
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