import 'package:daylist/components/customappbar.dart';
import 'package:daylist/components/floating_list_item.dart';
import 'package:daylist/components/now_playing_card.dart';
import 'package:daylist/utils/add_content.dart';
import 'package:daylist/utils/icons_list.dart';
import 'package:daylist/utils/themes.dart';
import 'package:intl/intl.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';
import 'package:material_ui/material_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Playlist extends StatefulWidget {
  Playlist({super.key, required this.playlistId});

  String playlistId;

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
  DateTime? _selectedEventDate;
  TimeOfDay? _selectedStartTime;
  TimeOfDay? _selectedEndTime;

  final supabase = Supabase.instance.client;
  late Future _eventsFuture;

  Future _loadEvents() => supabase
      .from("events")
      .select(
        "id, user_id, event_name, description, location, start_time, end_time, created_at, icon_codePoint, playlist_items!inner(playlist_id, position, created_at)",
      )
      .eq("playlist_items.playlist_id", widget.playlistId)
      .order("start_time", ascending: true);

  void _refreshEvents() {
    setState(() {
      _eventsFuture = _loadEvents();
    });
  }

  DateTime _dateTimeFor(DateTime date, TimeOfDay time) {
    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    ).toUtc();
  }

  @override
  void initState() {
    super.initState();
    _eventsFuture = _loadEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: "Today's playlist"),
      backgroundColor: Colors.white,
      body: FutureBuilder(
        future: _eventsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final events = snapshot.data ?? ["Error"];
          print(events);

          return Stack(
            children: [
              SafeArea(
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    Expanded(
                      child: ListView.separated(
                        itemBuilder: (context, index) {
                          var startTime = DateTime.parse(
                            events[index]["start_time"],
                          );
                          var formattedStartTime = DateFormat("HHmm")
                              .format(startTime);

                          var endTime = DateTime.parse(
                            events[index]["end_time"],
                          );
                          var formattedEndTime = DateFormat("HHmm")
                              .format(endTime);

                          return FloatingListItem(
                            floatingChild: LiquidGlassLens(
                              style: opaqueCardStyle,
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: ListTile(
                                  title: Text(
                                    events[index]["event_name"],
                                    style: Theme.of(context)
                                        .textTheme
                                        .displayMedium!
                                        .apply(fontWeightDelta: 1),
                                  ),
                                  leading: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      0,
                                      8,
                                      8,
                                      8,
                                    ),
                                    child: Icon(
                                      Icons.build,
                                      color: Colors.black,
                                      size: 30,
                                    ),
                                  ),
                                  subtitle: Row(
                                    children: [
                                      Text(
                                        formattedStartTime,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
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
                                        formattedEndTime,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: ListTile(
                                title: Text(
                                  events[index]["event_name"],
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayMedium!
                                      .apply(fontWeightDelta: 1),
                                ),
                                leading: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    0,
                                    8,
                                    8,
                                    8,
                                  ),
                                  child: Icon(
                                    Icons.build,
                                    color: Colors.black,
                                    size: 30,
                                  ),
                                ),
                                subtitle: Row(
                                  children: [
                                    Text(
                                      formattedStartTime,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall,
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
                                      formattedEndTime,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        itemCount: events.length,
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
                                style: Theme.of(context)
                                    .textTheme
                                    .displayMedium,
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
                              var selectedEventIcon = Icons.build;

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
                                        padding: const EdgeInsets.all(16),
                                        child: Text(
                                          "Create new event",
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineMedium,
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Row(
                                        children: [
                                          StatefulBuilder(
                                            builder: (context, setModalState) {
                                              return SizedBox(
                                                width: 56,
                                                height: 56,
                                                child: IconButton(
                                                  tooltip: "Choose event icon",
                                                  style: IconButton.styleFrom(
                                                    foregroundColor:
                                                        Colors.black,
                                                    side: BorderSide(
                                                      color: Colors.black
                                                          .withAlpha(100),
                                                    ),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            20,
                                                          ),
                                                    ),
                                                  ),
                                                  onPressed: () async {
                                                    final icon = await showModalBottomSheet<IconData>(
                                                      context: context,
                                                      backgroundColor:
                                                          Colors.white,
                                                      isScrollControlled: true,
                                                      builder: (pickerContext) {
                                                        return SafeArea(
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets.all(
                                                                  16,
                                                                ),
                                                            child: GridView.count(
                                                              crossAxisCount: 5,
                                                              shrinkWrap: true,
                                                              mainAxisSpacing:
                                                                  8,
                                                              crossAxisSpacing:
                                                                  8,
                                                              children: availableEventIcons.map((
                                                                icon,
                                                              ) {
                                                                return IconButton(
                                                                  tooltip: "Select icon",
                                                                  style: IconButton.styleFrom(
                                                                    foregroundColor:
                                                                        Colors
                                                                            .black,
                                                                    side: BorderSide(
                                                                      color: Colors
                                                                          .black
                                                                          .withAlpha(
                                                                            60,
                                                                          ),
                                                                    ),
                                                                    shape: RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                            16,
                                                                          ),
                                                                    ),
                                                                  ),
                                                                  onPressed: () =>
                                                                      Navigator.of(
                                                                        pickerContext,
                                                                      ).pop(
                                                                        icon,
                                                                      ),
                                                                  icon: Icon(
                                                                    icon,
                                                                  ),
                                                                );
                                                              }).toList(),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    );

                                                    if (icon != null) {
                                                      setModalState(() {
                                                        selectedEventIcon =
                                                            icon;
                                                      });
                                                    }
                                                  },
                                                  icon: Icon(selectedEventIcon),
                                                ),
                                              );
                                            },
                                          ),
                                          SizedBox(width: 10),
                                          Expanded(
                                            child: TextField(
                                              controller: nameFieldController,
                                              decoration: InputDecoration(
                                                hintText: "Name",
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  borderSide: BorderSide(
                                                    color: Colors.black
                                                        .withAlpha(60),
                                                  ),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            20,
                                                          ),
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
                                        controller: dateFieldController,
                                        readOnly: true,
                                        onTap: () async {
                                          final localizations =
                                              MaterialLocalizations.of(context);
                                          final pickedDate =
                                              await showDatePicker(
                                                context: context,
                                                initialDate:
                                                    _selectedEventDate ??
                                                    DateTime.now(),
                                                firstDate: DateTime(2000),
                                                lastDate: DateTime(2100),
                                              );

                                          if (pickedDate != null) {
                                            _selectedEventDate = DateTime(
                                              pickedDate.year,
                                              pickedDate.month,
                                              pickedDate.day,
                                            );
                                            dateFieldController.text =
                                                localizations.formatMediumDate(
                                                  pickedDate,
                                                );
                                          }
                                        },
                                        decoration: InputDecoration(
                                          hintText: "Date",
                                          suffixIcon: Icon(
                                            Icons.calendar_today,
                                            color: Colors.black54,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            borderSide: BorderSide(
                                              color: Colors.black.withAlpha(60),
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
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
                                                MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    2 -
                                                20,
                                            child: TextField(
                                              controller: startTimeController,
                                              readOnly: true,
                                              onTap: () async {
                                                final localizations =
                                                    MaterialLocalizations.of(
                                                      context,
                                                    );
                                                final pickedTime =
                                                    await showTimePicker(
                                                      context: context,
                                                      initialTime:
                                                          _selectedStartTime ??
                                                          TimeOfDay.now(),
                                                    );

                                                if (pickedTime != null) {
                                                  _selectedStartTime =
                                                      pickedTime;
                                                  startTimeController.text =
                                                      localizations
                                                          .formatTimeOfDay(
                                                            pickedTime,
                                                          );
                                                }
                                              },
                                              decoration: InputDecoration(
                                                hintText: "Start Time",
                                                suffixIcon: Icon(
                                                  Icons.access_time,
                                                  color: Colors.black54,
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  borderSide: BorderSide(
                                                    color: Colors.black
                                                        .withAlpha(60),
                                                  ),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            20,
                                                          ),
                                                      borderSide: BorderSide(
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                              ),
                                            ),
                                          ),
                                          Spacer(),
                                          SizedBox(
                                            width:
                                                MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    2 -
                                                20,
                                            child: TextField(
                                              controller: endTimeController,
                                              readOnly: true,
                                              onTap: () async {
                                                final localizations =
                                                    MaterialLocalizations.of(
                                                      context,
                                                    );
                                                final pickedTime =
                                                    await showTimePicker(
                                                      context: context,
                                                      initialTime:
                                                          _selectedEndTime ??
                                                          TimeOfDay.now(),
                                                    );

                                                if (pickedTime != null) {
                                                  _selectedEndTime = pickedTime;
                                                  endTimeController.text =
                                                      localizations
                                                          .formatTimeOfDay(
                                                            pickedTime,
                                                          );
                                                }
                                              },
                                              decoration: InputDecoration(
                                                hintText: "End Time",
                                                suffixIcon: Icon(
                                                  Icons.access_time,
                                                  color: Colors.black54,
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  borderSide: BorderSide(
                                                    color: Colors.black
                                                        .withAlpha(60),
                                                  ),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            20,
                                                          ),
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
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            borderSide: BorderSide(
                                              color: Colors.black.withAlpha(60),
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
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
                                            MediaQuery.of(context).size.width -
                                            40,
                                        style: glassButtonStyle,
                                        child: Text(
                                          "Create",
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelMedium,
                                        ),
                                        onPressed: () async {
                                          var navigator = Navigator.of(context);
                                          final user =
                                              supabase.auth.currentUser;
                                          final eventDate = _selectedEventDate;
                                          final startTime = _selectedStartTime;
                                          final endTime = _selectedEndTime;
                                          final missingFields = <String>[
                                            if (nameFieldController.text
                                                .trim()
                                                .isEmpty)
                                              'Name',
                                            if (eventDate == null ||
                                                dateFieldController.text
                                                    .trim()
                                                    .isEmpty)
                                              'Date',
                                            if (startTime == null ||
                                                startTimeController.text
                                                    .trim()
                                                    .isEmpty)
                                              'Start Time',
                                            if (endTime == null ||
                                                endTimeController.text
                                                    .trim()
                                                    .isEmpty)
                                              'End Time',
                                            if (notesTextController.text
                                                .trim()
                                                .isEmpty)
                                              'Notes',
                                          ];

                                          // Create event and store in database
                                          if (missingFields.isNotEmpty) {
                                            await showDialog<void>(
                                              context: context,
                                              builder: (dialogContext) =>
                                                  AlertDialog(
                                                    title: const Text(
                                                      'Missing required fields',
                                                    ),
                                                    content: Text(
                                                      'Please complete: ${missingFields.join(', ')}.',
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.of(
                                                              dialogContext,
                                                            ).pop(),
                                                        child: const Text('OK'),
                                                      ),
                                                    ],
                                                  ),
                                            );
                                            return;
                                          }

                                          if (user == null) {
                                            throw StateError(
                                              'You must be signed in to create an event',
                                            );
                                          }

                                          await addEventData(
                                            eventName: nameFieldController.text,
                                            description:
                                                notesTextController.text,
                                            startTime: _dateTimeFor(
                                              eventDate!,
                                              startTime!,
                                            ),
                                            endTime: _dateTimeFor(
                                              eventDate,
                                              endTime!,
                                            ),
                                            iconCodepoint:
                                                selectedEventIcon.codePoint,
                                            playlistId: widget.playlistId,
                                          );

                                          if (!mounted) return;
                                          _refreshEvents();
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
          );
        },
      ),
    );
  }
}
