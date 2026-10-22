import 'package:flutter/material.dart';

import '../../core/network/api_client.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final email = TextEditingController();
  bool busy = false;
  bool sent = false;
  String? error;
  final code = TextEditingController();
  final newPassword = TextEditingController();
  @override
  void dispose() {
    email.dispose();
    code.dispose();
    newPassword.dispose();
    super.dispose();
  }

  Future<void> send() async {
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final api = ApiClient();
      if (sent) {
        await api.post('/user/auth/reset-password', {
          'email': email.text.trim(),
          'code': code.text.trim(),
          'new_password': newPassword.text,
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password reset. Sign in with your new password.'),
            ),
          );
          Navigator.pop(context);
        }
      } else {
        await api.post('/user/auth/forgot-password', {
          'email': email.text.trim(),
        });
        if (mounted) setState(() => sent = true);
      }
    } on ApiException catch (e) {
      if (mounted) setState(() => error = e.message);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const StarHeader(
      title: 'Reset password',
      showBack: true,
      showWallet: false,
    ),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 25),
        const Icon(Icons.lock_reset, color: AppColors.gold, size: 42),
        const SizedBox(height: 15),
        Text(
          sent ? 'Enter your reset code' : 'Recover your account',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        Text(
          sent
              ? 'If that email matches an active account, a code was sent. The code expires in 15 minutes.'
              : 'Enter your account email and we will send a secure reset code.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 10,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 22),
        TextField(
          controller: email,
          enabled: !sent,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email address',
            prefixIcon: Icon(Icons.mail_outline),
          ),
        ),
        if (sent) ...[
          const SizedBox(height: 12),
          TextField(
            controller: code,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: const InputDecoration(
              labelText: 'Six-digit code',
              prefixIcon: Icon(Icons.password),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: newPassword,
            obscureText: true,
            autofillHints: const [AutofillHints.newPassword],
            decoration: const InputDecoration(
              labelText: 'New password (12+ characters)',
              prefixIcon: Icon(Icons.lock_outline),
            ),
          ),
        ],
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              error!,
              style: const TextStyle(color: Color(0xFFFDA4AF), fontSize: 10),
            ),
          ),
        const SizedBox(height: 14),
        GoldButton(
          label: sent ? 'RESET PASSWORD' : 'SEND RESET CODE',
          onPressed: send,
          icon: sent ? Icons.check : Icons.send_outlined,
          busy: busy,
        ),
      ],
    ),
  );
}
