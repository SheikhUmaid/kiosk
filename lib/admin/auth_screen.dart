import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:kiosk/admin/admin_theme.dart';
import 'package:kiosk/admin/home.dart';
import 'package:provider/provider.dart';
import 'package:kiosk/providers/system_provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userController = TextEditingController();
  final _passController = TextEditingController();

  bool _obscurePass = true;
  bool _isLoading = false;

  Future<void> _openZinthLabs() async {
    final Uri url = Uri.parse('https://zinthlabs.netlify.app'); // Replace with real URL
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;

      final user = _userController.text.trim();
      final pass = _passController.text.trim();

      if (user == 'admin' && await context.read<SystemProvider>().verifyAdminPassword(pass)) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const AdminHome(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Invalid username or password.'),
            backgroundColor: AdminTheme.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminTheme.bg,
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Container(
                  width: 420,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
                  decoration: AdminTheme.card(radius: 20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: const BoxDecoration(
                            color: AdminTheme.primaryXLight,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.admin_panel_settings_rounded,
                            size: 56,
                            color: AdminTheme.primary,
                          ),
                        ),
                        const SizedBox(height: 28),
                        const Text(
                          'Admin Portal',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AdminTheme.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Secure access required',
                          style: AdminTheme.caption,
                        ),
                        const SizedBox(height: 48),
                        TextFormField(
                          controller: _userController,
                          decoration: AdminTheme.inputDecor(
                            'Username',
                            icon: Icons.person_outline,
                          ),
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Enter username' : null,
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _passController,
                          obscureText: _obscurePass,
                          decoration: AdminTheme.inputDecor(
                            'Password',
                            icon: Icons.lock_outline,
                          ).copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePass
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: AdminTheme.textSecondary,
                              ),
                              onPressed: () => setState(
                                  () => _obscurePass = !_obscurePass),
                            ),
                          ),
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Enter password' : null,
                        ),
                        const SizedBox(height: 48),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            style: AdminTheme.primaryButton,
                            onPressed: _isLoading ? null : _login,
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('AUTHENTICATE'),
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextButton.icon(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back_rounded, size: 18),
                          label: const Text('Back to Kiosk'),
                          style: TextButton.styleFrom(
                            foregroundColor: AdminTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ----------- FOOTER -----------
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text.rich(
              TextSpan(
                text: 'Engineered in ',
                style: const TextStyle(
                  fontSize: 12,
                  color: AdminTheme.textSecondary,
                ),
                children: [
                  TextSpan(
                    text: 'Zinth Labs Pvt Ltd',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AdminTheme.primary,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer:
                        TapGestureRecognizer()..onTap = _openZinthLabs,
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}