import 'package:flutter/material.dart';
import 'admin_theme.dart';

class DownloadPage extends StatefulWidget {
  const DownloadPage({super.key});

  @override
  State<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {
  String _selectedFormat = 'CSV';
  DateTimeRange? _selectedDateRange;

  void _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AdminTheme.primary,
              onPrimary: Colors.white,
              onSurface: AdminTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDateRange = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Export Feedback Reports', style: AdminTheme.sectionTitle),
          const SizedBox(height: 8),
          Text(
            'डेटा को CSV या Excel प्रारूप में निर्यात करें',
            style: AdminTheme.caption,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: AdminTheme.card(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Report Configuration',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AdminTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 24),
                _buildOptionLabel('Select Date Range', 'तिथि सीमा चुनें'),
                const SizedBox(height: 12),
                InkWell(
                  onTap: _selectDateRange,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: AdminTheme.border),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 20,
                          color: AdminTheme.textSecondary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _selectedDateRange == null
                              ? 'Click to select range'
                              : '${_selectedDateRange!.start.toString().split(' ')[0]}  to  ${_selectedDateRange!.end.toString().split(' ')[0]}',
                          style: TextStyle(
                            color: _selectedDateRange == null
                                ? AdminTheme.textMuted
                                : AdminTheme.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.arrow_drop_down,
                          color: AdminTheme.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                _buildOptionLabel('Export Format', 'निर्यात प्रारूप'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _formatChip('CSV'),
                    const SizedBox(width: 12),
                    _formatChip('Excel'),
                    const SizedBox(width: 12),
                    _formatChip('PDF'),
                  ],
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Preparing $_selectedFormat report...'),
                          backgroundColor: AdminTheme.primary,
                        ),
                      );
                    },
                    icon: const Icon(Icons.download_rounded),
                    label: const Text('GENERATE REPORT'),
                    style: AdminTheme.primaryButton,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _buildRecentExports(),
        ],
      ),
    );
  }

  Widget _buildOptionLabel(String eng, String hindi) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(eng, style: AdminTheme.label),
        Text(hindi, style: AdminTheme.caption),
      ],
    );
  }

  Widget _formatChip(String format) {
    final selected = _selectedFormat == format;
    return InkWell(
      onTap: () => setState(() => _selectedFormat = format),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AdminTheme.primary : Colors.white,
          border: Border.all(
            color: selected ? AdminTheme.primary : AdminTheme.border,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          format,
          style: TextStyle(
            color: selected ? Colors.white : AdminTheme.textSecondary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildRecentExports() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recent Exports', style: AdminTheme.sectionTitle),
        const SizedBox(height: 12),
        Container(
          decoration: AdminTheme.card(),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, color: AdminTheme.border),
            itemBuilder: (_, i) {
              final dates = [
                'Oct 01 - Oct 31, 2024',
                'Sep 01 - Sep 30, 2024',
                'Aug 01 - Aug 31, 2024',
              ];
              return ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AdminTheme.primaryXLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.file_present_rounded,
                    color: AdminTheme.primary,
                    size: 20,
                  ),
                ),
                title: Text(
                  'Report_$i.csv',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(dates[i], style: AdminTheme.caption),
                trailing: TextButton(
                  onPressed: () {},
                  child: const Text('Download'),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
