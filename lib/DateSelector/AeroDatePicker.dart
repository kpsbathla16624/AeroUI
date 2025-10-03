import 'package:flutter/material.dart';

enum DatePickerType { calendar, input, monthYear, range, multi }

enum DatePickerVariant { filled, outlined, glass }

class AeroDatePicker extends StatefulWidget {
  // Core
  final DateTime? initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final ValueChanged<DateTime>? onDateChanged;

  // Types
  final DatePickerType type;

  // Range Selection
  final bool range;
  final DateTimeRange? initialRange;
  final ValueChanged<DateTimeRange>? onRangeChanged;

  // Multi-Date Selection
  final bool multi;
  final List<DateTime>? initialDates;
  final ValueChanged<List<DateTime>>? onMultiChanged;

  // Labels
  final String? label;
  final String? placeholder;
  final String? helperText;

  // Styling
  final DatePickerVariant variant;
  final BorderRadius? borderRadius;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? selectedDayColor;
  final Color? selectedDayBackground;
  final Color? todayHighlightColor;
  final Color? weekendColor;
  final TextStyle? headerTextStyle;
  final TextStyle? dayTextStyle;
  final Color? backgroundColor;

  // Behavior
  final bool showWeekNumbers;
  final bool showTodayButton;
  final bool autoCloseOnSelect;
  final bool allowPastDates;
  final bool allowFutureDates;

  // Advanced
  final List<DateTime>? disabledDates;
  final List<DateTime>? markedDates;
  final Widget Function(DateTime date)? markedDateBuilder;
  final Widget Function(BuildContext context, DateTime date, bool isSelected, bool isToday)? customDayBuilder;

  // States
  final bool isLoading;
  final bool disabled;

  // Accessibility
  final String? semanticsLabel;

  const AeroDatePicker({
    Key? key,
    this.initialDate,
    required this.firstDate,
    required this.lastDate,
    this.onDateChanged,
    this.type = DatePickerType.calendar,
    this.range = false,
    this.initialRange,
    this.onRangeChanged,
    this.multi = false,
    this.initialDates,
    this.onMultiChanged,
    this.label,
    this.placeholder,
    this.helperText,
    this.variant = DatePickerVariant.filled,
    this.borderRadius,
    this.activeColor,
    this.inactiveColor,
    this.selectedDayColor,
    this.selectedDayBackground,
    this.todayHighlightColor,
    this.weekendColor,
    this.headerTextStyle,
    this.dayTextStyle,
    this.backgroundColor,
    this.showWeekNumbers = false,
    this.showTodayButton = true,
    this.autoCloseOnSelect = true,
    this.allowPastDates = true,
    this.allowFutureDates = true,
    this.disabledDates,
    this.markedDates,
    this.markedDateBuilder,
    this.customDayBuilder,
    this.isLoading = false,
    this.disabled = false,
    this.semanticsLabel,
  }) : super(key: key);

  @override
  State<AeroDatePicker> createState() => _AeroDatePickerState();
}

class _AeroDatePickerState extends State<AeroDatePicker> {
  late DateTime _currentMonth;
  DateTime? _selectedDate;
  DateTimeRange? _selectedRange;
  List<DateTime> _selectedDates = [];
  final TextEditingController _inputController = TextEditingController();
  bool _isPickerVisible = false;

  @override
  void initState() {
    super.initState();
    _currentMonth = widget.initialDate ?? DateTime.now();
    _selectedDate = widget.initialDate;
    _selectedRange = widget.initialRange;
    _selectedDates = widget.initialDates ?? [];
    
    if (widget.type == DatePickerType.input && _selectedDate != null) {
      _inputController.text = _formatDate(_selectedDate!);
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  bool _isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isDateDisabled(DateTime date) {
    if (!widget.allowPastDates && date.isBefore(DateTime.now())) return true;
    if (!widget.allowFutureDates && date.isAfter(DateTime.now())) return true;
    if (widget.disabledDates != null) {
      return widget.disabledDates!.any((d) => _isSameDay(d, date));
    }
    return false;
  }

  bool _isDateMarked(DateTime date) {
    if (widget.markedDates == null) return false;
    return widget.markedDates!.any((d) => _isSameDay(d, date));
  }

  void _handleDateTap(DateTime date) {
    if (widget.disabled || _isDateDisabled(date)) return;

    setState(() {
      if (widget.range) {
        if (_selectedRange == null || _selectedRange!.end.isBefore(_selectedRange!.start)) {
          _selectedRange = DateTimeRange(start: date, end: date);
        } else {
          if (date.isBefore(_selectedRange!.start)) {
            _selectedRange = DateTimeRange(start: date, end: _selectedRange!.start);
          } else {
            _selectedRange = DateTimeRange(start: _selectedRange!.start, end: date);
          }
          if (widget.onRangeChanged != null) {
            widget.onRangeChanged!(_selectedRange!);
          }
        }
      } else if (widget.multi) {
        if (_selectedDates.any((d) => _isSameDay(d, date))) {
          _selectedDates.removeWhere((d) => _isSameDay(d, date));
        } else {
          _selectedDates.add(date);
        }
        if (widget.onMultiChanged != null) {
          widget.onMultiChanged!(_selectedDates);
        }
      } else {
        _selectedDate = date;
        if (widget.onDateChanged != null) {
          widget.onDateChanged!(date);
        }
        if (widget.type == DatePickerType.input) {
          _inputController.text = _formatDate(date);
          _isPickerVisible = false;
        }
      }
    });
  }

  void _changeMonth(int delta) {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + delta);
    });
  }

  void _jumpToToday() {
    setState(() {
      _currentMonth = DateTime.now();
      _handleDateTap(DateTime.now());
    });
  }

  BoxDecoration _getContainerDecoration() {
    final radius = widget.borderRadius ?? BorderRadius.circular(12);
    final theme = Theme.of(context);
    final bgColor = widget.backgroundColor ?? theme.colorScheme.background;
    
    switch (widget.variant) {
      case DatePickerVariant.filled:
        return BoxDecoration(
          color: bgColor,
          borderRadius: radius,
        );
      case DatePickerVariant.outlined:
        return BoxDecoration(
          color: bgColor,
          border: Border.all(color: widget.inactiveColor ?? Colors.grey.shade300),
          borderRadius: radius,
        );
      case DatePickerVariant.glass:
        return BoxDecoration(
          color: bgColor.withOpacity(0.1),
          borderRadius: radius,
          border: Border.all(color: Colors.white.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        );
    }
  }

  Widget _buildInputMode() {
     final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              widget.label!,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        GestureDetector(
          onTap: widget.disabled ? null : () {
            setState(() => _isPickerVisible = !_isPickerVisible);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: _getContainerDecoration(),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _inputController.text.isEmpty ? (widget.placeholder ?? 'dd/mm/yyyy') : _inputController.text,
                    style: TextStyle(
                      color: _inputController.text.isEmpty ? Colors.grey : theme.primaryColor,
                    ),
                  ),
                ),
                Icon(Icons.calendar_today, size: 20, color: widget.activeColor ?? Colors.blue),
              ],
            ),
          ),
        ),
        if (widget.helperText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 12),
            child: Text(
              widget.helperText!,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ),
        if (_isPickerVisible) ...[
          const SizedBox(height: 8),
          _buildCalendar(),
        ],
      ],
    );
  }

  Widget _buildMonthYearMode() {
     final theme = Theme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: _getContainerDecoration(),
        child: Column(
          children: [
            if (widget.label != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  widget.label!,
                  style: widget.headerTextStyle ?? const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: 12,
              itemBuilder: (context, index) {
                final monthDate = DateTime(_currentMonth.year, index + 1);
                final isSelected = _selectedDate != null && 
                    _selectedDate!.year == _currentMonth.year && 
                    _selectedDate!.month == index + 1;
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDate = DateTime(_currentMonth.year, index + 1, 1);
                      if (widget.onDateChanged != null) {
                        widget.onDateChanged!(_selectedDate!);
                      }
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? (widget.selectedDayBackground ?? Colors.blue) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][index],
                      style: TextStyle(
                        color: isSelected ? (widget.selectedDayColor ?? Colors.white) : theme.primaryColor,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: _getContainerDecoration(),
        child: widget.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 16),
                  _buildWeekdayLabels(),
                  const SizedBox(height: 8),
                  _buildDaysGrid(),
                  if (widget.showTodayButton) ...[
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _jumpToToday,
                      child: const Text('Today'),
                    ),
                  ],
                ],
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => _changeMonth(-1),
        ),
        Text(
          '${_getMonthName(_currentMonth.month)} ${_currentMonth.year}',
          style: widget.headerTextStyle ?? const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () => _changeMonth(1),
        ),
      ],
    );
  }

  String _getMonthName(int month) {
    const months = ['January', 'February', 'March', 'April', 'May', 'June',
                    'July', 'August', 'September', 'October', 'November', 'December'];
    return months[month - 1];
  }

  Widget _buildWeekdayLabels() {
    return Row(
      children: [
        if (widget.showWeekNumbers) 
          const SizedBox(width: 32),
        ...['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'].map((day) => Expanded(
          child: Center(
            child: Text(
              day,
              style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade600),
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildDaysGrid() {
    final daysInMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final firstWeekday = firstDayOfMonth.weekday;
    
    final List<Widget> dayWidgets = [];
    
    // Empty cells before first day
    for (int i = 1; i < firstWeekday; i++) {
      dayWidgets.add(const SizedBox.shrink());
    }
    
    // Days of month
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_currentMonth.year, _currentMonth.month, day);
      dayWidgets.add(_buildDayCell(date));
    }
    
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: widget.showWeekNumbers ? 8 : 7,
      children: dayWidgets,
    );
  }

  Widget _buildDayCell(DateTime date) {
     final theme = Theme.of(context);
    final isToday = _isSameDay(date, DateTime.now());
    final isSelected = widget.multi
        ? _selectedDates.any((d) => _isSameDay(d, date))
        : _isSameDay(date, _selectedDate);
    final isDisabled = _isDateDisabled(date);
    final isMarked = _isDateMarked(date);
    final isWeekend = date.weekday == 6 || date.weekday == 7;
    final isInRange = widget.range && _selectedRange != null &&
        date.isAfter(_selectedRange!.start.subtract(const Duration(days: 1))) &&
        date.isBefore(_selectedRange!.end.add(const Duration(days: 1)));

    if (widget.customDayBuilder != null) {
      return widget.customDayBuilder!(context, date, isSelected, isToday);
    }

    Color? backgroundColor;
    if (isSelected) {
      backgroundColor = widget.selectedDayBackground ?? Colors.blue;
    } else if (isInRange) {
      backgroundColor = (widget.selectedDayBackground ?? Colors.blue).withOpacity(0.2);
    }

    Color textColor = isSelected
        ? (widget.selectedDayColor ?? Colors.white)
        : isWeekend
            ? (widget.weekendColor ?? Colors.orange)
            : theme.primaryColor;

    if (isDisabled) {
      textColor = Colors.grey.shade400;
    }

    return GestureDetector(
      onTap: () => _handleDateTap(date),
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          border: isToday ? Border.all(color: widget.todayHighlightColor ?? Colors.red, width: 2) : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              '${date.day}',
              style: (widget.dayTextStyle ?? const TextStyle(fontSize: 14)).copyWith(color: textColor),
            ),
            if (isMarked)
              Positioned(
                bottom: 4,
                child: widget.markedDateBuilder?.call(date) ?? 
                  Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.semanticsLabel ?? 'Date picker',
      child: Opacity(
        opacity: widget.disabled ? 0.5 : 1.0,
        child: widget.type == DatePickerType.input
            ? _buildInputMode()
            : widget.type == DatePickerType.monthYear
                ? _buildMonthYearMode()
                : _buildCalendar(),
      ),
    );
  }
}

