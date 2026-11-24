import 'package:liquid_glass_easy/liquid_glass_easy.dart';
import 'package:material_ui/material_ui.dart';

class CustomAppbar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppbar({
    super.key,
    required this.title,
    this.useLiquidGlassBackButton = true,
  });

  final String title;
  final bool useLiquidGlassBackButton;

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
            child: useLiquidGlassBackButton
                ? LiquidGlassLens(child: _buildBackButton(context))
                : _buildBackButton(context),
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

  Widget _buildBackButton(BuildContext context) {
    return IconButton(
      onPressed: () => Navigator.of(context).pop(),
      icon: const Icon(Icons.chevron_left, color: Colors.black, size: 30),
    );
  }
}
