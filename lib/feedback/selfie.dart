import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:kiosk/theme/futuristic_theme.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:path_provider/path_provider.dart';
import 'package:kiosk/main.dart'; // For navigation

class TakeSelfiePage extends StatefulWidget {
  const TakeSelfiePage({super.key});

  @override
  State<TakeSelfiePage> createState() => _TakeSelfiePageState();
}

class _TakeSelfiePageState extends State<TakeSelfiePage>
    with TickerProviderStateMixin {
  CameraController? _controller;
  XFile? _imageFile;
  bool _isCameraInitialized = false;

  // Animations
  late AnimationController _scanController;
  late Animation<double> _scanAnimation;

  @override
  void initState() {
    super.initState();
    _initializeCamera();

    // Scan line animation
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _scanAnimation = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanController, curve: Curves.easeInOut),
    );
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      debugPrint("No cameras found");
      return;
    }

    for (var camera in cameras) {
      print("Name: ${camera.name}");
      print("Lens: ${camera.lensDirection}");
      print("Sensor: ${camera.sensorOrientation}");
    }
    // Default to front camera if available, else first
    final firstCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _controller = CameraController(
      firstCamera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    await _controller!.initialize();
    if (mounted) {
      setState(() {
        _isCameraInitialized = true;
      });
    }
  }

  Future<void> _captureImage() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (_controller!.value.isTakingPicture) return;

    try {
      final XFile file = await _controller!.takePicture();
      setState(() {
        _imageFile = file;
      });
    } catch (e) {
      print(e);
    }
  }

  void _retake() {
    setState(() {
      _imageFile = null;
    });
  }

  void _submit() async {
    if (_imageFile == null) return;

    try {
      // Get the Application Documents directory
      final directory = await getApplicationDocumentsDirectory();
      final String path = directory.path;
      final String fileName =
          'Kiosk_Selfie_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String newPath = '$path/$fileName';

      // Copy the file to the new path
      await File(_imageFile!.path).copy(newPath);
      print('Image saved to $newPath');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image Saved to $newPath'),
            backgroundColor: FuturisticTheme.primaryGold,
            duration: const Duration(seconds: 2),
          ),
        );
      }

      // Wait for snackbar
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const KioskLanding(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
          ),
          (route) => false,
        );
      }
    } catch (e) {
      print('Error saving image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save image'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized) {
      return const Scaffold(
        backgroundColor: FuturisticTheme.bgDark,
        body: Center(
          child: CircularProgressIndicator(color: FuturisticTheme.primaryGold),
        ),
      );
    }

    final size = MediaQuery.of(context).size;
    final isLandscape = size.width > size.height;

    return Scaffold(
      backgroundColor: FuturisticTheme.bgDark,
      body: Stack(
        children: [
          // Grid Background
          Positioned.fill(child: CustomPaint(painter: GridPainter())),

          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _imageFile == null ? 'CAPTURE PHOTO' : 'CONFIRM PHOTO',
                    style: FuturisticTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _imageFile == null
                        ? 'कृपया अपनी फोटो लें'
                        : 'कृपया फोटो की पुष्टि करें',
                    style: FuturisticTheme.body.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 30),

                  // Camera Preview Frame
                  Container(
                    width: isLandscape ? size.height * 0.6 : size.width * 0.8,
                    height: isLandscape
                        ? size.height * 0.6
                        : size.width * 0.8 * 1.33,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: FuturisticTheme.primaryGold.withOpacity(0.3),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: FuturisticTheme.primaryGold.withOpacity(0.1),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(19),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // The actual camera/image
                          _imageFile != null
                              ? Image.file(
                                  File(_imageFile!.path),
                                  fit: BoxFit.cover,
                                )
                              : CameraPreview(_controller!),

                          // Scanning overlay
                          if (_imageFile == null)
                            AnimatedBuilder(
                              animation: _scanAnimation,
                              builder: (context, child) {
                                return CustomPaint(
                                  painter: ScannerPainter(
                                    progress: _scanAnimation.value,
                                    color: FuturisticTheme.primaryGold,
                                  ),
                                );
                              },
                            ),

                          // Corner Brackets
                          CustomPaint(
                            painter: CornerBracketPainter(
                              color: FuturisticTheme.primaryGold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Controls
                  if (_imageFile == null)
                    GestureDetector(
                      onTap: _captureImage,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: FuturisticTheme.primaryGold,
                            width: 4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: FuturisticTheme.primaryGold.withOpacity(
                                0.5,
                              ),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Retake
                        GestureDetector(
                          onTap: _retake,
                          child: GlassmorphicContainer(
                            width: 160,
                            height: 50,
                            borderRadius: 25,
                            blur: 20,
                            alignment: Alignment.center,
                            border: 2,
                            linearGradient: LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.1),
                                Colors.white.withOpacity(0.01),
                              ],
                            ),
                            borderGradient: LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.5),
                                Colors.white.withOpacity(0.1),
                              ],
                            ),
                            child: Text(
                              'RETAKE / फिर से',
                              style: FuturisticTheme.body,
                            ),
                          ),
                        ),
                        const SizedBox(width: 30),
                        // Submit
                        GestureDetector(
                          onTap: _submit,
                          child: GlassmorphicContainer(
                            width: 160,
                            height: 50,
                            borderRadius: 25,
                            blur: 20,
                            alignment: Alignment.center,
                            border: 2,
                            linearGradient: LinearGradient(
                              colors: [
                                FuturisticTheme.primaryGold.withOpacity(0.3),
                                FuturisticTheme.primaryGold.withOpacity(0.1),
                              ],
                            ),
                            borderGradient: LinearGradient(
                              colors: [
                                FuturisticTheme.primaryGold,
                                FuturisticTheme.primaryGold.withOpacity(0.5),
                              ],
                            ),
                            child: Text(
                              'SUBMIT / जमा करें',
                              style: FuturisticTheme.buttonText.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
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

class ScannerPainter extends CustomPainter {
  final double progress;
  final Color color;

  ScannerPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final y = (progress + 1) / 2 * size.height; // Map -1..1 to 0..height

    if (y >= 0 && y <= size.height) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);

      // Glow
      final glowPaint = Paint()
        ..color = color.withOpacity(0.2)
        ..style = PaintingStyle.fill
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawRect(Rect.fromLTWH(0, y - 2, size.width, 4), glowPaint);
    }
  }

  @override
  bool shouldRepaint(ScannerPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class CornerBracketPainter extends CustomPainter {
  final Color color;
  CornerBracketPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final length = 30.0;

    // Top Left
    canvas.drawPath(
      Path()
        ..moveTo(0, length)
        ..lineTo(0, 0)
        ..lineTo(length, 0),
      paint,
    );
    // Top Right
    canvas.drawPath(
      Path()
        ..moveTo(size.width - length, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width, length),
      paint,
    );
    // Bottom Right
    canvas.drawPath(
      Path()
        ..moveTo(size.width, size.height - length)
        ..lineTo(size.width, size.height)
        ..lineTo(size.width - length, size.height),
      paint,
    );
    // Bottom Left
    canvas.drawPath(
      Path()
        ..moveTo(length, size.height)
        ..lineTo(0, size.height)
        ..lineTo(0, size.height - length),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
