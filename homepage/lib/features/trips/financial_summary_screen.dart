import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_theme.dart';
import '../../features/chat/receipt_scanner_screen.dart';
import '../../features/chat/scanned_receipt_screen.dart';
import '../../models/budget.dart';
import '../../models/receipt.dart';
import '../../models/trip.dart';
import '../../services/budget_service.dart';
import '../../services/expense_service.dart';
import '../../services/trip_service.dart';

class FinancialSummaryScreen extends StatefulWidget {
  const FinancialSummaryScreen({super.key, this.tripId = '', this.trip});

  final String tripId;
  final Trip? trip;

  @override
  State<FinancialSummaryScreen> createState() => _FinancialSummaryScreenState();
}

class _FinancialSummaryScreenState extends State<FinancialSummaryScreen> {
  final BudgetService _budgetService = BudgetService();
  final ExpenseService _expenseService = ExpenseService();
  late final Future<TripBudgetEstimate> _estimateFuture;
  late final Future<List<Receipt>> _receiptsFuture;
  late final Future<Receipt> _peopleReceiptFuture;
  int _selectedPage = 0;

  @override
  void initState() {
    super.initState();
    _estimateFuture = _loadEstimate();
    _receiptsFuture = _expenseService.getRecentReceipts();
    _peopleReceiptFuture = _expenseService.getScannedReceipt();
  }

  Future<TripBudgetEstimate> _loadEstimate() async {
    final trip = widget.trip ?? await TripService().getTrip(widget.tripId);
    return _budgetService.getTripEstimate(trip);
  }

  Future<void> _uploadReceipt() async {
    try {
      final photo = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (photo != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Selected receipt: ${photo.name}')),
        );
      }
    } on Exception catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to select receipt: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FutureBuilder<TripBudgetEstimate>(
          future: _estimateFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryGreen),
              );
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return Center(
                child: Text(
                  'Unable to load this trip estimate: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              );
            }
            final estimate = snapshot.data!;
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.chevron_left, size: 25),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints.tightFor(
                        width: 28,
                        height: 34,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Expanded(
                      child: Text(
                        'Financial Summary',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildBudgetSummary(estimate),
                const SizedBox(height: 14),
                _SummarySectionTabs(
                  selectedIndex: _selectedPage,
                  onSelected: (index) => setState(() => _selectedPage = index),
                ),
                const SizedBox(height: 14),
                if (_selectedPage == 0) ...[
                  const Padding(
                    padding: EdgeInsets.fromLTRB(4, 2, 4, 10),
                    child: Text(
                      'People',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildPeople(),
                ] else
                  _buildRecentReceipts(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBudgetSummary(TripBudgetEstimate estimate) {
    final total = estimate.estimatedTotal;
    final remaining = estimate.remainingBudget;
    final progress = estimate.budgetProgress;
    return Column(
      children: [
        _SummaryCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: const Text(
                      'Budget progress',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    '${(progress * 100).round()}%',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF168541),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 7,
                  backgroundColor: const Color(0xFFE8ECE9),
                  color: AppTheme.primaryGreen,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Estimated ${_money(total)}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ),
                  Text(
                    'Remaining ${_money(remaining.abs())}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      label: 'Budget',
                      value: _money(estimate.plannedBudget),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MetricCard(
                      label: remaining >= 0 ? 'Buffer' : 'Over budget by',
                      value: _money(remaining.abs()),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPeople() => FutureBuilder<Receipt>(
    future: _peopleReceiptFuture,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      if (snapshot.hasError || !snapshot.hasData) {
        return const Text('Unable to load trip members.');
      }
      final receipt = snapshot.data!;
      return Column(
        children: [
          for (final member in receipt.memberSplits)
            _PersonExpenseCard(
              member: member,
              total: receipt.totalAmount * member.splitPercentage / 100,
            ),
        ],
      );
    },
  );

  Widget _buildRecentReceipts() => FutureBuilder<List<Receipt>>(
    future: _receiptsFuture,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      if (snapshot.hasError || !snapshot.hasData) {
        return const Text('Unable to load recent receipts.');
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _ExpenseAction(
                  icon: Icons.camera_alt_outlined,
                  label: 'Scan Receipt',
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          ReceiptScannerScreen(groupId: widget.tripId),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: _ExpenseAction(
                  icon: Icons.image_outlined,
                  label: 'Upload Gallery',
                  onPressed: _uploadReceipt,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.fromLTRB(4, 2, 4, 10),
            child: Text(
              'Recent Receipts',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          for (final receipt in snapshot.data!)
            _ReceiptCard(
              receipt: receipt,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => ScannedReceiptScreen(
                    groupId: widget.tripId,
                    initialReceipt: receipt,
                  ),
                ),
              ),
            ),
        ],
      );
    },
  );

  String _money(double amount) => 'RM ${amount.round()}';
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: const Color(0xFFE9ECEA)),
      borderRadius: BorderRadius.circular(17),
    ),
    child: child,
  );
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 54),
    padding: const EdgeInsets.all(7),
    decoration: BoxDecoration(
      color: const Color(0xFFF5F7F6),
      borderRadius: BorderRadius.circular(11),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 9, color: AppTheme.textMuted),
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D3B32),
            ),
          ),
        ),
      ],
    ),
  );
}

class _SummarySectionTabs extends StatelessWidget {
  const _SummarySectionTabs({
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(5),
    decoration: BoxDecoration(
      color: const Color(0xFFF0F2F1),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        for (final (index, icon) in [
          (0, Icons.person_outline_rounded),
          (1, Icons.receipt_long_outlined),
        ])
          Expanded(
            child: Semantics(
              button: true,
              label: index == 0 ? 'People' : 'Receipts',
              selected: selectedIndex == index,
              child: IconButton(
                tooltip: index == 0 ? 'People' : 'Receipts',
                onPressed: () => onSelected(index),
                style: IconButton.styleFrom(
                  backgroundColor: selectedIndex == index
                      ? Colors.white
                      : Colors.transparent,
                  foregroundColor: selectedIndex == index
                      ? AppTheme.primaryGreen
                      : AppTheme.textMuted,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  minimumSize: const Size.fromHeight(40),
                  elevation: selectedIndex == index ? 1 : 0,
                ),
                icon: Icon(icon, size: 18),
              ),
            ),
          ),
      ],
    ),
  );
}

class _ExpenseAction extends StatelessWidget {
  const _ExpenseAction({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: onPressed,
    child: Column(
      children: [
        CircleAvatar(
          backgroundColor: const Color(0xFFE6F7EC),
          foregroundColor: AppTheme.primaryGreen,
          child: Icon(icon),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: AppTheme.textDark)),
      ],
    ),
  );
}

class _ReceiptCard extends StatelessWidget {
  const _ReceiptCard({required this.receipt, required this.onTap});

  final Receipt receipt;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isSettled = receipt.timestamp.toLowerCase().contains('settled');
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F7),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        receipt.merchantName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        receipt.timestamp.split('·').first.trim(),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.textMuted,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            width: 30,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isSettled
                                  ? AppTheme.primaryGreen
                                  : const Color(0xFFFF3030),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isSettled ? 'Settled' : 'Pending split',
                            style: TextStyle(
                              color: isSettled
                                  ? AppTheme.primaryGreen
                                  : const Color(0xFFFF3030),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'RM ${receipt.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PersonExpenseCard extends StatelessWidget {
  const _PersonExpenseCard({required this.member, required this.total});

  final ReceiptMemberSplit member;
  final double total;

  @override
  Widget build(BuildContext context) {
    final color = Color(member.colorHex);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7F6),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE9ECEA)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: color,
            child: Text(
              member.id,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              member.name,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            'RM ${total.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
