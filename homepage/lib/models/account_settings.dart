class NotificationPreferences {
  const NotificationPreferences({
    this.tripUpdates = true,
    this.groupChat = true,
    this.reminders = true,
    this.promotions = false,
  });

  final bool tripUpdates;
  final bool groupChat;
  final bool reminders;
  final bool promotions;

  bool get allEnabled => tripUpdates && groupChat && reminders && promotions;

  NotificationPreferences setAll(bool enabled) => NotificationPreferences(
    tripUpdates: enabled,
    groupChat: enabled,
    reminders: enabled,
    promotions: enabled,
  );

  NotificationPreferences copyWith({
    bool? tripUpdates,
    bool? groupChat,
    bool? reminders,
    bool? promotions,
  }) => NotificationPreferences(
    tripUpdates: tripUpdates ?? this.tripUpdates,
    groupChat: groupChat ?? this.groupChat,
    reminders: reminders ?? this.reminders,
    promotions: promotions ?? this.promotions,
  );
}

class ComfortTravelSettings {
  const ComfortTravelSettings({
    this.maxWalkingMinutes = 15,
    this.maxActivitiesPerDay = 3,
    this.restBreakFrequency = 1,
    this.accessibleTransportOnly = true,
    this.nearbyRestroomsPriority = true,
    this.minimizeStairs = false,
  });

  final int maxWalkingMinutes;
  final int maxActivitiesPerDay;
  final int restBreakFrequency;
  final bool accessibleTransportOnly;
  final bool nearbyRestroomsPriority;
  final bool minimizeStairs;

  ComfortTravelSettings copyWith({
    int? maxWalkingMinutes,
    int? maxActivitiesPerDay,
    int? restBreakFrequency,
    bool? accessibleTransportOnly,
    bool? nearbyRestroomsPriority,
    bool? minimizeStairs,
  }) => ComfortTravelSettings(
    maxWalkingMinutes: maxWalkingMinutes ?? this.maxWalkingMinutes,
    maxActivitiesPerDay: maxActivitiesPerDay ?? this.maxActivitiesPerDay,
    restBreakFrequency: restBreakFrequency ?? this.restBreakFrequency,
    accessibleTransportOnly:
        accessibleTransportOnly ?? this.accessibleTransportOnly,
    nearbyRestroomsPriority:
        nearbyRestroomsPriority ?? this.nearbyRestroomsPriority,
    minimizeStairs: minimizeStairs ?? this.minimizeStairs,
  );
}
