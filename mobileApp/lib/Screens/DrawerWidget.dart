import 'package:flutter/material.dart';

class DrawerWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [

          /// HEADER
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: Color(0xffe91e63),
            ),
            accountName: Text(
              "WomenBiz User",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: Text("user@email.com"),
            currentAccountPicture: CircleAvatar(
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
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),

                drawerItem(
                  icon: Icons.info,
                  title: "About us",
                  onTap: () {},
                ),

                drawerItem(
                  icon: Icons.phone,
                  title: "Contact use",
                  onTap: () {},
                ),

                drawerItem(
                  icon: Icons.settings,
                  title: "Settings",
                  onTap: () {},
                ),

                drawerItem(
                  icon: Icons.help_outline,
                  title: "Help & Support",
                  onTap: () {},
                ),

                // Divider(),

                // drawerItem(
                //   icon: Icons.logout,
                //   title: "Logout",
                //   onTap: () {},
                // ),
              ],
            ),
          ),

          /// FOOTER
          Padding(
            padding: const EdgeInsets.all(12),
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
      leading: Icon(icon, color: Color(0xffe91e63)),
      title: Text(
        title,
        style: TextStyle(fontSize: 16),
      ),
      onTap: onTap,
    );
  }
}