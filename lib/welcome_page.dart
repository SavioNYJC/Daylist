import 'package:flutter/widgets.dart';
import 'package:flutter_liquid_glass_plus/flutter_liquid_glass.dart';
import 'package:material_ui/material_ui.dart';

class WelcomePage extends StatefulWidget {
  const new({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    return LiquidGlassLayer(
      settings: LiquidGlassSettings(thickness: 30, blur: 30),
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                SizedBox(height: 40),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "Take control of your time.",
                    style: TextStyle(
                      fontSize: 40,
                      color: Colors.white,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
