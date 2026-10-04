import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../models/group_member.dart';
import '../../../models/leave_data.dart';
import '../../../services/group_summary_service.dart';
import '../../../services/leave_service.dart';

class MemberProfileModal extends StatelessWidget {
  final GroupMember member;
  final VoidCallback? onMemberUpdated;

  const MemberProfileModal({
    super.key,
    required this.member,
    this.onMemberUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: AppTheme.primaryGreen.withValues(alpha: 0.15),
                backgroundImage: member.avatarUrl != null
                    ? NetworkImage(member.avatarUrl!)
                    : null,
                child: member.avatarUrl == null
                    ? Text(
                        member.name.isNotEmpty ? member.name[0] : '',
                        style: const TextStyle(
                          fontSize: 18,
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  Text(
                    'Synced with Leave Optimizer',
                    style: TextStyle(
                      color: AppTheme.primaryGreen,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          MemberProfileCardWidget(
            member: member,
            onMemberUpdated: onMemberUpdated,
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class MemberProfileCardWidget extends StatefulWidget {
  final GroupMember member;
  final VoidCallback? onMemberUpdated;

  const MemberProfileCardWidget({
    super.key,
    required this.member,
    this.onMemberUpdated,
  });

  @override
  State<MemberProfileCardWidget> createState() =>
      _MemberProfileCardWidgetState();
}

class _MemberProfileCardWidgetState extends State<MemberProfileCardWidget> {
  final LeaveService _leaveService = LeaveService();
  final GroupSummaryService _summaryService = GroupSummaryService();

  late RangeValues _budgetRange;
  late List<String> _preferences;
  late String _dateRange;
  LeaveData? _leaveData;
  bool _isLoadingLeave = true;

  @override
  void initState() {
    super.initState();
    _budgetRange = RangeValues(
      widget.member.minBudget,
      widget.member.maxBudget,
    );
    _preferences = List.from(widget.member.preferences);
    _dateRange = widget.member.dateRange;
    _loadLeaveData();
  }

  Future<void> _selectDateRange() async {
    final today = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(today.year, today.month),
      lastDate: DateTime(today.year + 2),
      initialDateRange: DateTimeRange(
        start: today,
        end: today.add(const Duration(days: 6)),
      ),
    );
    if (picked == null || !mounted || !widget.member.isMe) return;

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final selected =
        '${months[picked.start.month - 1]} ${picked.start.day} - '
        '${months[picked.end.month - 1]} ${picked.end.day}, ${picked.end.year}';
    setState(() => _dateRange = selected);
    await _summaryService.updateMemberDateRange(
      memberId: widget.member.id,
      dateRange: selected,
    );
    widget.onMemberUpdated?.call();
  }

  Future<void> _loadLeaveData() async {
    final leaveData = await _leaveService.getUserLeaveData();
    if (mounted) {
      setState(() {
        _leaveData = leaveData;
        _isLoadingLeave = false;
      });
    }
  }

  void _updateBudget(RangeValues values) {
    if (!widget.member.isMe) return;
    setState(() {
      _budgetRange = values;
    });
    _summaryService.updateMemberBudget(
      memberId: widget.member.id,
      minBudget: values.start,
      maxBudget: values.end,
    );
    widget.onMemberUpdated?.call();
  }

  void _addPreferenceDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Preference'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'e.g. Vegetarian only, Morning start',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
            ),
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                setState(() {
                  _preferences.add(text);
                });
                _summaryService.updateMemberPreferences(
                  memberId: widget.member.id,
                  preferences: _preferences,
                );
                widget.onMemberUpdated?.call();
              }
              Navigator.pop(ctx);
            },
            child: const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _removePreference(String item) {
    if (!widget.member.isMe) return;
    setState(() {
      _preferences.remove(item);
    });
    _summaryService.updateMemberPreferences(
      memberId: widget.member.id,
      preferences: _preferences,
    );
    widget.onMemberUpdated?.call();
  }

  @override
  Widget build(BuildContext context) {
    final minVal = _budgetRange.start.round();
    final maxVal = _budgetRange.end.round();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primaryGreen.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGreen.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. AVAILABLE DATES (Synced with Leave Optimizer)
          Row(
            children: [
              const Expanded(
                child: Text(
                  'AVAILABLE DATES',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF788896),
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              if (_leaveData != null)
                Text(
                  '${_leaveData!.leaveBalance} Leave Days Left',
                  style: const TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGreen,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          InkWell(
            onTap: widget.member.isMe ? _selectDateRange : null,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 15,
                          color: AppTheme.textDark,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _dateRange,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    size: 18,
                    color: AppTheme.textMuted,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Synced Leave Optimizer Calendar Month
          _isLoadingLeave
              ? const SizedBox(
                  height: 100,
                  child: Center(child: CircularProgressIndicator()),
                )
              : _buildLeaveOptimizerCalendar(),

          const SizedBox(height: 16),

          // 2. TRIP BUDGET RANGE (Editable for 'Ying (You)')
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.member.isMe
                      ? 'TRIP BUDGET RANGE (EDITABLE)'
                      : 'TRIP BUDGET RANGE',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF788896),
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'RM$minVal – RM$maxVal',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          RangeSlider(
            values: _budgetRange,
            min: 500,
            max: 10000,
            divisions: 19,
            activeColor: AppTheme.primaryGreen,
            inactiveColor: Colors.grey.shade200,
            onChanged: widget.member.isMe ? _updateBudget : null,
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'MIN RM $minVal',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textMuted,
                ),
              ),
              Text(
                'MAX RM $maxVal',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 3. PREFERENCES (Editable for 'Ying (You)')
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'PREFERENCES',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF788896),
                  letterSpacing: 0.5,
                ),
              ),
              if (widget.member.isMe)
                InkWell(
                  onTap: _addPreferenceDialog,
                  child: const Row(
                    children: [
                      Icon(Icons.add, size: 14, color: AppTheme.primaryGreen),
                      SizedBox(width: 2),
                      Text(
                        'Add',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          ..._preferences.map(
            (pref) => Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: Row(
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      pref,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textDark,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (widget.member.isMe)
                    InkWell(
                      onTap: () => _removePreference(pref),
                      child: const Icon(
                        Icons.close,
                        size: 14,
                        color: AppTheme.textMuted,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveOptimizerCalendar() {
    final days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'June 2026',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Icon(Icons.chevron_left, size: 16),
                  SizedBox(width: 8),
                  Icon(Icons.chevron_right, size: 16),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: days
                .map(
                  (d) => Text(
                    d,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textMuted,
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: List.generate(14, (i) {
              final dayNum = 12 + i;
              final isSelected = dayNum >= 12 && dayNum <= 18;
              return Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryGreen
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '$dayNum',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isSelected ? Colors.white : AppTheme.textDark,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
