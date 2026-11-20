import 'package:flutter/widgets.dart';
import 'package:flutter_liquid_glass_plus/flutter_liquid_glass.dart';
import 'package:material_ui/material_ui.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  CustomAppBar({super.key, required this.title, required this.titleSize});

  final String title;
  final String titleSize;

  @override
  Size get preferredSize => const Size.fromHeight(210);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF38415C), Color(0xFFD1DBFA)],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 24,
            top: 24,
            child: LGCard(
              shape: LiquidRoundedRectangle(borderRadius: 28),
              padding: EdgeInsets.zero,
              child: IconButton(
                onPressed: () {
                  // Open settings
                },
                icon: const Icon(Icons.settings_outlined),
              ),
            ),
          ),

          const Positioned(
            left: 32,
            bottom: 22,
            child: Text(
              'Your Mix',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
