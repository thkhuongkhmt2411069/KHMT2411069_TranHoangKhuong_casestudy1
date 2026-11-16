import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  Database? _database;

  Future<void> init() async {
    _database ??= await databaseFactoryFfiWeb.openDatabase('expense_manager.db',
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE transactions (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              type TEXT NOT NULL,
              category TEXT NOT NULL,
              amount REAL NOT NULL,
              date TEXT NOT NULL,
              note TEXT NOT NULL DEFAULT ''
            )
          ''');
          await db.insert('transactions', {
            'type': 'Chi tiêu',
            'category': 'Ăn uống',
            'amount': 50000,
            'date': DateTime(2024, 9, 3).toIso8601String(),
            'note': 'Ăn trưa',
          });
          await db.insert('transactions', {
            'type': 'Chi tiêu',
            'category': 'Di chuyển',
            'amount': 100000,
            'date': DateTime(2024, 9, 3).toIso8601String(),
            'note': 'Xăng xe',
          });
          await db.insert('transactions', {
            'type': 'Thu nhập',
            'category': 'Lương',
            'amount': 8000000,
            'date': DateTime(2024, 9, 1).toIso8601String(),
            'note': 'Lương tháng 9',
          });
          await db.insert('transactions', {
            'type': 'Chi tiêu',
            'category': 'Mua sắm',
            'amount': 300000,
            'date': DateTime(2024, 8, 31).toIso8601String(),
            'note': 'Mua sắm',
          });
          await db.insert('transactions', {
            'type': 'Chi tiêu',
            'category': 'Học tập',
            'amount': 500000,
            'date': DateTime(2024, 8, 30).toIso8601String(),
            'note': 'Học phí',
          });
        },
      ),
    );
  }

  Database get _db {
    final db = _database;
    if (db == null) throw StateError('Database chưa được khởi tạo');
    return db;
  }

  Future<int> insertTransaction(Map<String, Object?> data) =>
      _db.insert('transactions', data);

  Future<List<Map<String, dynamic>>> getTransactions() =>
      _db.query('transactions', orderBy: 'date DESC, id DESC');

  Future<int> updateTransaction(int id, Map<String, Object?> data) =>
      _db.update('transactions', data, where: 'id = ?', whereArgs: [id]);

  Future<int> deleteTransaction(int id) =>
      _db.delete('transactions', where: 'id = ?', whereArgs: [id]);

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
