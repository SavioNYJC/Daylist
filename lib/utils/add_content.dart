import 'package:supabase_flutter/supabase_flutter.dart';

// add event to user playlist
class EventData {
  final String id;
  final String userId;
  final String eventName;
  final String? description;
  final String? location;
  final int? iconCodepoint;
  final DateTime startTime;
  final DateTime endTime;
  final DateTime created_at;

  const EventData({
    required this.id,
    required this.userId,
    required this.eventName,
    this.description,
    this.location,
    this.iconCodepoint,
    required this.startTime,
    required this.endTime,
    required this.created_at,
  });

  factory EventData.fromMap(Map<String, dynamic> map) {
    return EventData(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      eventName: map['event_name'] as String,
      description: map['description'] as String?,
      location: map['location'] as String?,
      iconCodepoint: map['icon_codepoint'] as int?,
      startTime: DateTime.parse(map['start_time'] as String).toLocal(),
      endTime: DateTime.parse(map['end_time'] as String).toLocal(),
      created_at: DateTime.parse(map['created_at'] as String),
    );
  }
}

/// adds an event to the table
Future<EventData> addEventData({
  required String eventName,
  String? description,
  String? location,
  int? iconCodepoint,
  required DateTime startTime,
  required DateTime endTime,
  required String playlistId,
  int position = 0,
}) async {
  final user = Supabase.instance.client.auth.currentUser;

  if (user == null) {
    throw StateError('You must be signed in to add event data');
  }

  final data = <String, dynamic>{
    'user_id': user.id,
    'event_name': eventName,
    'description': description,
    'location': location,
    'icon_codePoint': iconCodepoint,
    'start_time': startTime.toIso8601String(),
    'end_time': endTime.toIso8601String(),
  };

  final row = await Supabase.instance.client
      .from('events')
      .insert(data)
      .select()
      .single();

  final event = EventData.fromMap(row);

  await Supabase.instance.client.from('playlist_items').insert({
    'playlist_id': playlistId,
    'event_id': event.id,
    'position': position,
  });
  // returns an EventData object to use for updating the UI to reflect changes
  return event;
}

// adds a new playlist to user's playlists
class PlaylistData {
  final String id;
  final String userId;
  final String playlistName;
  final DateTime created_at;

  const PlaylistData({
    required this.id,
    required this.userId,
    required this.playlistName,
    required this.created_at,
  });

  factory PlaylistData.fromMap(Map<String, dynamic> map) {
    return PlaylistData(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      playlistName: map['playlist_name'] as String,
      created_at: DateTime.parse(map['created_at'] as String),
    );
  }
}

Future<PlaylistData> addPlaylistData({
  required String playlistName,
  required DateTime date,
}) async {
  final user = Supabase.instance.client.auth.currentUser;

  if (user == null) {
    throw StateError('You must be signed in to add a playlist');
  }

  final data = <String, dynamic>{
    'user_id': user.id,
    'playlist_name': playlistName,
    "date": date.toIso8601String(),
  };

  final row = await Supabase.instance.client
      .from('playlists')
      .insert(data)
      .select()
      .single();

  return PlaylistData.fromMap(row);
}
