import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class QuestionProvider extends ChangeNotifier {
  Database? _db;
  List<Map<String, dynamic>> _questions = [];

  List<Map<String, dynamic>> get questions => _questions;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  QuestionProvider() {
    _initDb();
  }

  Future<void> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'kiosk_questions.db');

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE questions (id INTEGER PRIMARY KEY AUTOINCREMENT, eng TEXT, hindi TEXT)',
        );
        // Insert default questions
        await db.insert('questions', {'eng': 'How was the service quality?', 'hindi': 'सेवा की गुणवत्ता कैसी थी?'});
        await db.insert('questions', {'eng': 'How was the staff behavior?', 'hindi': 'कर्मचारियों का व्यवहार कैसा था?'});
        await db.insert('questions', {'eng': 'How would you rate the facilities?', 'hindi': 'आप सुविधाओं को कैसे रेट करेंगे?'});
        await db.insert('questions', {'eng': 'How was the waiting time?', 'hindi': 'प्रतीक्षा समय कैसा था?'});
        await db.insert('questions', {'eng': 'Will you visit again?', 'hindi': 'क्या आप फिर से आएंगे?'});
      },
    );
    await _fetchQuestions();
  }

  Future<void> _fetchQuestions() async {
    if (_db == null) return;
    _questions = await _db!.query('questions');
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addQuestion(String eng, String hindi) async {
    if (_db == null) return;
    await _db!.insert('questions', {'eng': eng, 'hindi': hindi});
    await _fetchQuestions();
  }

  Future<void> editQuestion(int id, String eng, String hindi) async {
    if (_db == null) return;
    await _db!.update(
      'questions',
      {'eng': eng, 'hindi': hindi},
      where: 'id = ?',
      whereArgs: [id],
    );
    await _fetchQuestions();
  }

  Future<void> deleteQuestion(int id) async {
    if (_db == null) return;
    await _db!.delete(
      'questions',
      where: 'id = ?',
      whereArgs: [id],
    );
    await _fetchQuestions();
  }
}
