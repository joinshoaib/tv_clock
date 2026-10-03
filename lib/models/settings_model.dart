class ClockSettings {
  bool is24HourFormat;
  bool showSeconds;
  bool showDate;
  String theme;
  double size;
  double opacity;
  String position;
  String color;

  ClockSettings({
    this.is24HourFormat = false,
    this.showSeconds = true,
    this.showDate = true,
    this.theme = 'white',
    this.size = 48.0,
    this.opacity = 0.9,
    this.position = 'topRight',
    this.color = 'default',
  });

  Map<String, dynamic> toMap() {
    return {
      'is24HourFormat': is24HourFormat,
      'showSeconds': showSeconds,
      'showDate': showDate,
      'theme': theme,
      'size': size,
      'opacity': opacity,
      'position': position,
      'color': color,
    };
  }

  factory ClockSettings.fromMap(Map<String, dynamic> map) {
    return ClockSettings(
      is24HourFormat: map['is24HourFormat'] ?? false,
      showSeconds: map['showSeconds'] ?? true,
      showDate: map['showDate'] ?? true,
      theme: map['theme'] ?? 'white',
      size: (map['size'] ?? 48.0).toDouble(),
      opacity: (map['opacity'] ?? 0.9).toDouble(),
      position: map['position'] ?? 'topRight',
      color: map['color'] ?? 'default',
    );
  }

  ClockSettings copyWith({
    bool? is24HourFormat,
    bool? showSeconds,
    bool? showDate,
    String? theme,
    double? size,
    double? opacity,
    String? position,
    String? color,
  }) {
    return ClockSettings(
      is24HourFormat: is24HourFormat ?? this.is24HourFormat,
      showSeconds: showSeconds ?? this.showSeconds,
      showDate: showDate ?? this.showDate,
      theme: theme ?? this.theme,
      size: size ?? this.size,
      opacity: opacity ?? this.opacity,
      position: position ?? this.position,
      color: color ?? this.color,
    );
  }
}
