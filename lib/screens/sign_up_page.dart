import 'package:material_ui/material_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'login_page.dart';
import '../utils/user_facing_error.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _username = TextEditingController();
  String? _message;

  Future<void> _signUp() async {
    final username = _username.text.trim();
    if (username.isEmpty) {
      setState(() => _message = 'Please enter a username.');
      return;
    }

    try {
      final isUsernameAvailable = await Supabase.instance.client.rpc(
        'is_username_available',
        params: {'candidate_username': username},
      );

      if (!mounted) return;
      if (isUsernameAvailable != true) {
        setState(
          () => _message = 'That username is already taken. Please choose another.',
        );
        return;
      }

      final response = await Supabase.instance.client.auth.signUp(
        email: _email.text.trim(),
        password: _password.text,
        emailRedirectTo: Uri.base.origin,
        data: {'username': username},
      );

      if (!mounted) return;
      setState(() {
        _message = response.session == null
            ? 'Account created. Check your email to confirm it.'
            : 'Account created and signed in.';
      });
    } on AuthException catch (error) {
      debugPrint('Sign up failed: $error');
      if (!mounted) return;
      setState(() => _message = userFacingError(error));
    } on PostgrestException catch (error) {
      debugPrint('Sign up profile creation failed: $error');
      if (!mounted) return;
      setState(() => _message = userFacingError(error));
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _username.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign up')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          TextField(
            controller: _username,
            decoration: const InputDecoration(labelText: 'Username'),
          ),
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          TextField(
            controller: _password,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Password'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _signUp,
            child: const Text('Create account'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const LoginPage()),
              );
            },
            child: const Text('Already have an account? Log in'),
          ),
          if (_message != null) Text(_message!),
        ],
      ),
    );
  }
}
