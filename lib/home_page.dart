import 'package:daylist/components/appbar.dart';
import 'package:flutter_liquid_glass_plus/flutter_liquid_glass.dart';
import 'package:material_ui/material_ui.dart';

class HomePage extends StatefulWidget {
  const new({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return LiquidGlassLayer(
      settings: LiquidGlassSettings(thickness: 30, blur: 30),
      child: Scaffold(
        appBar: CustomAppBar(title: "My Mix", titleSize: "large"),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(children: []),
          ),
        ),
      ),
    );
    ;
  }
}
