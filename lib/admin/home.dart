import 'dart:math' as math;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:kiosk/providers/feedback_provider.dart';
import 'package:flutter/material.dart';
import 'admin_theme.dart';
import 'feed_list.dart';
import 'statistics.dart';
import 'download.dart';
import 'changepwd.dart';
import 'add_del_questions.dart';

// ═══════════════════════════════════════════════════════════════════
// Admin Home — Sidebar + routed content
// ═══════════════════════════════════════════════════════════════════

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  int _selectedIndex = 0;

  static const _navItems = <_NavItem>[
    _NavItem(
      Icons.dashboard_outlined,
      Icons.dashboard,
      'Dashboard',
      'डैशबोर्ड',
    ),
    _NavItem(Icons.bar_chart_outlined, Icons.bar_chart, 'Statistics', 'आँकड़े'),
    _NavItem(
      Icons.list_alt_outlined,
      Icons.list_alt,
      'Feedback List',
      'प्रतिक्रिया सूची',
    ),
    _NavItem(Icons.download_outlined, Icons.download, 'Download', 'डाउनलोड'),
    _NavItem(Icons.quiz_outlined, Icons.quiz, 'Questions', 'प्रश्न'),
    _NavItem(Icons.lock_outline, Icons.lock, 'Change Password', 'पासवर्ड'),
  ];

  // Each index maps to a content widget
  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return const _DashboardContent();
      case 1:
        return const StatisticsPage();
      case 2:
        return const FeedListPage();
      case 3:
        return const DownloadPage();
      case 4:
        return const AddDelQuestionsPage();
      case 5:
        return const ChangePwdPage();
      default:
        return const _DashboardContent();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 720;

    return Scaffold(
      backgroundColor: AdminTheme.bg,
      body: Row(
        children: [
          // ── Sidebar ─────────────────────────────────────────────
          _Sidebar(
            items: _navItems,
            selected: _selectedIndex,
            wide: isWide,
            onSelect: (i) => setState(() => _selectedIndex = i),
            onBack: () => Navigator.of(context).pop(),
          ),

          // ── Main area ───────────────────────────────────────────
          Expanded(
            child: Column(
              children: [
                _TopBar(
                  title: _navItems[_selectedIndex].label,
                  subtitle: _navItems[_selectedIndex].hindi,
                ),
                Expanded(child: _buildContent()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Sidebar ────────────────────────────────────────────────────────
class _Sidebar extends StatelessWidget {
  final List<_NavItem> items;
  final int selected;
  final bool wide;
  final ValueChanged<int> onSelect;
  final VoidCallback onBack;

  const _Sidebar({
    required this.items,
    required this.selected,
    required this.wide,
    required this.onSelect,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final w = wide ? 220.0 : 68.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: w,
      color: AdminTheme.sidebar,
      child: Column(
        children: [
          // Brand header
          Container(
            height: 64,
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.symmetric(horizontal: wide ? 20 : 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0x22FFFFFF))),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AdminTheme.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.shield_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                if (wide) ...[
                  const SizedBox(width: 12),
                  const Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ADMIN',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                      Text(
                        'Indian Army Kiosk',
                        style: TextStyle(
                          color: Color(0x88FFFFFF),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Nav items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              itemCount: items.length,
              itemBuilder: (_, i) {
                final item = items[i];
                final active = selected == i;
                return _SidebarTile(
                  item: item,
                  active: active,
                  wide: wide,
                  onTap: () => onSelect(i),
                );
              },
            ),
          ),

          // Back button
          const Divider(color: Color(0x22FFFFFF), height: 1),
          _SidebarTile(
            item: const _NavItem(
              Icons.arrow_back_rounded,
              Icons.arrow_back_rounded,
              'Exit',
              'वापस जाएँ',
            ),
            active: false,
            wide: wide,
            onTap: onBack,
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _SidebarTile extends StatefulWidget {
  final _NavItem item;
  final bool active;
  final bool wide;
  final VoidCallback onTap;

  const _SidebarTile({
    required this.item,
    required this.active,
    required this.wide,
    required this.onTap,
  });

  @override
  State<_SidebarTile> createState() => _SidebarTileState();
}

class _SidebarTileState extends State<_SidebarTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.active;
    final bgColor = active
        ? AdminTheme.sidebarActive
        : _hovered
        ? AdminTheme.sidebarHover
        : Colors.transparent;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          margin: const EdgeInsets.symmetric(vertical: 2),
          padding: EdgeInsets.symmetric(
            horizontal: widget.wide ? 14 : 0,
            vertical: 11,
          ),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: widget.wide
                ? MainAxisAlignment.start
                : MainAxisAlignment.center,
            children: [
              Icon(
                active ? widget.item.activeIcon : widget.item.icon,
                size: 20,
                color: active ? Colors.white : const Color(0xAAFFFFFF),
              ),
              if (widget.wide) ...[
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    widget.item.label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                      color: active ? Colors.white : const Color(0xCCFFFFFF),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Top Bar ─────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final String title;
  final String subtitle;
  const _TopBar({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AdminTheme.textPrimary,
                  ),
                ),
                Text(subtitle, style: AdminTheme.caption),
              ],
            ),
          ),
          // Live badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, size: 8, color: AdminTheme.success),
                SizedBox(width: 6),
                Text(
                  'LIVE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AdminTheme.success,
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
}

// ═══════════════════════════════════════════════════════════════════
// Dashboard Content (inline in home.dart)
// ═══════════════════════════════════════════════════════════════════

class _DashboardContent extends StatefulWidget {
  const _DashboardContent();

  @override
  State<_DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<_DashboardContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;
  int _chartTab = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
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
    final fbs = provider.feedbacks;

    int totalFb = fbs.length;
    int todayFb = 0;
    double sumRating = 0.0;
    int satisfiedCnt = 0;
    List<int> ratingDist = [0, 0, 0, 0, 0];
    
    Map<String, List<int>> qStats = {};
    List<_FbRow> recentFbs = [];
    DateTime now = DateTime.now();

    for (int i = 0; i < fbs.length; i++) {
       final f = fbs[i];
       
       DateTime? dt;
       if (f['timestamp'] != null) {
          dt = DateTime.parse(f['timestamp']).toLocal();
       }
       if (dt != null && dt.year == now.year && dt.month == now.month && dt.day == now.day) {
          todayFb++;
       }

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
          answers.forEach((k, v) {
            s += v;
            if (!qStats.containsKey(k)) qStats[k] = [];
            qStats[k]!.add(v);
          });
          avgR = (s / answers.length).round();
       }

       sumRating += avgR;
       if (avgR >= 4) satisfiedCnt++;
       if (avgR >= 1 && avgR <= 5) {
          ratingDist[avgR - 1]++;
       }

       if (recentFbs.length < 6) {
         String t = dt != null ? "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}" : '';
         String n = "${f['firstName'] ?? ''} ${f['lastName'] ?? ''}".trim();
         if (n.isEmpty && f['phone'] != null && f['phone'].toString().isNotEmpty) n = f['phone'].toString();
         if (n.isEmpty && f['unitNumber'] != null && f['unitNumber'].toString().isNotEmpty) n = f['unitNumber'].toString();
         if (n.isEmpty) n = 'Unknown';
         String rm = f['remarks'] ?? '';
         recentFbs.add(_FbRow(n, avgR, t, rm.isNotEmpty ? rm : 'No comment'));
       }
    }

    double avgRating = totalFb > 0 ? sumRating / totalFb : 0.0;
    int satisfaction = totalFb > 0 ? ((satisfiedCnt / totalFb) * 100).round() : 0;

    List<String> qLabels = [];
    List<double> qScores = [];
    qStats.forEach((k, v) {
      qLabels.add(k);
      double avg = v.fold(0, (a, b) => (a as num).toInt() + b) / v.length;
      qScores.add(avg);
    });
    
    // Default values if no question ratings
    if (qLabels.isEmpty) {
        qLabels = ['No Data Yet'];
        qScores = [0.0];
    }
    
    List<String> wLabels = [];
    List<int> wCounts = [0, 0, 0, 0, 0, 0, 0];
    List<double> wRatings = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
    List<List<int>> wRatingLists = List.generate(7, (_) => []);

    for (int i = 6; i >= 0; i--) {
       DateTime d = now.subtract(Duration(days: i));
       wLabels.add("${d.day}/${d.month}");
    }

    for (var f in fbs) {
       if (f['timestamp'] != null) {
          DateTime dt = DateTime.parse(f['timestamp']).toLocal();
          int diff = DateTime(now.year, now.month, now.day).difference(DateTime(dt.year, dt.month, dt.day)).inDays;
          if (diff >= 0 && diff < 7) {
             int idx = 6 - diff;
             wCounts[idx]++;
             
             Map<String, int> ans = {};
             if (f['answers'] != null && f['answers'].toString().isNotEmpty) {
               try {
                 final decoded = jsonDecode(f['answers']) as Map<String, dynamic>;
                 ans = decoded.map((k, v) => MapEntry(k, int.parse(v.toString())));
               } catch(_) {}
             }
             if (ans.isNotEmpty) {
                int s = 0;
                ans.values.forEach((v) => s += v);
                wRatingLists[idx].add((s / ans.length).round());
             }
          }
       }
    }
    for (int i = 0; i < 7; i++) {
       if (wRatingLists[i].isNotEmpty) {
          wRatings[i] = wRatingLists[i].fold(0, (a, b) => (a as num).toInt() + b) / wRatingLists[i].length;
       }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Stat cards ─────────────────────────────────────────
          _buildStatRow(totalFb.toString(), todayFb.toString(), avgRating.toStringAsFixed(1), '$satisfaction%'),
          const SizedBox(height: 24),

          // ── Chart tabs ─────────────────────────────────────────
          Row(
            children: [
              _chartTabBtn(0, 'Rating Dist.'),
              const SizedBox(width: 8),
              _chartTabBtn(1, 'Per Question'),
              const SizedBox(width: 8),
              _chartTabBtn(2, 'Weekly Trend'),
            ],
          ),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _buildChart(ratingDist, qLabels, qScores, wLabels, wCounts, wRatings),
          ),
          const SizedBox(height: 24),

          // ── Recent feedbacks ───────────────────────────────────
          _buildRecent(recentFbs),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _chartTabBtn(int idx, String label) {
    final active = _chartTab == idx;
    return GestureDetector(
      onTap: () {
        setState(() => _chartTab = idx);
        _ctrl.reset();
        _ctrl.forward();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AdminTheme.primary : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: active ? AdminTheme.primary : AdminTheme.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: active ? Colors.white : AdminTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String totalFb, String todayFb, String avgRating, String satisfaction) {
    final stats = [
      _Stat(
        'Total Feedback',
        'कुल फ़ीडबैक',
        totalFb,
        Icons.feedback_outlined,
        AdminTheme.primary,
      ),
      _Stat('Today', 'आज', todayFb, Icons.today_outlined, AdminTheme.accent),
      _Stat(
        'Avg Rating',
        'औसत रेटिंग',
        avgRating,
        Icons.star_outline_rounded,
        AdminTheme.warning,
      ),
      _Stat(
        'Satisfaction',
        'संतुष्टि',
        satisfaction,
        Icons.sentiment_satisfied_alt_outlined,
        AdminTheme.success,
      ),
    ];

    return LayoutBuilder(
      builder: (_, c) {
        final w = (c.maxWidth - 48) / 4;
        return Row(
          children: stats.asMap().entries.map((e) {
            final i = e.key;
            final stat = e.value;
            return Container(
              width: w,
              margin: EdgeInsets.only(right: i < 3 ? 16 : 0),
              padding: const EdgeInsets.all(18),
              decoration: AdminTheme.card(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: stat.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(stat.icon, size: 18, color: stat.color),
                      ),
                      const Spacer(),
                      Text(
                        stat.eng,
                        style: AdminTheme.caption.copyWith(fontSize: 10),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    stat.value,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: stat.color,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    stat.hindi,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AdminTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildChart(List<int> rDist, List<String> qL, List<double> qS, List<String> wL, List<int> wC, List<double> wR) {
    switch (_chartTab) {
      case 0:
        return _buildRatingDist(rDist);
      case 1:
        return _buildQBreakdown(qL, qS);
      default:
        return _buildWeekly(wL, wC, wR);
    }
  }

  Widget _buildRatingDist(List<int> rDist) {
    final total = rDist.fold<int>(0, (a, b) => a + b);
    final maxVal = rDist.isEmpty ? 1.0 : (rDist.reduce(math.max).toDouble() == 0 ? 1.0 : rDist.reduce(math.max).toDouble());
    final barColors = [
      AdminTheme.danger,
      const Color(0xFFE65100),
      AdminTheme.warning,
      AdminTheme.accent,
      AdminTheme.success,
    ];

    return Container(
      key: const ValueKey('rd'),
      padding: const EdgeInsets.all(20),
      decoration: AdminTheme.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _chartHeader('Rating Distribution', 'रेटिंग वितरण'),
          const SizedBox(height: 20),
          ...List.generate(5, (i) {
            final star = 5 - i;
            final count = rDist[star - 1];
            final pct = total == 0 ? 0.0 : count / total * 100;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  SizedBox(
                    width: 22,
                    child: Text(
                      '$star',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AdminTheme.textSecondary,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.star_rounded,
                    size: 14,
                    color: Color(0xFFE6A817),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AnimatedBuilder(
                      animation: _anim,
                      builder: (_, __) => ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: (count / maxVal) * _anim.value,
                          minHeight: 28,
                          backgroundColor: AdminTheme.bg,
                          valueColor: AlwaysStoppedAnimation(barColors[i]),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 72,
                    child: Text(
                      '$count  (${pct.toStringAsFixed(0)}%)',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AdminTheme.textSecondary,
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

  Widget _buildQBreakdown(List<String> qLabels, List<double> qScores) {
    return Container(
      key: const ValueKey('qb'),
      padding: const EdgeInsets.all(20),
      decoration: AdminTheme.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _chartHeader('Per-Question Analysis', 'प्रश्न-वार विश्लेषण'),
          const SizedBox(height: 20),
          if (qLabels.length == 1 && qLabels[0] == 'No Data Yet')
             const Text('Not enough data to analyze individual questions', style: TextStyle(color: AdminTheme.textMuted)),
          if (!(qLabels.length == 1 && qLabels[0] == 'No Data Yet'))
          ...List.generate(qLabels.length, (i) {
            final score = qScores[i];
            final color = _scoreColor(score);
            return Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(qLabels[i], style: AdminTheme.label),
                      Text(
                        '${score.toStringAsFixed(1)} / 5',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  AnimatedBuilder(
                    animation: _anim,
                    builder: (_, __) => ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: LinearProgressIndicator(
                        value: (score / 5.0) * _anim.value,
                        minHeight: 8,
                        backgroundColor: AdminTheme.bg,
                        valueColor: AlwaysStoppedAnimation(color),
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

  Widget _buildWeekly(List<String> wLabels, List<int> wCounts, List<double> wRatings) {
    return Container(
      key: const ValueKey('wt'),
      padding: const EdgeInsets.all(20),
      decoration: AdminTheme.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _chartHeader('Weekly Trend', 'साप्ताहिक रुझान'),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: AnimatedBuilder(
              animation: _anim,
              builder: (_, __) => CustomPaint(
                size: const Size(double.infinity, 180),
                painter: _WeeklyPainter(
                  progress: _anim.value,
                  counts: wCounts.isEmpty ? [0] : wCounts,
                  ratings: wRatings.isEmpty ? [0.0] : wRatings,
                  labels: wLabels.isEmpty ? [''] : wLabels,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _legendDot(AdminTheme.primary, 'Feedback count'),
              const SizedBox(width: 16),
              _legendDot(AdminTheme.warning, 'Avg rating'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color c, String label) => Row(
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
      Text(label, style: AdminTheme.caption),
    ],
  );

  Widget _buildRecent(List<_FbRow> recentFbs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Recent Feedbacks', style: AdminTheme.sectionTitle),
            const SizedBox(width: 8),
            Text('हाल की प्रतिक्रियाएँ', style: AdminTheme.caption),
          ],
        ),
        const SizedBox(height: 12),
        if (recentFbs.isEmpty)
          Container(
             width: double.infinity,
             padding: const EdgeInsets.all(20),
             decoration: AdminTheme.card(),
             child: const Center(child: Text("No feedbacks recorded yet.", style: TextStyle(color: AdminTheme.textMuted)))
          )
        else
        Container(
          decoration: AdminTheme.card(),
          child: Column(
            children: recentFbs.asMap().entries.map((e) {
              final i = e.key;
              final fb = e.value;
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  border: i < recentFbs.length - 1
                      ? const Border(
                          bottom: BorderSide(
                            color: AdminTheme.border,
                            width: 1,
                          ),
                        )
                      : null,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _ratingColor(fb.rating).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          fb.name.characters.first,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _ratingColor(fb.rating),
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
                              color: AdminTheme.textPrimary,
                            ),
                          ),
                          Text(fb.comment, style: AdminTheme.caption),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                        5,
                        (s) => Icon(
                          s < fb.rating
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          size: 15,
                          color: s < fb.rating
                              ? const Color(0xFFE6A817)
                              : AdminTheme.border,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(fb.time, style: AdminTheme.caption),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _chartHeader(String eng, String hindi) => Row(
    children: [
      Text(eng, style: AdminTheme.sectionTitle),
      const SizedBox(width: 8),
      Text(hindi, style: AdminTheme.caption),
    ],
  );

  Color _scoreColor(double s) {
    if (s >= 4.5) return AdminTheme.success;
    if (s >= 4.0) return AdminTheme.accent;
    if (s >= 3.5) return AdminTheme.warning;
    return AdminTheme.danger;
  }

  Color _ratingColor(int r) {
    if (r >= 5) return AdminTheme.success;
    if (r >= 4) return AdminTheme.accent;
    if (r >= 3) return AdminTheme.warning;
    return AdminTheme.danger;
  }
}

// ─── Weekly Bar+Line Painter ─────────────────────────────────────────
class _WeeklyPainter extends CustomPainter {
  final double progress;
  final List<int> counts;
  final List<double> ratings;
  final List<String> labels;

  _WeeklyPainter({
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

    final bgPaint = Paint()..color = AdminTheme.bg;
    final barPaint = Paint()..color = AdminTheme.primary.withOpacity(0.85);
    final gridP = Paint()
      ..color = AdminTheme.border.withOpacity(0.6)
      ..strokeWidth = 1;

    // grid
    for (int g = 0; g <= 4; g++) {
      final y = top + h * (g / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridP);
    }

    for (int i = 0; i < n; i++) {
      final x = bw * i + bw * 0.18;
      final w = bw * 0.64;
      final frac = (counts[i] / maxC) * progress;
      final barH = h * frac;
      final barTop = bottom - barH;

      // bg
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, top, w, h),
          const Radius.circular(5),
        ),
        bgPaint,
      );
      // bar
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, barTop, w, barH),
          const Radius.circular(5),
        ),
        barPaint,
      );

      // label
      final tp = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AdminTheme.textMuted,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x + w / 2 - tp.width / 2, bottom + 6));
    }

    // rating line
    if (progress > 0.3) {
      final lp = ((progress - 0.3) / 0.7).clamp(0.0, 1.0);
      final linePaint = Paint()
        ..color = AdminTheme.warning
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      final dotPaint = Paint()..color = AdminTheme.warning;

      final path = Path();
      final vis = (n * lp).ceil().clamp(0, n);
      for (int i = 0; i < vis; i++) {
        final cx = bw * i + bw * 0.5;
        final cy = bottom - h * ((ratings[i] - 3) / 2).clamp(0.0, 1.0);
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
  bool shouldRepaint(_WeeklyPainter o) => o.progress != progress;
}

// ─── Data models ─────────────────────────────────────────────────────
class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String hindi;
  const _NavItem(this.icon, this.activeIcon, this.label, this.hindi);
}

class _Stat {
  final String eng;
  final String hindi;
  final String value;
  final IconData icon;
  final Color color;
  const _Stat(this.eng, this.hindi, this.value, this.icon, this.color);
}

class _FbRow {
  final String name;
  final int rating;
  final String time;
  final String comment;
  const _FbRow(this.name, this.rating, this.time, this.comment);
}
