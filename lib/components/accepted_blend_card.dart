import 'package:daylist/components/blend_member_card.dart';
import 'package:daylist/services/blend_service.dart';
import 'package:material_ui/material_ui.dart';

class AcceptedBlendCard extends StatelessWidget {
  const AcceptedBlendCard({required this.connection, required this.onTap});

  final BlendConnection connection;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: BlendMemberCard(
            title: 'You',
            subtitle:
                connection.myPreviewEvent ?? _blendCardFallback(connection),
            icon: Icons.directions_car_outlined,
            onTap: onTap,
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text('–', style: TextStyle(fontSize: 22)),
        ),
        Expanded(
          child: BlendMemberCard(
            title: connection.otherUsername,
            subtitle:
                connection.otherPreviewEvent ?? _blendCardFallback(connection),
            icon: Icons.bookmark_border,
            onTap: onTap,
          ),
        ),
      ],
    );
  }

  String _blendCardFallback(BlendConnection connection) {
    final dateCount = connection.selectedDates.length;
    return dateCount == 0
        ? 'Nothing scheduled'
        : '$dateCount ${dateCount == 1 ? 'date' : 'dates'} selected';
  }
}
