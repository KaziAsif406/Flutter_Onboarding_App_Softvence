import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static Database? _database;
  static const String _databaseName = 'alarms.db';
  static const String _alarmsTable = 'alarms';
  static const int _databaseVersion = 1;

  /// Get database instance
  static Future<Database> getDatabase() async {
    _database ??= await _initializeDatabase();
    return _database!;
  }

  /// Initialize database
  static Future<Database> _initializeDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _createDatabase,
    );
  }

  /// Create database tables
  static Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_alarmsTable (
        id TEXT PRIMARY KEY,
        dateTime TEXT NOT NULL,
        label TEXT,
        isEnabled INTEGER NOT NULL
      )
    ''');
  }

  /// Get alarms table name
  static String getAlarmsTable() => _alarmsTable;

  /// Close database
  static Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
