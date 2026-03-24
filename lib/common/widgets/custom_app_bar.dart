import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onMenuPressed;

  const CustomAppBar({
    super.key,
    required this.title,
    required this.onMenuPressed,
  });

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();

    return AppBar(
      backgroundColor: Colors.amber,
      elevation: 0,
      centerTitle: true,

      leadingWidth: 90, // 🔥 AUGMENTE L’ESPACE

      leading: canPop
          ? IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      )
          : Center(
        child: Image.asset(
          "assets/images/logo1.png",
          height: 60, // taille contrôlée
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),

      actions: [
        IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: onMenuPressed,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}