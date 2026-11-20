import 'package:liquid_glass_easy/liquid_glass_easy.dart';
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
            left: 24,
            top: 70,
            child: LiquidGlassLens(
              child: IconButton(
                onPressed: () {
                  var navigator = Navigator.of(context);
                  navigator.pop();
                },
                icon: const Icon(Icons.chevron_left, size: 30),
              ),
            ),
          ),
          Positioned(
            right: 24,
            top: 70,
            child: LiquidGlassLens(
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
