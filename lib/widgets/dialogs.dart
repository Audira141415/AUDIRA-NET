import 'package:flutter/material.dart';
import '../config/routes.dart';

/// Reusable confirmation dialog for app exit
class ExitConfirmationDialog extends StatelessWidget {
  const ExitConfirmationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Keluar Aplikasi?'),
      content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context); // Close dialog
            Navigator.pushNamedAndRemoveUntil(
              context,
              Routes.unifiedLogin,
              (route) => false,
            );
          },
          style: FilledButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Keluar'),
        ),
      ],
    );
  }
}

/// Reusable error dialog
class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;

  const ErrorDialog({super.key, required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    );
  }
}

/// Reusable success dialog
class SuccessDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onClose;

  const SuccessDialog({
    super.key,
    required this.title,
    required this.message,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 28),
          const SizedBox(width: 12),
          Text(title),
        ],
      ),
      content: Text(message),
      actions: [
        FilledButton(
          onPressed: () {
            Navigator.pop(context);
            onClose?.call();
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}

/// Show exit confirmation dialog helper
void showExitConfirmationDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => const ExitConfirmationDialog(),
  );
}

/// Show error dialog helper
void showErrorDialog(BuildContext context, String title, String message) {
  showDialog(
    context: context,
    builder: (context) => ErrorDialog(title: title, message: message),
  );
}

/// Show success dialog helper
void showSuccessDialog(
  BuildContext context,
  String title,
  String message, {
  VoidCallback? onClose,
}) {
  showDialog(
    context: context,
    builder: (context) =>
        SuccessDialog(title: title, message: message, onClose: onClose),
  );
}
