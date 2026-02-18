import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/alarm_model.dart';

class AlarmService {
  static const String _alarmsKey = 'alarms_list';

  /// Get all alarms
  static Future<List<AlarmModel>> getAllAlarms() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final alarmsJson = prefs.getStringList(_alarmsKey) ?? [];

      return alarmsJson
          .map(
            (json) =>
                AlarmModel.fromJson(jsonDecode(json) as Map<String, dynamic>),
          )
          .toList()
        ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    } catch (e) {
      throw Exception('Failed to get alarms: $e');
    }
  }

  /// Add a new alarm
  static Future<AlarmModel> addAlarm(DateTime dateTime, {String? label}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final alarmsJson = prefs.getStringList(_alarmsKey) ?? [];

      final newAlarm = AlarmModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        dateTime: dateTime,
        label: label,
      );

      alarmsJson.add(jsonEncode(newAlarm.toJson()));
      await prefs.setStringList(_alarmsKey, alarmsJson);

      return newAlarm;
    } catch (e) {
      throw Exception('Failed to add alarm: $e');
    }
  }

  /// Update alarm
  static Future<void> updateAlarm(AlarmModel alarm) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final alarmsJson = prefs.getStringList(_alarmsKey) ?? [];

      final index = alarmsJson.indexWhere((json) {
        final alarm = AlarmModel.fromJson(
          jsonDecode(json) as Map<String, dynamic>,
        );
        return alarm.id == alarm.id;
      });

      if (index != -1) {
        alarmsJson[index] = jsonEncode(alarm.toJson());
        await prefs.setStringList(_alarmsKey, alarmsJson);
      }
    } catch (e) {
      throw Exception('Failed to update alarm: $e');
    }
  }

  /// Toggle alarm enabled status
  static Future<void> toggleAlarm(String alarmId, bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final alarmsJson = prefs.getStringList(_alarmsKey) ?? [];

      final index = alarmsJson.indexWhere((json) {
        final alarm = AlarmModel.fromJson(
          jsonDecode(json) as Map<String, dynamic>,
        );
        return alarm.id == alarmId;
      });

      if (index != -1) {
        final alarm = AlarmModel.fromJson(
          jsonDecode(alarmsJson[index]) as Map<String, dynamic>,
        );
        final updatedAlarm = alarm.copyWith(isEnabled: enabled);
        alarmsJson[index] = jsonEncode(updatedAlarm.toJson());
        await prefs.setStringList(_alarmsKey, alarmsJson);
      }
    } catch (e) {
      throw Exception('Failed to toggle alarm: $e');
    }
  }

  /// Delete alarm
  static Future<void> deleteAlarm(String alarmId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final alarmsJson = prefs.getStringList(_alarmsKey) ?? [];

      alarmsJson.removeWhere((json) {
        final alarm = AlarmModel.fromJson(
          jsonDecode(json) as Map<String, dynamic>,
        );
        return alarm.id == alarmId;
      });

      await prefs.setStringList(_alarmsKey, alarmsJson);
    } catch (e) {
      throw Exception('Failed to delete alarm: $e');
    }
  }

  /// Clear all alarms
  static Future<void> clearAllAlarms() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_alarmsKey);
    } catch (e) {
      throw Exception('Failed to clear alarms: $e');
    }
  }
}
