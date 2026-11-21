import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:daylist/screens/profile_page.dart';
import 'package:daylist/utils/themes.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';
import 'package:material_ui/material_ui.dart';

import '../components/customappbar.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppbar(
        title: 'App settings',
        useLiquidGlassBackButton: false,
      ),
      body: LiquidGlassView(
        backgroundWidget: const ColoredBox(color: Colors.white),
        child: SafeArea(
          child: ScrollConfiguration(
            // Android stretch overscroll can make BackdropFilter glass render black.
            behavior: const MaterialScrollBehavior().copyWith(
              overscroll: false,
            ),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: LiquidGlassLens(
                    style: glassCardStyle,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Text(
                            'Account',
                            style: Theme.of(context).textTheme.headlineMedium!
                                .apply(color: Colors.black),
                          ),
                        ),
                        const Divider(
                          height: 1,
                          indent: 16,
                          endIndent: 16,
                          color: Color(0xFFDDDDDD),
                        ),
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          leading: const Icon(
                            Icons.person_outline,
                            color: Colors.black,
                          ),
                          title: const Text(
                            'Account details',
                            style: TextStyle(color: Colors.black),
                          ),
                          trailing: const Icon(
                            Icons.chevron_right,
                            color: Colors.black54,
                          ),
                          onTap: () {
                            Navigator.of(context).push(
                              CupertinoPageRoute<void>(
                                builder: (_) => const ProfilePage(),
                              ),
                            );
                          },
                        ),
                      ],
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
