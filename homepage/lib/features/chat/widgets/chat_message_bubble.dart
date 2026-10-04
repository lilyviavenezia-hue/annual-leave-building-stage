import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../models/chat_message.dart';
import 'ai_recommendation_card.dart';

class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final Function(String messageText) onAskAi;

  const ChatMessageBubble({
    super.key,
    required this.message,
    required this.onAskAi,
  });

  @override
  Widget build(BuildContext context) {
    final isMe = message.senderId == 'user_me';

    return Dismissible(
      key: Key(message.id),
      direction: DismissDirection.startToEnd,
      confirmDismiss: (direction) async {
        onAskAi(message.text);
        return false;
      },
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        color: AppTheme.primaryGreen.withValues(alpha: 0.15),
        child: const Row(
          children: [
            Icon(Icons.auto_awesome, color: AppTheme.primaryGreen),
            SizedBox(width: 8),
            Text(
              'Asking AI...',
              style: TextStyle(
                color: AppTheme.primaryGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Padding(
                padding: const EdgeInsets.only(left: 4.0, bottom: 2.0),
                child: Text(
                  message.senderName,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textMuted,
                  ),
                ),
              ),
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: message.isAiResponse
                    ? Colors.teal.shade50
                    : (isMe ? AppTheme.primaryGreen : Colors.white),
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(16),
                  bottomLeft: !isMe ? const Radius.circular(0) : const Radius.circular(16),
                ),
                border: Border.all(
                  color: message.isAiResponse
                      ? AppTheme.primaryGreen.withValues(alpha: 0.3)
                      : Colors.grey.shade200,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: isMe ? Colors.white : AppTheme.textDark,
                      fontSize: 14,
                    ),
                  ),
                  if (message.type == MessageType.aiRecommendationCard &&
                      message.cardPayload != null)
                    AiRecommendationCard(cardPayload: message.cardPayload!),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}