import 'package:daylist/home_page.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';
import 'package:material_ui/material_ui.dart';

class WelcomePage extends StatefulWidget {
  const new({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0E162F), Color(0xFF404B6C), Color(0xFFD1DBFA)],
            stops: [0.3, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                SizedBox(height: 60),
                Text(
                  "Take control of your time.",
                  style: TextStyle(
                    fontSize: 40,
                    color: Colors.white,
                    decoration: TextDecoration.underline,
                  ),
                ),
                SizedBox(height: 40),
                Text(
                  "Organize your day into playlists, share schedules with others and live a more productive life.",
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 40),
                LiquidGlassButton(
                  label: "Register",
                  onPressed: () {
                    var navigator = Navigator.of(context);
                    navigator.push(
                      CupertinoPageRoute(
                        builder: (context) {
                          return HomePage();
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
