import 'package:flutter/material.dart';
import 'package:homempage/core/theme/app_theme.dart ';

import '../../../models/group_member.dart';
import 'member_profile.dart';

class MemberListTile extends StatelessWidget {
  final GroupMember member;
  final bool isExpanded;
  final VoidCallback onToggleExpand;

  const MemberListTile({
    super.key,
    required this.member,
    required this.isExpanded,
    required this.onToggleExpand,
  });

  @override
  Widget build(BuildContext context) {
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
            child: member.avatarUrl == null
                ? _MemberInitial(name: member.name)
                : ClipOval(
                    child: Image.network(
                      member.avatarUrl!,
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) =>
                          _MemberInitial(name: member.name),
                    ),
                  ),
          ),
          title: Text(
            member.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: AppTheme.textDark,
            ),
          ),
          subtitle: GestureDetector(
            onTap: onToggleExpand,
            child: Row(
              children: [
                const Flexible(
                  child: Text(
                    'View Preferences',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                ),
                const SizedBox(width: 2),
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 14,
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

class _MemberInitial extends StatelessWidget {
  const _MemberInitial({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) => Text(
    name.isNotEmpty ? name[0] : '',
    style: const TextStyle(
      color: AppTheme.primaryGreen,
      fontWeight: FontWeight.bold,
    ),
  );
}
