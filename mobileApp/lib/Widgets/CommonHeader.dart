import 'dart:io';
import 'package:flutter/material.dart';

class CommonHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBack;

  const CommonHeader({
    super.key,
    required this.title,
    this.showBack = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xffe91e63),
      elevation: 0,
      centerTitle: true,

      leading: showBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            )
          : IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => exit(0),
            ),

      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),

      actions: [
        Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
