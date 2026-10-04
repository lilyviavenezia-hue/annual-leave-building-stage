final Map<String, dynamic> mockLeaveData = {
  "selected_year": 2026,
  "leave_balance": 18,
  "date_statuses": {
    "2026-10-02": "recommended",
    "2026-10-05": "holiday",
    "2026-10-07": "busy",
    "2026-10-08": "busy",
    "2026-10-09": "busy",
    "2026-10-10": "busy",
  }
};

final List<Map<String, dynamic>> mockLeaveCombos = [
  {
    "id": "COMBO_001",
    "days_off": 4,
    "return_multiplier": "4x Return",
    "leave_days_used": 1,
    "date_range": "Oct 2 - Oct 5",
    "description": "Book off Friday Oct 2 before Labour Day (Mon Oct 5) for a fantastic 4-day weekend getaway.",
  }
];