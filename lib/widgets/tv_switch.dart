import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TvSwitch extends StatefulWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool autofocus;

  const TvSwitch({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.autofocus = false,
  });

  @override
  State<TvSwitch> createState() => _TvSwitchState();
}

class _TvSwitchState extends State<TvSwitch> {
  final FocusNode _node = FocusNode();

  @override
  void dispose() {
    _node.dispose();
    super.dispose();
  }

  void _toggle() {
    widget.onChanged(!widget.value);
  }

  void _handleKey(KeyEvent event) {
    if (event is KeyDownEvent || event is KeyRepeatEvent) {
      if (event.logicalKey == LogicalKeyboardKey.select ||
          event.logicalKey == LogicalKeyboardKey.enter ||
          event.logicalKey == LogicalKeyboardKey.space) {
        _toggle();
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
            onTap: _toggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: focused
                    ? Colors.deepPurple.withOpacity(0.5)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: focused ? Colors.white : Colors.transparent,
                  width: 3,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.label,
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  Container(
                    width: 60,
                    height: 32,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: widget.value ? Colors.greenAccent : Colors.white24,
                      border: Border.all(
                        color: focused ? Colors.white : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: AnimatedAlign(
                      duration: const Duration(milliseconds: 150),
                      alignment: widget.value
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: focused ? Colors.white : Colors.white70,
                          ),
                        ),
                      ),
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
