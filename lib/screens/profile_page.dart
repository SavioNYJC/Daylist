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
  bool _isDeletingAccount = false;

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
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.delete_forever_outlined,
                  color: Colors.redAccent,
                ),
                title: const Text(
                  'Delete account',
                  style: TextStyle(color: Colors.redAccent),
                ),
                trailing: _isDeletingAccount
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : null,
                onTap: _isDeletingAccount ? null : _confirmDeleteAccount,
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

  String _deleteAccountFailureMessage(FunctionException error) {
    final details = error.details;
    final code = details is Map ? details['code'] : null;

    if (error.status == 0) {
      return 'Could not reach the account deletion service. Check your '
          'connection and try again.';
    }
    if (error.status == 404) {
      return 'The account deletion service is not deployed. Deploy the '
          'delete-account Edge Function and try again.';
    }
    if (error.status == 401) {
      return 'Your session expired. Sign in again and retry.';
    }
    if (code == 'function_not_configured') {
      return 'The account deletion service is missing its Supabase keys. '
          'Check the Edge Function configuration.';
    }
    if (code == 'delete_rejected' || error.status >= 500) {
      return 'Supabase could not delete the account. A related table may be '
          'blocking deletion; check the Edge Function logs and delete rules.';
    }

    return 'Could not delete the account (HTTP ${error.status}). Check the '
        'Supabase Edge Function logs.';
  }

  void _showAccountMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.white,
          elevation: 8,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFDDDDDD)),
          ),
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.redAccent),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      );
  }

  Future<void> _confirmDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: const BorderSide(color: Color(0xFFDDDDDD)),
        ),
        title: const Text(
          'Delete account?',
          style: TextStyle(color: Colors.black),
        ),
        content: const Text(
          'This permanently deletes your account and its associated data. '
          'This action cannot be undone.',
          style: TextStyle(color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel', style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete account'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isDeletingAccount = true);
    try {
      await Supabase.instance.client.functions.invoke('delete-account');
    } on FunctionException catch (error) {
      debugPrint('Account deletion failed: $error');
      if (!mounted) return;
      _showAccountMessage(_deleteAccountFailureMessage(error));
      return;
    } finally {
      if (mounted) setState(() => _isDeletingAccount = false);
    }

    try {
      await Supabase.instance.client.auth.signOut(scope: SignOutScope.local);
    } on AuthException catch (error) {
      debugPrint('Could not clear the deleted account session: $error');
      if (!mounted) return;
      _showAccountMessage(
        'Account deleted. Restart the app to finish signing out.',
      );
      return;
    }

    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
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
