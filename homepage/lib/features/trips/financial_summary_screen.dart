import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_theme.dart';
import '../../features/chat/receipt_scanner_screen.dart';
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
  int _selectedPage = 0;
  int _selectedExpenseTab = 0;

  @override
  void initState() {
    super.initState();
    _estimateFuture = _loadEstimate();
    _receiptsFuture = _expenseService.getRecentReceipts();
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
                        'Budget and Expenses',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _SegmentControl(
                  labels: const ['Budget summary', 'Expenses'],
                  selectedIndex: _selectedPage,
                  onSelected: (index) => setState(() => _selectedPage = index),
                ),
                const SizedBox(height: 14),
                if (_selectedPage == 0)
                  _buildBudgetSummary(estimate)
                else
                  _buildExpenses(estimate),
                const SizedBox(height: 12),
                const Text(
                  'Estimates are based on this trip’s duration, traveller count, and planned budget. Actual costs may vary.',
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
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
    final withinBudget = remaining >= 0;
    return Column(
      children: [
        _SummaryCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total estimated cost',
                style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
              ),
              const SizedBox(height: 3),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _money(total),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1D3B32),
                      ),
                    ),
                  ),
                  _Badge(
                    label: withinBudget ? 'On budget' : 'Over budget',
                    background: withinBudget
                        ? const Color(0xFFE8F7EE)
                        : const Color(0xFFFFEEEE),
                    foreground: withinBudget
                        ? const Color(0xFF168541)
                        : Colors.red,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      label: 'Estimated per person',
                      value: _money(estimate.costPerPerson),
                      note: '${estimate.travellerCount} people',
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _MetricCard(
                      label: 'Planned budget',
                      value: _money(estimate.plannedBudget),
                      note: '${estimate.durationDays} days',
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _MetricCard(
                      label: withinBudget
                          ? 'Budget remaining'
                          : 'Over budget by',
                      value: _money(remaining.abs()),
                      note: 'Estimated',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        _SummaryCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Budget progress',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    '${(estimate.budgetProgress * 100).round()}%',
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
                  value: estimate.budgetProgress,
                  minHeight: 7,
                  backgroundColor: const Color(0xFFE8ECE9),
                  color: withinBudget ? const Color(0xFF25C45A) : Colors.red,
                ),
              ),
              const SizedBox(height: 7),
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
                    '${estimate.durationDays} days · ${estimate.travellerCount} people',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        _categoryBreakdown(estimate),
      ],
    );
  }

  Widget _buildExpenses(TripBudgetEstimate estimate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
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
        _SegmentControl(
          labels: const ['Line items', 'Recent receipts'],
          selectedIndex: _selectedExpenseTab,
          onSelected: (index) => setState(() => _selectedExpenseTab = index),
        ),
        const SizedBox(height: 14),
        if (_selectedExpenseTab == 0) ...[
          _SummaryCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Budget summary',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                _amountLine('Estimated total', estimate.estimatedTotal),
                const SizedBox(height: 5),
                _amountLine(
                  'Budget remaining',
                  estimate.remainingBudget,
                  positive: estimate.remainingBudget >= 0,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'Line items',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
          const SizedBox(height: 8),
          for (final item in estimate.categories) _ExpenseLineItem(item: item),
        ] else
          FutureBuilder<List<Receipt>>(
            future: _receiptsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError || !snapshot.hasData) {
                return const Text('Unable to load recent receipts.');
              }
              final receipts = snapshot.data!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recent Receipts',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 8),
                  for (final receipt in receipts)
                    _ReceiptCard(receipt: receipt),
                ],
              );
            },
          ),
      ],
    );
  }

  Widget _categoryBreakdown(TripBudgetEstimate estimate) {
    return _SummaryCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Expanded(
                child: Text(
                  'Category breakdown',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                'Estimated',
                style: TextStyle(fontSize: 10, color: AppTheme.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (final item in estimate.categories)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: item.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.category,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    _money(item.amount),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _amountLine(String label, double amount, {bool positive = false}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
          ),
        ),
        Text(
          _money(amount.abs()),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: positive ? AppTheme.primaryGreen : AppTheme.textDark,
          ),
        ),
      ],
    );
  }

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
  const _MetricCard({required this.label, required this.value, this.note});

  final String label;
  final String value;
  final String? note;

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
        if (note != null)
          Text(
            note!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 8, color: AppTheme.textMuted),
          ),
      ],
    ),
  );
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Text(
      label,
      style: TextStyle(
        color: foreground,
        fontSize: 9,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

class _SegmentControl extends StatelessWidget {
  const _SegmentControl({
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: const Color(0xFFF0F2F1),
      borderRadius: BorderRadius.circular(11),
    ),
    child: Row(
      children: [
        for (var index = 0; index < labels.length; index++)
          Expanded(
            child: GestureDetector(
              onTap: () => onSelected(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selectedIndex == index
                      ? Colors.white
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: selectedIndex == index
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 4,
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  labels[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: selectedIndex == index
                        ? AppTheme.primaryGreen
                        : AppTheme.textMuted,
                  ),
                ),
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

class _ExpenseLineItem extends StatelessWidget {
  const _ExpenseLineItem({required this.item});

  final BudgetItem item;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFFF3F3F7),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.category,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 3),
              const Text(
                'Estimated from your trip plan',
                style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
              ),
            ],
          ),
        ),
        Text(
          'RM ${item.amount.round()}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 8),
        const _Badge(
          label: 'Est.',
          background: Color(0xFFE5E6EA),
          foreground: AppTheme.textMuted,
        ),
      ],
    ),
  );
}

class _ReceiptCard extends StatelessWidget {
  const _ReceiptCard({required this.receipt});

  final Receipt receipt;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFFF3F3F7),
      borderRadius: BorderRadius.circular(15),
    ),
    child: Row(
      children: [
        const Icon(Icons.receipt_long_outlined, color: AppTheme.primaryGreen),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                receipt.merchantName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                receipt.timestamp,
                style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
              ),
            ],
          ),
        ),
        Text(
          'RM ${receipt.totalAmount.toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );
}
