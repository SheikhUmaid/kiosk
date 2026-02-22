import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class FeedbackProvider extends ChangeNotifier {
  Database? _db;

  // Active form state
  String? phone;
  String? firstName;
  String? lastName;
  String? unitNumber;
  Map<String, int> answers = {}; // "Question Text" -> Rating
  String? remarks;
  String? selfiePath;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  List<Map<String, dynamic>> _feedbacks = [];
  List<Map<String, dynamic>> get feedbacks => _feedbacks;

  FeedbackProvider() {
    _initDb();
  }

  Future<void> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'kiosk_feedbacks.db');

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE feedbacks (id INTEGER PRIMARY KEY AUTOINCREMENT, phone TEXT, firstName TEXT, lastName TEXT, unitNumber TEXT, answers TEXT, remarks TEXT, selfiePath TEXT, timestamp TEXT)',
        );
      },
    );
    await fetchFeedbacks();
  }

  Future<void> fetchFeedbacks() async {
    if (_db == null) return;
    _feedbacks = await _db!.query('feedbacks', orderBy: 'id DESC');
    _isLoading = false;
    notifyListeners();
  }

  // Setters for the current flow
  void setDetails(String p, String f, String l, String u) {
    phone = p;
    firstName = f;
    lastName = l;
    unitNumber = u;
    notifyListeners();
  }

  void addAnswer(String questionIdentifier, int rating) {
    answers[questionIdentifier] = rating;
    notifyListeners();
  }

  void setRemarks(String r) {
    remarks = r;
    notifyListeners();
  }

  Future<void> submitFeedback(String spath) async {
    if (_db == null) return;
    
    final data = {
      'phone': phone ?? '',
      'firstName': firstName ?? '',
      'lastName': lastName ?? '',
      'unitNumber': unitNumber ?? '',
      'answers': jsonEncode(answers),
      'remarks': remarks ?? '',
      'selfiePath': spath,
      'timestamp': DateTime.now().toIso8601String(),
    };

    await _db!.insert('feedbacks', data);

    // clear active form
    phone = null;
    firstName = null;
    lastName = null;
    unitNumber = null;
    answers.clear();
    remarks = null;
    selfiePath = null;
    
    await fetchFeedbacks();
  }

  Future<void> deleteFeedback(int id) async {
    if (_db == null) return;
    await _db!.delete(
      'feedbacks',
      where: 'id = ?',
      whereArgs: [id],
    );
    await fetchFeedbacks();
  }

  Future<void> updateFeedbackDetails(int id, {String? firstName, String? lastName, String? phone, String? unitNumber, String? remarks}) async {
    if (_db == null) return;
    
    final data = <String, dynamic>{};
    if (firstName != null) data['firstName'] = firstName;
    if (lastName != null) data['lastName'] = lastName;
    if (phone != null) data['phone'] = phone;
    if (unitNumber != null) data['unitNumber'] = unitNumber;
    if (remarks != null) data['remarks'] = remarks;
    
    if (data.isNotEmpty) {
      await _db!.update(
        'feedbacks',
        data,
        where: 'id = ?',
        whereArgs: [id],
      );
      await fetchFeedbacks();
    }
  }
}

