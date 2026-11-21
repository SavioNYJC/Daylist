import 'package:daylist/components/customappbar.dart';
import 'package:material_ui/material_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
      backgroundColor: Colors.white,
      appBar: const CustomAppbar(
        title: 'Account details',
        useLiquidGlassBackButton: false,
      ),
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
                  style: const TextStyle(color: Colors.black),
                ),
              ),
            );
          }

          final profile = snapshot.data;
          if (profile == null) {
            return const Center(
              child: Text(
                'Profile not found.',
                style: TextStyle(color: Colors.black),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              _ProfileDetailRow(
                label: 'Username',
                value: profile.username ?? 'Not set',
              ),
              const Divider(height: 1, color: Color(0xFFDDDDDD)),
              _ProfileDetailRow(label: 'User ID', value: profile.userId),
              const Divider(height: 1, color: Color(0xFFDDDDDD)),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.logout, color: Colors.redAccent),
                title: const Text(
                  'Sign out',
                  style: TextStyle(color: Colors.redAccent),
                ),
                onTap: _signOut,
              ),
              const Divider(height: 1, color: Color(0xFFDDDDDD)),
            ],
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

class _ProfileDetailRow extends StatelessWidget {
  const _ProfileDetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: const TextStyle(color: Colors.black54)),
      subtitle: Text(
        value,
        style: Theme.of(context).textTheme.bodyLarge!
            .apply(color: Colors.black),
      ),
    );
  }
}
