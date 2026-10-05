import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:homempage/features/home/leave_optimizer/widgets/leave_calendar_card.dart';
import 'package:homempage/models/leave_status.dart';

import 'dart:math' as math;

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
    final avatarUrl = member.avatarUrl;
    final ImageProvider? avatarImage = avatarUrl == null
        ? null
        : avatarUrl.startsWith('assets/')
        ? AssetImage(avatarUrl)
        : NetworkImage(avatarUrl);

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
                backgroundImage: avatarImage,
                child: avatarUrl == null
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
  late DateTimeRange _tripDateRange;
  late DateTime _calendarMonth;
  late final TextEditingController _minimumBudgetController;
  late final TextEditingController _maximumBudgetController;
  bool _isEditingBudget = false;
  LeaveData? _leaveData;
  bool _isLoadingLeave = true;

  @override
  void didUpdateWidget(covariant MemberProfileCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final memberBudgetChanged =
        oldWidget.member.id != widget.member.id ||
        oldWidget.member.minBudget != widget.member.minBudget ||
        oldWidget.member.maxBudget != widget.member.maxBudget;
    if (memberBudgetChanged && !_isEditingBudget) {
      _budgetRange = RangeValues(
        widget.member.minBudget,
        widget.member.maxBudget,
      );
      _minimumBudgetController.text = _budgetRange.start.round().toString();
      _maximumBudgetController.text = _budgetRange.end.round().toString();
    }
  }

  @override
  void initState() {
    super.initState();
    _budgetRange = RangeValues(
      widget.member.minBudget,
      widget.member.maxBudget,
    );
    _minimumBudgetController = TextEditingController(
      text: _budgetRange.start.round().toString(),
    );
    _maximumBudgetController = TextEditingController(
      text: _budgetRange.end.round().toString(),
    );
    _preferences = List.from(widget.member.preferences);
    _tripDateRange = _parseDateRange(widget.member.dateRange);
    _calendarMonth = DateTime(
      _tripDateRange.start.year,
      _tripDateRange.start.month,
    );
    _loadLeaveData(year: _calendarMonth.year);
  }

  @override
  void dispose() {
    _minimumBudgetController.dispose();
    _maximumBudgetController.dispose();
    super.dispose();
  }

  DateTimeRange _parseDateRange(String dateRange) {
    final dateParts = RegExp(r'([A-Za-z]{3})\s+(\d{1,2})')
        .allMatches(dateRange)
        .toList();
    final years = RegExp(r'\d{4}')
        .allMatches(dateRange)
        .map((match) => int.parse(match.group(0)!))
        .toList();
    const monthNumbers = {
      'Jan': 1,
      'Feb': 2,
      'Mar': 3,
      'Apr': 4,
      'May': 5,
      'Jun': 6,
      'Jul': 7,
      'Aug': 8,
      'Sep': 9,
      'Oct': 10,
      'Nov': 11,
      'Dec': 12,
    };

    if (dateParts.length < 2) {
      final start = DateTime.now();
      return DateTimeRange(
        start: start,
        end: start.add(const Duration(days: 6)),
      );
    }

    final currentYear = DateTime.now().year;
    final startYear = years.isNotEmpty ? years.first : currentYear;
    final endYear = years.length > 1 ? years.last : startYear;
    final start = DateTime(
      startYear,
      monthNumbers[dateParts.first.group(1)] ?? 1,
      int.parse(dateParts.first.group(2)!),
    );
    final end = DateTime(
      endYear,
      monthNumbers[dateParts[1].group(1)] ?? start.month,
      int.parse(dateParts[1].group(2)!),
    );
    return DateTimeRange(start: start, end: end);
  }

  String _formatDateRange(DateTimeRange dateRange) {
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
    final start = dateRange.start;
    final end = dateRange.end;
    if (start.year != end.year) {
      return '${months[start.month - 1]} ${start.day}, ${start.year} - '
          '${months[end.month - 1]} ${end.day}, ${end.year}';
    }
    final endDate = start.month == end.month
        ? '${end.day}'
        : '${months[end.month - 1]} ${end.day}';
    return '${months[start.month - 1]} ${start.day} - $endDate, ${end.year}';
  }

  Future<void> _loadLeaveData({required int year}) async {
    if (mounted) setState(() => _isLoadingLeave = true);
    final leaveData = await _leaveService.getUserLeaveData(year: year);
    if (mounted) {
      setState(() {
        _leaveData = leaveData;
        _isLoadingLeave = false;
      });
    }
  }

  Future<void> _selectTripDateRange() async {
    final today = DateTime.now();
    final firstYear = math.min(today.year - 10, _tripDateRange.start.year);
    final lastYear = math.max(today.year + 10, _tripDateRange.end.year);
    final selected = await showDateRangePicker(
      context: context,
      firstDate: DateTime(firstYear),
      lastDate: DateTime(lastYear, 12, 31),
      initialDateRange: _tripDateRange,
    );
    if (selected == null || !mounted) return;

    final updated = DateTimeRange(
      start: DateUtils.dateOnly(selected.start),
      end: DateUtils.dateOnly(selected.end),
    );
    setState(() {
      _tripDateRange = updated;
      _calendarMonth = DateTime(updated.start.year, updated.start.month);
    });
    await _summaryService.updateMemberDateRange(
      memberId: widget.member.id,
      dateRange: _formatDateRange(updated),
    );
    await _loadLeaveData(year: _calendarMonth.year);
    widget.onMemberUpdated?.call();
  }

  Future<void> _changeCalendarMonth(int year, int monthIndex) async {
    final month = DateTime(year, monthIndex + 1);
    setState(() => _calendarMonth = month);
    if (_leaveData?.selectedYear != year) {
      await _loadLeaveData(year: year);
    }
  }

  Future<void> _showLeaveStatusPicker(DateTime date) async {
    final dateKey =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final currentStatus =
        _leaveData?.dateStatuses[dateKey] ?? DateStatus.normal;
    if (currentStatus == DateStatus.holiday) return;

    final status = await showModalBottomSheet<DateStatus>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _statusTile(
              context,
              dateKey,
              'Busy',
              DateStatus.busy,
            ),
            _statusTile(
              context,
              dateKey,
              'Normal',
              DateStatus.normal,
            ),
            _statusTile(
              context,
              dateKey,
              'Leave Taken',
              DateStatus.annualLeave,
            ),
          ],
        ),
      ),
    );
    if (status == null) return;

    final updated = await _leaveService.updateDateStatus(dateKey, status);
    if (!updated || !mounted) return;
    await _loadLeaveData(year: date.year);
  }

  Widget _statusTile(
    BuildContext context,
    String dateKey,
    String label,
    DateStatus status,
  ) => ListTile(
    title: Text(label),
    trailing: _leaveData?.dateStatuses[dateKey] == status
        ? const Icon(Icons.check, color: AppTheme.primaryGreen)
        : null,
    onTap: () => Navigator.pop(context, status),
  );

  void _startBudgetEdit() {
    if (!widget.member.isMe) return;
    _minimumBudgetController.text = _budgetRange.start.round().toString();
    _maximumBudgetController.text = _budgetRange.end.round().toString();
    setState(() => _isEditingBudget = true);
  }

  void _cancelBudgetEdit() {
    _minimumBudgetController.text = _budgetRange.start.round().toString();
    _maximumBudgetController.text = _budgetRange.end.round().toString();
    setState(() => _isEditingBudget = false);
  }

  Future<void> _saveBudgetEdit() async {
    final minimum = int.tryParse(_minimumBudgetController.text);
    final maximum = int.tryParse(_maximumBudgetController.text);
    if (minimum == null || maximum == null || maximum < minimum) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid minimum and maximum budget.')),
      );
      return;
    }

    final updated = RangeValues(minimum.toDouble(), maximum.toDouble());
    final saved = await _summaryService.updateMemberBudget(
      memberId: widget.member.id,
      minBudget: updated.start,
      maxBudget: updated.end,
    );
    if (!mounted) return;
    if (!saved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to update the trip budget.')),
      );
      return;
    }

    setState(() {
      _budgetRange = updated;
      _isEditingBudget = false;
    });
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
    final leaveBalanceLabel = widget.member.isMe
        ? (_leaveData == null
              ? widget.member.leaveBalanceSummary
              : '${_leaveData!.leaveBalance} Leave Days Left')
        : widget.member.leaveBalanceSummary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. AVAILABLE DATES (Synced with Leave Optimizer)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'AVAILABLE DATES',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF788896),
                  letterSpacing: 0.5,
                ),
              ),
              Flexible(
                child: Text(
                  leaveBalanceLabel,
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          InkWell(
            onTap: _selectTripDateRange,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: AppTheme.textDark,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _formatDateRange(_tripDateRange),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDark,
                      ),
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

          // 2. TRIP BUDGET RANGE
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'TRIP BUDGET RANGE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF788896),
                  letterSpacing: 0.5,
                ),
              ),
              if (!_isEditingBudget)
                InkWell(
                  onTap: widget.member.isMe ? _startBudgetEdit : null,
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      'RM$minVal – RM$maxVal',
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          if (_isEditingBudget) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minimumBudgetController,
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      prefixText: 'RM ',
                      hintText: 'Min',
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _maximumBudgetController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      prefixText: 'RM ',
                      hintText: 'Max',
                      isDense: true,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Save budget',
                  visualDensity: VisualDensity.compact,
                  onPressed: _saveBudgetEdit,
                  icon: const Icon(
                    Icons.check_circle,
                    color: AppTheme.primaryGreen,
                  ),
                ),
                IconButton(
                  tooltip: 'Cancel editing',
                  visualDensity: VisualDensity.compact,
                  onPressed: _cancelBudgetEdit,
                  icon: const Icon(Icons.close, color: AppTheme.textMuted),
                ),
              ],
            ),
          ],

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
    return LeaveCalendarCard(
      selectedYear: _calendarMonth.year,
      currentMonthIndex: _calendarMonth.month - 1,
      dateStatuses: _leaveData?.dateStatuses ?? const {},
      selectedDateRange: null,
      onDateTap: _showLeaveStatusPicker,
      onMonthChanged: _changeCalendarMonth,
      showLegend: false,
    );
  }
}
