import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:kiosk/theme/futuristic_theme.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:kiosk/feedback/details.dart'; // Ensure correct navigation

class FeedBackHome extends StatefulWidget {
  const FeedBackHome({super.key});

  @override
  State<FeedBackHome> createState() => _FeedBackHomeState();
}

class _FeedBackHomeState extends State<FeedBackHome>
    with TickerProviderStateMixin {
  // Floating / idle bob animation
  late AnimationController _floatController;
  // Bounce on tap
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;
  int _bouncingIndex = -1;
  // Shimmer on question
  late AnimationController _shimmerController;
  // Gradient shift on submit button
  late AnimationController _gradientController;
  // Thank-you celebration
  late AnimationController _celebrationController;
  late Animation<double> _celebrationScale;
  late Animation<double> _celebrationRotate;
  int _currentQuestion = 0;
  bool _submitted = false;

  // Stores chosen emoji index for each question
  final Map<int, int> _answers = {};

  late AnimationController _entranceController;
  late Animation<double> _titleFade;
  late Animation<Offset> _titleSlide;

  late List<AnimationController> _emojiControllers;
  late List<Animation<double>> _emojiScales;
  late List<Animation<double>> _emojiFades;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  late AnimationController _submitController;
  late Animation<double> _submitScale;

  late AnimationController _transitionController;

  // Star burst animation per emoji
  late List<AnimationController> _starControllers;
  late List<Animation<double>> _starAnimations;

  final List<String> _questions = const [
    'HOW WAS OUR SERVICE?',
    'WAS THE STAFF HELPFUL?',
    'FACILITY CONDITION?',
    'WAITING TIME?',
    'VISIT AGAIN?',
  ];

  final List<String> _questionsHindi = const [
    'हमारी सेवा कैसी रही?',
    'कर्मचारियों का व्यवहार कैसा था?',
    'सुविधाओं की स्थिति कैसी थी?',
    'प्रतीक्षा समय कैसा था?',
    'क्या आप दोबारा यहाँ आना चाहेंगे?',
  ];

  final List<_FeedbackOption> _options = const [
    _FeedbackOption(
      asset: 'assets/emojis/em_angry.png',
      label: 'VERY BAD',
      value: 1,
    ),
    _FeedbackOption(asset: 'assets/emojis/em_sad.png', label: 'BAD', value: 2),
    _FeedbackOption(
      asset: 'assets/emojis/em_neutral.png',
      label: 'OKAY',
      value: 3,
    ),
    _FeedbackOption(
      asset: 'assets/emojis/em_happy.png',
      label: 'GOOD',
      value: 4,
    ),
    _FeedbackOption(
      asset: 'assets/emojis/em_excellent.png',
      label: 'EXCELLENT',
      value: 5,
    ),
  ];

  // Star colors per emoji level - Neon versions
  static const List<Color> _starColors = [
    Color(0xFFFF3D00), // Red Neon
    Color(0xFFFF9100), // Orange Neon
    Color(0xFFFFEA00), // Yellow Neon
    Color(0xFF00E676), // Green Neon
    Color(0xFFFFD700), // Gold Neon
  ];

  bool get _isLastQuestion => _currentQuestion == _questions.length - 1;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startEntrance();
  }

  void _initAnimations() {
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _titleFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );
    _titleSlide = Tween<Offset>(begin: const Offset(0, -0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
          ),
        );

    _emojiControllers = List.generate(5, (i) {
      return AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      );
    });

    _emojiScales = _emojiControllers.map((c) {
      return CurvedAnimation(
        parent: c,
        curve: Curves.elasticOut,
      ).drive(Tween(begin: 0.0, end: 1.0));
    }).toList();

    _emojiFades = _emojiControllers.map((c) {
      return CurvedAnimation(
        parent: c,
        curve: Curves.easeIn,
      ).drive(Tween(begin: 0.0, end: 1.0));
    }).toList();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _submitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _submitScale = CurvedAnimation(
      parent: _submitController,
      curve: Curves.elasticOut,
    ).drive(Tween(begin: 0.0, end: 1.0));

    _transitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _starControllers = List.generate(5, (i) {
      return AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 700),
      );
    });
    _starAnimations = _starControllers.map((c) {
      return CurvedAnimation(
        parent: c,
        curve: Curves.easeOut,
      ).drive(Tween(begin: 0.0, end: 1.0));
    }).toList();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _bounceAnimation =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.35), weight: 30),
          TweenSequenceItem(tween: Tween(begin: 1.35, end: 0.85), weight: 25),
          TweenSequenceItem(tween: Tween(begin: 0.85, end: 1.1), weight: 25),
          TweenSequenceItem(tween: Tween(begin: 1.1, end: 1.0), weight: 20),
        ]).animate(
          CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
        );

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _celebrationScale =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.2), weight: 50),
          TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 50),
        ]).animate(
          CurvedAnimation(
            parent: _celebrationController,
            curve: Curves.easeOutBack,
          ),
        );
    _celebrationRotate =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: -0.05, end: 0.05), weight: 50),
          TweenSequenceItem(tween: Tween(begin: 0.05, end: 0.0), weight: 50),
        ]).animate(
          CurvedAnimation(
            parent: _celebrationController,
            curve: Curves.easeInOut,
          ),
        );
  }

  void _startEntrance() async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    _entranceController.forward();

    for (int i = 0; i < _emojiControllers.length; i++) {
      await Future.delayed(const Duration(milliseconds: 120));
      if (!mounted) return;
      _emojiControllers[i].forward();
    }
  }

  void _replayEmojiEntrance() async {
    for (var c in _emojiControllers) {
      c.reset();
    }
    for (var c in _starControllers) {
      c.reset();
    }
    for (int i = 0; i < _emojiControllers.length; i++) {
      await Future.delayed(const Duration(milliseconds: 80));
      if (!mounted) return;
      _emojiControllers[i].forward();
    }
  }

  void _onSelect(int index) {
    if (_submitted) return;

    setState(() {
      _answers[_currentQuestion] = index;
      _bouncingIndex = index;
    });

    _bounceController.reset();
    _bounceController.forward().then((_) {
      if (mounted) setState(() => _bouncingIndex = -1);
    });

    for (var c in _starControllers) {
      c.reset();
    }
    _starControllers[index].forward();

    _pulseController.stop();
    _pulseController.reset();
    _pulseController.repeat(reverse: true);

    if (_isLastQuestion) {
      _submitController.forward();
    } else {
      Future.delayed(const Duration(milliseconds: 650), () {
        if (!mounted) return;
        _advanceToNextQuestion();
      });
    }
  }

  void _advanceToNextQuestion() {
    _pulseController.stop();
    _pulseController.reset();

    setState(() {
      _currentQuestion++;
    });

    _transitionController.reset();
    _transitionController.forward();
    _replayEmojiEntrance();
  }

  void _onSubmit() {
    if (!_answers.containsKey(_currentQuestion)) return;

    // Proceed to Details Page (Name input)
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const FeedBackDetails(), // We need to import details
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );

    // Note: Logic has changed from "Thank You" to "Details".
    // If the user wants Thank You first, we can do that, but usually details come before or after.
    // The previous code had _submitted = true showing Thank You immediately.
    // But Step 111 Impl Plan says "Details Form" is next.
    // I'll stick to the original flow: Show Thank You here if it was final submit?
    // Actually the previous code didn't navigate to Details.
    // Wait, the User Objective in Step 1 was "Feedback -> Details".
    // I'll make sure to navigate to Details on submit.
    // But currently `details.dart` exists.
    // I'll assume `_onSubmit` navigates to `FeedBackDetails`.
  }

  void _submitData() {
    // This is the actual final submit after Details.
    // But here in Home, we just collect answers.
    // I'll change _onSubmit to navigate.
  }

  void _resetAll() {
    setState(() {
      _submitted = false;
      _currentQuestion = 0;
      _answers.clear();
    });
    _submitController.reset();
    _transitionController.reset();
    for (var c in _emojiControllers) {
      c.reset();
    }
    for (var c in _starControllers) {
      c.reset();
    }
    _entranceController.reset();
    _startEntrance();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    for (var c in _emojiControllers) {
      c.dispose();
    }
    for (var c in _starControllers) {
      c.dispose();
    }
    _pulseController.dispose();
    _submitController.dispose();
    _transitionController.dispose();
    _floatController.dispose();
    _bounceController.dispose();
    _shimmerController.dispose();
    _gradientController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLandscape = size.width > size.height;
    final emojiSize = isLandscape ? size.height * 0.22 : size.width * 0.16;

    return Scaffold(
      backgroundColor: FuturisticTheme.bgDark,
      body: Stack(
        children: [
          // Grid Background
          Positioned.fill(child: CustomPaint(painter: GridPainter())),

          SafeArea(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.05),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: _buildForm(size, emojiSize, isLandscape),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(Size size, double emojiSize, bool isLandscape) {
    final selectedForCurrent = _answers[_currentQuestion];

    return Center(
      key: const ValueKey('form'),
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.05,
          vertical: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SlideTransition(
              position: _titleSlide,
              child: FadeTransition(
                opacity: _titleFade,
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 4,
                      decoration: BoxDecoration(
                        color: FuturisticTheme.primaryGold,
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: const [
                          BoxShadow(
                            color: FuturisticTheme.primaryGold,
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'YOUR FEEDBACK MATTERS',
                      textAlign: TextAlign.center,
                      style: FuturisticTheme.titleMedium,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'आपकी राय महत्वपूर्ण है',
                      textAlign: TextAlign.center,
                      style: FuturisticTheme.body.copyWith(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            _buildProgressBar(isLandscape),
            SizedBox(height: isLandscape ? 30 : 24),

            // Question text
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              child: GlassmorphicContainer(
                key: ValueKey('q_$_currentQuestion'),
                width: isLandscape ? size.width * 0.6 : size.width * 0.9,
                height: 120,
                borderRadius: 20,
                blur: 20,
                alignment: Alignment.center,
                border: 2,
                linearGradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.05),
                    Colors.white.withOpacity(0.01),
                  ],
                ),
                borderGradient: LinearGradient(
                  colors: [
                    FuturisticTheme.primaryGold.withOpacity(0.5),
                    Colors.white.withOpacity(0.1),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _questions[_currentQuestion],
                      textAlign: TextAlign.center,
                      style: FuturisticTheme.titleMedium.copyWith(fontSize: 28),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _questionsHindi[_currentQuestion],
                      textAlign: TextAlign.center,
                      style: FuturisticTheme.body.copyWith(
                        fontSize: 20,
                        color: FuturisticTheme.primaryGold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: isLandscape ? 40 : 32),

            // Emoji options
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_options.length, (index) {
                return _buildEmojiOption(
                  index: index,
                  option: _options[index],
                  emojiSize: emojiSize,
                  isSelected: selectedForCurrent == index,
                );
              }),
            ),

            const SizedBox(height: 40),

            // Submit Button
            if (_isLastQuestion)
              ScaleTransition(
                scale: _submitScale,
                child: AnimatedOpacity(
                  opacity: selectedForCurrent != null ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: GestureDetector(
                    onTap: selectedForCurrent != null ? _onSubmit : null,
                    child: GlassmorphicContainer(
                      width: 250,
                      height: 60,
                      borderRadius: 30,
                      blur: 20,
                      alignment: Alignment.center,
                      border: 2,
                      linearGradient: LinearGradient(
                        colors: [
                          FuturisticTheme.primaryGold.withOpacity(0.2),
                          FuturisticTheme.primaryGold.withOpacity(0.05),
                        ],
                      ),
                      borderGradient: LinearGradient(
                        colors: [
                          FuturisticTheme.primaryGold,
                          FuturisticTheme.primaryGold.withOpacity(0.5),
                        ],
                      ),
                      child: Text(
                        'SUBMIT / सबमिट',
                        style: FuturisticTheme.buttonText,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(bool isLandscape) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_questions.length, (i) {
        final isCompleted = _answers.containsKey(i);
        final isCurrent = i == _currentQuestion;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            width: isCurrent ? 40 : 12,
            height: 6,
            decoration: BoxDecoration(
              color: isCurrent
                  ? FuturisticTheme.primaryGold
                  : isCompleted
                  ? FuturisticTheme.primaryGold.withOpacity(0.5)
                  : Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(3),
              boxShadow: isCurrent
                  ? [
                      BoxShadow(
                        color: FuturisticTheme.primaryGold,
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                  : [],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildEmojiOption({
    required int index,
    required _FeedbackOption option,
    required double emojiSize,
    required bool isSelected,
  }) {
    final starColor = _starColors[index];
    final isBouncing = _bouncingIndex == index;

    return Expanded(
      child: FadeTransition(
        opacity: _emojiFades[index],
        child: ScaleTransition(
          scale: _emojiScales[index],
          child: GestureDetector(
            onTap: () => _onSelect(index),
            child: AnimatedBuilder(
              animation: Listenable.merge([
                _floatController,
                _bounceController,
              ]),
              builder: (context, _) {
                final floatOffset =
                    math.sin(
                      (_floatController.value * 2 * math.pi) + (index * 0.8),
                    ) *
                    4.0;

                final bounceScale = isBouncing ? _bounceAnimation.value : 1.0;

                return Transform.translate(
                  offset: Offset(0, floatOffset),
                  child: Transform.scale(
                    scale: bounceScale * (isSelected ? 1.1 : 1.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? Colors.white.withOpacity(0.1)
                                : Colors.transparent,
                            border: Border.all(
                              color: isSelected
                                  ? starColor
                                  : Colors.transparent,
                              width: 2,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: starColor.withOpacity(0.5),
                                      blurRadius: 20,
                                      spreadRadius: 2,
                                    ),
                                  ]
                                : [],
                          ),
                          child: Image.asset(
                            option.asset,
                            width: emojiSize,
                            height: emojiSize,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          option.label,
                          style: FuturisticTheme.body.copyWith(
                            fontSize: 12,
                            color: isSelected ? starColor : Colors.white70,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _FeedbackOption {
  final String asset;
  final String label;
  final int value;

  const _FeedbackOption({
    required this.asset,
    required this.label,
    required this.value,
  });
}

// Background Grid

// Star Burst Painter (Simplified for futuristic look)
class _StarBurstPainter extends CustomPainter {
  final double progress;
  final Color color;
  final int starCount;

  _StarBurstPainter({
    required this.progress,
    required this.color,
    this.starCount = 8,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0 || progress == 1) return;

    final paint = Paint()
      ..color = color.withOpacity(1.0 - progress)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final radius = progress * 60;
    canvas.drawCircle(Offset.zero, radius, paint);
  }

  @override
  bool shouldRepaint(_StarBurstPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
