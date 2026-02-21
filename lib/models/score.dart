class Score {
  final String gameType;
  final String contentType;
  final int value;
  final DateTime dateTime;
  final int? length;

  Score({
    required this.gameType,
    required this.contentType,
    required this.value,
    required this.dateTime,
    this.length,
  });

  Map<String, dynamic> toJson() {
    return {
      'gameType': gameType,
      'contentType': contentType,
      'value': value,
      'dateTime': dateTime.toIso8601String(),
      'length': length,
    };
  }

  factory Score.fromJson(Map<String, dynamic> json) {
    return Score(
      gameType: json['gameType'] as String,
      contentType: json['contentType'] as String,
      value: json['value'] as int,
      dateTime: DateTime.parse(json['dateTime'] as String),
      length: json['length'] as int?,
    );
  }

  String get formattedDate {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
