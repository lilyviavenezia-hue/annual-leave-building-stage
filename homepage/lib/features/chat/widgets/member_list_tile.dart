import 'package:flutter/material.dart';
import 'package:homempage/core/theme/app_theme.dart ';

import '../../../models/group_member.dart';
import 'member_profile.dart';

class MemberListTile extends StatelessWidget {
  final GroupMember member;
  final bool isExpanded;
  final VoidCallback onToggleExpand;
  final VoidCallback? onRemoveMember;

  const MemberListTile({
    super.key,
    required this.member,
    required this.isExpanded,
    required this.onToggleExpand,
    this.onRemoveMember,
  });

  @override
  Widget build(BuildContext context) {
    final avatarUrl = member.avatarUrl;
    final ImageProvider? avatarImage = avatarUrl == null
        ? null
        : avatarUrl.startsWith('assets/')
        ? AssetImage(avatarUrl)
        : NetworkImage(avatarUrl);

    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 4,
          ),
          leading: CircleAvatar(
            radius: 22,
            backgroundColor: AppTheme.primaryGreen.withValues(alpha: 0.12),
            backgroundImage: avatarImage,
            child: avatarUrl == null
                ? Text(
                    member.name.isNotEmpty ? member.name[0] : '',
                    style: const TextStyle(
                      color: AppTheme.primaryGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          title: Text(
            member.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: AppTheme.textDark,
            ),
          ),
          trailing: onRemoveMember == null
              ? null
              : IconButton(
                  tooltip: 'Remove member',
                  onPressed: onRemoveMember,
                  icon: const Icon(
                    Icons.person_remove_outlined,
                    color: AppTheme.textMuted,
                  ),
                ),
          subtitle: GestureDetector(
            onTap: onToggleExpand,
            child: Row(
              children: [
                const Text(
                  'View Preferences',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryGreen,
                  ),
                ),
                const SizedBox(width: 2),
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 16,
                  color: AppTheme.primaryGreen,
                ),
              ],
            ),
          ),
          onTap: onToggleExpand,
        ),
        if (isExpanded)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: MemberProfileCardWidget(member: member),
          ),
        const Divider(height: 1, indent: 20, endIndent: 20),
      ],
    );
  }
}
