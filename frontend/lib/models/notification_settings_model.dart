class NotificationSettings {
  bool notificationsEnabled;
  int reminderOffsetMinutes;

  NotificationSettings({
    required this.notificationsEnabled,
    required this.reminderOffsetMinutes,
  });

  Map<String, dynamic> toJson() => {
        'notificationsEnabled': notificationsEnabled,
        'reminderOffsetMinutes': reminderOffsetMinutes,
      };

  static NotificationSettings fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      reminderOffsetMinutes: json['reminderOffsetMinutes'] ?? 10,
    );
  }
}
