import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../models/group_poll.dart';

class StickyPollsSection extends StatefulWidget {
  final List<GroupPoll> activePolls;
  final Function(String pollId, String optionId) onVote;

  const StickyPollsSection({
    super.key,
    required this.activePolls,
    required this.onVote,
  });

  @override
  State<StickyPollsSection> createState() => _StickyPollsSectionState();
}

class _StickyPollsSectionState extends State<StickyPollsSection> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildVoterAvatars(int voteCount, List<String> votedUserIds) {
    if (voteCount <= 0) return const SizedBox.shrink();

    final Map<String, String> userAvatarMap = {
      'user_1': 'https://i.pravatar.cc/150?img=1',
      'user_2': 'https://i.pravatar.cc/150?img=2',
      'user_3': 'https://i.pravatar.cc/150?img=3',
      'user_4': 'https://i.pravatar.cc/150?img=4',
      'user_me': 'https://i.pravatar.cc/150?img=5',
    };

    final displayCount = votedUserIds.length.clamp(0, 3);
    final avatarsToRender = votedUserIds.take(displayCount).toList();

    return SizedBox(
      height: 20,
      width: avatarsToRender.isEmpty
          ? 20
          : (14.0 * avatarsToRender.length + 6.0),
      child: Stack(
        children: avatarsToRender.asMap().entries.map((entry) {
          final index = entry.key;
          final userId = entry.value;
          final avatarUrl = userAvatarMap[userId];

          return Positioned(
            left: index * 12.0,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: CircleAvatar(
                radius: 9,
                backgroundColor: AppTheme.primaryGreen.withValues(alpha: 0.2),
                backgroundImage: avatarUrl != null
                    ? NetworkImage(avatarUrl)
                    : null,
                child: avatarUrl == null
                    ? const Icon(
                        Icons.person,
                        size: 10,
                        color: AppTheme.primaryGreen,
                      )
                    : null,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.activePolls.isEmpty) return const SizedBox.shrink();

    final currentPoll = widget.activePolls[_currentPage];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: currentPoll.isExpanded
                  ? (96.0 + (currentPoll.options.length * 56.0))
                  : 74.0,
              child: PageView.builder(
                controller: _pageController,
                scrollDirection: Axis.vertical,
                itemCount: widget.activePolls.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final poll = widget.activePolls[index];

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 2.0),
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: AppTheme.cardBackground,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              poll.isExpanded = !poll.isExpanded;
                            });
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  poll.question,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    '${poll.totalVotes} votes',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppTheme.textMuted,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    poll.isExpanded
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    size: 18,
                                    color: AppTheme.textMuted,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        if (poll.isExpanded) ...[
                          const SizedBox(height: 10),
                          Column(
                            children: poll.options.map((option) {
                              final hasVoted = option.votedUserIds.contains(
                                'user_me',
                              );

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 6.0),
                                child: InkWell(
                                  onTap: () =>
                                      widget.onVote(poll.id, option.id),
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: hasVoted
                                          ? AppTheme.primaryGreen.withValues(
                                              alpha: 0.12,
                                            )
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: hasVoted
                                            ? AppTheme.primaryGreen
                                            : Colors.grey.shade300,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          option.text,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: hasVoted
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                            color: hasVoted
                                                ? AppTheme.primaryGreen
                                                : AppTheme.textDark,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            _buildVoterAvatars(
                                              option.voteCount,
                                              option.votedUserIds,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              '${option.voteCount}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: AppTheme.textDark,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          if (widget.activePolls.length > 1) ...[
            const SizedBox(width: 8),
            Container(
              width: 4,
              height: currentPoll.isExpanded ? 100 : 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(2),
              ),
              child: Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 200),
                    top:
                        (_currentPage / (widget.activePolls.length - 1)) *
                        ((currentPoll.isExpanded ? 100 : 40) - 16),
                    child: Container(
                      width: 4,
                      height: 16,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
