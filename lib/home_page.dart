import 'package:daylist/components/homeappbar.dart';
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
