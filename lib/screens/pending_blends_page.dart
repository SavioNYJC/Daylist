import 'package:daylist/components/customappbar.dart';
import 'package:daylist/services/blend_service.dart';
import 'package:daylist/utils/themes.dart';
import 'package:daylist/utils/user_facing_error.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';
import 'package:material_ui/material_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

typedef PendingBlendsLoader = Future<BlendHomeData> Function();
typedef PendingBlendResponder = Future<void> Function(
  BlendConnection invitation, {
  required bool accept,
});

class PendingBlendsPage extends StatefulWidget {
  const PendingBlendsPage({super.key, this.blendLoader, this.responder});

  final PendingBlendsLoader? blendLoader;
  final PendingBlendResponder? responder;

  @override
  State<PendingBlendsPage> createState() => _PendingBlendsPageState();
}

class _PendingBlendsPageState extends State<PendingBlendsPage> {
  late Future<BlendHomeData> _pendingFuture = _loadPending();
  bool _isResponding = false;

  BlendService get _blendService => BlendService(Supabase.instance.client);

  Future<BlendHomeData> _loadPending() =>
      widget.blendLoader?.call() ?? _blendService.loadHomeData();

  String _errorMessage(Object? error) {
    if (error is BlendServiceException) return error.message;
    return userFacingError(error);
  }

  void _reload() {
    setState(() {
      _pendingFuture = _loadPending();
    });
  }

  Future<void> _refreshPending() {
    final future = _loadPending();
    setState(() => _pendingFuture = future);
    return future.then<void>(
      (_) {},
      onError: (Object error, StackTrace stackTrace) {
        if (mounted) _showMessage(_errorMessage(error));
      },
    );
  }

  Future<void> _respond(
    BlendConnection invitation, {
    required bool accept,
  }) async {
    setState(() => _isResponding = true);
    try {
      if (widget.responder case final responder?) {
        await responder(invitation, accept: accept);
      } else {
        await _blendService.respondToInvitation(invitation, accept: accept);
      }
      if (!mounted) return;
      _showMessage(
        accept ? 'Blend invitation accepted.' : 'Blend invitation declined.',
      );
      _reload();
    } on BlendServiceException catch (error) {
      if (mounted) _showMessage(error.message);
    } on PostgrestException catch (error) {
      debugPrint('Responding to blend invitation failed: $error');
      if (mounted) _showMessage(userFacingError(error));
    } finally {
      if (mounted) setState(() => _isResponding = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFDDDDDD)),
          ),
          content: Text(message, style: const TextStyle(color: Colors.black)),
        ),
      );
  }

  String _dateSummary(BlendConnection invitation) {
    if (invitation.selectedDates.isEmpty) return 'No dates specified';
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
    final dates = invitation.selectedDates
        .map((date) => '${date.day} ${months[date.month - 1]}')
        .join(' · ');
    return dates;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppbar(
        title: 'Pending blends',
        useLiquidGlassBackButton: false,
      ),
      body: SafeArea(
        child: ScrollConfiguration(
          behavior: const MaterialScrollBehavior().copyWith(overscroll: false),
          child: FutureBuilder<BlendHomeData>(
            future: _pendingFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _errorMessage(snapshot.error),
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.black),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: _reload,
                          child: const Text('Try again'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final data = snapshot.data ?? const BlendHomeData();
              if (data.incoming.isEmpty && data.outgoing.isEmpty) {
                return RefreshIndicator(
                  onRefresh: _refreshPending,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: MediaQuery.sizeOf(context).height * 0.52,
                        child: const Center(
                          child: Padding(
                            padding: EdgeInsets.all(28),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.mark_email_read_outlined,
                                  color: Colors.black54,
                                  size: 48,
                                ),
                                SizedBox(height: 14),
                                Text(
                                  'No pending invitations',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'Blend invitations you send or receive will appear here.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.black54),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: _refreshPending,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                  children: [
                    const Text(
                      'Review the blend requests you have received and sent.',
                      style: TextStyle(color: Colors.black54, fontSize: 15),
                    ),
                    const SizedBox(height: 22),
                    if (data.incoming.isNotEmpty) ...[
                      _SectionHeading(
                        title: 'Received',
                        count: data.incoming.length,
                      ),
                      for (final invitation in data.incoming)
                        _IncomingInvitationCard(
                          invitation: invitation,
                          isResponding: _isResponding,
                          dateSummary: _dateSummary(invitation),
                          onAccept: () => _respond(invitation, accept: true),
                          onDecline: () => _respond(invitation, accept: false),
                        ),
                    ],
                    if (data.outgoing.isNotEmpty) ...[
                      if (data.incoming.isNotEmpty) const SizedBox(height: 14),
                      _SectionHeading(
                        title: 'Sent',
                        count: data.outgoing.length,
                      ),
                      for (final invitation in data.outgoing)
                        _OutgoingInvitationCard(
                          invitation: invitation,
                          dateSummary: _dateSummary(invitation),
                        ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFF0EDF5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IncomingInvitationCard extends StatelessWidget {
  const _IncomingInvitationCard({
    required this.invitation,
    required this.isResponding,
    required this.dateSummary,
    required this.onAccept,
    required this.onDecline,
  });

  final BlendConnection invitation;
  final bool isResponding;
  final String dateSummary;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: LiquidGlassLens(
        style: glassCardStyle,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  _InvitationAvatar(username: invitation.otherUsername),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          invitation.otherUsername,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          'Invited you to blend',
                          style: TextStyle(color: Colors.black54, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _InvitationDateDetails(summary: dateSummary),
              if (invitation.description?.isNotEmpty == true) ...[
                const SizedBox(height: 12),
                Text(
                  invitation.description!,
                  style: const TextStyle(color: Colors.black87, fontSize: 15),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: isResponding ? null : onDecline,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFB3261E),
                        side: const BorderSide(color: Color(0xFFB3261E)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Decline'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: isResponding ? null : onAccept,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFE9E5F0),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Accept'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OutgoingInvitationCard extends StatelessWidget {
  const _OutgoingInvitationCard({
    required this.invitation,
    required this.dateSummary,
  });

  final BlendConnection invitation;
  final String dateSummary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: LiquidGlassLens(
        style: glassButtonStyle,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  _InvitationAvatar(username: invitation.otherUsername),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          invitation.otherUsername,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          'Invitation sent',
                          style: TextStyle(color: Colors.black54, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0EDF5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Pending',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _InvitationDateDetails(summary: dateSummary),
              if (invitation.description?.isNotEmpty == true) ...[
                const SizedBox(height: 10),
                Text(
                  invitation.description!,
                  style: const TextStyle(color: Colors.black87, fontSize: 14),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _InvitationDateDetails extends StatelessWidget {
  const _InvitationDateDetails({required this.summary});

  final String summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F6F9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.calendar_today_outlined,
            color: Color(0xFF51466A),
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              summary,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InvitationAvatar extends StatelessWidget {
  const _InvitationAvatar({required this.username});

  final String username;

  @override
  Widget build(BuildContext context) {
    final initial = username.isEmpty ? '?' : username[0].toUpperCase();
    return CircleAvatar(
      radius: 23,
      backgroundColor: const Color(0xFFE9E5F0),
      child: Text(
        initial,
        style: const TextStyle(
          color: Color(0xFF4B3A68),
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
