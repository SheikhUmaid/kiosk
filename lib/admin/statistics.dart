import 'dart:math' as math;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:kiosk/providers/feedback_provider.dart';
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
    final provider = context.watch<FeedbackProvider>();
    final allFbs = provider.feedbacks;

    DateTime now = DateTime.now();
    DateTime startDate = DateTime(now.year, now.month, now.day);
    if (_selectedRange == 'Today') {
       startDate = DateTime(now.year, now.month, now.day);
    } else if (_selectedRange == 'This Week') {
       int diff = now.weekday - 1; // Mon=1
       startDate = DateTime(now.year, now.month, now.day - diff);
    } else if (_selectedRange == 'This Month') {
       startDate = DateTime(now.year, now.month, 1);
    } else if (_selectedRange == 'This Year') {
       startDate = DateTime(now.year, 1, 1);
    }

    int totalF = 0;
    double sumR = 0;
    int sat = 0;
    List<int> starCounts = [0,0,0,0,0];

    Map<String, List<int>> qStats = {};
    
    // For monthly chart (always show 12 months for this year)
    List<int> mCounts = List.filled(12, 0);
    List<List<int>> mRatingsLists = List.generate(12, (_) => []);

    for (var f in allFbs) {
       DateTime? dt;
       if (f['timestamp'] != null) {
          dt = DateTime.parse(f['timestamp']).toLocal();
       }
       if (dt == null) continue;

       Map<String, int> answers = {};
       if (f['answers'] != null && f['answers'].toString().isNotEmpty) {
         try {
           final decoded = jsonDecode(f['answers']) as Map<String, dynamic>;
           answers = decoded.map((k, v) => MapEntry(k, int.parse(v.toString())));
         } catch(_) {}
       }

       int avgR = 0;
       if (answers.isNotEmpty) {
          int s = 0;
          answers.values.forEach((v) => s += v);
          avgR = (s / answers.length).round();
       }

       // For Monthly Chart (Overall this year)
       if (dt.year == now.year) {
          mCounts[dt.month - 1]++;
          if (answers.isNotEmpty) mRatingsLists[dt.month - 1].add(avgR);
       }

       // For Filtered KPIs
       bool isInRange = dt.isAfter(startDate.subtract(const Duration(seconds: 1)));
       if (isInRange) {
          totalF++;
          sumR += avgR;
          if (avgR >= 4) sat++;
          if (avgR >= 1 && avgR <= 5) starCounts[avgR - 1]++;
          
          answers.forEach((k, v) {
            if (!qStats.containsKey(k)) qStats[k] = [];
            qStats[k]!.add(v);
          });
       }
    }

    double avgRating = totalF > 0 ? sumR / totalF : 0.0;
    double satPct = totalF > 0 ? sat / totalF : 0.0;

    List<double> mRatings = List.filled(12, 0.0);
    for (int i=0; i<12; i++) {
       if (mRatingsLists[i].isNotEmpty) {
          mRatings[i] = mRatingsLists[i].fold(0, (a, b) => (a as num).toInt() + b) / mRatingsLists[i].length;
       }
    }

    List<_PerfRow> perfRows = [];
    qStats.forEach((k, v) {
       double qAvg = v.fold(0, (a, b) => (a as num).toInt() + b) / v.length;
       perfRows.add(_PerfRow(k.toUpperCase(), '', qAvg, qAvg >= 4.0));
    });
    perfRows.sort((a,b) => b.score.compareTo(a.score)); // Sort highest first
    
    final monthLabels = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Filter bar ──────────────────────────────────────────
          _buildFilterBar(),
          const SizedBox(height: 24),

          // ── KPI row ─────────────────────────────────────────────
          _buildKpiRow(totalF.toString(), avgRating.toStringAsFixed(1), '${(satPct * 100).round()}%'),
          const SizedBox(height: 24),

          // ── Monthly trend ────────────────────────────────────────
          _buildMonthlyChart(monthLabels, mCounts, mRatings),
          const SizedBox(height: 24),

          // ── Satisfaction gauge + Performers ─────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 4, child: _buildGauge(satPct, starCounts, totalF)),
              const SizedBox(width: 20),
              Expanded(flex: 6, child: _buildPerformers(perfRows)),
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
  Widget _buildKpiRow(String totalSubmits, String avgRating, String sat) {
    final kpis = [
      _Kpi(
        'Total Submissions',
        totalSubmits,
        '',
        true,
        Icons.feedback_outlined,
        AdminTheme.primary,
      ),
      _Kpi(
        'Avg Rating',
        avgRating,
        '',
        true,
        Icons.star_outline_rounded,
        AdminTheme.warning,
      ),
      _Kpi(
        'Satisfaction Rate',
        sat,
        '',
        true,
        Icons.sentiment_satisfied_alt_outlined,
        AdminTheme.success,
      ),
      _Kpi(
        'Pending Review',
        '0',
        '',
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
                      child: kpi.delta.isNotEmpty ? Text(
                        kpi.delta,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: kpi.up
                              ? AdminTheme.success
                              : AdminTheme.danger,
                        ),
                      ) : const SizedBox(),
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
  Widget _buildMonthlyChart(List<String> monthLabels, List<int> mCounts, List<double> mRatings) {
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
                  counts: mCounts,
                  ratings: mRatings,
                  labels: monthLabels,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Satisfaction gauge ───────────────────────────────────────────
  Widget _buildGauge(double satPct, List<int> starCounts, int totalF) {
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
                painter: _GaugePainter(value: satPct * _anim.value),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${(satPct * 100).round()}%',
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
          _gaugeRow('Very Good', '5★', totalF > 0 ? starCounts[4] / totalF : 0.0, AdminTheme.success),
          _gaugeRow('Good', '4★', totalF > 0 ? starCounts[3] / totalF : 0.0, AdminTheme.accent),
          _gaugeRow('Average', '3★', totalF > 0 ? starCounts[2] / totalF : 0.0, AdminTheme.warning),
          _gaugeRow('Poor', '2★', totalF > 0 ? starCounts[1] / totalF : 0.0, const Color(0xFFE65100)),
          _gaugeRow('Bad', '1★', totalF > 0 ? starCounts[0] / totalF : 0.0, AdminTheme.danger),
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
  Widget _buildPerformers(List<_PerfRow> perfRows) {
    if (perfRows.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: AdminTheme.card(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _hdr('Question Performance', 'प्रश्न प्रदर्शन'),
            const SizedBox(height: 48),
            const Center(child: Text('No question data available for the selected range.', style: TextStyle(color: AdminTheme.textMuted))),
          ],
        ),
      );
    }
    
    // ensure max 5
    final displayRows = perfRows.take(5).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AdminTheme.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _hdr('Question Performance', 'प्रश्न प्रदर्शन'),
          const SizedBox(height: 16),
          ...displayRows.map((p) {
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
                          p.eng,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AdminTheme.textPrimary,
                          ),
                        ),
                        Text(p.hindi, style: AdminTheme.caption),
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
    
    // Default fallback if max == 0
    double maxC = 1.0;
    if (counts.isNotEmpty) {
      final highC = counts.reduce(math.max).toDouble();
      if (highC > 0) maxC = highC;
    }

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
