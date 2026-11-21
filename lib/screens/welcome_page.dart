import 'package:daylist/screens/login_page.dart';
import 'package:daylist/screens/sign_up_page.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';
import 'package:material_ui/material_ui.dart';
import 'package:cupertino_ui/cupertino_ui.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final _email = TextEditingController();

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
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  SizedBox(height: 60),
                  Text(
                    "Take control of your time.",
                    style: Theme.of(context).textTheme.headlineLarge!
                        .apply(decoration: TextDecoration.underline),
                  ),
                  SizedBox(height: 40),
                  Text(
                    "Organize your day into playlists, share schedules with others and live a more productive life.",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                  SizedBox(height: 40),
                  TextField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: "Enter email to begin",
                    ),
                  ),
                  SizedBox(height: 20),
                  LiquidGlassButton(
                    child: Text(
                      "Register",
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    onPressed: () {
                      var navigator = Navigator.of(context);
                      navigator.push(
                        CupertinoPageRoute(
                          builder: (context) {
                            return SignUpPage(suppliedEmail: _email.text);
                          },
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 32),
                  Text("Already have an account?"),
                  SizedBox(height: 20),
                  LiquidGlassButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        CupertinoPageRoute<void>(
                          builder: (_) => const LoginPage(),
                        ),
                      );
                    },
                    child: Text(
                      'Log in',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
