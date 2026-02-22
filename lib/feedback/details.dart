import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kiosk/feedback/home.dart';
import 'package:kiosk/theme/futuristic_theme.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:kiosk/main.dart'; // For navigation back to Home

class FeedBackDetails extends StatefulWidget {
  const FeedBackDetails({super.key});

  @override
  State<FeedBackDetails> createState() => _FeedBackDetailsState();
}

class _FeedBackDetailsState extends State<FeedBackDetails>
    with TickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _accountController = TextEditingController();
  final _phoneController = TextEditingController();

  final _nameFocus = FocusNode();
  final _accountFocus = FocusNode();
  final _phoneFocus = FocusNode();

  FocusNode? _activeFocus;
  TextEditingController?
  _activeController; // Track active controller for keyboard input

  bool _isUpperCase = false;
  bool _showNumpad = false;

  late final AnimationController _entranceController;
  late final Animation<double> _headerFade;
  late final Animation<Offset> _headerSlide;
  late final List<AnimationController> _fieldControllers;
  late final List<Animation<double>> _fieldSlides;
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

    // Staggered field entrance
    _fieldControllers = List.generate(3, (i) {
      return AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      );
    });
    _fieldSlides = _fieldControllers.map((c) {
      return CurvedAnimation(
        parent: c,
        curve: Curves.easeOutCubic,
      ).drive(Tween(begin: 0.0, end: 1.0));
    }).toList();

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
    _nameFocus.addListener(() => _onFocusChange(_nameFocus, _nameController));
    _accountFocus.addListener(
      () => _onFocusChange(_accountFocus, _accountController),
    );
    _phoneFocus.addListener(
      () => _onFocusChange(_phoneFocus, _phoneController),
    );

    _startEntrance();
  }

  void _startEntrance() async {
    await Future.delayed(const Duration(milliseconds: 150));
    if (!mounted) return;
    _entranceController.forward();
    for (int i = 0; i < _fieldControllers.length; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return;
      _fieldControllers[i].forward();
    }
  }

  void _onFocusChange(FocusNode focus, TextEditingController controller) {
    if (focus.hasFocus) {
      setState(() {
        _activeFocus = focus;
        _activeController = controller; // Set active controller
        _showNumpad = (focus == _accountFocus || focus == _phoneFocus);
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
    if (_activeFocus == _nameFocus) {
      _accountFocus.requestFocus();
    } else if (_activeFocus == _accountFocus) {
      _phoneFocus.requestFocus();
    } else {
      _activeFocus?.unfocus();
      _keyboardController.reverse();
    }
  }

  void _onSubmit() {
    if (_nameController.text.trim().isEmpty) {
      _nameFocus.requestFocus();
      return;
    }
    // Navigate immediately to FeedBackHome — no delay, no thank-you screen
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const FeedBackHome(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _entranceController.dispose();
    for (var c in _fieldControllers) c.dispose();
    _keyboardController.dispose();
    _nameController.dispose();
    _accountController.dispose();
    _phoneController.dispose();
    _nameFocus.dispose();
    _accountFocus.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLandscape = size.width > size.height;

    return Scaffold(
      backgroundColor: FuturisticTheme.bgDark,
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
                        const SizedBox(height: 24),
                        Text(
                          'ENTER DETAILS',
                          style: FuturisticTheme.titleMedium.copyWith(
                            fontSize: 28,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'अपनी जानकारी दर्ज करें',
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
                  index: 0,
                  controller: _nameController,
                  focusNode: _nameFocus,
                  label: 'NAME / नाम',
                  hint: 'FULL NAME',
                  icon: Icons.person_outline_rounded,
                ),
                const SizedBox(height: 20),
                _buildField(
                  index: 1,
                  controller: _accountController,
                  focusNode: _accountFocus,
                  label: 'ACCOUNT NO / खाता संख्या',
                  hint: '0000 0000 0000',
                  icon: Icons.account_balance_outlined,
                ),
                const SizedBox(height: 20),
                _buildField(
                  index: 2,
                  controller: _phoneController,
                  focusNode: _phoneFocus,
                  label: 'MOBILE / मोबाइल',
                  hint: '+91 0000000000',
                  icon: Icons.phone_outlined,
                ),
                const SizedBox(height: 40),

                AnimatedOpacity(
                  opacity: _nameController.text.trim().isNotEmpty ? 1.0 : 0.5,
                  duration: const Duration(milliseconds: 300),
                  child: GestureDetector(
                    onTap: _onSubmit,
                    child: GlassmorphicContainer(
                      width: isLandscape ? 300 : double.infinity,
                      height: 60,
                      borderRadius: 20,
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
                      child: Text('SUBMIT', style: FuturisticTheme.buttonText),
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
    required int index,
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    final isFocused = _activeFocus == focusNode;

    return FadeTransition(
      opacity: _fieldSlides[index],
      child: GestureDetector(
        onTap: () => focusNode.requestFocus(),
        child: GlassmorphicContainer(
          width: double.infinity,
          height: 80,
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
                    FuturisticTheme.primaryGold,
                    FuturisticTheme.primaryGold.withOpacity(0.5),
                  ]
                : [
                    Colors.white.withOpacity(0.1),
                    Colors.white.withOpacity(0.05),
                  ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isFocused
                      ? FuturisticTheme.primaryGold
                      : Colors.white54,
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: FuturisticTheme.body.copyWith(
                          fontSize: 12,
                          color: isFocused
                              ? FuturisticTheme.primaryGold
                              : Colors.white54,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Hide default cursor, handle manually through keyboard if needed or trust Flutter's hidden input
                      // Actually we use readOnly: true and custom keyboard
                      IgnorePointer(
                        child: TextField(
                          controller: controller,
                          focusNode: focusNode, // Keep focus for state
                          readOnly: true, // Prevent system keyboard
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
                  ? FuturisticTheme.primaryGold
                  : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isPrimary
                    ? FuturisticTheme.primaryGold
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
