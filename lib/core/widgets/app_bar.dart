import 'package:flutter/material.dart';
class appBar extends StatelessWidget implements PreferredSizeWidget {
  const appBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFB16546),
      elevation: 0,
        title: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                backgroundImage: AssetImage('lib/assets/images/logo.png'),
                radius: 16,
                backgroundColor: Colors.white,
              ),
              const SizedBox(width: 12),
              const Text(
                'AgroConnect',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
    );
  }


        @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

