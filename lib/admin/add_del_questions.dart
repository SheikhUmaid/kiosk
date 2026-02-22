import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kiosk/providers/question_provider.dart';
import 'admin_theme.dart';

class AddDelQuestionsPage extends StatefulWidget {
  const AddDelQuestionsPage({super.key});

  @override
  State<AddDelQuestionsPage> createState() => _AddDelQuestionsPageState();
}

class _AddDelQuestionsPageState extends State<AddDelQuestionsPage> {


  void _addQuestion(QuestionProvider provider) {
    showDialog(
      context: context,
      builder: (context) => _QuestionDialog(
        onSave: (eng, hindi) {
          provider.addQuestion(eng, hindi);
        },
      ),
    );
  }

  void _editQuestion(QuestionProvider provider, int id, String eng, String hindi) {
    showDialog(
      context: context,
      builder: (context) => _QuestionDialog(
        initialEng: eng,
        initialHindi: hindi,
        onSave: (newEng, newHindi) {
          provider.editQuestion(id, newEng, newHindi);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QuestionProvider>();
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    final questions = provider.questions;

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
                  onPressed: () => _addQuestion(provider),
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
                  itemCount: questions.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: AdminTheme.border),
                  itemBuilder: (_, i) {
                    final q = questions[i];
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
                        q['eng'],
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          q['hindi'],
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
                            onPressed: () => _editQuestion(provider, q['id'], q['eng'], q['hindi']),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              color: AdminTheme.danger,
                            ),
                            onPressed: () {
                              provider.deleteQuestion(q['id']);
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
