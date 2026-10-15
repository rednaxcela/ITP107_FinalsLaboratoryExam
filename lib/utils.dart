import 'package:flutter/material.dart';

import 'theme.dart';

/// Makes the first letter uppercase (JSONPlaceholder titles are lowercase).
String capitalize(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1);
}

/// Picks a stable avatar color for a post id.
Color avatarColorFor(dynamic id) {
  final number = id is int ? id : int.tryParse('$id') ?? 0;
  return AppColors.avatars[number % AppColors.avatars.length];
}

/// Shows a consistent snack bar message at the bottom of the screen.
void showAppMessage(
  BuildContext context,
  String text, {
  bool isError = false,
  bool isSuccess = false,
  SnackBarAction? action,
}) {
  final Color? color = isError
      ? AppColors.danger
      : isSuccess
          ? AppColors.success
          : null;

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (isError || isSuccess) ...[
              Icon(
                isError ? Icons.error_outline : Icons.check_circle_outline,
                color: Colors.white,
              ),
              const SizedBox(width: 10),
            ],
            Expanded(child: Text(text)),
          ],
        ),
        backgroundColor: color,
        action: action,
      ),
    );
}
