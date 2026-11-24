import 'package:daylist/utils/themes.dart';
import 'package:material_ui/material_ui.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';

class NowPlayingCard extends StatelessWidget {
  const NowPlayingCard({super.key, required this.eventName});

  final String eventName;

  @override
  Widget build(BuildContext context) {
    return LiquidGlassLens(
      style: glassCardStyle,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: ListTile(
          title: Padding(
            padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: Text(
              "Now playing",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          subtitle: Column(
            children: [
              SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.directions_car, size: 40, color: Colors.black),
                  SizedBox(width: 10),
                  Text(
                    "Travel to school",
                    style: Theme.of(context).textTheme.bodyMedium!
                        .apply(color: Colors.black),
                  ),
                  Spacer(),
                  LiquidGlassLens(
                    style: LiquidGlassStyle(color: Color(0xFF0088FF)),
                    child: IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  LiquidGlassLens(
                    style: glassButtonStyle,
                    child: IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.skip_previous,
                        color: Colors.black,
                        size: 36,
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  LiquidGlassLens(
                    style: glassButtonStyle,
                    child: IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.skip_next,
                        color: Colors.black,
                        size: 36,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
