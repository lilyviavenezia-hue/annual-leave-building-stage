class GroupTripSummary {
  final String groupId;
  final String title;
  final String dates;
  final String destination;
  final String budget;
  final double progress; // e.g., 0.71 for 5 of 7
  final int completedItems;
  final int totalItems;
  final List<String> pendingDecisions; // Budget, Accommodation, Transport, etc.
  final Map<String, String> confirmedDetails; // Destination, Dates, Duration, Travelers
  final List<String> preferenceTags;
  final bool isReadyToPlan;

  GroupTripSummary({
    required this.groupId,
    required this.title,
    required this.dates,
    required this.destination,
    required this.budget,
    required this.progress,
    required this.completedItems,
    required this.totalItems,
    required this.pendingDecisions,
    required this.confirmedDetails,
    required this.preferenceTags,
    this.isReadyToPlan = false,
  });

  factory GroupTripSummary.fromJson(Map<String, dynamic> json) {
    return GroupTripSummary(
      groupId: json['groupId'] as String,
      title: json['title'] as String,
      dates: json['dates'] as String,
      destination: json['destination'] as String,
      budget: json['budget'] as String,
      progress: (json['progress'] as num).toDouble(),
      completedItems: json['completedItems'] as int,
      totalItems: json['totalItems'] as int,
      pendingDecisions: (json['pendingDecisions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      confirmedDetails: Map<String, String>.from(json['confirmedDetails'] as Map),
      preferenceTags: (json['preferenceTags'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      isReadyToPlan: json['isReadyToPlan'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'groupId': groupId,
      'title': title,
      'dates': dates,
      'destination': destination,
      'budget': budget,
      'progress': progress,
      'completedItems': completedItems,
      'totalItems': totalItems,
      'pendingDecisions': pendingDecisions,
      'confirmedDetails': confirmedDetails,
      'preferenceTags': preferenceTags,
      'isReadyToPlan': isReadyToPlan,
    };
  }
}

class GroupSuggestion {
  final String id;
  final String title;
  final String location;
  final String category;
  final int matchPercentage;
  final String imageUrl;
  final bool isSaved;

  GroupSuggestion({
    required this.id,
    required this.title,
    required this.location,
    required this.category,
    required this.matchPercentage,
    required this.imageUrl,
    this.isSaved = false,
  });

  factory GroupSuggestion.fromJson(Map<String, dynamic> json) {
    return GroupSuggestion(
      id: json['id'] as String,
      title: json['title'] as String,
      location: json['location'] as String,
      category: json['category'] as String,
      matchPercentage: json['matchPercentage'] as int,
      imageUrl: json['imageUrl'] as String,
      isSaved: json['isSaved'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'location': location,
      'category': category,
      'matchPercentage': matchPercentage,
      'imageUrl': imageUrl,
      'isSaved': isSaved,
    };
  }
}