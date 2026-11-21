import 'package:daylist/components/customappbar.dart';
import 'package:material_ui/material_ui.dart';

class Playlist extends StatefulWidget {
  const new({super.key});

  @override
  State<Playlist> createState() => _PlaylistState();
}

class _PlaylistState extends State<Playlist> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: "Today's playlist"),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(children: []),
            ),
          ],
        ),
      ),
    );
  }
}
