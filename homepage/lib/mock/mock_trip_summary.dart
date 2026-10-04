final List<Map<String, dynamic>> mockGroupSuggestionsData = [
  {
    "id": "sug_1",
    "title": "Kiyomizu-dera",
    "location": "Higashiyama, Kyoto",
    "category": "GROUP MATCH",
    "matchPercentage": 94,
    "imageUrl": "https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?auto=format&fit=crop&w=600&q=80",
    "isSaved": true
  },
  {
    "id": "sug_2",
    "title": "Arashiyama",
    "location": "Ukyo-ku, Kyoto",
    "category": "GROUP MATCH",
    "matchPercentage": 88,
    "imageUrl": "https://images.unsplash.com/photo-1545569341-9eb8b30979d9?auto=format&fit=crop&w=600&q=80",
    "isSaved": true
  },
  {
    "id": "sug_3",
    "title": "Nishiki Market",
    "location": "Nakagyo, Kyoto",
    "category": "FOOD • NIGHTLIFE",
    "matchPercentage": 82,
    "imageUrl": "https://images.unsplash.com/photo-1503899036084-c55cdd92da26?auto=format&fit=crop&w=600&q=80",
    "isSaved": false
  },
  {
    "id": "sug_4",
    "title": "Fushimi Inari",
    "location": "Fushimi-ku, Kyoto",
    "category": "GROUP MATCH",
    "matchPercentage": 91,
    "imageUrl": "https://images.unsplash.com/photo-1478436127897-769e1b3f0f36?auto=format&fit=crop&w=600&q=80",
    "isSaved": true
  }
];

final Map<String, dynamic> mockTripSummaryData = {
  "groupId": "group_kyoto_1",
  "title": "Kyoto Itinerary",
  "dates": "Jan 12 - Jan 18, 2026",
  "destination": "Kyoto, Japan",
  "budget": "RM1000",
  "progress": 0.71,
  "completedItems": 5,
  "totalItems": 7,
  "pendingDecisions": ["Budget", "Accommodation", "Transport"],
  "confirmedDetails": {
    "Destination": "Kyoto, Japan",
    "Dates": "Jan 12 - 18",
    "Traveller": "8 Friends",
    "Duration": "7 days",
    "Budget": "RM1000"
  },
  "preferenceTags": [
    "5-star hotel",
    "no seafood",
    "prefers transit",
    "high-efficiency pace",
    "low-crowd spaces"
  ],
  "isReadyToPlan": true
};

final List<Map<String, dynamic>> mockGroupMembersData = [
  {
    "id": "user_me",
    "name": "Ying (You)",
    "role": "Host",
    "avatarUrl": "https://i.pravatar.cc/150?img=5",
    "preferences": ["Morning start", "Local street food", "No fast pace"],
    "leaveBalanceSummary": "14 Days Available",
    "minBudget": 1000.0,
    "maxBudget": 5000.0,
    "dateRange": "Jun 12 - Jun 18, 2026",
    "isMe": true
  },
  {
    "id": "collab_2",
    "name": "Alex Wong",
    "role": "Member",
    "avatarUrl": "https://i.pravatar.cc/150?img=2",
    "preferences": ["Avoid crowded spots", "City photography"],
    "leaveBalanceSummary": "8 Days Available",
    "minBudget": 1500.0,
    "maxBudget": 4000.0,
    "dateRange": "Jun 12 - Jun 18, 2026",
    "isMe": false
  },
  {
    "id": "collab_3",
    "name": "Ving Ang",
    "role": "Member",
    "avatarUrl": "https://i.pravatar.cc/150?img=3",
    "preferences": ["Anime & Museums", "Ramen hunting"],
    "leaveBalanceSummary": "10 Days Available",
    "minBudget": 2000.0,
    "maxBudget": 6000.0,
    "dateRange": "Jun 12 - Jun 18, 2026",
    "isMe": false
  }
];