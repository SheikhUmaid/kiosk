import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'admin_theme.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  String _selectedRange = 'This Month';
  final _ranges = ['Today', 'This Week', 'This Month', 'This Year'];

  // ── Mock data ────────────────────────────────────────────────────
  static const _monthLabels = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  static const _monthlyCounts = [
    210,
    185,
    240,
    280,
    310,
    265,
    290,
    330,
    275,
    350,
    320,
    380,
  ];
  static const _monthlyRatings = [
    3.9,
    4.0,
    4.1,
    4.2,
    4.0,
    4.3,
    4.2,
    4.4,
    4.1,
    4.5,
    4.3,
    4.6,
  ];

  static const _performers = <_PerfRow>[
    _PerfRow('HOW WAS OUR SERVICE?', 'सेवा गुणवत्ता', 4.6, true),
    _PerfRow('VISIT AGAIN?', 'पुनः आगमन', 4.4, true),
    _PerfRow('STAFF HELPFUL?', 'कर्मचारी व्यवहार', 4.1, true),
    _PerfRow('FACILITY CONDITION?', 'सुविधाएँ', 3.8, false),
    _PerfRow('WAITING TIME?', 'प्रतीक्षा समय', 3.6, false),
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Filter bar ──────────────────────────────────────────
          _buildFilterBar(),
          const SizedBox(height: 24),

          // ── KPI row ─────────────────────────────────────────────
          _buildKpiRow(),
          const SizedBox(height: 24),

          // ── Monthly trend ────────────────────────────────────────
          _buildMonthlyChart(),
          const SizedBox(height: 24),

          // ── Satisfaction gauge + Performers ─────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 4, child: _buildGauge()),
              const SizedBox(width: 20),
              Expanded(flex: 6, child: _buildPerformers()),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ── Filter bar ───────────────────────────────────────────────────
  Widget _buildFilterBar() {
    return Row(
      children: [
        ..._ranges.map((r) {
          final active = r == _selectedRange;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedRange = r);
                _ctrl.reset();
                _ctrl.forward();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: active ? AdminTheme.primary : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: active ? AdminTheme.primary : AdminTheme.border,
                  ),
                ),
                child: Text(
                  r,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: active ? Colors.white : AdminTheme.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }),
        const Spacer(),
        OutlinedButton.icon(
          style: AdminTheme.outlinedButton,
          onPressed: () {},
          icon: const Icon(Icons.calendar_today_outlined, size: 16),
          label: const Text('Custom Range'),
        ),
      ],
    );
  }

  // ── KPI row ──────────────────────────────────────────────────────
  Widget _buildKpiRow() {
    final kpis = [
      _Kpi(
        'Total Submissions',
        '3,623',
        '+12.4%',
        true,
        Icons.feedback_outlined,
        AdminTheme.primary,
      ),
      _Kpi(
        'Avg Rating',
        '4.2',
        '+0.3',
        true,
        Icons.star_outline_rounded,
        AdminTheme.warning,
      ),
      _Kpi(
        'Satisfaction Rate',
        '87%',
        '+5.1%',
        true,
        Icons.sentiment_satisfied_alt_outlined,
        AdminTheme.success,
      ),
      _Kpi(
        'Pending Review',
        '14',
        '-3',
        false,
        Icons.pending_outlined,
        AdminTheme.danger,
      ),
    ];

    return Row(
      children: kpis.asMap().entries.map((e) {
        final i = e.key;
        final kpi = e.value;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i < 3 ? 16 : 0),
            padding: const EdgeInsets.all(18),
            decoration: AdminTheme.card(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(kpi.icon, size: 18, color: kpi.color),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: (kpi.up ? AdminTheme.success : AdminTheme.danger)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        kpi.delta,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: kpi.up
                              ? AdminTheme.success
                              : AdminTheme.danger,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  kpi.value,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: kpi.color,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  kpi.label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AdminTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Monthly trend chart ──────────────────────────────────────────
  Widget _buildMonthlyChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AdminTheme.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _hdr('Monthly Trend', 'मासिक रुझान'),
          const SizedBox(height: 6),
          Row(
            children: [
              _dot(AdminTheme.primary, 'Feedback count'),
              const SizedBox(width: 16),
              _dot(AdminTheme.warning, 'Avg rating'),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: AnimatedBuilder(
              animation: _anim,
              builder: (_, __) => CustomPaint(
                size: const Size(double.infinity, 200),
                painter: _MonthlyPainter(
                  progress: _anim.value,
                  counts: _monthlyCounts,
                  ratings: _monthlyRatings,
                  labels: _monthLabels,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Satisfaction gauge ───────────────────────────────────────────
  Widget _buildGauge() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AdminTheme.card(),
      child: Column(
        children: [
          _hdr('Satisfaction', 'संतुष्टि'),
          const SizedBox(height: 24),
          AnimatedBuilder(
            animation: _anim,
            builder: (_, __) => SizedBox(
              width: 160,
              height: 160,
              child: CustomPaint(
                painter: _GaugePainter(value: 0.87 * _anim.value),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '87%',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: AdminTheme.primary,
                        ),
                      ),
                      const Text(
                        'Satisfied',
                        style: TextStyle(
                          fontSize: 11,
                          color: AdminTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _gaugeRow('Very Good', '5★', 0.41, AdminTheme.success),
          _gaugeRow('Good', '4★', 0.33, AdminTheme.accent),
          _gaugeRow('Average', '3★', 0.16, AdminTheme.warning),
          _gaugeRow('Poor', '2★', 0.06, const Color(0xFFE65100)),
          _gaugeRow('Bad', '1★', 0.03, AdminTheme.danger),
        ],
      ),
    );
  }

  Widget _gaugeRow(String label, String stars, double frac, Color c) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AdminTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: frac,
                minHeight: 6,
                backgroundColor: AdminTheme.bg,
                valueColor: AlwaysStoppedAnimation(c),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 30,
            child: Text(
              '${(frac * 100).toInt()}%',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AdminTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Performers ───────────────────────────────────────────────────
  Widget _buildPerformers() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AdminTheme.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _hdr('Question Performance', 'प्रश्न प्रदर्शन'),
          const SizedBox(height: 16),
          ..._performers.map((p) {
            final color = p.top ? AdminTheme.success : AdminTheme.danger;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.04),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: color.withOpacity(0.15)),
              ),
              child: Row(
                children: [
                  Icon(
                    p.top
                        ? Icons.trending_up_rounded
                        : Icons.trending_down_rounded,
                    size: 20,
                    color: color,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.hindi,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AdminTheme.textPrimary,
                          ),
                        ),
                        Text(p.eng, style: AdminTheme.caption),
                      ],
                    ),
                  ),
                  Text(
                    p.score.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                  const Text(
                    ' /5',
                    style: TextStyle(fontSize: 12, color: AdminTheme.textMuted),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _hdr(String e, String h) => Row(
    children: [
      Text(e, style: AdminTheme.sectionTitle),
      const SizedBox(width: 8),
      Text(h, style: AdminTheme.caption),
    ],
  );

  Widget _dot(Color c, String l) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: c,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
      const SizedBox(width: 6),
      Text(l, style: AdminTheme.caption),
    ],
  );
}

// ─── Data models ──────────────────────────────────────────────────────
class _Kpi {
  final String label, value, delta;
  final bool up;
  final IconData icon;
  final Color color;
  const _Kpi(
    this.label,
    this.value,
    this.delta,
    this.up,
    this.icon,
    this.color,
  );
}

class _PerfRow {
  final String eng, hindi;
  final double score;
  final bool top;
  const _PerfRow(this.eng, this.hindi, this.score, this.top);
}

// ─── Monthly chart painter ────────────────────────────────────────────
class _MonthlyPainter extends CustomPainter {
  final double progress;
  final List<int> counts;
  final List<double> ratings;
  final List<String> labels;

  _MonthlyPainter({
    required this.progress,
    required this.counts,
    required this.ratings,
    required this.labels,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final maxC = counts.reduce(math.max).toDouble();
    final n = counts.length;
    final bw = size.width / n;
    final bottom = size.height - 24.0;
    final top = 8.0;
    final h = bottom - top;

    final gridP = Paint()
      ..color = AdminTheme.border.withOpacity(0.5)
      ..strokeWidth = 1;
    for (int g = 0; g <= 4; g++) {
      final y = top + h * (g / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridP);
    }

    final barP = Paint()..color = AdminTheme.primary.withOpacity(0.8);
    final bgP = Paint()..color = AdminTheme.bg;

    for (int i = 0; i < n; i++) {
      final x = bw * i + bw * 0.15;
      final w = bw * 0.7;
      final frac = (counts[i] / maxC) * progress;
      final bH = h * frac;
      final bTop = bottom - bH;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, top, w, h),
          const Radius.circular(5),
        ),
        bgP,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, bTop, w, bH),
          const Radius.circular(5),
        ),
        barP,
      );

      final tp = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AdminTheme.textMuted,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x + w / 2 - tp.width / 2, bottom + 6));
    }

    if (progress > 0.3) {
      final lp = ((progress - 0.3) / 0.7).clamp(0.0, 1.0);
      final lineP = Paint()
        ..color = AdminTheme.warning
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      final dotP = Paint()..color = AdminTheme.warning;
      final path = Path();
      final vis = (n * lp).ceil().clamp(0, n);

      for (int i = 0; i < vis; i++) {
        final cx = bw * i + bw * 0.5;
        final cy = bottom - h * ((ratings[i] - 3) / 2).clamp(0.0, 1.0);
        if (i == 0)
          path.moveTo(cx, cy);
        else
          path.lineTo(cx, cy);
        canvas.drawCircle(Offset(cx, cy), 4, dotP);
      }
      canvas.drawPath(path, lineP);
    }
  }

  @override
  bool shouldRepaint(_MonthlyPainter o) => o.progress != progress;
}

// ─── Gauge painter ────────────────────────────────────────────────────
class _GaugePainter extends CustomPainter {
  final double value; // 0..1

  _GaugePainter({required this.value});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;
    const start = math.pi * 0.75;
    const sweep = math.pi * 1.5;

    // Track
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      start,
      sweep,
      false,
      Paint()
        ..color = AdminTheme.bg
        ..strokeWidth = 16
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Value arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      start,
      sweep * value,
      false,
      Paint()
        ..color = AdminTheme.primary
        ..strokeWidth = 16
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_GaugePainter o) => o.value != value;
}
