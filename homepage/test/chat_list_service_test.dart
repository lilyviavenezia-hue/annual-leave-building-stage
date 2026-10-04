import 'package:flutter_test/flutter_test.dart';
import 'package:homempage/services/chat_list_service.dart';

void main() {
  test(
    'accepting an invitation adds its trip to active conversations',
    () async {
      final service = ChatListService();

      expect(await service.acceptInvitation('inv_1'), isTrue);
      expect(await service.getPendingInvitations(), isEmpty);

      final conversations = await service.getConversations();
      final joinedTrip = conversations.firstWhere(
        (conversation) => conversation.groupId == 'group_inv_1',
      );
      expect(joinedTrip.title, 'Tokyo Spring Blossom');
      expect(joinedTrip.destination, 'Tokyo, Japan');
      expect(joinedTrip.lastMessage, 'You joined the trip');

      expect(await service.acceptInvitation('inv_1'), isFalse);
      expect(
        (await service.getConversations())
            .where((conversation) => conversation.groupId == 'group_inv_1')
            .length,
        1,
      );
    },
  );
}
