import 'dart:async';
import 'dart:io';

import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:kiosk/main.dart';
import 'package:kiosk/theme/futuristic_theme.dart';
import 'package:path_provider/path_provider.dart';

class TakeSelfiePage extends StatefulWidget {
  const TakeSelfiePage({super.key});

  @override
  State<TakeSelfiePage> createState() => _TakeSelfiePageState();
}

class _TakeSelfiePageState extends State<TakeSelfiePage>
    with TickerProviderStateMixin {
  int _cameraId = -1;
  List<CameraDescription>? _cameras;

  // State
  bool _isCameraInitialized = false;
  bool _isCameraError = false;
  String _errorMessage = '';

  // Captured photo
  XFile? _capturedImage;

  // Animations
  late AnimationController _scanController;
  late Animation<double> _scanAnimation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _entranceController;
  late Animation<double> _entranceFade;
  late Animation<Offset> _entranceSlide;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initializeCamera();
  }

  void _initAnimations() {
    // Scan line
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _scanAnimation = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanController, curve: Curves.easeInOut),
    );

    // Pulse on capture button
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Entrance
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _entranceFade = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );
    _entranceSlide =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: Curves.easeOutCubic,
          ),
        );
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await CameraPlatform.instance.availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        throw Exception('No cameras available');
      }

      // Use the first available camera (usually front-facing)
      final camera = _cameras![0];
      
      const mediaSettings = MediaSettings(
        resolutionPreset: ResolutionPreset.medium,
        fps: 15,
        videoBitrate: 200000,
        audioBitrate: 32000,
        enableAudio: false,
      );

      _cameraId = await CameraPlatform.instance.createCameraWithSettings(
        camera,
        mediaSettings,
      );

      await CameraPlatform.instance.initializeCamera(_cameraId);
      // Give the camera a moment to warm up
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;

      setState(() => _isCameraInitialized = true);
      _entranceController.forward();
    } catch (e) {
      debugPrint('Camera init error: $e');
      if (mounted) {
        setState(() {
          _isCameraError = true;
          _errorMessage = e.toString();
        });
        _entranceController.forward();
      }
    }
  }

  Future<void> _captureImage() async {
    try {
      if (_cameraId < 0) {
        return;
      }
      final XFile image = await CameraPlatform.instance.takePicture(_cameraId);
      if (!mounted) return;
      setState(() {
        _capturedImage = image;
      });
    } catch (e) {
      debugPrint('Capture error: $e');
    }
  }

  void _retake() {
    setState(() {
      _capturedImage = null;
    });
  }

  Future<void> _submit() async {
    final image = _capturedImage;
    if (image == null) return;

    try {
      final directory = await getApplicationDocumentsDirectory();
      final String fileName =
          'Kiosk_Selfie_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String filePath = '${directory.path}/$fileName';

      // Copy the captured image to the desired location
      await File(image.path).copy(filePath);
      debugPrint('Selfie saved to $filePath');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Photo saved: $fileName'),
            backgroundColor: FuturisticTheme.primaryBlue,
            duration: const Duration(seconds: 2),
          ),
        );
      }

      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const KioskLanding(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 500),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint('Save error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save photo'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Skip selfie — just go back to landing
  void _skip() {
    // Navigate — dispose() will call dispose on controller once the widget is removed
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const KioskLanding(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
      (route) => false,
    );
  }

  @override
  void dispose() {
    if (_cameraId >= 0) {
      CameraPlatform.instance.dispose(_cameraId);
    }
    _scanController.dispose();
    _pulseController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLandscape = size.width > size.height;

    return Scaffold(
      backgroundColor: FuturisticTheme.bgBlueDark,
      body: Stack(
        children: [
          // Grid Background
          Positioned.fill(child: CustomPaint(painter: GridPainter())),

          // Loading state
          if (!_isCameraInitialized && !_isCameraError)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    color: FuturisticTheme.primaryBlue,
                    strokeWidth: 2,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'INITIALIZING CAMERA...',
                    style: FuturisticTheme.body.copyWith(
                      color: FuturisticTheme.primaryBlue,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'कैमरा प्रारंभ हो रहा है...',
                    style: FuturisticTheme.body.copyWith(color: Colors.white54),
                  ),
                ],
              ),
            ),

          // Error state
          if (_isCameraError)
            FadeTransition(
              opacity: _entranceFade,
              child: _buildErrorState(size, isLandscape),
            ),

          // Camera ready state
          if (_isCameraInitialized && !_isCameraError)
            FadeTransition(
              opacity: _entranceFade,
              child: SlideTransition(
                position: _entranceSlide,
                child: _buildCameraUI(size, isLandscape),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCameraUI(Size size, bool isLandscape) {
    final previewWidth = isLandscape ? size.height * 0.65 : size.width * 0.85;
    final previewHeight = previewWidth * 0.75; // 4:3 ratio

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Title
            Text(
              _capturedImage == null ? 'CAPTURE PHOTO' : 'CONFIRM PHOTO',
              style: FuturisticTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              _capturedImage == null
                  ? 'कृपया अपनी फोटो लें'
                  : 'कृपया फोटो की पुष्टि करें',
              style: FuturisticTheme.body.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 24),

            // Camera Frame
            Container(
              width: previewWidth,
              height: previewHeight,
              decoration: BoxDecoration(
                border: Border.all(
                  color: FuturisticTheme.primaryBlue.withOpacity(0.4),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: FuturisticTheme.primaryBlue.withOpacity(0.12),
                    blurRadius: 30,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Preview / Captured image
                    _buildPreviewContent(),

                    // Scanning overlay (preview only)
                    if (_capturedImage == null)
                      AnimatedBuilder(
                        animation: _scanAnimation,
                        builder: (context, _) => CustomPaint(
                          painter: ScannerPainter(
                            progress: _scanAnimation.value,
                            color: FuturisticTheme.primaryBlue,
                          ),
                        ),
                      ),

                    // Corner brackets
                    CustomPaint(
                      painter: CornerBracketPainter(
                        color: FuturisticTheme.primaryBlue,
                      ),
                    ),

                    // "LIVE" badge
                    if (_capturedImage == null)
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'LIVE',
                                style: FuturisticTheme.body.copyWith(
                                  fontSize: 11,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 36),

            // Controls
            if (_capturedImage == null)
              _buildCaptureButton()
            else
              _buildConfirmButtons(),

            const SizedBox(height: 20),

            // Skip button
            TextButton(
              onPressed: _skip,
              child: Text(
                'SKIP / छोड़ें',
                style: FuturisticTheme.body.copyWith(
                  color: Colors.white38,
                  fontSize: 13,
                  letterSpacing: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewContent() {
    if (_capturedImage != null) {
      return Image.file(
        File(_capturedImage!.path),
        fit: BoxFit.cover,
      );
    }

    if (_isCameraInitialized && _cameraId >= 0) {
      return CameraPlatform.instance.buildPreview(_cameraId);
    }

    // Show placeholder while waiting for camera initialization
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.camera_alt_outlined,
              color: FuturisticTheme.primaryBlue.withOpacity(0.4),
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              'LOADING PREVIEW...',
              style: FuturisticTheme.body.copyWith(
                color: Colors.white24,
                fontSize: 12,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaptureButton() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) =>
          Transform.scale(scale: _pulseAnimation.value, child: child),
      child: GestureDetector(
        onTap: _captureImage,
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: FuturisticTheme.primaryBlue, width: 4),
            boxShadow: [
              BoxShadow(
                color: FuturisticTheme.primaryBlue.withOpacity(0.5),
                blurRadius: 24,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Container(
            margin: const EdgeInsets.all(5),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmButtons() {
    return Row(
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
            child: Text('RETAKE / फिर से', style: FuturisticTheme.body),
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
                FuturisticTheme.primaryBlue.withOpacity(0.3),
                FuturisticTheme.primaryBlue.withOpacity(0.1),
              ],
            ),
            borderGradient: LinearGradient(
              colors: [
                FuturisticTheme.primaryBlue,
                FuturisticTheme.primaryBlue.withOpacity(0.5),
              ],
            ),
            child: Text(
              'SUBMIT / जमा करें',
              style: FuturisticTheme.buttonText.copyWith(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(Size size, bool isLandscape) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GlassmorphicContainer(
              width: 120,
              height: 120,
              borderRadius: 60,
              blur: 20,
              alignment: Alignment.center,
              border: 2,
              linearGradient: LinearGradient(
                colors: [
                  Colors.red.withOpacity(0.2),
                  Colors.red.withOpacity(0.05),
                ],
              ),
              borderGradient: LinearGradient(
                colors: [
                  Colors.red.withOpacity(0.6),
                  Colors.red.withOpacity(0.2),
                ],
              ),
              child: const Icon(
                Icons.no_photography_outlined,
                color: Colors.redAccent,
                size: 52,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'CAMERA UNAVAILABLE',
              style: FuturisticTheme.titleMedium.copyWith(
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'कैमरा उपलब्ध नहीं है',
              style: FuturisticTheme.body.copyWith(color: Colors.white54),
            ),
            const SizedBox(height: 40),
            GestureDetector(
              onTap: _skip,
              child: GlassmorphicContainer(
                width: 220,
                height: 55,
                borderRadius: 28,
                blur: 20,
                alignment: Alignment.center,
                border: 2,
                linearGradient: LinearGradient(
                  colors: [
                    FuturisticTheme.primaryBlue.withOpacity(0.2),
                    FuturisticTheme.primaryBlue.withOpacity(0.05),
                  ],
                ),
                borderGradient: LinearGradient(
                  colors: [
                    FuturisticTheme.primaryBlue,
                    FuturisticTheme.primaryBlue.withOpacity(0.4),
                  ],
                ),
                child: Text(
                  'CONTINUE / जारी रखें',
                  style: FuturisticTheme.buttonText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Painters
// ─────────────────────────────────────────────────────────

class ScannerPainter extends CustomPainter {
  final double progress;
  final Color color;

  ScannerPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final y = (progress + 1) / 2 * size.height;
    if (y < 0 || y > size.height) return;

    final linePaint = Paint()
      ..color = color.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);

    final glowPaint = Paint()
      ..color = color.withOpacity(0.15)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawRect(Rect.fromLTWH(0, y - 4, size.width, 8), glowPaint);
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
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const length = 28.0;

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
