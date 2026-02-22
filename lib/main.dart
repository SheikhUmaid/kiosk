import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:kiosk/admin/home.dart';
import 'package:kiosk/feedback/home.dart';
import 'package:kiosk/feedback/details.dart';
import 'package:kiosk/feedback/selfie.dart';
import 'package:kiosk/theme/futuristic_theme.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kiosk',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: FuturisticTheme.bgDark,
        primaryColor: FuturisticTheme.primaryGold,
        useMaterial3: true,
      ),
      home: const KioskLanding(),
    );
  }
}

class KioskLanding extends StatefulWidget {
  const KioskLanding({super.key});

  @override
  State<KioskLanding> createState() => _KioskLandingState();
}

class _KioskLandingState extends State<KioskLanding>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;

  // Staggered hero entrance
  late final Animation<double> _heroScale;
  late final Animation<double> _scanLine; // Scanner effect

  // media_kit player
  late final Player _player;
  late final VideoController _videoController;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _fade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    );

    // Hero video entrance
    _heroScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
      ),
    );

    _scanLine = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.linear),
      ),
    ); // We'll loop this separately if needed

    // media_kit Video player
    _player = Player();
    _videoController = VideoController(_player);

    // Open asset video — looping, muted
    _player.setPlaylistMode(PlaylistMode.loop);
    _player.setVolume(0);
    _player.open(Media('asset:///assets/emojis/logomodel.mp4'));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _player.dispose();
    super.dispose();
  }

  void _navigateTo(Widget page) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isLandscape = constraints.maxWidth > constraints.maxHeight;
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;

          return Stack(
            children: [
              // Background Elements
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 1.5,
                      colors: [
                        FuturisticTheme.bgMaroon,
                        FuturisticTheme.bgDark,
                        Colors.black,
                      ],
                      stops: [0.0, 0.6, 1.0],
                    ),
                  ),
                ),
              ),

              // Grid Overlay
              Positioned.fill(child: CustomPaint(painter: GridPainter())),

              SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isLandscape ? width * 0.08 : 24,
                    vertical: 24,
                  ),
                  child: Column(
                    children: [
                      // Top Bar - Responsive layout
                      _buildTopBar(isLandscape, width),

                      Expanded(
                        child: Center(
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(height: 20),
                                // Hero Video section with dynamic sizing
                                _buildHeroSection(isLandscape, width, height),
                                const SizedBox(height: 40),
                                // Animated Text
                                _buildWelcomeText(isLandscape, width),
                                const SizedBox(height: 10),
                                Text(
                                  'SEVA ASMAKAM DHARMA',
                                  textAlign: TextAlign.center,
                                  style: FuturisticTheme.body.copyWith(
                                    color: FuturisticTheme.primaryGold,
                                    letterSpacing: width < 400 ? 2.0 : 4.0,
                                    fontSize: width < 400 ? 12 : 16,
                                  ),
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopBar(bool isLandscape, double width) {
    final bool useVertical = width < 480;
    if (useVertical) {
      return Column(
        children: [
          FadeTransition(
            opacity: _fade,
            child: _FuturisticButton(
              icon: Icons.rate_review_outlined,
              label: 'FEEDBACK',
              sublabel: 'प्रतिक्रिया',
              onTap: () => _navigateTo(const FeedBackDetails()),
            ),
          ),
          const SizedBox(height: 12),
          FadeTransition(
            opacity: _fade,
            child: _FuturisticButton(
              icon: Icons.admin_panel_settings_outlined,
              label: 'ADMIN',
              sublabel: 'प्रशासन',
              isSecondary: true,
              onTap: () => _navigateTo(const AdminHome()),
            ),
          ),
        ],
      );
    }
    return Row(
      children: [
        Expanded(
          child: FadeTransition(
            opacity: _fade,
            child: _FuturisticButton(
              icon: Icons.rate_review_outlined,
              label: 'FEEDBACK',
              sublabel: 'प्रतिक्रिया',
              onTap: () => _navigateTo(const FeedBackDetails()),
            ),
          ),
        ),
        SizedBox(width: isLandscape ? 40 : 20),
        Expanded(
          child: FadeTransition(
            opacity: _fade,
            child: _FuturisticButton(
              icon: Icons.admin_panel_settings_outlined,
              label: 'ADMIN',
              sublabel: 'प्रशासन',
              isSecondary: true,
              onTap: () => _navigateTo(const AdminHome()),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroSection(bool isLandscape, double width, double height) {
    double baseSize = isLandscape ? height * 0.5 : width * 0.6;
    // Clamp sizes
    baseSize = baseSize.clamp(200.0, 500.0);

    return ScaleTransition(
      scale: _heroScale,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Glowing Back Plate
          Container(
            width: baseSize * 1.1,
            height: baseSize * 1.1,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: FuturisticTheme.primaryGold.withOpacity(0.2),
                  blurRadius: 60,
                  spreadRadius: 10,
                ),
              ],
            ),
          ),
          // Video Container
          ClipRRect(
            borderRadius: BorderRadius.circular(baseSize),
            child: Container(
              width: baseSize,
              height: baseSize,
              color: Colors.black,
              child: Video(
                controller: _videoController,
                controls: NoVideoControls,
                fill: Colors.black,
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Tech Ring Overlay
          SizedBox(
            width: baseSize * 1.15,
            height: baseSize * 1.15,
            child: CircularProgressIndicator(
              value: 0.7,
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                FuturisticTheme.primaryGold.withOpacity(0.3),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeText(bool isLandscape, double width) {
    double fontSize = isLandscape ? 48 : 32;
    if (width < 400) fontSize = 24;

    return SizedBox(
      height: fontSize * 2.0,
      child: DefaultTextStyle(
        style: FuturisticTheme.titleLarge.copyWith(fontSize: fontSize),
        child: AnimatedTextKit(
          animatedTexts: [
            TypewriterAnimatedText(
              'INDIAN ARMY',
              speed: const Duration(milliseconds: 150),
              cursor: '_',
              textAlign: TextAlign.center,
            ),
            TypewriterAnimatedText(
              'WELCOME',
              speed: const Duration(milliseconds: 150),
              cursor: '_',
              textAlign: TextAlign.center,
            ),
            TypewriterAnimatedText(
              'JAI HIND',
              speed: const Duration(milliseconds: 150),
              cursor: '_',
              textAlign: TextAlign.center,
            ),
          ],
          repeatForever: true,
          pause: const Duration(seconds: 2),
        ),
      ),
    );
  }
}

class _FuturisticButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final VoidCallback onTap;
  final bool isSecondary;

  const _FuturisticButton({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.onTap,
    this.isSecondary = false,
  });

  @override
  State<_FuturisticButton> createState() => _FuturisticButtonState();
}

class _FuturisticButtonState extends State<_FuturisticButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.95 : (_isHovered ? 1.02 : 1.0),
          duration: const Duration(milliseconds: 200),
          child: GlassmorphicContainer(
            width: double.infinity,
            height: 100,
            borderRadius: 20,
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
                _isHovered
                    ? FuturisticTheme.primaryGold
                    : Colors.white.withOpacity(0.5),
                Colors.white.withOpacity(0.1),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.icon,
                  size: 32,
                  color: _isHovered
                      ? FuturisticTheme.primaryGold
                      : Colors.white,
                ),
                const SizedBox(width: 20),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.label,
                      style: FuturisticTheme.buttonText.copyWith(
                        color: _isHovered
                            ? FuturisticTheme.primaryGold
                            : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.sublabel,
                      style: FuturisticTheme.body.copyWith(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}