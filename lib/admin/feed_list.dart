import 'package:flutter/material.dart';
import 'dart:convert';
import 'admin_theme.dart';
import 'package:provider/provider.dart';
import 'package:kiosk/providers/feedback_provider.dart';

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

  _Feedback? _expanded;

  List<_Feedback> _getFiltered(List<_Feedback> allFeedbacks) {
    var list = allFeedbacks.where((f) {
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

  Future<void> _confirmDelete(BuildContext context, _Feedback fb) async {
    final provider = context.read<FeedbackProvider>();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Feedback'),
        content: Text('Are you sure you want to delete feedback from ${fb.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: AdminTheme.danger)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await provider.deleteFeedback(int.parse(fb.id));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Feedback deleted')));
        setState(() {
          if (_expanded?.id == fb.id) _expanded = null;
        });
      }
    }
  }

  Future<void> _editFeedback(BuildContext context, _Feedback fb) async {
    final provider = context.read<FeedbackProvider>();
    
    final fnCtrl = TextEditingController(text: fb.firstName);
    final lnCtrl = TextEditingController(text: fb.lastName);
    final phCtrl = TextEditingController(text: fb.mobile != '-' ? fb.mobile : '');
    final unCtrl = TextEditingController(text: fb.account != '-' ? fb.account : '');
    final remCtrl = TextEditingController(text: fb.comment);

    final save = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Feedback'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: fnCtrl, decoration: const InputDecoration(labelText: 'First Name')),
              TextField(controller: lnCtrl, decoration: const InputDecoration(labelText: 'Last Name')),
              TextField(controller: phCtrl, decoration: const InputDecoration(labelText: 'Phone')),
              TextField(controller: unCtrl, decoration: const InputDecoration(labelText: 'Unit Number / Account')),
              TextField(controller: remCtrl, decoration: const InputDecoration(labelText: 'Remarks')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
             onPressed: () => Navigator.pop(ctx, true), 
             child: const Text('Save', style: TextStyle(color: AdminTheme.primary))
          ),
        ],
      ),
    );

    if (save == true) {
      await provider.updateFeedbackDetails(
        int.parse(fb.id),
        firstName: fnCtrl.text.trim(),
        lastName: lnCtrl.text.trim(),
        phone: phCtrl.text.trim(),
        unitNumber: unCtrl.text.trim(),
        remarks: remCtrl.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Feedback updated')));
        setState(() {
          _expanded = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FeedbackProvider>();
    
    final allFeedbacks = provider.feedbacks.map((f) {
      final idStr = (f['id'] ?? '').toString();
      final nameStr = '${f['firstName'] ?? ''} ${f['lastName'] ?? ''}'.trim();
      
      String timeStr = '';
      String dateStr = '';
      if (f['timestamp'] != null) {
        final dt = DateTime.parse(f['timestamp']).toLocal();
        dateStr = "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}";
        timeStr = "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
      }

      Map<String, int> answers = {};
      if (f['answers'] != null && f['answers'].toString().isNotEmpty) {
        try {
          final decoded = jsonDecode(f['answers']) as Map<String, dynamic>;
          answers = decoded.map((k, v) => MapEntry(k, int.parse(v.toString())));
        } catch (_) {}
      }

      int avgRating = 0;
      if (answers.isNotEmpty) {
        int sum = 0;
        answers.values.forEach((v) => sum += v);
        avgRating = (sum / answers.length).round();
      }

      return _Feedback(
        idStr,
        f['firstName'] ?? '',
        f['lastName'] ?? '',
        nameStr.isEmpty ? 'Unknown' : nameStr,
        avgRating,
        timeStr,
        dateStr,
        f['phone'] ?? '-',
        f['unitNumber'] ?? '-',
        f['remarks'] ?? '',
        answers,
      );
    }).toList();

    final list = _getFiltered(allFeedbacks);

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
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => _editFeedback(context, fb),
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Edit'),
                style: TextButton.styleFrom(foregroundColor: AdminTheme.primary),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () => _confirmDelete(context, fb),
                icon: const Icon(Icons.delete_outline, size: 16),
                label: const Text('Delete'),
                style: TextButton.styleFrom(foregroundColor: AdminTheme.danger),
              ),
            ],
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
  final String id, firstName, lastName, name, time, date, mobile, account, comment;
  final int rating;
  final Map<String, int> answers;

  const _Feedback(
    this.id,
    this.firstName,
    this.lastName,
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
