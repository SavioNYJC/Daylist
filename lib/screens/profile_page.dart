import 'package:daylist/components/customappbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:material_ui/material_ui.dart';

import '../utils/user_facing_error.dart';

class Profile {
  const Profile({required this.userId, this.username});

  final String userId;
  final String? username;

  factory Profile.fromMap(Map<String, dynamic> row) {
    return Profile(
      userId: row['user_id'] as String,
      username: row['username'] as String?,
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final Future<Profile?> _profile = _loadProfile();

  Future<Profile?> _loadProfile() async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;

    if (user == null) {
      throw StateError('You must be signed in to view your profile');
    }

    final row = await client
        .from('profiles')
        .select('user_id, username')
        .eq('user_id', user.id)
        .maybeSingle();

    return row == null ? null : Profile.fromMap(row);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: "App settings"),
      body: FutureBuilder<Profile?>(
        future: _profile,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  userFacingError(snapshot.error),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final profile = snapshot.data;
          if (profile == null) {
            return const Center(child: Text('Profile not found.'));
          }

          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('User ID: ${profile.userId}'),
                Text('Username: ${profile.username ?? 'Not set'}'),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _signOut() async {
    try {
      await Supabase.instance.client.auth.signOut();
      if (!mounted) return;
      Navigator.of(context).pop();
    } on AuthException catch (error) {
      debugPrint('Sign out failed: $error');
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(userFacingError(error))));
    }
  }
}
