import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';
import 'package:material_ui/material_ui.dart';

class CustomAppbar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppbar({super.key, required this.title});

  final String title;

  @override
  Size get preferredSize => const Size.fromHeight(180);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF38415C), Color(0xFFD1DBFA)],
          stops: [0, 0.5],
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
                icon: const Icon(
                  Icons.chevron_left,
                  color: Colors.black,
                  size: 30,
                ),
              ),
            ),
          ),

          Positioned(
            right: 24,
            top: 70,
            child: LiquidGlassLens(
              child: IconButton(
                onPressed: () {
                  var navigator = Navigator.of(context);
                  navigator.push(
                    CupertinoPageRoute(
                      builder: (context) {
                        return Placeholder();
                      },
                    ),
                  );
                },
                icon: const Icon(Icons.edit, color: Colors.black, size: 24),
              ),
            ),
          ),

          Positioned(
            left: 32,
            bottom: 22,
            child: Text(
              title,
              style: Theme.of(context).textTheme.headlineLarge!
                  .apply(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
