import 'package:flutter/material.dart';

import '../../app.dart';
import '../../core/network/api_client.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets.dart';
import 'forgot_password_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final username = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final referral = TextEditingController();
  final verificationCode = TextEditingController();
  bool register = false;
  bool verificationPending = false;
  bool busy = false;
  String? error;

  @override
  void dispose() {
    username.dispose();
    email.dispose();
    password.dispose();
    referral.dispose();
    verificationCode.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    FocusScope.of(context).unfocus();
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final store = AppStoreScope.of(context);
      if (verificationPending) {
        await store.verifyEmail(email.text, verificationCode.text);
      } else if (register) {
        final account = await store.register(
          username.text,
          email.text,
          password.text,
          referral.text,
        );
        if (account != null && mounted) {
          setState(() {
            verificationPending = true;
            if (account['debug_code'] != null) {
              verificationCode.text = account['debug_code'].toString();
            }
          });
        }
      } else {
        await store.signIn(email.text, password.text);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = e.toString();
          if (e is ApiException && e.code == 'EMAIL_NOT_VERIFIED') {
            verificationPending = true;
          }
        });
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  void _showServerSettings() {
    final store = AppStoreScope.of(context);
    final urlController = TextEditingController(text: store.auth.api.baseUrl);
    String? testResult;
    bool testing = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Backend API Server',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Point to your PC local IP or domain running XAMPP/PHP.',
                style: TextStyle(color: AppColors.muted, fontSize: 11),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: urlController,
                decoration: const InputDecoration(
                  labelText: 'API Base URL',
                  prefixIcon: Icon(Icons.dns, size: 18),
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: [
                  ActionChip(
                    label: const Text('Wi-Fi PC (192.168.1.5)', style: TextStyle(fontSize: 11)),
                    onPressed: () => setModalState(() {
                      urlController.text = 'http://192.168.1.5/starguess-admin/api/v1';
                    }),
                  ),
                  ActionChip(
                    label: const Text('Emulator (10.0.2.2)', style: TextStyle(fontSize: 11)),
                    onPressed: () => setModalState(() {
                      urlController.text = 'http://10.0.2.2/starguess-admin/api/v1';
                    }),
                  ),
                ],
              ),
              if (testResult != null) ...[
                const SizedBox(height: 10),
                Text(
                  testResult!,
                  style: TextStyle(
                    fontSize: 12,
                    color: testResult!.startsWith('OK')
                        ? const Color(0xFF34D399)
                        : const Color(0xFFF87171),
                  ),
                ),
              ],
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: testing
                          ? null
                          : () async {
                              setModalState(() {
                                testing = true;
                                testResult = 'Testing connection...';
                              });
                              try {
                                store.auth.api.updateBaseUrl(urlController.text);
                                final res = await store.auth.api.get('/health');
                                setModalState(() {
                                  testing = false;
                                  testResult = 'OK: Connected (${res['data']?['status'] ?? 'ready'})';
                                });
                              } catch (e) {
                                setModalState(() {
                                  testing = false;
                                  testResult = 'Failed: $e';
                                });
                              }
                            },
                      child: Text(testing ? 'Testing...' : 'Test Connection'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        store.auth.api.updateBaseUrl(urlController.text);
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Server set to: ${store.auth.api.baseUrl}')),
                        );
                      },
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 30, 24, 28),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.settings_ethernet_rounded, color: AppColors.gold, size: 22),
                    tooltip: 'Configure Backend Server IP',
                    onPressed: _showServerSettings,
                  ),
                ),
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Image.asset(
                      'assets/images/starguess_app_icon_1791401317308_min.jpg',
                      width: 86,
                      height: 86,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 19),
                const Text(
                  'STAR GUESS',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.gold,
                    letterSpacing: 3.3,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  register
                      ? 'Create your account'
                      : 'Predict. Deduce. Outsmart.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Competitive 1v1 number prediction with Stars rewards.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.muted, fontSize: 12),
                ),
                const SizedBox(height: 26),
                if (!verificationPending)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        _Tab(
                          label: 'SIGN IN',
                          selected: !register,
                          onTap: () => setState(() {
                            register = false;
                            error = null;
                          }),
                        ),
                        _Tab(
                          label: 'CREATE ACCOUNT',
                          selected: register,
                          onTap: () => setState(() {
                            register = true;
                            error = null;
                          }),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 20),
                if (register && !verificationPending) ...[
                  _input(
                    username,
                    'Gamer handle',
                    Icons.person_outline,
                    hint: 'ApexGuesser',
                  ),
                  const SizedBox(height: 12),
                ],
                _input(
                  email,
                  'Email',
                  Icons.mail_outline,
                  hint: 'player@example.com',
                  keyboard: TextInputType.emailAddress,
                  enabled: !verificationPending,
                ),
                if (verificationPending) ...[
                  const SizedBox(height: 12),
                  _input(
                    verificationCode,
                    'Six-digit email code',
                    Icons.verified_user_outlined,
                    keyboard: TextInputType.number,
                  ),
                ] else ...[
                  const SizedBox(height: 12),
                  _input(
                    password,
                    'Password (12+ characters for new accounts)',
                    Icons.lock_outline,
                    obscure: true,
                  ),
                ],
                if (register && !verificationPending) ...[
                  const SizedBox(height: 12),
                  _input(
                    referral,
                    'Referral code (optional)',
                    Icons.key_outlined,
                  ),
                ],
                if (!register && !verificationPending)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ForgotPasswordScreen(),
                        ),
                      ),
                      child: const Text(
                        'Forgot password?',
                        style: TextStyle(color: AppColors.gold, fontSize: 11),
                      ),
                    ),
                  ),
                if (error != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    error!,
                    style: const TextStyle(
                      color: Color(0xFFFDA4AF),
                      fontSize: 12,
                    ),
                  ),
                  if (error!.contains('Cannot reach StarGuess')) ...[
                    const SizedBox(height: 4),
                    TextButton.icon(
                      onPressed: _showServerSettings,
                      icon: const Icon(Icons.settings_ethernet, size: 14, color: AppColors.gold),
                      label: const Text(
                        'Change Server IP Address',
                        style: TextStyle(color: AppColors.gold, fontSize: 12),
                      ),
                    ),
                  ],
                ],
                if (verificationPending)
                  TextButton(
                    onPressed: busy
                        ? null
                        : () async {
                            try {
                              final res = await AppStoreScope.of(
                                context,
                              ).sendVerificationCode(email.text);
                              if (mounted) {
                                setState(() {
                                  if (res['debug_code'] != null) {
                                    verificationCode.text =
                                        res['debug_code'].toString();
                                    error =
                                        'Verification code: ${res['debug_code']}';
                                  } else {
                                    error =
                                        'If this email needs verification, a new code was sent.';
                                  }
                                });
                              }
                            } catch (e) {
                              if (mounted) setState(() => error = e.toString());
                            }
                          },
                    child: const Text(
                      'RESEND VERIFICATION CODE',
                      style: TextStyle(color: AppColors.gold, fontSize: 10),
                    ),
                  ),
                const SizedBox(height: 14),
                GoldButton(
                  label: verificationPending
                      ? 'VERIFY EMAIL'
                      : register
                      ? 'CREATE ACCOUNT'
                      : 'SIGN IN TO PLAY',
                  onPressed: submit,
                  icon: Icons.arrow_forward_rounded,
                  busy: busy,
                ),
                const SizedBox(height: 18),
                const Text(
                  'Secure sessions · Server verified gameplay · Audited Stars ledger',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 10),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  Widget _input(
    TextEditingController controller,
    String label,
    IconData icon, {
    String? hint,
    bool obscure = false,
    TextInputType? keyboard,
    bool enabled = true,
  }) => TextField(
    controller: controller,
    obscureText: obscure,
    keyboardType: keyboard,
    enabled: enabled,
    textInputAction: TextInputAction.next,
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, size: 18),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
    ),
  );
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Expanded(
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: selected ? AppColors.gold : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: selected ? AppColors.background : AppColors.muted,
          ),
        ),
      ),
    ),
  );
}
