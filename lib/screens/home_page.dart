import 'package:daylist/components/homeappbar.dart';
import 'package:daylist/screens/playlist.dart';
import 'package:daylist/utils/themes.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';
import 'package:material_ui/material_ui.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: HomeAppBar(title: "My Mix", titleSize: "large"),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Upcoming playlists",
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.left,
              ),
              SizedBox(height: 10),
              Divider(),
              SizedBox(height: 10),
              // TODO: List view of playlists
              LiquidGlassButton(
                style: glassButtonStyle,
                child: Text(
                  "Test playlist page",
                  style: Theme.of(context).textTheme.bodyMedium!
                      .apply(color: Colors.black),
                ),
                onPressed: () {
                  var navigator = Navigator.of(context);
                  navigator.push(
                    CupertinoPageRoute(
                      builder: (context) {
                        return Playlist();
                      },
                    ),
                  );
                },
              ),
              SizedBox(height: 10),
              SizedBox(height: 10),
              Text(
                "Blends",
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.left,
              ),
              SizedBox(height: 10),
              Divider(),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
