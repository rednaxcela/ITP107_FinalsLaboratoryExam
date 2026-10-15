import 'package:flutter/material.dart';

/// Friendly message used for empty lists and errors.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.color,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final Color? color;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tone = color ?? theme.colorScheme.primary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: tone.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 46, color: tone),
            ),
            const SizedBox(height: 20),
            Text(title,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(message,
                textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
            if (onAction != null && actionLabel != null) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: 220,
                child: FilledButton.icon(
                  onPressed: onAction,
                  icon: Icon(actionIcon ?? Icons.refresh),
                  label: Text(actionLabel!),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
