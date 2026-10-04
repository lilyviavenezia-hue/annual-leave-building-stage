import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:homempage/core/theme/app_theme.dart';

class BudgetRangeSlider extends StatefulWidget {
  final RangeValues range;
  final ValueChanged<RangeValues> onChanged;

  const BudgetRangeSlider({
    super.key,
    required this.range,
    required this.onChanged,
  });

  @override
  State<BudgetRangeSlider> createState() => _BudgetRangeSliderState();
}

class _BudgetRangeSliderState extends State<BudgetRangeSlider> {
  late final TextEditingController _minimumController;
  late final TextEditingController _maximumController;
  late final FocusNode _minimumFocus;
  late final FocusNode _maximumFocus;

  @override
  void initState() {
    super.initState();
    _minimumController = TextEditingController(
      text: widget.range.start.round().toString(),
    );
    _maximumController = TextEditingController(
      text: widget.range.end.round().toString(),
    );
    _minimumFocus = FocusNode()..addListener(_normalizeMinimum);
    _maximumFocus = FocusNode()..addListener(_normalizeMaximum);
  }

  @override
  void didUpdateWidget(covariant BudgetRangeSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_minimumFocus.hasFocus) {
      _setControllerValue(_minimumController, widget.range.start);
    }
    if (!_maximumFocus.hasFocus) {
      _setControllerValue(_maximumController, widget.range.end);
    }
  }

  @override
  void dispose() {
    _minimumFocus
      ..removeListener(_normalizeMinimum)
      ..dispose();
    _maximumFocus
      ..removeListener(_normalizeMaximum)
      ..dispose();
    _minimumController.dispose();
    _maximumController.dispose();
    super.dispose();
  }

  void _setControllerValue(TextEditingController controller, double value) {
    final text = value.round().toString();
    if (controller.text != text) {
      controller.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }
  }

  void _normalizeMinimum() {
    if (!_minimumFocus.hasFocus) {
      _setControllerValue(_minimumController, widget.range.start);
    }
  }

  void _normalizeMaximum() {
    if (!_maximumFocus.hasFocus) {
      _setControllerValue(_maximumController, widget.range.end);
    }
  }

  void _onAmountChanged(String text, {required bool isMinimum}) {
    final amount = int.tryParse(text);
    if (amount == null) return;

    final value = amount.clamp(0, 10000).toDouble();
    final updatedRange = isMinimum
        ? RangeValues(
            value,
            widget.range.end < value ? value : widget.range.end,
          )
        : RangeValues(
            widget.range.start > value ? value : widget.range.start,
            value,
          );
    widget.onChanged(updatedRange);
  }

  Widget _amountField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String key,
    required ValueChanged<String> onChanged,
  }) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: TextField(
          key: ValueKey(key),
          controller: controller,
          focusNode: focusNode,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(5),
          ],
          textInputAction: TextInputAction.done,
          onChanged: onChanged,
          onSubmitted: (_) => focusNode.unfocus(),
          decoration: const InputDecoration(
            prefixText: 'RM ',
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          ),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Budget',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppTheme.primaryGreen,
            inactiveTrackColor: Colors.grey.shade200,
            thumbColor: Colors.white,
            overlayColor: AppTheme.primaryGreen.withValues(alpha: 0.2),
            trackHeight: 4,
            rangeThumbShape: const RoundRangeSliderThumbShape(
              enabledThumbRadius: 12,
              elevation: 2,
            ),
          ),
          child: RangeSlider(
            values: widget.range,
            min: 0,
            max: 10000,
            onChanged: widget.onChanged,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _amountField(
              controller: _minimumController,
              focusNode: _minimumFocus,
              key: 'budget-min-input',
              onChanged: (text) => _onAmountChanged(text, isMinimum: true),
            ),
            const SizedBox(width: 16),
            _amountField(
              controller: _maximumController,
              focusNode: _maximumFocus,
              key: 'budget-max-input',
              onChanged: (text) => _onAmountChanged(text, isMinimum: false),
            ),
          ],
        ),
      ],
    );
  }
}
