import 'package:flutter/material.dart';

class TvButton extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return ElevatedButton(
      autofocus: autofocus,
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.focused)) {
            return Colors.deepPurple;
          }
          if (isSelected) {
            return Colors.deepPurple.withOpacity(0.7);
          }
          return Colors.deepPurple.withOpacity(0.3);
        }),
        foregroundColor: WidgetStateProperty.all(Colors.white),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
        ),
        minimumSize: WidgetStateProperty.all(const Size(200, 64)),
        side: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.focused)) {
            return const BorderSide(color: Colors.white, width: 3);
          }
          if (isSelected) {
            return const BorderSide(color: Colors.greenAccent, width: 3);
          }
          return BorderSide(
            color: Colors.deepPurple.withOpacity(0.3),
            width: 3,
          );
        }),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 28),
            const SizedBox(width: 12),
          ],
          Text(
            label,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
