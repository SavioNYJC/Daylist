import 'package:daylist/home_page.dart';
import 'package:daylist/welcome_page.dart';
import 'package:flutter/services.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';
import 'package:material_ui/material_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/login_page.dart';
import 'screens/profile_page.dart';
import 'screens/sign_up_page.dart';
import 'utils/user_facing_error.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://owhfuqhpuoluyapbuhge.supabase.co',
    publishableKey: 'sb_publishable_GXA7TxGejB3-uTXAI00gbQ_PVVXVrKl',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(title: 'Daylist', home: AuthGate());
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Supabase.instance.client.auth;

    return StreamBuilder<AuthState>(
      stream: auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Authentication issue')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      userFacingError(snapshot.error),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const LoginPage(),
                          ),
                        );
                      },
                      child: const Text('Log in'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final session = snapshot.data?.session ?? auth.currentSession;
        if (session != null) {
          return const HomePage();
        }

        return const SignUpPage();
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const ProfilePage()),
            );
          },
          child: const Text('Account information'),
        ),
      ),
    );
  }
}
// void main() {
//   runApp(
//     MaterialApp(
//       home: RootPage(),
//       theme: ThemeData(brightness: Brightness.dark),
//     ),
//   );
// }

// class RootPage extends StatefulWidget {
//   const new({super.key});

//   @override
//   State<RootPage> createState() => _RootPageState();
// }

// class _RootPageState extends State<RootPage> {
//   bool _isLoggedIn = false;

//   @override
//   Widget build(BuildContext context) {
//     if (_isLoggedIn) {
//       return HomePage();
//     } else {
//       return WelcomePage();
//     }
//   }
// }
