const List<String> mockCollaboratorAvatarAssets = [
  'assets/avatars/ski-traveller.jpg',
  'assets/avatars/paris-traveller.jpg',
  'assets/avatars/hiking-traveller.jpg',
  'assets/avatars/green-traveller.jpg',
];

final List<Map<String, dynamic>> mockCollaboratorsList = [
  {
    "id": "collab_1",
    "name": "Sarah Chen",
    "email": "sarah.chen@example.com",
    "avatarUrl": mockCollaboratorAvatarAssets[0],
    "isAdded": true,
  },
  {
    "id": "collab_2",
    "name": "Alex Wong",
    "email": "alex.wong@example.com",
    "avatarUrl": mockCollaboratorAvatarAssets[1],
    "isAdded": true,
  },
  {
    "id": "collab_3",
    "name": "Miriam Al-Jamil",
    "email": "miriam.al-jamil@example.com",
    "avatarUrl": mockCollaboratorAvatarAssets[2],
    "isAdded": true,
  },
  {
    "id": "collab_4",
    "name": "David Tan",
    "email": "david.tan@example.com",
    "avatarUrl": mockCollaboratorAvatarAssets[3],
    "isAdded": true,
  },
];

final List<Map<String, dynamic>> mockSearchSuggestions = [
  {
    "id": "collab_5",
    "name": "Jessica Taylor",
    "email": "jessica.t@example.com",
    "avatarUrl": mockCollaboratorAvatarAssets[0],
    "isAdded": false,
  },
];
