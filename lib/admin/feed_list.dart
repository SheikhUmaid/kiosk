import 'package:flutter/material.dart';
import 'admin_theme.dart';

class FeedListPage extends StatefulWidget {
  const FeedListPage({super.key});

  @override
  State<FeedListPage> createState() => _FeedListPageState();
}

class _FeedListPageState extends State<FeedListPage> {
  String _search = '';
  int _filterRating = 0; // 0 = all
  String _sortBy = 'Newest';
  final _sorts = ['Newest', 'Oldest', 'Highest Rating', 'Lowest Rating'];

  // ── Mock data ────────────────────────────────────────────────────
  static final _allFeedbacks = List<_Feedback>.unmodifiable([
    _Feedback(
      '1001',
      'राम कुमार',
      5,
      '10:42 AM',
      '22 Feb 2026',
      '9876543210',
      'ACC-001',
      'बहुत बढ़िया सेवा मिली। कर्मचारी बहुत सहायक थे।',
      {'सेवा': 5, 'कर्मचारी': 5, 'सुविधा': 4, 'प्रतीक्षा': 4, 'पुनः': 5},
    ),
    _Feedback(
      '1002',
      'सीता देवी',
      4,
      '10:28 AM',
      '22 Feb 2026',
      '9876543211',
      'ACC-002',
      'अच्छा अनुभव रहा।',
      {'सेवा': 4, 'कर्मचारी': 4, 'सुविधा': 4, 'प्रतीक्षा': 3, 'पुनः': 4},
    ),
    _Feedback(
      '1003',
      'अजय सिंह',
      3,
      '10:15 AM',
      '22 Feb 2026',
      '9876543212',
      'ACC-003',
      'ठीक-ठाक अनुभव था, कुछ सुधार की जरूरत है।',
      {'सेवा': 3, 'कर्मचारी': 3, 'सुविधा': 3, 'प्रतीक्षा': 2, 'पुनः': 3},
    ),
    _Feedback(
      '1004',
      'प्रिया शर्मा',
      5,
      '09:58 AM',
      '22 Feb 2026',
      '9876543213',
      'ACC-004',
      'बहुत संतुष्ट हूँ।',
      {'सेवा': 5, 'कर्मचारी': 5, 'सुविधा': 5, 'प्रतीक्षा': 5, 'पुनः': 5},
    ),
    _Feedback(
      '1005',
      'विजय पटेल',
      2,
      '09:41 AM',
      '22 Feb 2026',
      '9876543214',
      'ACC-005',
      'प्रतीक्षा समय बहुत लंबा था।',
      {'सेवा': 2, 'कर्मचारी': 3, 'सुविधा': 2, 'प्रतीक्षा': 1, 'पुनः': 2},
    ),
    _Feedback(
      '1006',
      'मीना गुप्ता',
      4,
      '09:30 AM',
      '22 Feb 2026',
      '9876543215',
      'ACC-006',
      'अच्छी सेवा।',
      {'सेवा': 4, 'कर्मचारी': 4, 'सुविधा': 4, 'प्रतीक्षा': 3, 'पुनः': 4},
    ),
    _Feedback(
      '1007',
      'रोहित वर्मा',
      5,
      '09:12 AM',
      '21 Feb 2026',
      '9876543216',
      'ACC-007',
      'उत्कृष्ट सेवा!',
      {'सेवा': 5, 'कर्मचारी': 5, 'सुविधा': 5, 'प्रतीक्षा': 4, 'पुनः': 5},
    ),
    _Feedback(
      '1008',
      'अनीता यादव',
      4,
      '08:55 AM',
      '21 Feb 2026',
      '9876543217',
      'ACC-008',
      'संतोषजनक अनुभव।',
      {'सेवा': 4, 'कर्मचारी': 4, 'सुविधा': 3, 'प्रतीक्षा': 3, 'पुनः': 4},
    ),
    _Feedback(
      '1009',
      'सुरेश मिश्र',
      1,
      '08:30 AM',
      '21 Feb 2026',
      '9876543218',
      'ACC-009',
      'बहुत खराब अनुभव।',
      {'सेवा': 1, 'कर्मचारी': 1, 'सुविधा': 2, 'प्रतीक्षा': 1, 'पुनः': 1},
    ),
    _Feedback(
      '1010',
      'कविता सिंह',
      5,
      '08:10 AM',
      '21 Feb 2026',
      '9876543219',
      'ACC-010',
      'शानदार सेवा।',
      {'सेवा': 5, 'कर्मचारी': 5, 'सुविधा': 5, 'प्रतीक्षा': 5, 'पुनः': 5},
    ),
  ]);

  _Feedback? _expanded;

  List<_Feedback> get _filtered {
    var list = _allFeedbacks.where((f) {
      final q = _search.toLowerCase();
      final matchSearch =
          q.isEmpty ||
          f.name.toLowerCase().contains(q) ||
          f.id.contains(q) ||
          f.account.toLowerCase().contains(q);
      final matchRating = _filterRating == 0 || f.rating == _filterRating;
      return matchSearch && matchRating;
    }).toList();

    switch (_sortBy) {
      case 'Oldest':
        list = list.reversed.toList();
        break;
      case 'Highest Rating':
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'Lowest Rating':
        list.sort((a, b) => a.rating.compareTo(b.rating));
        break;
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final list = _filtered;

    return Column(
      children: [
        // ── Toolbar ─────────────────────────────────────────────
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            children: [
              // Search
              Expanded(
                flex: 4,
                child: TextField(
                  onChanged: (v) => setState(() => _search = v),
                  style: const TextStyle(
                    fontSize: 14,
                    color: AdminTheme.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search by name, ID, account…',
                    hintStyle: const TextStyle(
                      color: AdminTheme.textMuted,
                      fontSize: 13,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      size: 18,
                      color: AdminTheme.textMuted,
                    ),
                    filled: true,
                    fillColor: AdminTheme.bg,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AdminTheme.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AdminTheme.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: AdminTheme.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Rating filter
              ...List.generate(5, (i) {
                final r = i + 1;
                final active = _filterRating == r;
                return Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: GestureDetector(
                    onTap: () => setState(() => _filterRating = active ? 0 : r),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: active ? AdminTheme.primary : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: active
                              ? AdminTheme.primary
                              : AdminTheme.border,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star_rounded,
                            size: 13,
                            color: active
                                ? Colors.white
                                : const Color(0xFFE6A817),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '$r',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: active
                                  ? Colors.white
                                  : AdminTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              const SizedBox(width: 12),

              // Sort
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _sortBy,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AdminTheme.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  items: _sorts
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) => setState(() => _sortBy = v ?? _sortBy),
                ),
              ),
            ],
          ),
        ),

        // ── Table header ─────────────────────────────────────
        Container(
          color: AdminTheme.bg,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Row(
            children: [
              _th('#', flex: 1),
              _th('Name', flex: 3),
              _th('Account', flex: 2),
              _th('Mobile', flex: 2),
              _th('Rating', flex: 2),
              _th('Date', flex: 2),
              _th('Time', flex: 2),
              _th('', flex: 1),
            ],
          ),
        ),
        const Divider(height: 1, color: AdminTheme.border),

        // ── List ─────────────────────────────────────────────
        Expanded(
          child: list.isEmpty
              ? _emptyState()
              : ListView.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: AdminTheme.border),
                  itemBuilder: (_, i) {
                    final fb = list[i];
                    final isExp = _expanded?.id == fb.id;
                    return Column(
                      children: [
                        _buildRow(fb, isExp),
                        if (isExp) _buildDetail(fb),
                      ],
                    );
                  },
                ),
        ),

        // ── Footer ───────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          color: Colors.white,
          child: Row(
            children: [
              Text(
                '${list.length} record${list.length == 1 ? '' : 's'} found',
                style: AdminTheme.caption,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _th(String t, {required int flex}) => Expanded(
    flex: flex,
    child: Text(
      t.toUpperCase(),
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: AdminTheme.textMuted,
        letterSpacing: 0.8,
      ),
    ),
  );

  Widget _buildRow(_Feedback fb, bool expanded) {
    final ratedColor = _ratingColor(fb.rating);
    return InkWell(
      onTap: () => setState(() => _expanded = expanded ? null : fb),
      hoverColor: AdminTheme.primaryXLight.withOpacity(0.3),
      child: Container(
        color: expanded ? AdminTheme.primaryXLight : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Text(
                fb.id,
                style: AdminTheme.caption.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: ratedColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        fb.name.characters.first,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: ratedColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      fb.name,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AdminTheme.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(fb.account, style: AdminTheme.caption),
            ),
            Expanded(
              flex: 2,
              child: Text(fb.mobile, style: AdminTheme.caption),
            ),
            Expanded(
              flex: 2,
              child: Row(
                children: List.generate(
                  5,
                  (s) => Icon(
                    s < fb.rating
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: 14,
                    color: s < fb.rating
                        ? const Color(0xFFE6A817)
                        : AdminTheme.border,
                  ),
                ),
              ),
            ),
            Expanded(flex: 2, child: Text(fb.date, style: AdminTheme.caption)),
            Expanded(flex: 2, child: Text(fb.time, style: AdminTheme.caption)),
            Expanded(
              flex: 1,
              child: Icon(
                expanded
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: AdminTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetail(_Feedback fb) {
    return Container(
      color: AdminTheme.primaryXLight,
      padding: const EdgeInsets.fromLTRB(80, 0, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(color: AdminTheme.border),
          Text('Comment:', style: AdminTheme.label),
          const SizedBox(height: 4),
          Text(
            fb.comment,
            style: const TextStyle(
              fontSize: 13,
              color: AdminTheme.textPrimary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          Text('Per-question ratings:', style: AdminTheme.label),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: fb.answers.entries.map((e) {
              final c = _ratingColor(e.value);
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: c.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: c.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      e.key,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AdminTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(Icons.star_rounded, size: 13, color: c),
                    Text(
                      ' ${e.value}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: c,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.inbox_outlined,
          size: 52,
          color: AdminTheme.textMuted.withOpacity(0.5),
        ),
        const SizedBox(height: 12),
        const Text(
          'No feedback found',
          style: TextStyle(
            fontSize: 15,
            color: AdminTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Text(
          'Try adjusting the search or filters.',
          style: AdminTheme.caption,
        ),
      ],
    ),
  );

  Color _ratingColor(int r) {
    if (r >= 5) return AdminTheme.success;
    if (r >= 4) return AdminTheme.accent;
    if (r >= 3) return AdminTheme.warning;
    return AdminTheme.danger;
  }
}

class _Feedback {
  final String id, name, time, date, mobile, account, comment;
  final int rating;
  final Map<String, int> answers;

  const _Feedback(
    this.id,
    this.name,
    this.rating,
    this.time,
    this.date,
    this.mobile,
    this.account,
    this.comment,
    this.answers,
  );
}
