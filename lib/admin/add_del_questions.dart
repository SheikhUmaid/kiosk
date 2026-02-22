import 'package:flutter/material.dart';
import 'admin_theme.dart';

class AddDelQuestionsPage extends StatefulWidget {
  const AddDelQuestionsPage({super.key});

  @override
  State<AddDelQuestionsPage> createState() => _AddDelQuestionsPageState();
}

class _AddDelQuestionsPageState extends State<AddDelQuestionsPage> {
  final List<Map<String, String>> _questions = [
    {
      'eng': 'How was the service quality?',
      'hindi': 'सेवा की गुणवत्ता कैसी थी?',
    },
    {
      'eng': 'How was the staff behavior?',
      'hindi': 'कर्मचारियों का व्यवहार कैसा था?',
    },
    {
      'eng': 'How would you rate the facilities?',
      'hindi': 'आप सुविधाओं को कैसे रेट करेंगे?',
    },
    {'eng': 'How was the waiting time?', 'hindi': 'प्रतीक्षा समय कैसा था?'},
    {'eng': 'Will you visit again?', 'hindi': 'क्या आप फिर से आएंगे?'},
  ];

  void _addQuestion() {
    showDialog(
      context: context,
      builder: (context) => _QuestionDialog(
        onSave: (eng, hindi) {
          setState(() {
            _questions.add({'eng': eng, 'hindi': hindi});
          });
        },
      ),
    );
  }

  void _editQuestion(int index) {
    showDialog(
      context: context,
      builder: (context) => _QuestionDialog(
        initialEng: _questions[index]['eng'],
        initialHindi: _questions[index]['hindi'],
        onSave: (eng, hindi) {
          setState(() {
            _questions[index] = {'eng': eng, 'hindi': hindi};
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Manage Questions',
                      style: AdminTheme.sectionTitle,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'प्रतिक्रिया प्रश्नों को जोड़ें या हटाएं',
                      style: AdminTheme.caption,
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: _addQuestion,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('ADD NEW'),
                  style: AdminTheme.primaryButton,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Container(
                decoration: AdminTheme.card(),
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _questions.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: AdminTheme.border),
                  itemBuilder: (_, i) {
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: AdminTheme.primaryXLight,
                        child: Text(
                          '${i + 1}',
                          style: const TextStyle(
                            color: AdminTheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        _questions[i]['eng']!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          _questions[i]['hindi']!,
                          style: TextStyle(
                            color: AdminTheme.textMuted,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.edit_outlined,
                              color: AdminTheme.primary,
                            ),
                            onPressed: () => _editQuestion(i),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              color: AdminTheme.danger,
                            ),
                            onPressed: () {
                              setState(() {
                                _questions.removeAt(i);
                              });
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionDialog extends StatefulWidget {
  final String? initialEng;
  final String? initialHindi;
  final Function(String eng, String hindi) onSave;

  const _QuestionDialog({
    this.initialEng,
    this.initialHindi,
    required this.onSave,
  });

  @override
  State<_QuestionDialog> createState() => _QuestionDialogState();
}

class _QuestionDialogState extends State<_QuestionDialog> {
  late TextEditingController _engController;
  late TextEditingController _hindiController;

  @override
  void initState() {
    super.initState();
    _engController = TextEditingController(text: widget.initialEng);
    _hindiController = TextEditingController(text: widget.initialHindi);
  }

  @override
  void dispose() {
    _engController.dispose();
    _hindiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialEng == null ? 'Add Question' : 'Edit Question'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _engController,
              decoration: AdminTheme.inputDecor(
                'English Question',
                icon: Icons.language,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _hindiController,
              decoration: AdminTheme.inputDecor(
                'Hindi Question',
                icon: Icons.translate,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCEL'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_engController.text.isNotEmpty &&
                _hindiController.text.isNotEmpty) {
              widget.onSave(_engController.text, _hindiController.text);
              Navigator.pop(context);
            }
          },
          style: AdminTheme.primaryButton.copyWith(
            padding: WidgetStateProperty.all(
              const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
          ),
          child: const Text('SAVE'),
        ),
      ],
    );
  }
}
