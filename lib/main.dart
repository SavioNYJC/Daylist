import 'package:app_links/app_links.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:daylist/screens/home_page.dart';
import 'package:daylist/screens/welcome_page.dart';
import 'package:daylist/utils/themes.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:material_ui/material_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/login_page.dart';
import 'utils/user_facing_error.dart';

final ValueNotifier<bool> _emailConfirmationReceived = ValueNotifier(false);

bool _isEmailConfirmationLink(Uri uri) {
  final fragmentParameters = Uri.splitQueryString(uri.fragment);
  return uri.queryParameters.containsKey('code') ||
      fragmentParameters.containsKey('code');
}

void _handleEmailConfirmationLink(Uri uri) {
  if (_isEmailConfirmationLink(uri)) {
    _emailConfirmationReceived.value = true;
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    _handleEmailConfirmationLink(Uri.base);
  } else {
    final appLinks = AppLinks();
    appLinks.uriLinkStream.listen(
      _handleEmailConfirmationLink,
      onError: (Object error) {
        debugPrint('Could not read the email confirmation link: $error');
      },
    );
    final initialLink = await appLinks.getInitialLink();
    if (initialLink != null) {
      _handleEmailConfirmationLink(initialLink);
    }
  }

  await Supabase.initialize(
    url: 'https://owhfuqhpuoluyapbuhge.supabase.co',
    publishableKey: 'sb_publishable_GXA7TxGejB3-uTXAI00gbQ_PVVXVrKl',
    authOptions: const FlutterAuthClientOptions(detectSessionInUri: false),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daylist',
      theme: appTheme,
      home: ValueListenableBuilder<bool>(
        valueListenable: _emailConfirmationReceived,
        builder: (context, emailConfirmed, _) {
          if (!emailConfirmed) {
            return const AuthGate();
          }

          return EmailConfirmedPage(
            onLogIn: () {
              Navigator.of(context).push(
                CupertinoPageRoute<void>(builder: (_) => const LoginPage()),
              );
              _emailConfirmationReceived.value = false;
            },
          );
        },
      ),
    );
  }
}

class EmailConfirmedPage extends StatelessWidget {
  const EmailConfirmedPage({super.key, required this.onLogIn});

  final VoidCallback onLogIn;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Email confirmed'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Your email has been confirmed. Log in to continue.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: onLogIn, child: const Text('Log in')),
            ],
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
