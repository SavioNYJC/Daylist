import 'package:daylist/home_page.dart';
import 'package:daylist/screens/welcome_page.dart';
import 'package:material_ui/material_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/login_page.dart';
import 'screens/profile_page.dart';
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
    return MaterialApp(
      title: 'Daylist',
      home: AuthGate(),
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: "DM Sans",
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: Colors.grey.shade100),
          ),
        ),
        textTheme: TextTheme(
          headlineLarge: TextStyle(
            fontSize: 40,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: -1,
          ),
          headlineMedium: TextStyle(
            fontSize: 32,
            color: Colors.black,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
          headlineSmall: TextStyle(
            fontSize: 28,
            color: Colors.black,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
          bodyMedium: TextStyle(fontSize: 18),
          labelMedium: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.25,
          ),
        ),
      ),
    );
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

        return WelcomePage();
      },
    );
  }
}
