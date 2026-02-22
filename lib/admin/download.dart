import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:kiosk/providers/feedback_provider.dart';
import 'admin_theme.dart';

class DownloadPage extends StatefulWidget {
  const DownloadPage({super.key});

  @override
  State<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {
  String _selectedFormat = 'CSV';
  DateTimeRange? _selectedDateRange;
  List<FileSystemEntity> _recentExports = [];

  @override
  void initState() {
    super.initState();
    _loadRecentExports();
  }

  Future<void> _loadRecentExports() async {
    try {
      final dbPath = await getApplicationDocumentsDirectory();
      final kioskDir = Directory('${dbPath.path}/kiosk_exports');
      if (await kioskDir.exists()) {
        final List<FileSystemEntity> entities = await kioskDir.list().toList();
        entities.sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
        setState(() {
          _recentExports = entities.take(5).toList();
        });
      }
    } catch (e) {
      debugPrint("Error loading recent: $e");
    }
  }

  Future<void> _generateReport() async {
    if (_selectedDateRange == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date range first'), backgroundColor: AdminTheme.danger),
      );
      return;
    }

    final provider = context.read<FeedbackProvider>();
    final allFbs = provider.feedbacks;

    // Filter by date
    final start = _selectedDateRange!.start;
    final end = _selectedDateRange!.end.add(const Duration(hours: 23, minutes: 59, seconds: 59));
    
    final filteredFbs = allFbs.where((f) {
      if (f['timestamp'] == null) return false;
      final dt = DateTime.parse(f['timestamp']).toLocal();
      return dt.isAfter(start) && dt.isBefore(end);
    }).toList();

    if (filteredFbs.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No feedback found in this date range.'), backgroundColor: AdminTheme.warning),
        );
      }
      return;
    }

    // Prepare header row
    List<String> qHeaders = [];
    if (filteredFbs.isNotEmpty) {
       for (var f in filteredFbs) {
          if (f['answers'] != null) {
             try {
               final dec = jsonDecode(f['answers']) as Map<String, dynamic>;
               for (var k in dec.keys) {
                  if (!qHeaders.contains(k)) qHeaders.add(k);
               }
             } catch(_) {}
          }
       }
    }
    List<String> headers = ['ID', 'Date', 'Time', 'First Name', 'Last Name', 'Phone', 'Unit Number', 'Remarks', ...qHeaders];

    // Prepare row data
    List<List<dynamic>> rows = [headers];
    for (var f in filteredFbs) {
       DateTime dt = DateTime.parse(f['timestamp']!).toLocal();
       String dateStr = "${dt.day.toString().padLeft(2,'0')}-${dt.month.toString().padLeft(2,'0')}-${dt.year}";
       String timeStr = "${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}";
       
       Map<String, dynamic> ans = {};
       if (f['answers'] != null) {
         try { ans = jsonDecode(f['answers']); } catch(_) {}
       }

       List<dynamic> row = [
         f['id'],
         dateStr,
         timeStr,
         f['firstName'] ?? '',
         f['lastName'] ?? '',
         f['phone'] ?? '',
         f['unitNumber'] ?? '',
         f['remarks'] ?? '',
       ];

       for (var h in qHeaders) {
          row.add(ans[h] ?? '');
       }
       rows.add(row);
    }

    // Save logic
    try {
      final dPath = await getApplicationDocumentsDirectory();
      final kDir = Directory('${dPath.path}/kiosk_exports');
      if (!(await kDir.exists())) {
         await kDir.create(recursive: true);
      }

      String fileName = 'Feedback_${start.year}${start.month}${start.day}_to_${end.year}${end.month}${end.day}';
      
      if (_selectedFormat == 'CSV') {
        String csvText = CsvCodec().encode(rows);
        final file = File('${kDir.path}/$fileName.csv');
        await file.writeAsString(csvText);
        _showSuccess(file.path);
      } else if (_selectedFormat == 'Excel') {
        var excel = Excel.createExcel();
        Sheet sheetObject = excel['Feedbacks'];
        excel.setDefaultSheet('Feedbacks');
        
        for (int i=0; i<rows.length; i++) {
           sheetObject.appendRow(rows[i].map((e) => TextCellValue(e.toString())).toList());
        }
        
        final fileBytes = excel.save();
        if (fileBytes != null) {
          final file = File('${kDir.path}/$fileName.xlsx');
          await file.writeAsBytes(fileBytes);
          _showSuccess(file.path);
        }
      } else if (_selectedFormat == 'PDF') {
         // Placeholder for PDF implementation
         if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('PDF generation coming soon!'), backgroundColor: AdminTheme.accent),
            );
         }
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e'), backgroundColor: AdminTheme.danger),
        );
      }
    }
  }

  void _showSuccess(String path) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saved to: $path'), backgroundColor: AdminTheme.success, duration: const Duration(seconds: 4)),
      );
      _loadRecentExports(); // refresh UI
    }
  }

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
                    onPressed: _generateReport,
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
        if (_recentExports.isEmpty)
           Container(
             width: double.infinity,
             padding: const EdgeInsets.all(24),
             decoration: AdminTheme.card(),
             child: const Center(child: Text("No exports generated yet.", style: TextStyle(color: AdminTheme.textMuted)))
           )
        else
        Container(
          decoration: AdminTheme.card(),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _recentExports.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, color: AdminTheme.border),
            itemBuilder: (_, i) {
              final file = _recentExports[i];
              final name = file.path.split(Platform.pathSeparator).last;
              final size = (File(file.path).lengthSync() / 1024).toStringAsFixed(1) + ' KB';
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
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text('Size: $size', style: AdminTheme.caption),
                trailing: TextButton(
                  onPressed: () {
                     // Since they are already on machine disk, we can notify the user of the path
                     ScaffoldMessenger.of(context).showSnackBar(
                       SnackBar(content: Text('File located at: ${file.path}')),
                     );
                  },
                  child: const Text('Show Path'),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
