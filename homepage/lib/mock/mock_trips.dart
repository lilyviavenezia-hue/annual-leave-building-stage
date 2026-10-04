final Map<String, dynamic> mockCurrentPlanningTrip = {
  "id": "PLAN_001",
  "flag_emoji": "🇰🇷",
  "destination": "Seoul",
  "date_range": "12-17 Dec",
  "duration": "5 days",
  "days_to_go": 12,
  "progress": 0.85,
};

final Map<String, dynamic> mockUpcomingTrip = {
  "id": "TRIP_001",
  "destination": "Kyoto, Japan",
  "date_range": "12 - 18 October 2026",
  "duration": "6 days",
  "budget": "RM 2,000 budget",
  "traveller_count": 4,
  "planned_budget": 2000,
  "origin_city": "Kuala Lumpur",
  "image_url": "https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?q=80&w=1000&auto=format&fit=crop",
  "status": "upcoming",
};

final List<Map<String, dynamic>> mockTrips = [
  {
    ...mockUpcomingTrip,
    "id": "ITIN_KYOTO_2026",
    "date_range": "12 - 18 October 2026",
    "duration": "6 days",
    "status": "upcoming",
  },
  {
    "id": "TRIP_PENANG",
    "destination": "Penang, Malaysia",
    "date_range": "12 - 18 December 2026",
    "duration": "6 days",
    "budget": "",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/6/65/Skyline_of_George_Town%2C_Penang_at_night_Nov2024-29-17.jpg/1280px-Skyline_of_George_Town%2C_Penang_at_night_Nov2024-29-17.jpg",
    "status": "draft",
    "traveller_count": 4,
    "planned_budget": 3000,
    "origin_city": "Kuala Lumpur",
  },
  {
    "id": "TRIP_BALI",
    "destination": "Bali, Indonesia",
    "date_range": "12 - 18 February 2025",
    "duration": "6 days",
    "budget": "",
    "image_url": "https://images.unsplash.com/photo-1537996194471-e657df975ab4?auto=format&fit=crop&w=1000&q=80",
    "status": "completed",
    "traveller_count": 2,
    "planned_budget": 1800,
    "origin_city": "Kuala Lumpur",
  },
];
