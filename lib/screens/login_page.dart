import 'package:daylist/screens/home_page.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';
import 'package:material_ui/material_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../utils/user_facing_error.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.notice});

  final String? notice;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  String? _message;

  @override
  void initState() {
    super.initState();
    _message = widget.notice;
  }

  Future<void> _login() async {
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: _email.text.trim(),
        password: _password.text,
      );

      if (!mounted) return;
      Navigator.of(context).pop();
    } on AuthException catch (error) {
      debugPrint('Login failed: $error');
      if (!mounted) return;
      setState(() => _message = userFacingError(error));
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        backgroundColor: Colors.transparent,
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
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Text(
                  "Log in",
                  style: TextStyle(
                    fontSize: 40,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.left,
                ),
                SizedBox(height: 40),
                TextField(
                  style: TextStyle(color: Colors.white),
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'Enter email',
                    hintStyle: TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  style: TextStyle(color: Colors.white),
                  controller: _password,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: 'Enter password',
                    hintStyle: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 24),
                LiquidGlassButton(
                  onPressed: _login,
                  child: const Text('Log in'),
                ),
                if (_message != null) SizedBox(height: 20),
                if (_message != null)
                  Text(
                    _message!,
                    style: Theme.of(context).textTheme.bodyMedium!
                        .apply(color: Colors.redAccent),
                  ),
                SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    var navigator = Navigator.of(context);
                    navigator.pushAndRemoveUntil(
                      CupertinoPageRoute(
                        builder: (context) {
                          return HomePage();
                        },
                      ),
                      (Route<dynamic> route) => false,
                    );
                  },
                  child: Text(
                    "Forgot password?",
                    style: Theme.of(context).textTheme.bodyMedium!.apply(
                      decoration: TextDecoration.underline,
                      color: Colors.white,
                    ),
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
