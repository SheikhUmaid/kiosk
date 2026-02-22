import 'package:flutter/material.dart';
import 'admin_theme.dart';

class ChangePwdPage extends StatefulWidget {
  const ChangePwdPage({super.key});

  @override
  State<ChangePwdPage> createState() => _ChangePwdPageState();
}

class _ChangePwdPageState extends State<ChangePwdPage> {
  final _formKey = GlobalKey<FormState>();
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Security Settings', style: AdminTheme.sectionTitle),
          const SizedBox(height: 8),
          Text('अपना एडमिन पासवर्ड अपडेट करें', style: AdminTheme.caption),
          const SizedBox(height: 24),
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              padding: const EdgeInsets.all(32),
              decoration: AdminTheme.card(),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.lock_reset_rounded,
                          color: AdminTheme.primary,
                          size: 28,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Update Password',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AdminTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      obscureText: _obscureOld,
                      decoration:
                          AdminTheme.inputDecor(
                            'Current Password',
                            icon: Icons.lock_outline,
                          ).copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureOld
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                size: 20,
                                color: AdminTheme.textMuted,
                              ),
                              onPressed: () =>
                                  setState(() => _obscureOld = !_obscureOld),
                            ),
                          ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      obscureText: _obscureNew,
                      decoration:
                          AdminTheme.inputDecor(
                            'New Password',
                            icon: Icons.vpn_key_outlined,
                          ).copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureNew
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                size: 20,
                                color: AdminTheme.textMuted,
                              ),
                              onPressed: () =>
                                  setState(() => _obscureNew = !_obscureNew),
                            ),
                          ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      obscureText: _obscureConfirm,
                      decoration:
                          AdminTheme.inputDecor(
                            'Confirm New Password',
                            icon: Icons.verified_user_outlined,
                          ).copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirm
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                size: 20,
                                color: AdminTheme.textMuted,
                              ),
                              onPressed: () => setState(
                                () => _obscureConfirm = !_obscureConfirm,
                              ),
                            ),
                          ),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Password updated successfully'),
                                backgroundColor: AdminTheme.success,
                              ),
                            );
                          }
                        },
                        style: AdminTheme.primaryButton,
                        child: const Text('UPDATE PASSWORD'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Center(
                      child: Text(
                        'Ensure your password is at least 8 characters long.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AdminTheme.textMuted,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
