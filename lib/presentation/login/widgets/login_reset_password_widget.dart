import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/services/providers/auth_providers.dart';

class LoginResetPasswordWidget extends StatelessWidget {
  final String initialEmail;

  const LoginResetPasswordWidget({super.key, required this.initialEmail});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => showDialog<void>(
        context: context,
        builder: (_) => _ResetPasswordDialog(initialEmail: initialEmail),
      ),
      child: const Text('Passwort vergessen?'),
    );
  }
}

class _ResetPasswordDialog extends ConsumerStatefulWidget {
  final String initialEmail;

  const _ResetPasswordDialog({required this.initialEmail});

  @override
  ConsumerState<_ResetPasswordDialog> createState() =>
      _ResetPasswordDialogState();
}

class _ResetPasswordDialogState extends ConsumerState<_ResetPasswordDialog> {
  late final TextEditingController _emailController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      await ref
          .read(authControllerProvider.notifier)
          .sendPasswordResetEmail(email);

      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).pop();
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Falls ein Konto mit dieser E-Mail-Adresse existiert, erhältst du in Kürze eine E-Mail.',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Fehler beim Senden der E-Mail. Bitte versuche es erneut.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Passwort zurücksetzen'),
      content: TextField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(labelText: 'E-Mail-Adresse'),
        autofocus: true,
        onSubmitted: _isLoading ? null : (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Abbrechen'),
        ),
        TextButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Zurücksetzen'),
        ),
      ],
    );
  }
}
