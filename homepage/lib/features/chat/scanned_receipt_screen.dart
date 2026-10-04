import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/receipt.dart';
import '../../services/expense_service.dart';

class ScannedReceiptScreen extends StatefulWidget {
  final String groupId;

  const ScannedReceiptScreen({super.key, required this.groupId});

  @override
  State<ScannedReceiptScreen> createState() => _ScannedReceiptScreenState();
}

class _ScannedReceiptScreenState extends State<ScannedReceiptScreen> {
  final ExpenseService _expenseService = ExpenseService();
  Receipt? _receipt;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReceipt();
  }

  Future<void> _loadReceipt() async {
    final receipt = await _expenseService.getScannedReceipt();
    if (mounted) {
      setState(() {
        _receipt = receipt;
        _isLoading = false;
      });
    }
  }

  void _toggleMemberForItem(ReceiptItem item, String memberId) {
    setState(() {
      if (item.assignedMemberIds.contains(memberId)) {
        if (item.assignedMemberIds.length > 1) {
          item.assignedMemberIds.remove(memberId);
        }
      } else {
        item.assignedMemberIds.add(memberId);
      }
    });
  }

  void _confirmSplit() async {
    if (_receipt != null) {
      await _expenseService.confirmReceiptSplit(_receipt!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expense split confirmed and posted!')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Back',
          style: TextStyle(
            color: AppTheme.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  children: [
                    // 1. Merchant Header & Receipt Items Card
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _receipt!.merchantName,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.textDark,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _receipt!.timestamp,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.receipt_long,
                                  color: AppTheme.primaryGreen,
                                  size: 22,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),

                          // Line Items
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _receipt!.items.length,
                            separatorBuilder: (_, _) => const Divider(height: 20),
                            itemBuilder: (context, index) {
                              final item = _receipt!.items[index];
                              final itemTotal = item.price * item.quantity;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            item.title,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: AppTheme.textDark,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          const Icon(Icons.edit_outlined,
                                              size: 14, color: AppTheme.textMuted),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            'RM ${itemTotal.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 16,
                                              color: AppTheme.textDark,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          const Icon(Icons.edit_outlined,
                                              size: 14, color: AppTheme.textMuted),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${item.quantity} × RM ${item.price.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textMuted,
                                    ),
                                  ),
                                  const SizedBox(height: 10),

                                  // Member Avatar Toggles driven by receipt.memberSplits
                                  Row(
                                    children: [
                                      const Icon(Icons.people_outline,
                                          size: 18, color: AppTheme.textMuted),
                                      const SizedBox(width: 10),
                                      ..._receipt!.memberSplits.map((m) {
                                        final isAssigned =
                                            item.assignedMemberIds.contains(m.id);
                                        final memberColor = Color(m.colorHex);

                                        return GestureDetector(
                                          onTap: () =>
                                              _toggleMemberForItem(item, m.id),
                                          child: Container(
                                            margin: const EdgeInsets.only(right: 8),
                                            width: 32,
                                            height: 32,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: isAssigned
                                                  ? memberColor
                                                  : Colors.white,
                                              border: Border.all(
                                                color: isAssigned
                                                    ? Colors.transparent
                                                    : Colors.grey.shade300,
                                              ),
                                            ),
                                            child: Text(
                                              m.id,
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: isAssigned
                                                    ? Colors.white
                                                    : AppTheme.textMuted,
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 2. Total & Percentage Split Breakdown Card
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'TOTAL',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textMuted,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Text(
                                'RM ${_receipt!.totalAmount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.textDark,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Dynamic Percentage Splits
                          ..._receipt!.memberSplits.map((m) {
                            final memberColor = Color(m.colorHex);
                            final calculatedAmount =
                                (_receipt!.totalAmount * m.splitPercentage) / 100;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: memberColor,
                                    child: Text(
                                      m.id,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: AppTheme.cardBackground,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          '${m.splitPercentage}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        const Text('%',
                                            style: TextStyle(color: AppTheme.textMuted)),
                                      ],
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    'RM ${calculatedAmount.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: AppTheme.textDark,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 3. "Paid By" Container
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Paid by',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: const Color(0xFF66BB6A),
                                child: Text(
                                  _receipt!.paidByMemberAvatar,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _receipt!.paidByMemberName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.textDark,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 4. "Confirm split" CTA
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: _confirmSplit,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Confirm split',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }
}