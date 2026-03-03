import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SystemProvider extends ChangeNotifier {
  Database? _db;
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  String _unitName = 'Kiosk System';
  String get unitName => _unitName;

  bool _isInstalled = false;
  bool get isInstalled => _isInstalled;

  SystemProvider() {
    _initDb();
  }

  Future<void> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'kiosk_settings.db');

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE settings (key TEXT PRIMARY KEY, value TEXT)',
        );
      },
    );

    await _loadSettings();
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _loadSettings() async {
    if (_db == null) return;
    
    final List<Map<String, dynamic>> maps = await _db!.query('settings');
    final settings = {for (var m in maps) m['key'] as String: m['value'] as String};

    _unitName = settings['unit_name'] ?? '342 COY ASC (SUP) Type D';
    _isInstalled = settings['is_installed'] == 'true';
    
    notifyListeners();
  }

  Future<void> saveSettings({required String unitName, required String adminPassword}) async {
    if (_db == null) return;

    await _db!.insert(
      'settings',
      {'key': 'unit_name', 'value': unitName},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await _db!.insert(
      'settings',
      {'key': 'admin_password', 'value': adminPassword},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await _db!.insert(
      'settings',
      {'key': 'is_installed', 'value': 'true'},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    await _loadSettings();
  }

  Future<bool> verifyAdminPassword(String password) async {
    if (_db == null) return false;
    
    final List<Map<String, dynamic>> maps = await _db!.query(
      'settings',
      where: 'key = ?',
      whereArgs: ['admin_password'],
    );

    if (maps.isEmpty) return password == 'admin123'; // Fallback for safety during dev
    return maps.first['value'] == password;
  }

  Future<void> updatePassword(String newPassword) async {
    if (_db == null) return;

    await _db!.insert(
      'settings',
      {'key': 'admin_password', 'value': newPassword},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
