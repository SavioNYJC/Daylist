import 'package:daylist/components/accepted_blend_card.dart';
import 'package:daylist/components/home_quick_action_button.dart';
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
  final Map<String, Future<Map<String, DateTime?>>> _playlistTimeRangeFutures =
      {};
  final Set<String> _pendingDeletePlaylistIds = {};
  final Set<String> _collapsingPlaylistIds = {};
  final Set<String> _removedPlaylistIds = {};

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

  Future<Map<String, DateTime?>> getPlaylistTimeRange(String playlistId) async {
    final response = await supabase.rpc(
      "get_playlist_time_range",
      params: {"p_playlist_id": playlistId},
    );

    final result = response[0];

    return {
      "earliest_start_time": result["earliest_start_time"] != null
          ? DateTime.parse(result["earliest_start_time"]).toLocal()
          : null,
      "latest_end_time": result["latest_end_time"] != null
          ? DateTime.parse(result["latest_end_time"]).toLocal()
          : null,
    };
  }

  Future<Map<String, DateTime?>> _playlistTimeRangeFuture(String playlistId) =>
      _playlistTimeRangeFutures.putIfAbsent(
        playlistId,
        () => getPlaylistTimeRange(playlistId),
      );

  void _refreshPlaylists() {
    setState(() {
      _playlistTimeRangeFutures.clear();
      _removedPlaylistIds.clear();
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
          content: Text(message),
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
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: nameFieldController,
                  decoration: InputDecoration(
                    hintText: "Name",
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
                    style: Theme.of(context).textTheme.labelMedium,
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

                    nameFieldController.text = "";
                    dateFieldController.text = "";
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

  Future<void> _deletePlaylist(String playlistId) async {
    if (!_pendingDeletePlaylistIds.add(playlistId)) return;

    try {
      await supabase.from('playlists').delete().eq('id', playlistId);
      if (!mounted) return;

      setState(() => _collapsingPlaylistIds.add(playlistId));
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;
      setState(() {
        _collapsingPlaylistIds.remove(playlistId);
        _removedPlaylistIds.add(playlistId);
      });
      _showMessage('Playlist deleted.');
    } catch (error) {
      debugPrint('Deleting playlist failed: $error');
      if (mounted) _showMessage(userFacingError(error));
    } finally {
      _pendingDeletePlaylistIds.remove(playlistId);
    }
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
                  final visiblePlaylists = playlists
                      .where(
                        (playlist) =>
                            !_removedPlaylistIds.contains(playlist["id"]),
                      )
                      .toList();
                  print(playlists);

                  if (visiblePlaylists.isEmpty) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        'No playlists yet. Use the + menu to create a playlist.',
                      ),
                    );
                  }

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: List<Widget>.generate(visiblePlaylists.length, (
                      index,
                    ) {
                      final playlistId =
                          visiblePlaylists[index]["id"] as String;
                      var playlistDate = DateTime.parse(
                        visiblePlaylists[index]["date"],
                      );

                      String formattedDate = DateFormat("d MMMM")
                          .format(playlistDate);

                      return AnimatedSize(
                        key: ValueKey(playlistId),
                        alignment: Alignment.topCenter,
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        child: _collapsingPlaylistIds.contains(playlistId)
                            ? const SizedBox.shrink()
                            : Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (index > 0)
                                    Divider(
                                      thickness: 1,
                                      color: Color(0xFF6D6D6D)
                                          .withValues(alpha: 0.7),
                                    ),
                                  FutureBuilder<Map<String, DateTime?>>(
                                    future: _playlistTimeRangeFuture(
                                      playlistId,
                                    ),
                                    builder: (context, timeRangeSnapshot) {
                                      if (timeRangeSnapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Padding(
                                          padding: EdgeInsets.all(10),
                                          child: Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        );
                                      }
                                      if (timeRangeSnapshot.hasError) {
                                        return Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Text(
                                            'Error loading playlist time: '
                                            '${timeRangeSnapshot.error}',
                                          ),
                                        );
                                      }

                                      final playlistTimeRange =
                                          timeRangeSnapshot.data!;
                                      final earliestStart =
                                          playlistTimeRange["earliest_start_time"];
                                      final latestEnd =
                                          playlistTimeRange["latest_end_time"];

                                      return Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: ListTile(
                                          trailing: SizedBox(
                                            width: 48,
                                            height: 48,
                                            child: LiquidGlassLens(
                                              style: glassButtonStyle,
                                              child: IconButton(
                                                onPressed: () =>
                                                    _deletePlaylist(playlistId),
                                                icon: Icon(
                                                  Icons.delete,
                                                  size: 30,
                                                  color: Color(0xffff3b30),
                                                ),
                                              ),
                                            ),
                                          ),
                                          onTap: () async {
                                            await Navigator.of(
                                              context,
                                            ).push<void>(
                                              CupertinoPageRoute<void>(
                                                builder: (context) => Playlist(
                                                  playlistId: playlistId,
                                                ),
                                              ),
                                            );
                                            if (mounted) _refreshPlaylists();
                                          },
                                          title: Text(
                                            formattedDate,
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
                                              Icons.calendar_month,
                                              color: Colors.black,
                                              size: 30,
                                            ),
                                          ),
                                          subtitle: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(height: 10),
                                              Text(
                                                visiblePlaylists[index]["playlist_name"],
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall,
                                                textAlign: TextAlign.left,
                                              ),
                                              SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Text(
                                                    earliestStart == null
                                                        ? "--"
                                                        : DateFormat("HHmm")
                                                              .format(
                                                                earliestStart,
                                                              ),
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
                                                    latestEnd == null
                                                        ? "--"
                                                        : DateFormat(
                                                            "HHmm",
                                                          ).format(latestEnd),
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
                                  ),
                                ],
                              ),
                      );
                    }),
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
                    QuickActionButton(
                      label: 'New playlist',
                      icon: Icons.playlist_add,
                      onTap: _openNewPlaylist,
                    ),
                    QuickActionButton(
                      label: 'Pending blends',
                      icon: Icons.notifications_none,
                      onTap: _openPendingBlends,
                    ),
                    QuickActionButton(
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
              Text(_errorMessage(snapshot.error)),
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
                child: AcceptedBlendCard(
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
