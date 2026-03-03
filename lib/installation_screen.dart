import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:kiosk/theme/futuristic_theme.dart';
import 'package:kiosk/providers/system_provider.dart';

class InstallationScreen extends StatefulWidget {
  const InstallationScreen({super.key});

  @override
  State<InstallationScreen> createState() => _InstallationScreenState();
}

class _InstallationScreenState extends State<InstallationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _unitController = TextEditingController(text: '342 COY ASC (SUP) Type D');
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePass = true;

  Future<void> _completeInstallation() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        await context.read<SystemProvider>().saveSettings(
          unitName: _unitController.text.trim(),
          adminPassword: _passController.text.trim(),
        );
        // Navigation will be handled by the Consumer in main.dart
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.5,
                  colors: [
                    FuturisticTheme.bgBlueMid,
                    FuturisticTheme.bgBlueDark,
                    Colors.black,
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(child: CustomPaint(painter: GridPainter())),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: GlassmorphicContainer(
                width: 500,
                height: 650,
                borderRadius: 24,
                blur: 20,
                alignment: Alignment.center,
                border: 2,
                linearGradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.white.withOpacity(0.05),
                  ],
                ),
                borderGradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    FuturisticTheme.primaryBlue.withOpacity(0.5),
                    Colors.white.withOpacity(0.1),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.settings_suggest_rounded,
                          size: 64,
                          color: FuturisticTheme.primaryBlue,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'SYSTEM INITIALIZATION',
                          style: FuturisticTheme.titleMedium.copyWith(
                            color: FuturisticTheme.primaryBlue,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Configure your kiosk details',
                          style: FuturisticTheme.body.copyWith(fontSize: 14),
                        ),
                        const SizedBox(height: 48),
                        
                        // Unit Name Field
                        _buildTextField(
                          controller: _unitController,
                          label: 'UNIT NAME / LOCATION',
                          icon: Icons.business_rounded,
                          validator: (v) => v == null || v.isEmpty ? 'Unit name is required' : null,
                        ),
                        const SizedBox(height: 24),

                        // Admin Password Field
                        _buildTextField(
                          controller: _passController,
                          label: 'ADMIN PASSWORD',
                          icon: Icons.lock_outline_rounded,
                          obscureText: _obscurePass,
                          toggleObscure: () => setState(() => _obscurePass = !_obscurePass),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Password is required';
                            if (v.length < 6) return 'Minimum 6 characters';
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Confirm Password Field
                        _buildTextField(
                          controller: _confirmPassController,
                          label: 'CONFIRM PASSWORD',
                          icon: Icons.lock_reset_rounded,
                          obscureText: _obscurePass,
                          validator: (v) {
                            if (v != _passController.text) return 'Passwords do not match';
                            return null;
                          },
                        ),
                        const SizedBox(height: 48),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: FuturisticTheme.primaryBlue,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 8,
                              shadowColor: FuturisticTheme.primaryBlue.withOpacity(0.4),
                            ),
                            onPressed: _isLoading ? null : _completeInstallation,
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.black)
                                : Text(
                                    'FINALIZE SETUP',
                                    style: FuturisticTheme.buttonTextBlue.copyWith(
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    VoidCallback? toggleObscure,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: FuturisticTheme.body.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: FuturisticTheme.primaryBlue.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          cursorColor: FuturisticTheme.primaryBlue,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: FuturisticTheme.primaryBlue.withOpacity(0.6), size: 20),
            suffixIcon: toggleObscure != null
                ? IconButton(
                    icon: Icon(
                      obscureText ? Icons.visibility_off : Icons.visibility,
                      color: Colors.white38,
                    ),
                    onPressed: toggleObscure,
                  )
                : null,
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: FuturisticTheme.primaryBlue, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }
}
