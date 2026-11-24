import 'package:daylist/components/customappbar.dart';
import 'package:daylist/components/now_playing_card.dart';
import 'package:daylist/utils/themes.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';
import 'package:material_ui/material_ui.dart';

class Playlist extends StatefulWidget {
  const new({super.key});

  @override
  State<Playlist> createState() => _PlaylistState();
}

class _PlaylistState extends State<Playlist> {
  List testingEventsList = [
    "Rise and shine",
    "Eat breakfast",
    "Travel to school",
    "School",
    "Eat lunch",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: "Today's playlist"),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: ListView.separated(
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      testingEventsList[index],
                      style: Theme.of(context).textTheme.displayMedium!
                          .apply(color: Colors.black, fontWeightDelta: 1),
                    ),
                    leading: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
                      child: Icon(Icons.build, color: Colors.black, size: 30),
                    ),
                    subtitle: Row(
                      children: [
                        Text(
                          "0730",
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        SizedBox(width: 6),
                        SizedBox(
                          width: 10,
                          child: Divider(color: Colors.black, thickness: 1),
                        ),
                        SizedBox(width: 6),
                        Text(
                          "0800",
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  );
                },
                itemCount: testingEventsList.length,
                separatorBuilder: (context, index) {
                  return Divider(thickness: 1, color: Color(0xFF6D6D6D));
                },
              ),
            ),
          ),
          Column(
            children: [
              Spacer(),
              Row(
                children: [
                  Spacer(),
                  LiquidGlassButton(
                    height: 72,
                    style: glassButtonStyle,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 20,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add,
                            color: const Color.fromARGB(255, 98, 96, 96),
                            size: 30,
                          ),
                          SizedBox(width: 10),
                          Text(
                            "New",
                            style: Theme.of(context).textTheme.displayMedium!
                                .apply(color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return Padding(
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                Text(
                                  "Add new event",
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium!
                                      .apply(color: Colors.black),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                  SizedBox(width: 20),
                ],
              ),
              SizedBox(height: 10),
              NowPlayingCard(eventName: "Travel to school"),
            ],
          ),
        ],
      ),
    );
  }
}
