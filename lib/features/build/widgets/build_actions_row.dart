// lib/features/build/widgets/build_actions_row.dart
import 'package:flutter/material.dart';

class BuildActionsRow extends StatelessWidget {
  final VoidCallback onReset;
  final VoidCallback onSave;
  final VoidCallback onAutoComplete;
  final VoidCallback onCheckout;
  final bool disabled;

  const BuildActionsRow({
    Key? key,
    required this.onReset,
    required this.onSave,
    required this.onAutoComplete,
    required this.onCheckout,
    this.disabled = false,
  }) : super(key: key);

  Widget _actionButton({
    required BuildContext context,
    required Color background,
    required Widget child,
    required VoidCallback onTap,
    bool enabled = true,
    EdgeInsetsGeometry? padding,
  }) {
    final btn = Material(
      color: background,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: enabled ? onTap : null,
        child: Container(
          padding: padding ?? const EdgeInsets.symmetric(vertical: 14),
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: enabled ? 1.0 : 0.55,
      child: btn,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Reset (muted gray)
          Expanded(
            child: _actionButton(
              context: context,
              background: Colors.grey.shade200,
              enabled: !disabled,
              onTap: () {
                showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Reset build?'),
                    content: const Text(
                      'This will clear your temporary build.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                ).then((ok) {
                  if (ok == true) onReset();
                });
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh, color: Colors.grey[800]),
                  const SizedBox(height: 6),
                  Text(
                    'Reset',
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Save (neutral dark)
          Expanded(
            child: _actionButton(
              context: context,
              background: Colors.blueGrey.shade700,
              enabled: !disabled,
              onTap: onSave,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.save, color: Colors.white),
                  SizedBox(height: 6),
                  Text(
                    'Save',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Auto Fill (green gradient-like)
          Expanded(
            child: _actionButton(
              context: context,
              background:
                  const LinearGradient(
                        colors: [Color(0xFF10B981), Color(0xFF059669)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(Rect.fromLTWH(0, 0, 200, 60)) !=
                      null
                  ? Colors.transparent
                  : const Color(0xFF10B981),
              // We will wrap gradient manually below to keep complexity low for native color
              onTap: onAutoComplete,
              enabled: !disabled,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.flash_on, color: Colors.white),
                    SizedBox(height: 6),
                    Text(
                      'Auto Fill',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Checkout (yellow)
          Expanded(
            child: _actionButton(
              context: context,
              background: const Color(0xFFFFC107),
              enabled: !disabled,
              onTap: onCheckout,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.shopping_cart, color: Colors.black),
                  SizedBox(height: 6),
                  Text(
                    'Checkout',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
