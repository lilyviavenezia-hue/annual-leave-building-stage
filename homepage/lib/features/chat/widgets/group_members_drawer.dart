import 'package:flutter/material.dart';
import 'package:homempage/core/theme/app_theme.dart ';

import '../../../models/group_member.dart';
import 'member_list_tile.dart';

class GroupMembersDrawer extends StatefulWidget {
  final List<GroupMember> members;
  final VoidCallback? onAddMemberPressed;
  final ValueChanged<GroupMember>? onRemoveMember;

  const GroupMembersDrawer({
    super.key,
    required this.members,
    this.onAddMemberPressed,
    this.onRemoveMember,
  });

  @override
  State<GroupMembersDrawer> createState() => _GroupMembersDrawerState();
}

class _GroupMembersDrawerState extends State<GroupMembersDrawer> {
  String? _expandedMemberId;

  @override
  Widget build(BuildContext context) {
    final isHost = widget.members.any(
      (member) => member.isMe && member.role == 'Host',
    );

    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drawer Header
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 16.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Trip Members',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textDark,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryGreen,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 22,
                      ),
                      onPressed: widget.onAddMemberPressed,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Members List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: widget.members.length,
                itemBuilder: (context, index) {
                  final member = widget.members[index];
                  final isExpanded = _expandedMemberId == member.id;

                  return MemberListTile(
                    member: member,
                    isExpanded: isExpanded,
                    onRemoveMember: isHost && !member.isMe
                        ? () => widget.onRemoveMember?.call(member)
                        : null,
                    onToggleExpand: () {
                      setState(() {
                        _expandedMemberId = isExpanded ? null : member.id;
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
