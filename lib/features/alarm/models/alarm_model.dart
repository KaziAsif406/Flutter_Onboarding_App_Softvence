class AlarmModel {
  final String id;
  final DateTime dateTime;
  final bool isEnabled;
  final String? label;

  AlarmModel({
    required this.id,
    required this.dateTime,
    this.isEnabled = true,
    this.label,
  });

  // Copy with modifications
  AlarmModel copyWith({
    String? id,
    DateTime? dateTime,
    bool? isEnabled,
    String? label,
  }) {
    return AlarmModel(
      id: id ?? this.id,
      dateTime: dateTime ?? this.dateTime,
      isEnabled: isEnabled ?? this.isEnabled,
      label: label ?? this.label,
    );
  }

  // Convert to JSON for storage
  Map<String, dynamic> toJson() => {
    'id': id,
    'dateTime': dateTime.toIso8601String(),
    'isEnabled': isEnabled,
    'label': label,
  };

  // Create from JSON
  factory AlarmModel.fromJson(Map<String, dynamic> json) => AlarmModel(
    id: json['id'] as String,
    dateTime: DateTime.parse(json['dateTime'] as String),
    isEnabled: json['isEnabled'] as bool? ?? true,
    label: json['label'] as String?,
  );
}
