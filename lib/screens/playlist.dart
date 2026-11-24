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

  final TextEditingController nameFieldController = TextEditingController();
  final TextEditingController dateFieldController = TextEditingController();
  final TextEditingController startTimeController = TextEditingController();
  final TextEditingController endTimeController = TextEditingController();
  final TextEditingController notesTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: "Today's playlist"),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                SizedBox(height: 10),
                Expanded(
                  child: ListView.separated(
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(10),
                        child: ListTile(
                          title: Text(
                            testingEventsList[index],
                            style: Theme.of(context).textTheme.displayMedium!
                                .apply(color: Colors.black, fontWeightDelta: 1),
                          ),
                          leading: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
                            child: Icon(
                              Icons.build,
                              color: Colors.black,
                              size: 30,
                            ),
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
                                child: Divider(
                                  color: Colors.black,
                                  thickness: 1,
                                ),
                              ),
                              SizedBox(width: 6),
                              Text(
                                "0800",
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    itemCount: testingEventsList.length,
                    separatorBuilder: (context, index) {
                      return Divider(
                        thickness: 1,
                        color: Color(0xFF6D6D6D).withValues(alpha: 0.7),
                      );
                    },
                  ),
                ),
              ],
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
                        backgroundColor: Colors.white,
                        context: context,
                        isScrollControlled: true,
                        builder: (context) {
                          return AnimatedPadding(
                            duration: const Duration(milliseconds: 200),
                            padding: EdgeInsets.fromLTRB(
                              10,
                              10,
                              10,
                              MediaQuery.viewInsetsOf(context).bottom,
                            ),
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Text(
                                      "Create new event",
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium!
                                          .apply(color: Colors.black),
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  TextField(
                                    controller: nameFieldController,
                                    decoration: InputDecoration(
                                      hintText: "Name",
                                      hintStyle: TextStyle(color: Colors.black),

                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        borderSide: BorderSide(
                                          color: Colors.black.withAlpha(60),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        borderSide: BorderSide(
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  TextField(
                                    controller: dateFieldController,
                                    decoration: InputDecoration(
                                      hintText: "Date",
                                      hintStyle: TextStyle(color: Colors.black),

                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        borderSide: BorderSide(
                                          color: Colors.black.withAlpha(60),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        borderSide: BorderSide(
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    children: [
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                2 -
                                            50,
                                        child: TextField(
                                          controller: startTimeController,
                                          decoration: InputDecoration(
                                            hintText: "Start Time",
                                            hintStyle: TextStyle(
                                              color: Colors.black,
                                            ),

                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              borderSide: BorderSide(
                                                color: Colors.black.withAlpha(
                                                  60,
                                                ),
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              borderSide: BorderSide(
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 20),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                2 -
                                            50,
                                        child: TextField(
                                          controller: endTimeController,
                                          decoration: InputDecoration(
                                            hintText: "End Time",
                                            hintStyle: TextStyle(
                                              color: Colors.black,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              borderSide: BorderSide(
                                                color: Colors.black.withAlpha(
                                                  60,
                                                ),
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              borderSide: BorderSide(
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  TextField(
                                    controller: notesTextController,
                                    maxLines: 6,
                                    minLines: 3,
                                    decoration: InputDecoration(
                                      hintText: "Add notes...",
                                      hintStyle: TextStyle(color: Colors.black),

                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        borderSide: BorderSide(
                                          color: Colors.black.withAlpha(60),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        borderSide: BorderSide(
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  LiquidGlassButton(
                                    height: 64,
                                    width:
                                        MediaQuery.of(context).size.width - 40,
                                    style: glassButtonStyle,
                                    child: Text(
                                      "Register",
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium!
                                          .apply(color: Colors.black),
                                    ),
                                    onPressed: () {
                                      var navigator = Navigator.of(context);

                                      // Create event and store in database

                                      navigator.pop();
                                    },
                                  ),
                                  SizedBox(height: 60),
                                ],
                              ),
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
