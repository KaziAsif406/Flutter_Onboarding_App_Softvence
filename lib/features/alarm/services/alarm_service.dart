import 'package:sqflite/sqflite.dart';
import '../models/alarm_model.dart';
import 'database_service.dart';
import 'notification_service.dart';

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

      // Schedule notification
      if (newAlarm.isEnabled) {
        await NotificationService.scheduleAlarmNotification(
          alarmId: newAlarm.id,
          alarmDateTime: newAlarm.dateTime,
          alarmLabel: newAlarm.label ?? 'Alarm',
        );
      }

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

      // Cancel existing notification and reschedule if enabled
      await NotificationService.cancelAlarmNotification(alarm.id);

      if (alarm.isEnabled) {
        await NotificationService.scheduleAlarmNotification(
          alarmId: alarm.id,
          alarmDateTime: alarm.dateTime,
          alarmLabel: alarm.label ?? 'Alarm',
        );
      }
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

      // Handle notification scheduling
      if (enabled) {
        // Fetch alarm details to schedule notification
        final maps = await db.query(
          tableName,
          where: 'id = ?',
          whereArgs: [alarmId],
        );

        if (maps.isNotEmpty) {
          final alarm = AlarmModel.fromMap(maps.first);
          await NotificationService.scheduleAlarmNotification(
            alarmId: alarmId,
            alarmDateTime: alarm.dateTime,
            alarmLabel: alarm.label ?? 'Alarm',
          );
        }
      } else {
        // Cancel notification if alarm is disabled
        await NotificationService.cancelAlarmNotification(alarmId);
      }
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

      // Cancel notification
      await NotificationService.cancelAlarmNotification(alarmId);
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

      // Cancel all notifications
      await NotificationService.cancelAllNotifications();
    } catch (e) {
      throw Exception('Failed to clear alarms: $e');
    }
  }
}
