class PlanningTrip {
  final String id;
  final String flagEmoji;
  final String destination;
  final String dateRange;
  final String duration;
  final int daysToGo;
  final double progress;

  PlanningTrip({
    required this.id,
    required this.flagEmoji,
    required this.destination,
    required this.dateRange,
    required this.duration,
    required this.daysToGo,
    required this.progress,
  });

  factory PlanningTrip.fromJson(Map<String, dynamic> json) {
    return PlanningTrip(
      id: json['id'] ?? '',
      flagEmoji: json['flag_emoji'] ?? '',
      destination: json['destination'] ?? '',
      dateRange: json['date_range'] ?? '',
      duration: json['duration'] ?? '',
      daysToGo: json['days_to_go'] ?? 0,
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'flag_emoji': flagEmoji,
      'destination': destination,
      'date_range': dateRange,
      'duration': duration,
      'days_to_go': daysToGo,
      'progress': progress,
    };
  }
}