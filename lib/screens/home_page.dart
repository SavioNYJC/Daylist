import 'package:daylist/utils/add_content.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:daylist/components/homeappbar.dart';
import 'package:daylist/screens/blend_page.dart';
import 'package:daylist/screens/create_blend_dialog.dart';
import 'package:daylist/screens/pending_blends_page.dart';
import 'package:daylist/screens/playlist.dart';
import 'package:daylist/services/blend_service.dart';
import 'package:daylist/utils/themes.dart';
import 'package:intl/intl.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';
import 'package:material_ui/material_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:daylist/utils/user_facing_error.dart';

typedef BlendHomeLoader = Future<BlendHomeData> Function();
typedef BlendInvitationCreator = Future<void> Function(
  String username,
  List<DateTime> dates,
  String? description,
);

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.blendLoader, this.blendCreator});

  final BlendHomeLoader? blendLoader;
  final BlendInvitationCreator? blendCreator;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<BlendHomeData> _blendFuture = _loadBlends();
  bool _isActionMenuOpen = false;
  bool _isInviting = false;

  BlendService get _blendService => BlendService(Supabase.instance.client);

  final supabase = Supabase.instance.client;
  late Future _playlistsFuture;

  Future<BlendHomeData> _loadBlends() =>
      widget.blendLoader?.call() ?? _blendService.loadHomeData();

  Future _loadPlaylists() {
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw StateError('You must be signed in to load playlists');
    }

    return supabase
        .from("playlists")
        .select()
        .eq("user_id", user.id)
        .order("date", ascending: true);
  }

  void _refreshPlaylists() {
    setState(() {
      _playlistsFuture = _loadPlaylists();
    });
  }

  void _refreshBlends() {
    setState(() {
      _blendFuture = _loadBlends();
    });
  }

  String _errorMessage(Object? error) {
    if (error is BlendServiceException) return error.message;
    if (error is PostgrestException && error.code == '23505') {
      return 'There is already an invitation or blend with this person.';
    }
    return userFacingError(error);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFDDDDDD)),
          ),
          content: Text(message, style: const TextStyle(color: Colors.black)),
        ),
      );
  }

  Future<void> _inviteBlend() async {
    _closeActionMenu();
    final draft = await showModalBottomSheet<BlendInvitationDraft>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      barrierColor: Colors.black54,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      clipBehavior: Clip.antiAlias,
      builder: (_) => const CreateBlendDialog(),
    );
    if (draft == null || !mounted) return;

    setState(() => _isInviting = true);
    try {
      if (widget.blendCreator case final creator?) {
        await creator(draft.username, draft.selectedDates, draft.description);
      } else {
        await _blendService.inviteByUsername(
          draft.username,
          selectedDates: draft.selectedDates,
          description: draft.description,
        );
      }
      if (!mounted) return;
      _showMessage('Invitation sent to ${draft.username}.');
      _refreshBlends();
    } on BlendServiceException catch (error) {
      if (mounted) _showMessage(error.message);
    } on PostgrestException catch (error) {
      debugPrint('Sending blend invitation failed: $error');
      if (mounted) _showMessage(_errorMessage(error));
    } finally {
      if (mounted) setState(() => _isInviting = false);
    }
  }

  void _closeActionMenu() {
    if (_isActionMenuOpen) {
      setState(() => _isActionMenuOpen = false);
    }
  }

  void _openNewPlaylist() {
    final TextEditingController nameFieldController = TextEditingController();
    final TextEditingController dateFieldController = TextEditingController();
    DateTime? selectedEventDate;

    _closeActionMenu();

    // Show action sheet to create new playlist

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
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    "Create new playlist",
                    style: Theme.of(context).textTheme.headlineMedium!
                        .apply(color: Colors.black),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  style: TextStyle(color: Colors.black),

                  controller: nameFieldController,
                  decoration: InputDecoration(
                    hintText: "Name",
                    hintStyle: TextStyle(color: Colors.black),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: Colors.black.withAlpha(60)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: Colors.black),
                    ),
                  ),
                ),

                SizedBox(height: 10),
                TextField(
                  controller: dateFieldController,
                  style: TextStyle(color: Colors.black),
                  readOnly: true,
                  onTap: () async {
                    final localizations = MaterialLocalizations.of(context);
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: selectedEventDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );

                    if (pickedDate != null) {
                      selectedEventDate = DateTime(
                        pickedDate.year,
                        pickedDate.month,
                        pickedDate.day,
                      );
                      dateFieldController.text = localizations.formatMediumDate(
                        pickedDate,
                      );
                    }
                  },
                  decoration: InputDecoration(
                    hintText: "Date",
                    hintStyle: TextStyle(color: Colors.black),
                    suffixIcon: Icon(
                      Icons.calendar_today,
                      color: Colors.black54,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: Colors.black.withAlpha(60)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: Colors.black),
                    ),
                  ),
                ),
                SizedBox(height: 20),

                LiquidGlassButton(
                  height: 64,
                  width: MediaQuery.of(context).size.width - 40,
                  style: glassButtonStyle,
                  child: Text(
                    "Create",
                    style: Theme.of(context).textTheme.labelMedium!
                        .apply(color: Colors.black),
                  ),
                  onPressed: () async {
                    var navigator = Navigator.of(context);
                    final user = supabase.auth.currentUser;
                    final eventDate = selectedEventDate;

                    // Create event and store in database
                    if (user == null) {
                      throw StateError(
                        'You must be signed in to create a playlist',
                      );
                    }

                    if (eventDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Select a valid date.')),
                      );
                      return;
                    }
                    // Create playlist

                    await addPlaylistData(
                      playlistName: nameFieldController.text,
                      date: selectedEventDate!,
                    );

                    if (!mounted) return;
                    _refreshPlaylists();
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
  }

  void _openPendingBlends() {
    _closeActionMenu();
    Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (_) => PendingBlendsPage(blendLoader: widget.blendLoader),
      ),
    );
  }

  void _openBlendPreview() {
    final now = DateTime.now();
    final day = DateTime(now.year, now.month, now.day);
    final connection = BlendConnection(
      user1Id: 'preview-you',
      user2Id: 'preview-edward',
      otherUserId: 'preview-edward',
      otherUsername: 'Edward',
      status: 'accepted',
      isIncoming: false,
      selectedDates: [day],
      description: 'A sample blend to preview the page.',
    );
    final previewData = BlendDayData(
      day: day,
      myEvents: [
        ScheduleEvent(
          name: 'Travel to school',
          startTime: day.add(const Duration(hours: 8)),
          endTime: day.add(const Duration(hours: 9)),
        ),
        ScheduleEvent(
          name: 'Work on Daylist',
          startTime: day.add(const Duration(hours: 10)),
          endTime: day.add(const Duration(hours: 12)),
        ),
      ],
      otherEvents: [
        ScheduleEvent(
          name: 'Study physics',
          startTime: day.add(const Duration(hours: 9)),
          endTime: day.add(const Duration(hours: 10)),
        ),
      ],
    );
    Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (_) => BlendPage(
          connection: connection,
          dayLoader: (connection, selectedDay) async => previewData,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _playlistsFuture = _loadPlaylists();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const HomeAppBar(title: 'My Mix', titleSize: 'large'),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: _buildActionMenu(),
      body: SafeArea(
        child: ScrollConfiguration(
          behavior: const MaterialScrollBehavior().copyWith(overscroll: false),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 112),
            children: [
              Text(
                'Upcoming playlists',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 10),
              const Divider(),
              FutureBuilder(
                future: _playlistsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final playlists = snapshot.data ?? ["Error"];
                  print(playlists);

                  return ListView.separated(
                    shrinkWrap: true,
                    separatorBuilder: (context, index) => Divider(
                      thickness: 1,
                      color: Color(0xFF6D6D6D).withValues(alpha: 0.7),
                    ),
                    itemCount: playlists.length,
                    itemBuilder: (context, index) {
                      var playlistDate = DateTime.parse(
                        playlists[index]["date"],
                      );

                      String formattedDate = DateFormat("d MMMM")
                          .format(playlistDate);

                      return Padding(
                        padding: const EdgeInsets.all(10),
                        child: ListTile(
                          onTap: () {
                            var navigator = Navigator.of(context);
                            navigator.push(
                              CupertinoPageRoute(
                                builder: (context) => Playlist(
                                  playlist_id: playlists[index]["id"],
                                ),
                              ),
                            );
                          },
                          title: Text(
                            formattedDate,
                            style: Theme.of(context).textTheme.displayMedium!
                                .apply(color: Colors.black, fontWeightDelta: 1),
                          ),
                          leading: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
                            child: Icon(
                              Icons.calendar_month,
                              color: Colors.black,
                              size: 30,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 10),
                              Text(
                                playlists[index]["playlist_name"],
                                style: Theme.of(context).textTheme.bodySmall,
                                textAlign: TextAlign.left,
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    "0730",
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
                                    "0800",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 20),
              Text('Blends', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              _buildBlendContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionMenu() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          alignment: Alignment.bottomLeft,
          child: _isActionMenuOpen
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _QuickActionButton(
                      label: 'New playlist',
                      icon: Icons.playlist_add,
                      onTap: _openNewPlaylist,
                    ),
                    _QuickActionButton(
                      label: 'Pending blends',
                      icon: Icons.notifications_none,
                      onTap: _openPendingBlends,
                    ),
                    _QuickActionButton(
                      label: 'New blend',
                      icon: Icons.add,
                      onTap: _isInviting ? null : _inviteBlend,
                    ),
                  ],
                )
              : const SizedBox(width: 1, height: 0),
        ),
        const SizedBox(height: 10),
        FloatingActionButton(
          tooltip: _isActionMenuOpen
              ? 'Close quick actions'
              : 'Open quick actions',
          onPressed: () =>
              setState(() => _isActionMenuOpen = !_isActionMenuOpen),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 5,
          shape: const CircleBorder(
            side: BorderSide(color: Color(0xFFD6D3DB), width: 1.2),
          ),
          child: _isInviting
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : SizedBox(
                  width: 56,
                  height: 56,
                  child: AnimatedRotation(
                    turns: _isActionMenuOpen ? 0.125 : 0,
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeInOut,
                    child: const Icon(Icons.add, size: 28),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildBlendContent() {
    return FutureBuilder<BlendHomeData>(
      future: _blendFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _errorMessage(snapshot.error),
                style: const TextStyle(color: Colors.black),
              ),
              TextButton(
                onPressed: _refreshBlends,
                child: const Text('Try again'),
              ),
              if (kDebugMode) _previewButton(),
            ],
          );
        }

        final data = snapshot.data ?? const BlendHomeData();
        if (data.accepted.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'No blends yet. Use the + menu to create a blend or review invitations.',
                  style: TextStyle(color: Colors.black54),
                ),
              ),
              if (kDebugMode) _previewButton(),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final connection in data.accepted)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _AcceptedBlendCard(
                  connection: connection,
                  onTap: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute<void>(
                        builder: (_) => BlendPage(connection: connection),
                      ),
                    );
                  },
                ),
              ),
            if (kDebugMode) _previewButton(),
          ],
        );
      },
    );
  }

  Widget _previewButton() => Align(
    alignment: Alignment.centerLeft,
    child: TextButton.icon(
      onPressed: _openBlendPreview,
      icon: const Icon(Icons.visibility_outlined),
      label: const Text('Preview sample blend'),
      style: TextButton.styleFrom(foregroundColor: Colors.black),
    ),
  );
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        elevation: 5,
        shadowColor: Colors.black26,
        shape: const StadiumBorder(side: BorderSide(color: Color(0xFFE0DDE4))),
        child: InkWell(
          onTap: onTap,
          customBorder: const StadiumBorder(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 20, color: Colors.black87),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
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

class _AcceptedBlendCard extends StatelessWidget {
  const _AcceptedBlendCard({required this.connection, required this.onTap});

  final BlendConnection connection;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _BlendMemberCard(
            title: 'You',
            subtitle:
                connection.myPreviewEvent ?? _blendCardFallback(connection),
            icon: Icons.directions_car_outlined,
            onTap: onTap,
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            '–',
            style: TextStyle(color: Colors.black54, fontSize: 22),
          ),
        ),
        Expanded(
          child: _BlendMemberCard(
            title: connection.otherUsername,
            subtitle:
                connection.otherPreviewEvent ?? _blendCardFallback(connection),
            icon: Icons.bookmark_border,
            onTap: onTap,
          ),
        ),
      ],
    );
  }

  String _blendCardFallback(BlendConnection connection) {
    final dateCount = connection.selectedDates.length;
    return dateCount == 0
        ? 'Nothing scheduled'
        : '$dateCount ${dateCount == 1 ? 'date' : 'dates'} selected';
  }
}

class _BlendMemberCard extends StatelessWidget {
  const _BlendMemberCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return LiquidGlassLens(
      style: glassCardStyle,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: SizedBox(
          height: 126,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(icon, color: Colors.black, size: 22),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
