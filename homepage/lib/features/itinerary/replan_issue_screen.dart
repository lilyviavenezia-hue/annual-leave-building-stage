import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../models/replan_alternative.dart';
import '../../services/replan_service.dart';

class ReplanIssueScreen extends StatefulWidget {
  const ReplanIssueScreen({super.key, required this.destination});

  final String destination;

  @override
  State<ReplanIssueScreen> createState() => _ReplanIssueScreenState();
}

class _ReplanIssueScreenState extends State<ReplanIssueScreen> {
  int _issueMode = 0;
  bool _remindToRebook = true;
  bool _checkRefund = false;
  String _selectedAction = '';
  int _alternativeIndex = 0;
  final PageController _alternativeController = PageController();
  final TextEditingController _issueController = TextEditingController(
    text: 'Flight delayed for 2h (auto-generated)',
  );
  final ReplanService _replanService = ReplanService();

  @override
  void dispose() {
    _issueController.dispose();
    _alternativeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final city = widget.destination.split(',').first;
    final alternatives = _replanService.getNearbyAlternatives(
      widget.destination,
    );
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'annual leave',
                          style: TextStyle(
                            color: AppTheme.primaryGreen,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Close',
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const Text(
                    'What happened?',
                    style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const _SectionLabel('SELECT AN ISSUE'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _IssueModeCard(
                          title: 'Rearrange Itinerary',
                          description: 'Reschedule or cancel affected plans',
                          selected: _issueMode == 0,
                          onTap: () => _selectIssueMode(0),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _IssueModeCard(
                          title: 'Find Alternatives',
                          description: 'Find nearby alternatives for unforeseen situation',
                          selected: _issueMode == 1,
                          onTap: () => _selectIssueMode(1),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _issueController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.edit_outlined, size: 18),
                      filled: true,
                      fillColor: const Color(0xFFF2F2F6),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_issueMode == 0) ...[
                    const _SectionLabel('AFFECTED BOOKINGS'),
                    const SizedBox(height: 8),
                    _BookingRow(
                      icon: Icons.hotel_outlined,
                      title: '$city hotel',
                      subtitle: 'Check-in may be delayed by 2h',
                      status: 'Needs change',
                      statusColor: const Color(0xFFF6DDE2),
                    ),
                    _BookingRow(
                      icon: Icons.restaurant_outlined,
                      title: '$city dinner reservation',
                      subtitle: 'Reservation: 7:30 PM',
                      status: 'Can keep',
                      statusColor: Colors.white,
                    ),
                    _BookingRow(
                      icon: Icons.train_outlined,
                      title: 'Airport transfer',
                      subtitle: 'Arrival transfer to $city',
                      status: 'Review',
                      statusColor: const Color(0xFFF6DDE2),
                    ),
                    _BookingRow(
                      icon: Icons.confirmation_number_outlined,
                      title: '$city attraction ticket',
                      subtitle: 'Timed entry ticket',
                      status: 'Needs change',
                      statusColor: const Color(0xFFF6DDE2),
                    ),
                    const SizedBox(height: 8),
                    const _SectionLabel('FLIGHT DELAY ACTIONS'),
                    const SizedBox(height: 8),
                    _ActionRow(
                      icon: Icons.calendar_month_outlined,
                      text: 'Move to next available flight',
                      selected:
                          _selectedAction == 'Move to next available flight',
                      onTap: () =>
                          _selectAction('Move to next available flight'),
                    ),
                    _ActionRow(
                      icon: Icons.currency_exchange,
                      text: 'Cancel and request refund',
                      selected: _selectedAction == 'Cancel and request refund',
                      onTap: () => _selectAction('Cancel and request refund'),
                    ),
                    _ActionRow(
                      icon: Icons.trending_flat,
                      text: 'Reschedule on the itinerary',
                      selected:
                          _selectedAction == 'Reschedule on the itinerary',
                      onTap: () => _selectAction('Reschedule on the itinerary'),
                    ),
                  ] else ...[
                    Row(
                      children: [
                        const Expanded(
                          child: _SectionLabel('RECOMMENDED NEARBY'),
                        ),
                        Text(
                          alternatives.isEmpty
                              ? 'No matches'
                              : '${_alternativeIndex + 1} of ${alternatives.length}  ›',
                          style: TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (alternatives.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Text(
                          'Nearby alternatives are not available for this destination yet.',
                          style: TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      )
                    else
                      SizedBox(
                        height: 390,
                        child: PageView.builder(
                          controller: _alternativeController,
                          itemCount: alternatives.length,
                          onPageChanged: (index) =>
                              setState(() => _alternativeIndex = index),
                          itemBuilder: (context, index) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: _AlternativeCard(
                              alternative: alternatives[index],
                              onReplace: () =>
                                  _selectAction(alternatives[index].title),
                            ),
                          ),
                        ),
                      ),
                    if (alternatives.length > 1) ...[
                      const SizedBox(height: 7),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          alternatives.length,
                          (index) => Container(
                            width: 7,
                            height: 7,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: index == _alternativeIndex
                                  ? AppTheme.primaryGreen
                                  : const Color(0xFFD2D4DA),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                  const SizedBox(height: 14),
                  const _SectionLabel('FOLLOW-UP REMINDERS'),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Remind me to rebook hotel',
                      style: TextStyle(fontSize: 12),
                    ),
                    value: _remindToRebook,
                    onChanged: (value) =>
                        setState(() => _remindToRebook = value),
                  ),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Check refund status in 48h',
                      style: TextStyle(fontSize: 12),
                    ),
                    value: _checkRefund,
                    onChanged: (value) => setState(() => _checkRefund = value),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          _selectedAction.isEmpty
                              ? 'Replan options saved for ${widget.destination}.'
                              : '$_selectedAction selected for ${widget.destination}.',
                        ),
                      ),
                    );
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.auto_awesome, size: 17),
                  label: const Text('Restructure Itinerary'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectAction(String action) {
    setState(() => _selectedAction = action);
  }

  void _selectIssueMode(int mode) {
    if (_issueMode == mode) return;
    setState(() {
      _issueMode = mode;
      _issueController.text = mode == 0
          ? 'Flight delayed for 2h (auto-generated)'
          : 'Fushimi Inari-taisha Shrine is closed.';
      _selectedAction = '';
    });
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      color: AppTheme.textMuted,
      fontSize: 10,
      fontWeight: FontWeight.w600,
    ),
  );
}

class _IssueModeCard extends StatelessWidget {
  const _IssueModeCard({
    required this.title,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(14),
    onTap: onTap,
    child: Container(
      height: 86,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFFF3038) : const Color(0xFFF2F2F6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: selected ? Colors.white : AppTheme.textDark,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            description,
            style: TextStyle(
              color: selected ? Colors.white70 : AppTheme.textMuted,
              fontSize: 9,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ),
  );
}

class _BookingRow extends StatelessWidget {
  const _BookingRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.statusColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String status;
  final Color statusColor;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 7),
    padding: const EdgeInsets.all(9),
    decoration: BoxDecoration(
      color: const Color(0xFFF2F2F6),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: const Color(0xFFFF3038),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 9, color: AppTheme.textMuted),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
          decoration: BoxDecoration(
            color: statusColor,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Text(status, style: const TextStyle(fontSize: 8)),
        ),
      ],
    ),
  );
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.text,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 7),
    child: Material(
      color: selected ? const Color(0xFFE7F7EC) : const Color(0xFFF2F2F6),
      borderRadius: BorderRadius.circular(11),
      child: ListTile(
        dense: true,
        minLeadingWidth: 20,
        leading: Icon(icon, color: AppTheme.primaryGreen, size: 17),
        title: Text(text, style: const TextStyle(fontSize: 11)),
        onTap: onTap,
      ),
    ),
  );
}

class _AlternativeCard extends StatelessWidget {
  const _AlternativeCard({required this.alternative, required this.onReplace});

  final ReplanAlternative alternative;
  final VoidCallback onReplace;

  @override
  Widget build(BuildContext context) => Container(
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFE5E7EB)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x10000000),
          blurRadius: 12,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 124,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                alternative.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  color: const Color(0xFFE5F0E8),
                  child: const Icon(
                    Icons.photo_outlined,
                    color: AppTheme.primaryGreen,
                    size: 36,
                  ),
                ),
              ),
              Positioned(
                top: 9,
                left: 9,
                child: _ImageTag(
                  text: '${alternative.distance} from current stop',
                ),
              ),
              Positioned(
                top: 9,
                right: 9,
                child: _ImageTag(text: alternative.category),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                alternative.title,
                style: const TextStyle(
                  color: AppTheme.textDark,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                alternative.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 10),
              ),
              const SizedBox(height: 8),
              _AlternativeDetail(
                label: 'Distance',
                value: alternative.distance,
              ),
              _AlternativeDetail(
                label: 'Travel time',
                value: alternative.travelTime,
              ),
              _AlternativeDetail(
                label: 'Operating hours',
                value: alternative.openingHours,
              ),
              _AlternativeDetail(
                label: 'Visit duration',
                value: alternative.visitDuration,
              ),
              _AlternativeDetail(label: 'Price', value: alternative.price),
              const SizedBox(height: 7),
              SizedBox(
                width: double.infinity,
                height: 34,
                child: ElevatedButton(
                  onPressed: onReplace,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Replace Current Activity',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _ImageTag extends StatelessWidget {
  const _ImageTag({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.94),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(text, style: const TextStyle(fontSize: 9)),
  );
}

class _AlternativeDetail extends StatelessWidget {
  const _AlternativeDetail({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 10),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.textDark,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}
