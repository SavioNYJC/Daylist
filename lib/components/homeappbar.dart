import 'package:daylist/screens/profile_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';
import 'package:material_ui/material_ui.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  HomeAppBar({super.key, required this.title, required this.titleSize});

  final String title;
  final String titleSize;

  @override
  Size get preferredSize => const Size.fromHeight(320);

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
            right: 24,
            top: 70,
            child: LiquidGlassLens(
              child: IconButton(
                onPressed: () {
                  var navigator = Navigator.of(context);
                  navigator.push(
                    CupertinoPageRoute(
                      builder: (context) {
                        return ProfilePage();
                      },
                    ),
                  );
                },
                icon: const Icon(Icons.settings_outlined),
              ),
            ),
          ),

          Positioned(
            left: 32,
            bottom: 170,
            child: Text(
              'Your Mix',
              style: Theme.of(context).textTheme.headlineLarge!
                  .apply(color: Colors.black),
            ),
          ),

          Positioned(
            left: 24,
            bottom: 22,
            child: SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              height: 130,
              child: LiquidGlassLens(
                style: const LiquidGlassStyle(
                  shape: LiquidGlassShape.continuousRoundedRectangle(
                    cornerRadius: 28,
                  ),
                  refractionIndex: 2,
                  refractionWidth: 24,
                  blur: 3,
                  shadow: LiquidGlassShadow(
                    blur: 10,
                    opacity: 0.25,
                    inset: -10,
                    cornerRadius: 20,
                    offset: Offset(0, 5),
                  ),
                  // color: Color(0x22FFFFFF),
                ),
                child: InkWell(
                  onTap: () {},
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: ListTile(
                      trailing: LiquidGlassLens(
                        style: LiquidGlassStyle(color: Color(0xFF0088FF)),
                        child: IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                      title: Text(
                        "Currently active",
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      subtitle: Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          children: [
                            Icon(
                              Icons.directions_car,
                              color: Colors.black,
                              size: 30,
                            ),
                            Text(
                              "Travel to school",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
