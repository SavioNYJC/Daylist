import 'package:supabase_flutter/supabase_flutter.dart';

class BlendConnection {
  const BlendConnection({
    required this.user1Id,
    required this.user2Id,
    required this.otherUserId,
    required this.otherUsername,
    required this.status,
    required this.isIncoming,
    this.selectedDates = const [],
    this.description,
    this.myPreviewEvent,
    this.otherPreviewEvent,
  });

  final String user1Id;
  final String user2Id;
  final String otherUserId;
  final String otherUsername;
  final String status;
  final bool isIncoming;
  final List<DateTime> selectedDates;
  final String? description;
  final String? myPreviewEvent;
  final String? otherPreviewEvent;
}

class BlendHomeData {
  const BlendHomeData({
    this.accepted = const [],
    this.incoming = const [],
    this.outgoing = const [],
  });

  final List<BlendConnection> accepted;
  final List<BlendConnection> incoming;
  final List<BlendConnection> outgoing;
}

class ScheduleEvent {
  const ScheduleEvent({
    required this.name,
    required this.startTime,
    required this.endTime,
  });

  final String name;
  final DateTime startTime;
  final DateTime endTime;

  factory ScheduleEvent.fromMap(Map<String, dynamic> row) {
    return ScheduleEvent(
      name: row['event_name'] as String,
      startTime: DateTime.parse(row['start_time'] as String).toLocal(),
      endTime: DateTime.parse(row['end_time'] as String).toLocal(),
    );
  }
}

class BlendDayData {
  const BlendDayData({
    required this.day,
    required this.myEvents,
    required this.otherEvents,
  });

  final DateTime day;
  final List<ScheduleEvent> myEvents;
  final List<ScheduleEvent> otherEvents;
}

class BlendServiceException implements Exception {
  const BlendServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}

class BlendService {
  const BlendService(this._client);

  final SupabaseClient _client;

  String get _currentUserId {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw const BlendServiceException('Please log in to use blends.');
    }
    return userId;
  }

  Future<BlendHomeData> loadHomeData() async {
    final currentUserId = _currentUserId;
    final rows = await _client
        .from('blends')
        .select('user1_id, user2_id, status, selected_dates, description')
        .or('user1_id.eq.$currentUserId,user2_id.eq.$currentUserId');

    final records = rows.map((row) {
      final user1Id = row['user1_id'] as String;
      final user2Id = row['user2_id'] as String;
      final otherUserId = user1Id == currentUserId ? user2Id : user1Id;
      final rawDates = row['selected_dates'];
      return (
        user1Id: user1Id,
        user2Id: user2Id,
        otherUserId: otherUserId,
        status: row['status'] as String,
        isIncoming: user2Id == currentUserId,
        selectedDates: rawDates is List
            ? rawDates.map((date) => DateTime.parse(date as String)).toList()
            : const <DateTime>[],
        description: row['description'] as String?,
      );
    }).toList();

    if (records.isEmpty) return const BlendHomeData();

    final profileRows = await _client
        .from('profiles')
        .select('user_id, username')
        .inFilter(
          'user_id',
          records.map((record) => record.otherUserId).toSet().toList(),
        );
    final usernames = {
      for (final profile in profileRows)
        profile['user_id'] as String:
            (profile['username'] as String?) ?? 'User',
    };

    final acceptedRecords = records
        .where((record) => record.status == 'accepted')
        .toList();
    final previews = acceptedRecords.isEmpty
        ? const <String, String>{}
        : await _loadEventPreviews(
            currentUserId,
            acceptedRecords.map((record) => record.otherUserId).toSet(),
          );

    final accepted = <BlendConnection>[];
    final incoming = <BlendConnection>[];
    final outgoing = <BlendConnection>[];
    for (final record in records) {
      final connection = BlendConnection(
        user1Id: record.user1Id,
        user2Id: record.user2Id,
        otherUserId: record.otherUserId,
        otherUsername: usernames[record.otherUserId] ?? 'User',
        status: record.status,
        isIncoming: record.isIncoming,
        selectedDates: record.selectedDates,
        description: record.description,
        myPreviewEvent: previews[currentUserId],
        otherPreviewEvent: previews[record.otherUserId],
      );

      switch (record.status) {
        case 'accepted':
          accepted.add(connection);
        case 'pending':
          (record.isIncoming ? incoming : outgoing).add(connection);
      }
    }

    accepted.sort(
      (a, b) => a.otherUsername.toLowerCase().compareTo(
        b.otherUsername.toLowerCase(),
      ),
    );
    return BlendHomeData(
      accepted: accepted,
      incoming: incoming,
      outgoing: outgoing,
    );
  }

  Future<void> inviteByUsername(
    String rawUsername, {
    required List<DateTime> selectedDates,
    String? description,
  }) async {
    final currentUserId = _currentUserId;
    final username = rawUsername.trim();
    if (username.isEmpty) {
      throw const BlendServiceException('Enter a username.');
    }
    if (selectedDates.isEmpty) {
      throw const BlendServiceException('Select at least one date.');
    }

    final target = await _client
        .from('profiles')
        .select('user_id, username')
        .ilike('username', _escapeLike(username))
        .maybeSingle();
    if (target == null) {
      throw const BlendServiceException('No account matches that username.');
    }

    final targetUserId = target['user_id'] as String;
    if (targetUserId == currentUserId) {
      throw const BlendServiceException('You cannot invite yourself.');
    }

    final existingDirect = await _client
        .from('blends')
        .select('user1_id, user2_id, status')
        .eq('user1_id', currentUserId)
        .eq('user2_id', targetUserId)
        .maybeSingle();
    final existingReverse = existingDirect == null
        ? await _client
              .from('blends')
              .select('user1_id, user2_id, status')
              .eq('user1_id', targetUserId)
              .eq('user2_id', currentUserId)
              .maybeSingle()
        : null;
    final existing = existingDirect ?? existingReverse;

    if (existing != null) {
      final status = existing['status'] as String;
      if (status == 'accepted') {
        throw const BlendServiceException('You are already blended.');
      }
      if (status == 'pending') {
        throw const BlendServiceException(
          'There is already a pending invitation for this person.',
        );
      }

      await _client
          .from('blends')
          .delete()
          .eq('user1_id', existing['user1_id'] as String)
          .eq('user2_id', existing['user2_id'] as String)
          .eq('status', status);
    }

    await _client.from('blends').insert({
      'user1_id': currentUserId,
      'user2_id': targetUserId,
      'status': 'pending',
      'selected_dates': selectedDates.map((date) => _dateKey(date)).toList(),
      'description': description?.trim().isEmpty == true
          ? null
          : description?.trim(),
    });
  }

  Future<void> respondToInvitation(
    BlendConnection invitation, {
    required bool accept,
  }) async {
    final currentUserId = _currentUserId;
    if (!invitation.isIncoming || invitation.user2Id != currentUserId) {
      throw const BlendServiceException('This invitation cannot be changed.');
    }

    final updatedRows = await _client
        .from('blends')
        .update({'status': accept ? 'accepted' : 'rejected'})
        .eq('user1_id', invitation.user1Id)
        .eq('user2_id', invitation.user2Id)
        .eq('status', 'pending')
        .select('status');
    if (updatedRows.isEmpty) {
      throw const BlendServiceException(
        'This invitation is no longer available. Refresh and try again.',
      );
    }
  }

  Future<BlendDayData> loadDay(
    BlendConnection connection,
    DateTime selectedDay,
  ) async {
    if (connection.status != 'accepted') {
      throw const BlendServiceException(
        'Accept the blend invitation before viewing schedules.',
      );
    }
    if (connection.selectedDates.isNotEmpty &&
        !connection.selectedDates.any(
          (date) =>
              date.year == selectedDay.year &&
              date.month == selectedDay.month &&
              date.day == selectedDay.day,
        )) {
      throw const BlendServiceException(
        'This date was not selected for the blend.',
      );
    }

    final currentUserId = _currentUserId;
    final startOfDay = DateTime(
      selectedDay.year,
      selectedDay.month,
      selectedDay.day,
    );
    final startUtc = startOfDay.toUtc().toIso8601String();
    final endUtc = startOfDay
        .add(const Duration(days: 1))
        .toUtc()
        .toIso8601String();

    final results = await Future.wait([
      _loadEvents(currentUserId, startUtc, endUtc),
      _loadEvents(connection.otherUserId, startUtc, endUtc),
    ]);

    return BlendDayData(
      day: startOfDay,
      myEvents: results[0],
      otherEvents: results[1],
    );
  }

  Future<Map<String, String>> _loadEventPreviews(
    String currentUserId,
    Set<String> otherUserIds,
  ) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final rows = await _client
        .from('events')
        .select('user_id, event_name')
        .inFilter('user_id', {currentUserId, ...otherUserIds}.toList())
        .gte('end_time', now.toUtc().toIso8601String())
        .lt(
          'start_time',
          startOfDay.add(const Duration(days: 1)).toUtc().toIso8601String(),
        )
        .order('start_time');

    final previews = <String, String>{};
    for (final row in rows) {
      previews.putIfAbsent(
        row['user_id'] as String,
        () => row['event_name'] as String,
      );
    }
    return previews;
  }

  Future<List<ScheduleEvent>> _loadEvents(
    String userId,
    String startUtc,
    String endUtc,
  ) async {
    final rows = await _client
        .from('events')
        .select('event_name, start_time, end_time')
        .eq('user_id', userId)
        .gt('end_time', startUtc)
        .lt('start_time', endUtc)
        .order('start_time');
    return rows.map(ScheduleEvent.fromMap).toList();
  }

  String _dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  String _escapeLike(String value) => value
      .replaceAll(r'\', r'\\')
      .replaceAll('%', r'\%')
      .replaceAll('_', r'\_');
}
