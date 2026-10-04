import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';

class TravelChecklistScreen extends StatefulWidget {
  const TravelChecklistScreen({super.key});

  @override
  State<TravelChecklistScreen> createState() => _TravelChecklistScreenState();
}

class _TravelChecklistScreenState extends State<TravelChecklistScreen> {
  final List<_ChecklistItem> _items = [
    _ChecklistItem('Passport', isComplete: true),
    _ChecklistItem('Flight ticket', isComplete: true, isSaved: true),
    _ChecklistItem('Travel adapter', isComplete: true),
    _ChecklistItem('Charger', isComplete: true),
    _ChecklistItem('Hotel Invoice', isPending: true),
    _ChecklistItem('Travel insurance'),
    _ChecklistItem('Toiletries'),
    _ChecklistItem('Camera'),
    _ChecklistItem('Medication'),
  ];

  int get _completedCount => _items.where((item) => item.isComplete).length;

  void _addItem() {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add checklist item'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'e.g. Sunglasses'),
          onSubmitted: (_) => _saveItem(dialogContext, controller.text),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => _saveItem(dialogContext, controller.text),
            child: const Text('Add'),
          ),
        ],
      ),
    ).whenComplete(controller.dispose);
  }

  void _saveItem(BuildContext dialogContext, String value) {
    final itemName = value.trim();
    if (itemName.isEmpty) return;
    setState(() => _items.add(_ChecklistItem(itemName)));
    Navigator.of(dialogContext).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _showTicketDetails
            ? _buildTicketDetails(context)
            : _buildChecklist(context),
      ),
    );
  }

  bool _showTicketDetails = false;

  Widget _buildChecklist(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PageTitle(
                title: 'Travel Checklist',
                onBack: () => context.pop(),
              ),
              const SizedBox(height: 7),
              Text(
                '$_completedCount of ${_items.length} completed',
                style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
              ),
              const SizedBox(height: 7),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: _items.isEmpty ? 0 : _completedCount / _items.length,
                  minHeight: 5,
                  backgroundColor: const Color(0xFFF0F0F5),
                  color: AppTheme.primaryGreen,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            itemCount: _items.length,
            itemBuilder: (context, index) => _buildChecklistRow(index),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _addItem,
                  icon: const Icon(Icons.add, size: 17),
                  label: const Text('Add item'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryGreen,
                    minimumSize: const Size.fromHeight(42),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  key: const ValueKey('checklist-next'),
                  onPressed: () => setState(() => _showTicketDetails = true),
                  icon: const Icon(Icons.arrow_forward, size: 17),
                  label: const Text('Next: ticket'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(42),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChecklistRow(int index) {
    final item = _items[index];
    return InkWell(
      onTap: item.isSaved
          ? () => setState(() => _showTicketDetails = true)
          : () => setState(() => item.isComplete = !item.isComplete),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 40,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F3F7),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(
              item.isComplete
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              color: item.isComplete
                  ? AppTheme.primaryGreen
                  : const Color(0xFFA5A5AD),
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                item.title,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (item.isSaved)
              _ItemBadge(
                label: 'Saved',
                color: AppTheme.primaryGreen,
                onTap: () => setState(() => _showTicketDetails = true),
              )
            else if (item.isPending)
              const _ItemBadge(label: 'Pending', color: Color(0xFFFF823E)),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketDetails(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
          child: _PageTitle(
            title: 'Travel Checklist',
            onBack: () => setState(() => _showTicketDetails = false),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFE7EBE8)),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: Color(0xFFE8F7EE),
                          child: Icon(
                            Icons.check,
                            color: AppTheme.primaryGreen,
                            size: 17,
                          ),
                        ),
                        SizedBox(width: 9),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ticket saved',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Ready for airport check-in',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _ItemBadge(
                          label: 'PDF',
                          color: Color(0xFF8A9290),
                          neutral: true,
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Your boarding pass is saved and ready to scan. Keep this screen handy for check-in, security, and gate access.',
                      style: TextStyle(
                        fontSize: 11,
                        height: 1.45,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFE7EBE8)),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: const Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(13),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Boarding pass',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 3),
                                Text(
                                  'Electronic ticket • Non-refundable',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: AppTheme.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _ItemBadge(
                            label: 'Confirmed',
                            color: AppTheme.primaryGreen,
                            neutral: true,
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 1),
                    Padding(
                      padding: EdgeInsets.all(13),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 13,
                                backgroundColor: AppTheme.primaryGreen,
                                child: Text(
                                  'AL',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Aurora Airlines',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Flight AA 214',
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: AppTheme.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                'On time',
                                style: TextStyle(
                                  color: AppTheme.primaryGreen,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _AirportCode(code: 'SFO', city: 'San Francisco'),
                              Icon(
                                Icons.flight_takeoff,
                                color: AppTheme.primaryGreen,
                                size: 18,
                              ),
                              _AirportCode(code: 'JFK', city: 'New York'),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Duration',
                                    style: TextStyle(
                                      fontSize: 8,
                                      color: AppTheme.textMuted,
                                    ),
                                  ),
                                  Text(
                                    '5h 20m',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: _TicketField(
                                  label: 'Passenger',
                                  value: 'Maya Chen',
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: _TicketField(
                                  label: 'Booking ref',
                                  value: 'AL2148K',
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: _TicketField(
                                  label: 'Date',
                                  value: '18 Jun 2026',
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: _TicketField(
                                  label: 'Gate',
                                  value: 'G12',
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: _TicketField(
                                  label: 'Departure',
                                  value: '08:30 PDT',
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: _TicketField(
                                  label: 'Arrival',
                                  value: '16:50 EDT',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  key: const ValueKey('ticket-previous'),
                  onPressed: () => setState(() => _showTicketDetails = false),
                  icon: const Icon(Icons.arrow_back, size: 17),
                  label: const Text('Previous: checklist'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryGreen,
                    minimumSize: const Size.fromHeight(42),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => context.pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(42),
                  ),
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PageTitle extends StatelessWidget {
  const _PageTitle({required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onBack,
          icon: const Icon(Icons.chevron_left, size: 25),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints.tightFor(width: 28, height: 34),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}

class _ItemBadge extends StatelessWidget {
  const _ItemBadge({
    required this.label,
    required this.color,
    this.neutral = false,
    this.onTap,
  });

  final String label;
  final Color color;
  final bool neutral;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: neutral ? const Color(0xFFF0F3F1) : color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: neutral ? color : Colors.white,
          fontSize: 8,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    return onTap == null ? badge : GestureDetector(onTap: onTap, child: badge);
  }
}

class _AirportCode extends StatelessWidget {
  const _AirportCode({required this.code, required this.city});

  final String code;
  final String city;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          code,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        Text(
          city,
          style: const TextStyle(fontSize: 8, color: AppTheme.textMuted),
        ),
      ],
    );
  }
}

class _TicketField extends StatelessWidget {
  const _TicketField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7F6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 8, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _ChecklistItem {
  _ChecklistItem(
    this.title, {
    this.isComplete = false,
    this.isPending = false,
    this.isSaved = false,
  });

  final String title;
  bool isComplete;
  final bool isPending;
  final bool isSaved;
}
