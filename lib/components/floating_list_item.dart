import 'package:material_ui/material_ui.dart';

class FloatingListItem extends StatefulWidget {
  const FloatingListItem({
    super.key,
    required this.child,
    required this.floatingChild,
  });

  final Widget child;
  final Widget? floatingChild;

  @override
  State<FloatingListItem> createState() => FloatingListItemState();
}

class FloatingListItemState extends State<FloatingListItem> {
  final LayerLink _layerLink = LayerLink();

  OverlayEntry? _overlayEntry;
  bool _isFloatingShown = false;

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;

    if (mounted) {
      setState(() {
        _isFloatingShown = false;
      });
    }
  }

  void _showOverlay() {
    if (_overlayEntry != null) return;

    setState(() {
      _isFloatingShown = true;
    });

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: _removeOverlay,
                behavior: HitTestBehavior.translucent,
                child: SizedBox.expand(),
              ),
            ),

            CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              targetAnchor: Alignment.center,
              followerAnchor: Alignment.center,
              child: TweenAnimationBuilder(
                tween: Tween(begin: 0.9, end: 1.0),
                duration: Duration(milliseconds: 180),
                curve: Curves.easeOutBack,
                builder: (context, scale, child) {
                  return Transform.scale(scale: scale, child: child);
                },
                child: Material(
                  color: Colors.transparent,
                  elevation: 12,
                  borderRadius: BorderRadius.circular(28),
                  child: widget.floatingChild,
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context, rootOverlay: true).insert(_overlayEntry!);
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    _overlayEntry = null;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onLongPress: _showOverlay,
        child: Visibility(
          visible: !_isFloatingShown,
          maintainSize: true,
          maintainAnimation: true,
          maintainState: true,
          child: widget.child,
        ),
      ),
    );
  }
}
