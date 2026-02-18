import 'package:sqflite/sqflite.dart';
import '../models/alarm_model.dart';
import 'database_service.dart';

class AlarmService {
  /// Get all alarms
  static Future<List<AlarmModel>> getAllAlarms() async {
    try {
      final db = await DatabaseService.getDatabase();
      final tableName = DatabaseService.getAlarmsTable();

      final maps = await db.query(tableName, orderBy: 'dateTime ASC');

      return List.generate(maps.length, (i) => AlarmModel.fromMap(maps[i]));
    } catch (e) {
      throw Exception('Failed to get alarms: $e');
    }
  }

  /// Add a new alarm
  static Future<AlarmModel> addAlarm(DateTime dateTime, {String? label}) async {
    try {
      final db = await DatabaseService.getDatabase();
      final tableName = DatabaseService.getAlarmsTable();

      final newAlarm = AlarmModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        dateTime: dateTime,
        label: label,
      );

      await db.insert(
        tableName,
        newAlarm.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      return newAlarm;
    } catch (e) {
      throw Exception('Failed to add alarm: $e');
    }
  }

  /// Update alarm
  static Future<void> updateAlarm(AlarmModel alarm) async {
    try {
      final db = await DatabaseService.getDatabase();
      final tableName = DatabaseService.getAlarmsTable();

      await db.update(
        tableName,
        alarm.toMap(),
        where: 'id = ?',
        whereArgs: [alarm.id],
      );
    } catch (e) {
      throw Exception('Failed to update alarm: $e');
    }
  }

  /// Toggle alarm enabled status
  static Future<void> toggleAlarm(String alarmId, bool enabled) async {
    try {
      final db = await DatabaseService.getDatabase();
      final tableName = DatabaseService.getAlarmsTable();

      await db.update(
        tableName,
        {'isEnabled': enabled ? 1 : 0},
        where: 'id = ?',
        whereArgs: [alarmId],
      );
    } catch (e) {
      throw Exception('Failed to toggle alarm: $e');
    }
  }

  /// Delete alarm
  static Future<void> deleteAlarm(String alarmId) async {
    try {
      final db = await DatabaseService.getDatabase();
      final tableName = DatabaseService.getAlarmsTable();

      await db.delete(tableName, where: 'id = ?', whereArgs: [alarmId]);
    } catch (e) {
      throw Exception('Failed to delete alarm: $e');
    }
  }

  /// Clear all alarms
  static Future<void> clearAllAlarms() async {
    try {
      final db = await DatabaseService.getDatabase();
      final tableName = DatabaseService.getAlarmsTable();

      await db.delete(tableName);
    } catch (e) {
      throw Exception('Failed to clear alarms: $e');
    }
  }
}
