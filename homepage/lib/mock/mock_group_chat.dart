final Map<String, dynamic> mockGroupChatData = {
  "groupId": "group_kyoto_1",
  "messages": [
    {
      "id": "msg_1",
      "senderId": "user_2",
      "senderName": "Alex Wong",
      "senderAvatar": "https://i.pravatar.cc/150?img=2",
      "text": "I'm thinking of Tokyo for our next trip. What do you think?",
      "timestamp": "2026-10-12T14:30:00Z",
      "type": "text",
      "isAiResponse": false
    },
    {
      "id": "msg_2",
      "senderId": "user_3",
      "senderName": "Ving Ang",
      "senderAvatar": "https://i.pravatar.cc/150?img=3",
      "text": "Sounds great! I've been wanting to visit the new Ghibli Museum.",
      "timestamp": "2026-10-12T14:32:00Z",
      "type": "text",
      "isAiResponse": false
    },
    {
      "id": "msg_3",
      "senderId": "user_4",
      "senderName": "Mei Chen",
      "senderAvatar": "https://i.pravatar.cc/150?img=4",
      "text": "Kyoto's a place we can consider too for planning this trip.",
      "timestamp": "2026-10-12T14:35:00Z",
      "type": "text",
      "isAiResponse": false
    },
    {
      "id": "msg_4",
      "senderId": "user_2",
      "senderName": "Alex Wong",
      "senderAvatar": "https://i.pravatar.cc/150?img=2",
      "text": "RM 1,000 to RM 5,000. Let's avoid super crowded areas.",
      "timestamp": "2026-10-12T14:38:00Z",
      "type": "text",
      "isAiResponse": false
    },
    {
      "id": "msg_5",
      "senderId": "ai_planner",
      "senderName": "AI PLANNER • LIVE",
      "senderAvatar": null,
      "text": "Kyoto is a historic Japanese city famous for its classical Buddhist temples, peaceful gardens, and traditional wooden houses. As the former imperial capital of Japan, it preserves the nation's rich cultural heritage through timeless shrines and food culture.",
      "timestamp": "2026-10-12T14:39:00Z",
      "type": "text",
      "isAiResponse": true
    }
  ],
  "polls": [
    {
      "id": "poll_1",
      "question": "Where Should We Visit",
      "totalVotes": 4,
      "isClosed": false,
      "isMinimized": false,
      "options": [
        {
          "id": "opt_1",
          "text": "Shibuya Crossing",
          "voteCount": 2,
          "votedUserIds": ["user_1", "user_2"]
        },
        {
          "id": "opt_2",
          "text": "Ghibli Museum",
          "voteCount": 1,
          "votedUserIds": ["user_3"]
        },
        {
          "id": "opt_3",
          "text": "Asakusa Kannon Temple",
          "voteCount": 1,
          "votedUserIds": ["user_4"]
        }
      ]
    },
    {
      "id": "poll_2",
      "question": "Preferred Accommodation Type",
      "totalVotes": 3,
      "isClosed": false,
      "isMinimized": false,
      "options": [
        {
          "id": "opt_2_1",
          "text": "Traditional Ryokan",
          "voteCount": 2,
          "votedUserIds": ["user_1", "user_3"]
        },
        {
          "id": "opt_2_2",
          "text": "City Center Hotel",
          "voteCount": 1,
          "votedUserIds": ["user_2"]
        },
        {
          "id": "opt_2_3",
          "text": "Airbnb Apartment",
          "voteCount": 0,
          "votedUserIds": []
        }
      ]
    }
  ]
};