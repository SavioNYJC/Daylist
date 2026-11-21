import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';
import 'package:material_ui/material_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'login_page.dart';
import '../utils/user_facing_error.dart';

class SignUpPage extends StatefulWidget {
  final String suppliedEmail;

  SignUpPage({super.key, this.suppliedEmail = ""});

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
          () => _message =
              'That username is already taken. Please choose another.',
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
    if (widget.suppliedEmail != "") {
      _email.text = widget.suppliedEmail!;
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0E162F), Color(0xFF404B6C), Color(0xFFD1DBFA)],
          stops: [0.3, 0.6, 1.0],
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            onPressed: () {
              var navigator = Navigator.of(context);
              navigator.pop();
            },
            icon: Icon(Icons.chevron_left, size: 30),
          ),
        ),
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Text(
                  "Sign up",
                  style: TextStyle(
                    fontSize: 40,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.left,
                ),
                SizedBox(height: 40),
                TextField(
                  controller: _username,
                  decoration: const InputDecoration(hintText: 'Enter username'),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(hintText: 'Enter email'),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _password,
                  obscureText: true,
                  decoration: const InputDecoration(hintText: 'Enter password'),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _password,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: 'Re-enter password',
                  ),
                ),
                const SizedBox(height: 24),
                LiquidGlassButton(
                  onPressed: _signUp,
                  label: "Create account",
                  child: Text(
                    'Create account',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
                SizedBox(height: 32),
                Center(child: Text("Already have an account?")),
                SizedBox(height: 20),
                LiquidGlassButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(builder: (_) => const LoginPage()),
                    );
                  },
                  child: Text(
                    'Log in',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),

                if (_message != null) Text(_message!),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
