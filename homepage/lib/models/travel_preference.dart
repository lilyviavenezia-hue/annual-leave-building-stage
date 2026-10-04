class TravelPreference {
  final String transcript;
  final String pace; // Relaxed, Balanced, Packed
  final String accessibility; // Standard, Prefer accessible, Wheelchair-friendly
  final String restroomPriority; // Low, Medium, High
  final String startTime; // e.g. "08:00 AM"
  final String endTime; // e.g. "09:00 PM"

  TravelPreference({
    required this.transcript,
    required this.pace,
    required this.accessibility,
    required this.restroomPriority,
    required this.startTime,
    required this.endTime,
  });

  factory TravelPreference.fromJson(Map<String, dynamic> json) {
    return TravelPreference(
      transcript: json['transcript'] ?? '',
      pace: json['pace'] ?? 'Balanced',
      accessibility: json['accessibility'] ?? 'Standard',
      restroomPriority: json['restroom_priority'] ?? 'Medium',
      startTime: json['start_time'] ?? '08:00 AM',
      endTime: json['end_time'] ?? '09:00 PM',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transcript': transcript,
      'pace': pace,
      'accessibility': accessibility,
      'restroom_priority': restroomPriority,
      'start_time': startTime,
      'end_time': endTime,
    };
  }

  TravelPreference copyWith({
    String? transcript,
    String? pace,
    String? accessibility,
    String? restroomPriority,
    String? startTime,
    String? endTime,
  }) {
    return TravelPreference(
      transcript: transcript ?? this.transcript,
      pace: pace ?? this.pace,
      accessibility: accessibility ?? this.accessibility,
      restroomPriority: restroomPriority ?? this.restroomPriority,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }
}