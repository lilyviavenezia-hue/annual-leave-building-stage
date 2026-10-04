class Trip {
  final String id;
  final String destination;
  final String dateRange;
  final String duration;
  final String budget;
  final String imageUrl;
  final String status;
  final int travellerCount;
  final double plannedBudget;
  final String originCity;
  final double? estimatedBudget;
  final Map<String, double>? budgetBreakdown;

  Trip({
    required this.id,
    required this.destination,
    required this.dateRange,
    required this.duration,
    required this.budget,
    required this.imageUrl,
    required this.status,
    this.travellerCount = 4,
    this.plannedBudget = 2000,
    this.originCity = 'Kuala Lumpur',
    this.estimatedBudget,
    this.budgetBreakdown,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'] as String? ?? '',
      destination: json['destination'] as String? ?? '',
      dateRange: json['date_range'] as String? ?? '',
      duration: json['duration'] as String? ?? '',
      budget: json['budget'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      status: json['status'] as String? ?? '',
      travellerCount: json['traveller_count'] as int? ?? 4,
      plannedBudget:
          (json['planned_budget'] as num?)?.toDouble() ??
          _budgetFromLabel(json['budget'] as String?),
      originCity: json['origin_city'] as String? ?? 'Kuala Lumpur',
      estimatedBudget: (json['estimated_budget'] as num?)?.toDouble(),
      budgetBreakdown: _parseBudgetBreakdown(json['budget_breakdown']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'destination': destination,
      'date_range': dateRange,
      'duration': duration,
      'budget': budget,
      'image_url': imageUrl,
      'status': status,
      'traveller_count': travellerCount,
      'planned_budget': plannedBudget,
      'origin_city': originCity,
      'estimated_budget': estimatedBudget,
      'budget_breakdown': budgetBreakdown,
    };
  }

  Trip copyWith({
    String? id,
    String? destination,
    String? dateRange,
    String? duration,
    String? budget,
    String? imageUrl,
    String? status,
    int? travellerCount,
    double? plannedBudget,
    String? originCity,
    double? estimatedBudget,
    Map<String, double>? budgetBreakdown,
  }) {
    return Trip(
      id: id ?? this.id,
      destination: destination ?? this.destination,
      dateRange: dateRange ?? this.dateRange,
      duration: duration ?? this.duration,
      budget: budget ?? this.budget,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
      travellerCount: travellerCount ?? this.travellerCount,
      plannedBudget: plannedBudget ?? this.plannedBudget,
      originCity: originCity ?? this.originCity,
      estimatedBudget: estimatedBudget ?? this.estimatedBudget,
      budgetBreakdown: budgetBreakdown ?? this.budgetBreakdown,
    );
  }

  static double _budgetFromLabel(String? label) {
    final digits = label?.replaceAll(RegExp(r'[^0-9.]'), '') ?? '';
    return double.tryParse(digits) ?? 2000;
  }

  static Map<String, double>? _parseBudgetBreakdown(dynamic value) {
    if (value is! Map) return null;
    return {
      for (final entry in value.entries)
        if (entry.value is num)
          entry.key.toString(): (entry.value as num).toDouble(),
    };
  }
}
