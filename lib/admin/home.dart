import 'package:flutter/material.dart';
import 'dart:math' as math;

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final List<Animation<double>> _cardFades;
  late final List<Animation<Offset>> _cardSlides;

  // Chart animation
  late final AnimationController _chartController;
  late final Animation<double> _chartProgress;

  // Tab selection
  int _selectedTab = 0;

  // Demo data
  static const _totalFeedbacks = 1247;
  static const _todayCount = 38;
  static const _avgRating = 4.2;
  static const _satisfactionPct = 87;

  // Rating distribution (1–5 stars)
  static const _ratingDistribution = [42, 78, 198, 412, 517];

  // Per-question averages
  static const _questionLabels = [
    'सेवा गुणवत्ता',
    'कर्मचारी व्यवहार',
    'सुविधाएँ',
    'प्रतीक्षा समय',
    'पुनः आगमन',
  ];
  static const _questionScores = [4.1, 4.4, 3.8, 3.6, 4.6];

  // Weekly trend (last 7 days)
  static const _weeklyLabels = [
    'सोम',
    'मंगल',
    'बुध',
    'गुरु',
    'शुक्र',
    'शनि',
    'रवि',
  ];
  static const _weeklyData = [28, 35, 22, 41, 38, 45, 38];
  static const _weeklyAvgRating = [3.9, 4.1, 4.0, 4.3, 4.2, 4.5, 4.2];

  // Recent feedbacks
  static const _recentFeedbacks = [
    _DemoFeedback('राम कुमार', 5, '10:42 AM', 'बहुत बढ़िया सेवा'),
    _DemoFeedback('सीता देवी', 4, '10:28 AM', 'अच्छा अनुभव'),
    _DemoFeedback('अजय सिंह', 3, '10:15 AM', 'ठीक-ठाक'),
    _DemoFeedback('प्रिया शर्मा', 5, '09:58 AM', 'बहुत संतुष्ट'),
    _DemoFeedback('विजय पटेल', 2, '09:41 AM', 'सुधार आवश्यक'),
    _DemoFeedback('मीना गुप्ता', 4, '09:30 AM', 'अच्छी सेवा'),
    _DemoFeedback('रोहित वर्मा', 5, '09:12 AM', 'उत्कृष्ट'),
    _DemoFeedback('अनीता यादव', 4, '08:55 AM', 'संतोषजनक'),
  ];

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    // 4 stat cards with staggered fade+slide
    _cardFades = List.generate(4, (i) {
      final start = 0.05 + i * 0.08;
      final end = (start + 0.35).clamp(0.0, 1.0);
      return CurvedAnimation(
        parent: _entranceController,
        curve: Interval(start, end, curve: Curves.easeOut),
      );
    });
    _cardSlides = List.generate(4, (i) {
      final start = 0.05 + i * 0.08;
      final end = (start + 0.4).clamp(0.0, 1.0);
      return Tween<Offset>(
        begin: const Offset(0, 0.12),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _entranceController,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        ),
      );
    });

    _chartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _chartProgress = CurvedAnimation(
      parent: _chartController,
      curve: Curves.easeOutCubic,
    );

    _entranceController.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _chartController.forward();
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _chartController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLandscape = size.width > size.height;
    final pad = isLandscape ? size.width * 0.04 : 16.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F4),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(pad, isLandscape),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: pad, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stat cards row
                    _buildStatCards(isLandscape),
                    const SizedBox(height: 20),

                    // Tab bar for chart views
                    _buildTabBar(),
                    const SizedBox(height: 16),

                    // Charts area
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      switchInCurve: Curves.easeOut,
                      child: _selectedTab == 0
                          ? _buildRatingChart(size, isLandscape)
                          : _selectedTab == 1
                          ? _buildQuestionBreakdown(size, isLandscape)
                          : _buildWeeklyTrend(size, isLandscape),
                    ),
                    const SizedBox(height: 24),

                    // Recent feedbacks
                    _buildRecentSection(isLandscape),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Top Bar ──────────────────────────────────────────────────
  Widget _buildTopBar(double pad, bool isLandscape) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: pad, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE8E4DE), width: 1)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF0EDE8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                size: 20,
                color: Color(0xFF333333),
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'प्रशासन डैशबोर्ड',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A1A),
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Administration Dashboard',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF999999),
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          // Live indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, size: 8, color: Color(0xFF2E7D32)),
                SizedBox(width: 6),
                Text(
                  'LIVE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2E7D32),
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Stat Cards ───────────────────────────────────────────────
  Widget _buildStatCards(bool isLandscape) {
    final cards = [
      _StatData(
        'कुल प्रतिक्रिया',
        _totalFeedbacks.toString(),
        'Total Feedback',
        Icons.bar_chart_rounded,
        const Color(0xFF1A3A2A),
      ),
      _StatData(
        'आज',
        _todayCount.toString(),
        'Today',
        Icons.today_rounded,
        const Color(0xFF37474F),
      ),
      _StatData(
        'औसत रेटिंग',
        _avgRating.toStringAsFixed(1),
        'Avg Rating',
        Icons.star_rounded,
        const Color(0xFFE65100),
      ),
      _StatData(
        'संतुष्टि',
        '$_satisfactionPct%',
        'Satisfaction',
        Icons.sentiment_satisfied_alt_rounded,
        const Color(0xFF2E7D32),
      ),
    ];

    return Row(
      children: List.generate(cards.length, (i) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < 3 ? 10 : 0),
            child: FadeTransition(
              opacity: _cardFades[i],
              child: SlideTransition(
                position: _cardSlides[i],
                child: _buildStatCard(cards[i]),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildStatCard(_StatData data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEAE6E0), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: data.color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(data.icon, size: 18, color: data.color),
              ),
              const Spacer(),
              Text(
                data.engLabel,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFAAAAAA),
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            data.value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: data.color,
              letterSpacing: -0.5,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            data.label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF777777),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Tab Bar ──────────────────────────────────────────────────
  Widget _buildTabBar() {
    const tabs = ['रेटिंग वितरण', 'प्रश्न विश्लेषण', 'साप्ताहिक रुझान'];
    const engTabs = [
      'Rating Distribution',
      'Question Analysis',
      'Weekly Trend',
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(tabs.length, (i) {
          final isActive = _selectedTab == i;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedTab = i);
                _chartController.reset();
                _chartController.forward();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFF1A3A2A) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isActive
                        ? const Color(0xFF1A3A2A)
                        : const Color(0xFFE0DBD4),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      tabs[i],
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isActive
                            ? Colors.white
                            : const Color(0xFF555555),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      engTabs[i],
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: isActive
                            ? Colors.white.withValues(alpha: 0.6)
                            : const Color(0xFFAAAAAA),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ─── Rating Distribution Bar Chart ────────────────────────────
  Widget _buildRatingChart(Size size, bool isLandscape) {
    final maxVal = _ratingDistribution.reduce(math.max).toDouble();
    final total = _ratingDistribution.fold<int>(0, (a, b) => a + b);
    final barHeight = isLandscape ? 36.0 : 30.0;

    return Container(
      key: const ValueKey('rating'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEAE6E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text(
                'रेटिंग वितरण',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              SizedBox(width: 8),
              Text(
                'Rating Distribution',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFFAAAAAA),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...List.generate(5, (i) {
            final starLevel = 5 - i;
            final count = _ratingDistribution[starLevel - 1];
            final pct = count / total * 100;
            final barFraction = count / maxVal;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    child: Text(
                      '$starLevel',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF555555),
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.star_rounded,
                    size: 16,
                    color: Color(0xFFE6A817),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AnimatedBuilder(
                      animation: _chartProgress,
                      builder: (context, _) {
                        return Container(
                          height: barHeight,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F2EE),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: barFraction * _chartProgress.value,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _barColor(starLevel),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 55,
                    child: Text(
                      '$count (${pct.toStringAsFixed(0)}%)',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF777777),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Color _barColor(int stars) {
    switch (stars) {
      case 5:
        return const Color(0xFF2E7D32);
      case 4:
        return const Color(0xFF558B2F);
      case 3:
        return const Color(0xFFE6A817);
      case 2:
        return const Color(0xFFE65100);
      default:
        return const Color(0xFFC62828);
    }
  }

  // ─── Question Breakdown ───────────────────────────────────────
  Widget _buildQuestionBreakdown(Size size, bool isLandscape) {
    return Container(
      key: const ValueKey('questions'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEAE6E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text(
                'प्रश्न-वार विश्लेषण',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              SizedBox(width: 8),
              Text(
                'Per-Question Analysis',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFFAAAAAA),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...List.generate(_questionLabels.length, (i) {
            final score = _questionScores[i];
            final fraction = score / 5.0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _questionLabels[i],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF333333),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            score.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: _scoreColor(score),
                            ),
                          ),
                          const Text(
                            '/5',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFFAAAAAA),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  AnimatedBuilder(
                    animation: _chartProgress,
                    builder: (context, _) {
                      return Container(
                        height: 10,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F2EE),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: fraction * _chartProgress.value,
                            child: Container(
                              decoration: BoxDecoration(
                                color: _scoreColor(score),
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Color _scoreColor(double score) {
    if (score >= 4.5) return const Color(0xFF2E7D32);
    if (score >= 4.0) return const Color(0xFF558B2F);
    if (score >= 3.5) return const Color(0xFFE6A817);
    if (score >= 3.0) return const Color(0xFFE65100);
    return const Color(0xFFC62828);
  }

  // ─── Weekly Trend ─────────────────────────────────────────────
  Widget _buildWeeklyTrend(Size size, bool isLandscape) {
    final chartHeight = isLandscape ? 200.0 : 180.0;

    return Container(
      key: const ValueKey('weekly'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEAE6E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text(
                'साप्ताहिक रुझान',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              SizedBox(width: 8),
              Text(
                'Weekly Trend',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFFAAAAAA),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Legend
          Row(
            children: [
              _legendDot(const Color(0xFF1A3A2A), 'प्रतिक्रिया संख्या'),
              const SizedBox(width: 16),
              _legendDot(const Color(0xFFE6A817), 'औसत रेटिंग'),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: chartHeight,
            child: AnimatedBuilder(
              animation: _chartProgress,
              builder: (context, _) {
                return CustomPaint(
                  size: Size(double.infinity, chartHeight),
                  painter: _WeeklyChartPainter(
                    progress: _chartProgress.value,
                    counts: _weeklyData,
                    ratings: _weeklyAvgRating,
                    labels: _weeklyLabels,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Color(0xFF888888),
          ),
        ),
      ],
    );
  }

  // ─── Recent Feedbacks ─────────────────────────────────────────
  Widget _buildRecentSection(bool isLandscape) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text(
              'हाल की प्रतिक्रियाएँ',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
              ),
            ),
            SizedBox(width: 8),
            Text(
              'Recent Feedbacks',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: Color(0xFFAAAAAA),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEAE6E0)),
          ),
          child: Column(
            children: List.generate(_recentFeedbacks.length, (i) {
              final fb = _recentFeedbacks[i];
              final isLast = i == _recentFeedbacks.length - 1;
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  border: isLast
                      ? null
                      : const Border(
                          bottom: BorderSide(
                            color: Color(0xFFF0EDE8),
                            width: 1,
                          ),
                        ),
                ),
                child: Row(
                  children: [
                    // Avatar circle
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _avatarColor(fb.rating),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          fb.name.characters.first,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fb.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            fb.comment,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF999999),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Stars
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(5, (s) {
                        return Icon(
                          s < fb.rating
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          size: 16,
                          color: s < fb.rating
                              ? const Color(0xFFE6A817)
                              : const Color(0xFFD8D3CA),
                        );
                      }),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      fb.time,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFAAAAAA),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Color _avatarColor(int rating) {
    if (rating >= 5) return const Color(0xFF2E7D32);
    if (rating >= 4) return const Color(0xFF558B2F);
    if (rating >= 3) return const Color(0xFFE6A817);
    if (rating >= 2) return const Color(0xFFE65100);
    return const Color(0xFFC62828);
  }
}

// ═══════════════════════════════════════════════════════════════════
// Data models
// ═══════════════════════════════════════════════════════════════════

class _StatData {
  final String label;
  final String value;
  final String engLabel;
  final IconData icon;
  final Color color;

  const _StatData(this.label, this.value, this.engLabel, this.icon, this.color);
}

class _DemoFeedback {
  final String name;
  final int rating;
  final String time;
  final String comment;

  const _DemoFeedback(this.name, this.rating, this.time, this.comment);
}

// ═══════════════════════════════════════════════════════════════════
// Weekly chart painter — bars + line overlay
// ═══════════════════════════════════════════════════════════════════

class _WeeklyChartPainter extends CustomPainter {
  final double progress;
  final List<int> counts;
  final List<double> ratings;
  final List<String> labels;

  _WeeklyChartPainter({
    required this.progress,
    required this.counts,
    required this.ratings,
    required this.labels,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final maxCount = counts.reduce(math.max).toDouble();
    final barCount = counts.length;
    final barWidth = size.width / barCount;
    final chartBottom = size.height - 24;
    final chartTop = 8.0;
    final chartHeight = chartBottom - chartTop;

    final barPaint = Paint()..style = PaintingStyle.fill;
    final barBgPaint = Paint()
      ..color = const Color(0xFFF5F2EE)
      ..style = PaintingStyle.fill;

    // Grid lines
    final gridPaint = Paint()
      ..color = const Color(0xFFF0EDE8)
      ..strokeWidth = 1;
    for (int g = 0; g <= 4; g++) {
      final y = chartTop + chartHeight * (g / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Label text style
    final labelStyle = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: const Color(0xFF999999),
    );

    // Bars
    for (int i = 0; i < barCount; i++) {
      final x = barWidth * i + barWidth * 0.15;
      final w = barWidth * 0.7;
      final fraction = (counts[i] / maxCount) * progress;
      final barH = chartHeight * fraction;
      final barTop = chartBottom - barH;

      // Background
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, chartTop, w, chartHeight),
          const Radius.circular(6),
        ),
        barBgPaint,
      );

      // Filled bar
      barPaint.color = const Color(
        0xFF1A3A2A,
      ).withValues(alpha: 0.7 + 0.3 * (counts[i] / maxCount));
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, barTop, w, barH),
          const Radius.circular(6),
        ),
        barPaint,
      );

      // Count label on top of bar
      if (progress > 0.5) {
        final countTp = TextPainter(
          text: TextSpan(text: '${counts[i]}', style: labelStyle),
          textDirection: TextDirection.ltr,
        )..layout();
        countTp.paint(
          canvas,
          Offset(x + w / 2 - countTp.width / 2, barTop - 18),
        );
      }

      // Day label below
      final tp = TextPainter(
        text: TextSpan(text: labels[i], style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x + w / 2 - tp.width / 2, chartBottom + 6));
    }

    // Rating line overlay
    if (progress > 0.3) {
      final lineProgress = ((progress - 0.3) / 0.7).clamp(0.0, 1.0);
      final linePaint = Paint()
        ..color = const Color(0xFFE6A817)
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      final dotPaint = Paint()
        ..color = const Color(0xFFE6A817)
        ..style = PaintingStyle.fill;

      final ratingMin = 3.0;
      final ratingMax = 5.0;

      final path = Path();
      final visibleCount = (barCount * lineProgress).ceil();

      for (int i = 0; i < visibleCount && i < barCount; i++) {
        final cx = barWidth * i + barWidth * 0.5;
        final normalised = ((ratings[i] - ratingMin) / (ratingMax - ratingMin))
            .clamp(0.0, 1.0);
        final cy = chartBottom - chartHeight * normalised;

        if (i == 0) {
          path.moveTo(cx, cy);
        } else {
          path.lineTo(cx, cy);
        }
        canvas.drawCircle(Offset(cx, cy), 4, dotPaint);
      }
      canvas.drawPath(path, linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _WeeklyChartPainter old) {
    return old.progress != progress;
  }
}
