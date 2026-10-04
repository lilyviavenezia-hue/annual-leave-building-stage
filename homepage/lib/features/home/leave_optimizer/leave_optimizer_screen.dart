import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'package:homempage/models/leave_status.dart';
import '../../../models/leave_combo.dart';
import '../../../services/leave_service.dart';
import 'widgets/calendar_grid.dart';
import 'widgets/leave_combo_card.dart';

class LeaveOptimizerModal extends StatefulWidget {
  const LeaveOptimizerModal({super.key});

  @override
  State<LeaveOptimizerModal> createState() => _LeaveOptimizerModalState();
}

class _LeaveOptimizerModalState extends State<LeaveOptimizerModal> {
  final LeaveService _leaveService = LeaveService();
  late Future<List<LeaveCombo>> _leaveCombosFuture;
  
  bool _isLoading = true;

  int _selectedYear = 2026;
  int _currentMonthIndex = 9;
  int _leaveBalance = 18;
  Map<String, DateStatus> _dateStatuses = {};

  final List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  final List<int> _availableYears = [2025, 2026, 2027, 2028];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _leaveCombosFuture = _leaveService.getLeaveCombos();
  }

  Future<void> _loadInitialData() async {
    final leaveData = await _leaveService.getUserLeaveData();
    if (mounted) {
      setState(() {
        _selectedYear = leaveData.selectedYear;
        _leaveBalance = leaveData.leaveBalance;
        _dateStatuses = leaveData.dateStatuses;
        _isLoading = false;
      });
    }
  }

  void _showLeaveBalanceDialog() {
    final controller = TextEditingController(text: _leaveBalance.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Annual Leave'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Total Leave Days Remaining',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
            ),
            onPressed: () async {
              final val = int.tryParse(controller.text);
              if (val != null) {
                setState(() => _leaveBalance = val);
                await _leaveService.updateLeaveBalance(val);
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Save', style: TextStyle(color: AppTheme.backgroundWhite)),
          ),
        ],
      ),
    );
  }

  void _showStatusPickerBottomSheet(DateTime date) {
    final dateKey =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final currentStatus = _dateStatuses[dateKey] ?? DateStatus.normal;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Set Status for ${_months[date.month - 1]} ${date.day}, ${date.year}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildStatusOption(context, dateKey, 'Normal Working Day', DateStatus.normal, AppTheme.cardBackground, currentStatus),
            _buildStatusOption(context, dateKey, 'Busy / High Priority Work', DateStatus.busy, AppTheme.statusBusyBg, currentStatus),
            _buildStatusOption(context, dateKey, 'Annual Leave', DateStatus.annualLeave, AppTheme.statusAnnualLeaveBg, currentStatus),
            _buildStatusOption(context, dateKey, 'Public / Regional Holiday', DateStatus.holiday, AppTheme.statusHolidayBg, currentStatus),
            _buildStatusOption(context, dateKey, 'Recommended Bridge Day', DateStatus.recommended, AppTheme.statusRecommendedBg, currentStatus),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusOption(
    BuildContext context,
    String dateKey,
    String label,
    DateStatus status,
    Color color,
    DateStatus selectedStatus,
  ) {
    final isSelected = status == selectedStatus;
    return ListTile(
      leading: CircleAvatar(backgroundColor: color, radius: 12),
      title: Text(label),
      trailing: isSelected ? const Icon(Icons.check, color: AppTheme.primaryGreen) : null,
      onTap: () {
        setState(() {
          if (status == DateStatus.normal) {
            _dateStatuses.remove(dateKey);
          } else {
            _dateStatuses[dateKey] = status;
          }
        });
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.textDark),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Leave Optimizer',
            style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold),
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.cardBackground,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.textMuted.withValues(alpha: 0.2)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: _selectedYear,
                              icon: const Icon(Icons.keyboard_arrow_down_rounded),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textDark,
                              ),
                              items: _availableYears.map((int yr) {
                                return DropdownMenuItem<int>(
                                  value: yr,
                                  child: Text('$yr'),
                                );
                              }).toList(),
                              onChanged: (newYear) {
                                if (newYear != null) {
                                  setState(() => _selectedYear = newYear);
                                }
                              },
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: _showLeaveBalanceDialog,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppTheme.badgeGreenLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '$_leaveBalance Days Remaining',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryGreen,
                                  ),
                                ),
                                const Text(
                                  'TAP TO EDIT BALANCE',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.cardBackground,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${_months[_currentMonthIndex]} $_selectedYear',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textDark,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.badgeGreenLight,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  '1 Public Holiday',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.primaryGreen,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildLegendItem('Busy', AppTheme.statusBusyBg),
                              _buildLegendItem('Holiday', AppTheme.statusHolidayBg),
                              _buildLegendItem('Annual Leave', AppTheme.statusAnnualLeaveBg),
                              _buildLegendItem('Recommended', AppTheme.statusRecommendedBg),
                            ],
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onHorizontalDragEnd: (details) {
                              if (details.primaryVelocity! < 0) {
                                if (_currentMonthIndex < 11) {
                                  setState(() => _currentMonthIndex++);
                                }
                              } else if (details.primaryVelocity! > 0) {
                                if (_currentMonthIndex > 0) {
                                  setState(() => _currentMonthIndex--);
                                }
                              }
                            },
                            child: CalendarGrid(
                              selectedYear: _selectedYear,
                              currentMonthIndex: _currentMonthIndex,
                              dateStatuses: _dateStatuses,
                              onDateTap: _showStatusPickerBottomSheet,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Recommended Leave Combos',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    FutureBuilder<List<LeaveCombo>>(
                      future: _leaveCombosFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        final combos = snapshot.data!;

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: combos.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            return LeaveComboCard.fromModel(combo: combos[index]);
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
        ),
      ],
    );
  }
}