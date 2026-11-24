import 'package:daylist/components/customappbar.dart';
import 'package:daylist/services/blend_service.dart';
import 'package:daylist/utils/themes.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';
import 'package:material_ui/material_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

typedef BlendDayLoader = Future<BlendDayData> Function(
  BlendConnection connection,
  DateTime day,
);

class BlendPage extends StatefulWidget {
  const BlendPage({super.key, required this.connection, this.dayLoader});

  final BlendConnection connection;
  final BlendDayLoader? dayLoader;

  @override
  State<BlendPage> createState() => _BlendPageState();
}

class _BlendPageState extends State<BlendPage> {
  late final List<DateTime> _availableDays;
  late DateTime _selectedDay;
  late Future<BlendDayData> _day;

  @override
  void initState() {
    super.initState();
    final selectedDates = widget.connection.selectedDates;
    _availableDays = selectedDates.isEmpty ? [DateTime.now()] : selectedDates;
    _selectedDay = _availableDays.first;
    _day = _loadDay(_selectedDay);
  }

  Future<BlendDayData> _loadDay(DateTime day) =>
      widget.dayLoader?.call(widget.connection, day) ??
      BlendService(Supabase.instance.client).loadDay(widget.connection, day);

  void _selectDay(DateTime day) {
    setState(() {
      _selectedDay = day;
      _day = _loadDay(day);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppbar(
        title: 'You + ${widget.connection.otherUsername}',
        useLiquidGlassBackButton: false,
      ),
      body: SafeArea(
        child: ScrollConfiguration(
          behavior: const MaterialScrollBehavior().copyWith(overscroll: false),
          child: FutureBuilder<BlendDayData>(
            future: _day,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      _errorMessage(snapshot.error),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                );
              }

              final day = snapshot.data!;
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                children: [
                  Center(
                    child: Text(
                      _formatDay(day.day),
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (_availableDays.length > 1) ...[
                    const SizedBox(height: 14),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final availableDay in _availableDays)
                          _DayChip(
                            day: availableDay,
                            selected: _isSameDay(availableDay, _selectedDay),
                            onTap: () => _selectDay(availableDay),
                          ),
                      ],
                    ),
                  ],
                  if (widget.connection.description?.isNotEmpty == true) ...[
                    const SizedBox(height: 14),
                    LiquidGlassLens(
                      style: glassCardStyle,
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Text(
                          widget.connection.description!,
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _ScheduleColumn(
                          title: 'Your day',
                          events: day.myEvents,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ScheduleColumn(
                          title: "${widget.connection.otherUsername}'s day",
                          events: day.otherEvents,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  String _errorMessage(Object? error) {
    if (error is BlendServiceException) return error.message;
    if (error is PostgrestException && error.code == '42501') {
      return 'You do not have permission to view this schedule. Make sure '
          'the blend is accepted.';
    }
    return 'Could not load the blended schedule. Check your connection and '
        'try again.';
  }

  String _formatDay(DateTime day) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final prefix = _isSameDay(day, DateTime.now()) ? 'Today · ' : '';
    return '$prefix${weekdays[day.weekday - 1]}, '
        '${months[day.month - 1]} ${day.day}';
  }

  bool _isSameDay(DateTime first, DateTime second) =>
      first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
}

class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.day,
    required this.selected,
    required this.onTap,
  });

  final DateTime day;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE9E5F0) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFDDDDDD)),
        ),
        child: Text(
          '${day.day} ${months[day.month - 1]}',
          style: const TextStyle(color: Colors.black),
        ),
      ),
    );
  }
}

class _ScheduleColumn extends StatelessWidget {
  const _ScheduleColumn({required this.title, required this.events});

  final String title;
  final List<ScheduleEvent> events;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 54,
          child: Align(
            alignment: Alignment.topCenter,
            child: Text(
              title,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        if (events.isEmpty)
          const _EmptyScheduleCard()
        else
          for (final event in events)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ScheduleEventCard(event: event),
            ),
      ],
    );
  }
}

class _ScheduleEventCard extends StatelessWidget {
  const _ScheduleEventCard({required this.event});

  final ScheduleEvent event;

  String _time(DateTime value) =>
      '${value.hour.toString().padLeft(2, '0')}'
      '${value.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return LiquidGlassLens(
      style: glassCardStyle,
      child: SizedBox(
        height: 112,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.wb_sunny_outlined,
                size: 22,
                color: Color(0xFFFFB800),
              ),
              const Spacer(),
              Text(
                event.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.black, fontSize: 14),
              ),
              Text(
                '${_time(event.startTime)} - ${_time(event.endTime)}',
                maxLines: 1,
                style: const TextStyle(color: Colors.black54, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyScheduleCard extends StatelessWidget {
  const _EmptyScheduleCard();

  @override
  Widget build(BuildContext context) {
    return LiquidGlassLens(
      style: glassCardStyle,
      child: const SizedBox(
        height: 112,
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              'No events this day',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54, fontSize: 13),
            ),
          ),
        ),
      ),
    );
  }
}
