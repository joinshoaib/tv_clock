import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TvButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool autofocus;
  final IconData? icon;
  final bool isSelected;

  const TvButton({
    super.key,
    required this.label,
    this.onPressed,
    this.autofocus = false,
    this.icon,
    this.isSelected = false,
  });

  @override
  State<TvButton> createState() => _TvButtonState();
}

class _TvButtonState extends State<TvButton> {
  final FocusNode _node = FocusNode();

  @override
  void dispose() {
    _node.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.onPressed != null) {
      widget.onPressed!();
    }
  }

  void _handleKey(KeyEvent event) {
    if (event is KeyDownEvent || event is KeyRepeatEvent) {
      if (event.logicalKey == LogicalKeyboardKey.select ||
          event.logicalKey == LogicalKeyboardKey.enter ||
          event.logicalKey == LogicalKeyboardKey.space) {
        _handleTap();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _node,
      autofocus: widget.autofocus,
      onKeyEvent: (_, event) {
        _handleKey(event);
        return KeyEventResult.handled;
      },
      child: Builder(
        builder: (context) {
          final focused = Focus.of(context).hasFocus;
          return GestureDetector(
            onTap: _handleTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              decoration: BoxDecoration(
                color: focused
                    ? Colors.deepPurple
                    : widget.isSelected
                    ? Colors.deepPurple.withOpacity(0.7)
                    : Colors.deepPurple.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: focused
                      ? Colors.white
                      : widget.isSelected
                      ? Colors.greenAccent
                      : Colors.transparent,
                  width: focused ? 4 : 3,
                ),
                boxShadow: focused
                    ? [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.4),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.icon != null) ...[
                    Icon(widget.icon, color: Colors.white, size: 28),
                    const SizedBox(width: 12),
                  ],
                  Text(
                    widget.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
