class UsageData {
  final String id;
  final String customerId;
  final DateTime date;
  final double downloadGB;
  final double uploadGB;
  final int durationMinutes;

  UsageData({
    required this.id,
    required this.customerId,
    required this.date,
    required this.downloadGB,
    required this.uploadGB,
    required this.durationMinutes,
  });

  factory UsageData.fromJson(Map<String, dynamic> json) {
    return UsageData(
      id: json['id'] as String,
      customerId: json['customerId'] as String,
      date: DateTime.parse(json['date'] as String),
      downloadGB: (json['downloadGB'] as num).toDouble(),
      uploadGB: (json['uploadGB'] as num).toDouble(),
      durationMinutes: json['durationMinutes'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'date': date.toIso8601String(),
      'downloadGB': downloadGB,
      'uploadGB': uploadGB,
      'durationMinutes': durationMinutes,
    };
  }

  double get totalGB => downloadGB + uploadGB;
}
