import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kiosk/theme/futuristic_theme.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:kiosk/feedback/selfie.dart';
import 'package:provider/provider.dart';
import 'package:kiosk/providers/feedback_provider.dart';

class FeedBackRemarks extends StatefulWidget {
  const FeedBackRemarks({super.key});

  @override
  State<FeedBackRemarks> createState() => _FeedBackRemarksState();
}

class _FeedBackRemarksState extends State<FeedBackRemarks>
    with TickerProviderStateMixin {
  final _remarkController = TextEditingController();
  final _remarkFocus = FocusNode();

  FocusNode? _activeFocus;
  TextEditingController? _activeController; // Track active controller for keyboard input

  bool _isUpperCase = false;
  bool _showNumpad = false;

  late final AnimationController _entranceController;
  late final Animation<double> _headerFade;
  late final Animation<Offset> _headerSlide;
  late final AnimationController _fieldController;
  late final Animation<double> _fieldSlide;
  late final AnimationController _keyboardController;
  late final Animation<double> _keyboardSlide;

  void _navigateTo(Widget page) {
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
      (route) => false,
    );
  }

  @override
  void initState() {
    super.initState();

    // Header entrance
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _headerFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    );
    _headerSlide = Tween<Offset>(begin: const Offset(0, -0.2), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
          ),
        );

    // Field entrance
    _fieldController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fieldSlide = CurvedAnimation(
      parent: _fieldController,
      curve: Curves.easeOutCubic,
    ).drive(Tween(begin: 0.0, end: 1.0));

    // Keyboard slide up
    _keyboardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _keyboardSlide = CurvedAnimation(
      parent: _keyboardController,
      curve: Curves.easeOutCubic,
    ).drive(Tween(begin: 0.0, end: 1.0));

    // Focus listeners
    _remarkFocus.addListener(() => _onFocusChange(_remarkFocus, _remarkController));

    _startEntrance();
  }

  void _startEntrance() async {
    await Future.delayed(const Duration(milliseconds: 150));
    if (!mounted) return;
    _entranceController.forward();
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;
    _fieldController.forward();
  }

  void _onFocusChange(FocusNode focus, TextEditingController controller) {
    if (focus.hasFocus) {
      setState(() {
        _activeFocus = focus;
        _activeController = controller;
        _showNumpad = false; 
      });
      _keyboardController.forward();
    }
  }

  // Keyboard Logic
  void _onKeyTap(String key) {
    if (_activeController == null) return;
    HapticFeedback.lightImpact();

    final text = _activeController!.text;
    final selection = _activeController!.selection;
    final cursorPos = selection.isValid ? selection.baseOffset : text.length;

    // Insert key at cursor position
    final newText =
        text.substring(0, cursorPos) + key + text.substring(cursorPos);
    _activeController!.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: cursorPos + key.length),
    );
  }

  void _onBackspace() {
    if (_activeController == null) return;
    HapticFeedback.lightImpact();

    final text = _activeController!.text;
    final selection = _activeController!.selection;
    final cursorPos = selection.isValid ? selection.baseOffset : text.length;

    if (cursorPos > 0) {
      final newText =
          text.substring(0, cursorPos - 1) + text.substring(cursorPos);
      _activeController!.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: cursorPos - 1),
      );
    }
  }

  void _onSpace() => _onKeyTap(' ');

  void _toggleCase() {
    setState(() => _isUpperCase = !_isUpperCase);
    HapticFeedback.lightImpact();
  }

  void _toggleKeyboard() {
    setState(() => _showNumpad = !_showNumpad);
    HapticFeedback.lightImpact();
  }

  void _onDone() {
    _activeFocus?.unfocus();
    _keyboardController.reverse();
  }

  void _onSubmit() {
    context.read<FeedbackProvider>().setRemarks(_remarkController.text.trim());
    // Navigate immediately to next screen 
    _navigateTo(const TakeSelfiePage());
  }
  
  void _onSkip() {
    context.read<FeedbackProvider>().setRemarks('');
    // Navigate immediately to next screen
    _navigateTo(const TakeSelfiePage());
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _fieldController.dispose();
    _keyboardController.dispose();
    _remarkController.dispose();
    _remarkFocus.dispose();
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
          SafeArea(child: _buildForm(size, isLandscape)),
        ],
      ),
    );
  }

  Widget _buildForm(Size size, bool isLandscape) {
    return Column(
      key: const ValueKey('form'),
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isLandscape ? size.width * 0.15 : size.width * 0.08,
              vertical: 24,
            ),
            child: Column(
              children: [
                SlideTransition(
                  position: _headerSlide,
                  child: FadeTransition(
                    opacity: _headerFade,
                    child: Column(
                      children: [
                        Container(
                          width: 60,
                          height: 4,
                          decoration: BoxDecoration(
                            color: FuturisticTheme.primaryBlue,
                            borderRadius: BorderRadius.circular(2),
                            boxShadow: const [
                              BoxShadow(
                                color: FuturisticTheme.primaryBlue,
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'ADDITIONAL REMARKS',
                          style: FuturisticTheme.titleMedium.copyWith(
                            fontSize: 28,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'अतिरिक्त टिप्पणियाँ दें',
                          style: FuturisticTheme.body.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                _buildField(
                  controller: _remarkController,
                  focusNode: _remarkFocus,
                  label: 'REMARKS / टिप्पणियाँ',
                  hint: 'TYPE YOUR REMARKS HERE...',
                  icon: Icons.comment_outlined,
                  isLandscape: isLandscape,
                ),
                
                const SizedBox(height: 40),

                AnimatedOpacity(
                  opacity: _remarkController.text.trim().isNotEmpty ? 1.0 : 0.5,
                  duration: const Duration(milliseconds: 300),
                  child: GestureDetector(
                    onTap: _remarkController.text.trim().isNotEmpty ? _onSubmit : null,
                    child: GlassmorphicContainer(
                      width: isLandscape ? 300 : double.infinity,
                      height: 60,
                      borderRadius: 20,
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
                      child: Text('SUBMIT', style: FuturisticTheme.buttonText),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Skip Button
                GestureDetector(
                    onTap: _onSkip,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      child: Text(
                        'SKIP / छोड़ें',
                        style: FuturisticTheme.body.copyWith(
                          fontSize: 14,
                          color: Colors.white54,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Keyboard
        AnimatedBuilder(
          animation: _keyboardSlide,
          builder: (context, child) {
            return ClipRect(
              child: Align(
                alignment: Alignment.bottomCenter,
                heightFactor: _keyboardSlide.value,
                child: child,
              ),
            );
          },
          child: _buildKeyboard(size, isLandscape),
        ),
      ],
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required IconData icon,
    required bool isLandscape,
  }) {
    final isFocused = _activeFocus == focusNode;

    return FadeTransition(
      opacity: _fieldSlide,
      child: GestureDetector(
        onTap: () => focusNode.requestFocus(),
        child: GlassmorphicContainer(
          width: double.infinity,
          height: isLandscape ? 120 : 160,
          borderRadius: 20,
          blur: 10,
          alignment: Alignment.center,
          border: 2,
          linearGradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.05),
              Colors.white.withOpacity(0.01),
            ],
          ),
          borderGradient: LinearGradient(
            colors: isFocused
                ? [
                    FuturisticTheme.primaryBlue,
                    FuturisticTheme.primaryBlue.withOpacity(0.5),
                  ]
                : [
                    Colors.white.withOpacity(0.1),
                    Colors.white.withOpacity(0.05),
                  ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  icon,
                  color: isFocused
                      ? FuturisticTheme.primaryBlue
                      : Colors.white54,
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: FuturisticTheme.body.copyWith(
                          fontSize: 12,
                          color: isFocused
                              ? FuturisticTheme.primaryBlue
                              : Colors.white54,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: TextField(
                          controller: controller,
                          focusNode: focusNode,
                          readOnly: false,
                          showCursor: true,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _onDone(),
                          maxLines: null,
                          expands: true,
                          style: FuturisticTheme.body.copyWith(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: hint,
                            hintStyle: const TextStyle(color: Colors.white24),
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Custom Keyboard
  Widget _buildKeyboard(Size size, bool isLandscape) {
    return Container(
      width: double.infinity,
      color: Colors.black.withOpacity(0.8), // Dark background for keyboard
      padding: EdgeInsets.fromLTRB(
        isLandscape ? 24 : 4,
        10,
        isLandscape ? 24 : 4,
        20,
      ),
      child: _showNumpad
          ? _buildNumpad(isLandscape)
          : _buildQwerty(isLandscape),
    );
  }

  Widget _buildQwerty(bool isLandscape) {
    final rows = [
      ['q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p'],
      ['a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l'],
      ['z', 'x', 'c', 'v', 'b', 'n', 'm'],
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildKeyRow(rows[0], isLandscape),
        const SizedBox(height: 6),
        _buildKeyRow(rows[1], isLandscape),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSpecialKey(
              icon: _isUpperCase ? Icons.keyboard_capslock : Icons.arrow_upward,
              onTap: _toggleCase,
              flex: 2,
              isLandscape: isLandscape,
            ),
            const SizedBox(width: 4),
            ...rows[2].map(
              (k) => Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: _buildKey(k, isLandscape),
                ),
              ),
            ),
            const SizedBox(width: 4),
            _buildSpecialKey(
              icon: Icons.backspace_outlined,
              onTap: _onBackspace,
              flex: 2,
              isLandscape: isLandscape,
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            _buildSpecialKey(
              label: '123',
              onTap: _toggleKeyboard,
              flex: 3,
              isLandscape: isLandscape,
            ),
            const SizedBox(width: 4),
            Expanded(
              flex: 10,
              child: _buildActionKey(
                label: 'SPACE',
                onTap: _onSpace,
                isLandscape: isLandscape,
              ),
            ),
            const SizedBox(width: 4),
            _buildSpecialKey(
              label: 'DONE',
              onTap: _onDone,
              flex: 3,
              isLandscape: isLandscape,
              isPrimary: true,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNumpad(bool isLandscape) {
    final rows = [
      ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'],
      ['-', '/', ':', ';', '(', ')', '₹', '&', '@', '"'],
      ['.', ',', '?', '!', "'", '#', '%', '*'],
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildKeyRow(rows[0], isLandscape),
        const SizedBox(height: 6),
        _buildKeyRow(rows[1], isLandscape),
        const SizedBox(height: 6),
        Row(
          children: [
            const Spacer(flex: 2),
            ...rows[2].map(
              (k) => Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: _buildKey(k, isLandscape, isLiteral: true),
                ),
              ),
            ),
            const Spacer(flex: 2),
            _buildSpecialKey(
              icon: Icons.backspace_outlined,
              onTap: _onBackspace,
              flex: 2,
              isLandscape: isLandscape,
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            _buildSpecialKey(
              label: 'ABC',
              onTap: _toggleKeyboard,
              flex: 3,
              isLandscape: isLandscape,
            ),
            const SizedBox(width: 4),
            Expanded(
              flex: 10,
              child: _buildActionKey(
                label: 'SPACE',
                onTap: _onSpace,
                isLandscape: isLandscape,
              ),
            ),
            const SizedBox(width: 4),
            _buildSpecialKey(
              label: 'DONE',
              onTap: _onDone,
              flex: 3,
              isLandscape: isLandscape,
              isPrimary: true,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKeyRow(List<String> keys, bool isLandscape) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: keys
          .map(
            (k) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: _buildKey(k, isLandscape),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildKey(String key, bool isLandscape, {bool isLiteral = false}) {
    final display = (!isLiteral && _isUpperCase) ? key.toUpperCase() : key;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onKeyTap(display),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: isLandscape ? 50 : 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Text(
            display,
            style: FuturisticTheme.body.copyWith(
              fontSize: 20,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialKey({
    IconData? icon,
    String? label,
    required VoidCallback onTap,
    required int flex,
    required bool isLandscape,
    bool isPrimary = false,
  }) {
    return Expanded(
      flex: flex,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: isLandscape ? 50 : 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isPrimary
                  ? FuturisticTheme.primaryBlue
                  : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isPrimary
                    ? FuturisticTheme.primaryBlue
                    : Colors.white.withOpacity(0.1),
              ),
            ),
            child: icon != null
                ? Icon(
                    icon,
                    color: isPrimary ? Colors.black : Colors.white,
                    size: 20,
                  )
                : Text(
                    label ?? '',
                    style: FuturisticTheme.body.copyWith(
                      fontSize: 14,
                      color: isPrimary ? Colors.black : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionKey({
    required String label,
    required VoidCallback onTap,
    required bool isLandscape,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: isLandscape ? 50 : 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Text(
            label,
            style: FuturisticTheme.body.copyWith(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
