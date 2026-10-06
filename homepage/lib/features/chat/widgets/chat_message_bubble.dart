import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../models/account_profile.dart';
import '../../../models/chat_message.dart';
import 'ai_recommendation_card.dart';

class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final AccountProfile? currentUserProfile;
  final Function(String messageText) onAskAi;

  const ChatMessageBubble({
    super.key,
    required this.message,
    this.currentUserProfile,
    required this.onAskAi,
  });

  @override
  Widget build(BuildContext context) {
    final isMe = message.senderId == 'user_me';

    return Dismissible(
      key: Key(message.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        if (direction != DismissDirection.endToStart) return false;
        onAskAi(message.text);
        return false;
      },
      background: const ColoredBox(color: Colors.transparent),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppTheme.primaryGreen.withValues(alpha: 0.15),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(Icons.eco_outlined, color: AppTheme.primaryGreen),
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
        child: Row(
          mainAxisAlignment: isMe
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isMe) ...[_buildAvatar(), const SizedBox(width: 8)],
            Flexible(
              child: Column(
                crossAxisAlignment: isMe
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
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
                        bottomRight: isMe
                            ? const Radius.circular(0)
                            : const Radius.circular(16),
                        bottomLeft: !isMe
                            ? const Radius.circular(0)
                            : const Radius.circular(16),
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
                          AiRecommendationCard(
                            cardPayload: message.cardPayload!,
                          ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              MaterialLocalizations.of(context).formatTimeOfDay(
                                TimeOfDay.fromDateTime(
                                  message.timestamp.toLocal(),
                                ),
                              ),
                              style: TextStyle(
                                color: isMe
                                    ? Colors.white.withValues(alpha: 0.75)
                                    : AppTheme.textMuted,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (isMe) ...[const SizedBox(width: 8), _buildAvatar()],
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final profile = message.senderId == 'user_me' ? currentUserProfile : null;
    final image = profile?.avatarBytes != null
        ? Image.memory(
            profile!.avatarBytes!,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _avatarFallback(),
          )
        : _imageFromUrl(profile?.avatarUrl ?? message.senderAvatar);

    return CircleAvatar(
      radius: 16,
      backgroundColor: AppTheme.surfaceSecondary,
      child: image ?? _avatarFallback(),
    );
  }

  Widget? _imageFromUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    final image = url.startsWith('assets/')
        ? Image.asset(
            url,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _avatarFallback(),
          )
        : Image.network(
            url,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _avatarFallback(),
          );
    return ClipOval(child: SizedBox.expand(child: image));
  }

  Widget _avatarFallback() => Icon(
    message.isAiResponse ? Icons.eco_outlined : Icons.person,
    size: 18,
    color: AppTheme.primaryGreen,
  );
}
