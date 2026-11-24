import 'package:material_ui/material_ui.dart';

class BlendInvitationDraft {
  const BlendInvitationDraft({
    required this.username,
    required this.selectedDates,
    required this.description,
  });

  final String username;
  final List<DateTime> selectedDates;
  final String? description;
}

class CreateBlendDialog extends StatefulWidget {
  const CreateBlendDialog({super.key});

  @override
  State<CreateBlendDialog> createState() => _CreateBlendDialogState();
}

class _CreateBlendDialogState extends State<CreateBlendDialog> {
  static const _mainTextColor = Color(0xFF211E25);
  static const _secondaryTextColor = Color(0xFF514B59);
  static const _accentTextColor = Color(0xFF4B3A68);
  static const _errorTextColor = Color(0xFFB3261E);

  final _usernameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final Set<DateTime> _selectedDates = {};
  String? _usernameError;
  String? _datesError;

  DateTime get _today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    final username = _usernameController.text.trim();
    if (username.isEmpty || _selectedDates.isEmpty) {
      setState(() {
        _usernameError = username.isEmpty ? 'Enter a username.' : null;
        _datesError = _selectedDates.isEmpty
            ? 'Select at least one date.'
            : null;
      });
      return;
    }

    Navigator.of(context).pop(
      BlendInvitationDraft(
        username: username,
        selectedDates: _selectedDates.toList()..sort(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
      ),
    );
  }

  Future<void> _addDate() async {
    if (_selectedDates.length >= 7) return;

    final today = _today;
    final date = await showDatePicker(
      context: context,
      initialDate: _suggestedDate(today),
      firstDate: today,
      lastDate: today.add(const Duration(days: 90)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          brightness: Brightness.light,
          colorScheme: const ColorScheme.light(primary: Color(0xFF8476A7)),
        ),
        child: child!,
      ),
    );
    if (date == null || !mounted) return;

    final selectedDate = DateTime(date.year, date.month, date.day);
    setState(() {
      _selectedDates.add(selectedDate);
      _datesError = null;
    });
  }

  DateTime _suggestedDate(DateTime today) {
    for (var offset = 0; offset <= 90; offset++) {
      final date = today.add(Duration(days: offset));
      if (!_selectedDates.contains(date)) return date;
    }
    return today;
  }

  String _formatDate(DateTime date) {
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
    return '${date.day} ${months[date.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final screenHeight = MediaQuery.sizeOf(context).height;

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 520,
          maxHeight: screenHeight * 0.9,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Create new blend',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 27,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Username',
                style: TextStyle(
                  color: _mainTextColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _usernameController,
                textInputAction: TextInputAction.next,
                style: const TextStyle(color: _mainTextColor, fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Enter their username',
                  hintStyle: const TextStyle(
                    color: _secondaryTextColor,
                    fontSize: 16,
                  ),
                  errorText: _usernameError,
                  errorStyle: const TextStyle(
                    color: _errorTextColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: Color(0xFFCBC7D0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: Color(0xFFCBC7D0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(
                      color: Color(0xFF8476A7),
                      width: 1.5,
                    ),
                  ),
                ),
                onChanged: (_) {
                  if (_usernameError != null) {
                    setState(() => _usernameError = null);
                  }
                },
              ),
              const SizedBox(height: 18),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFDDDDDD)),
                  borderRadius: BorderRadius.circular(18),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Blend dates',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Choose up to 7 days to compare',
                                style: TextStyle(
                                  color: _secondaryTextColor,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _selectedDates.length < 7
                              ? _addDate
                              : null,
                          icon: const Icon(Icons.add, size: 21),
                          label: const Text(
                            'Add date',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: _accentTextColor,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_selectedDates.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: Text(
                          'No dates selected yet',
                          style: TextStyle(
                            color: _secondaryTextColor,
                            fontSize: 15,
                          ),
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.only(top: 14),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final date
                                in (_selectedDates.toList()..sort()))
                              Chip(
                                label: Text(_formatDate(date)),
                                labelStyle: const TextStyle(
                                  color: _mainTextColor,
                                  fontSize: 15,
                                ),
                                backgroundColor: const Color(0xFFF0EDF5),
                                side: BorderSide.none,
                                deleteIconColor: _accentTextColor,
                                onDeleted: () => setState(() {
                                  _selectedDates.remove(date);
                                }),
                                visualDensity: VisualDensity.compact,
                              ),
                          ],
                        ),
                      ),
                    if (_datesError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          _datesError!,
                          style: TextStyle(
                            color: _errorTextColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Description (optional)',
                style: TextStyle(
                  color: _mainTextColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                maxLength: 300,
                style: const TextStyle(color: _mainTextColor, fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'What would you like to plan together?',
                  hintStyle: const TextStyle(
                    color: _secondaryTextColor,
                    fontSize: 16,
                  ),
                  counterStyle: const TextStyle(
                    color: _secondaryTextColor,
                    fontSize: 13,
                  ),
                  alignLabelWithHint: true,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: Color(0xFFCBC7D0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: Color(0xFFCBC7D0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(
                      color: Color(0xFF8476A7),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFE9E5F0),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Create',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
