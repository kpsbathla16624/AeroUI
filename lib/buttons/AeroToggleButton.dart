import 'package:flutter/material.dart';

/// Toggle button style
enum ToggleButtonStyle {
  switch_,      // iOS-style switch
  checkbox,     // Checkbox alternative
  chip,         // Chip-style toggle
  button,       // Button-style toggle
}

/// Toggle button size
enum ToggleButtonSize {
  sm,
  md,
  lg,
}

/// AeroToggleButton - Advanced toggle button with multiple styles
class AeroToggleButton extends StatefulWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final ToggleButtonStyle style;
  final ToggleButtonSize size;
  final String? label;
  final String? activeLabel;
  final String? inactiveLabel;
  final IconData? icon;
  final IconData? activeIcon;
  final IconData? inactiveIcon;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? thumbColor;
  final Color? trackColor;
  final bool isDisabled;
  final bool showLabels;
  final Duration animationDuration;
  final Widget? customThumb;

  const AeroToggleButton({
    Key? key,
    required this.value,
    required this.onChanged,
    this.style = ToggleButtonStyle.switch_,
    this.size = ToggleButtonSize.md,
    this.label,
    this.activeLabel,
    this.inactiveLabel,
    this.icon,
    this.activeIcon,
    this.inactiveIcon,
    this.activeColor,
    this.inactiveColor,
    this.thumbColor,
    this.trackColor,
    this.isDisabled = false,
    this.showLabels = false,
    this.animationDuration = const Duration(milliseconds: 200),
    this.customThumb,
  }) : super(key: key);

  // Convenience constructors
  factory AeroToggleButton.switch_({
    Key? key,
    required bool value,
    required ValueChanged<bool>? onChanged,
    String? label,
    ToggleButtonSize size = ToggleButtonSize.md,
    Color? activeColor,
    bool isDisabled = false,
  }) {
    return AeroToggleButton(
      key: key,
      value: value,
      onChanged: onChanged,
      style: ToggleButtonStyle.switch_,
      size: size,
      label: label,
      activeColor: activeColor,
      isDisabled: isDisabled,
    );
  }

  factory AeroToggleButton.checkbox({
    Key? key,
    required bool value,
    required ValueChanged<bool>? onChanged,
    String? label,
    ToggleButtonSize size = ToggleButtonSize.md,
    Color? activeColor,
    bool isDisabled = false,
  }) {
    return AeroToggleButton(
      key: key,
      value: value,
      onChanged: onChanged,
      style: ToggleButtonStyle.checkbox,
      size: size,
      label: label,
      activeColor: activeColor,
      isDisabled: isDisabled,
    );
  }

  factory AeroToggleButton.chip({
    Key? key,
    required bool value,
    required ValueChanged<bool>? onChanged,
    String? label,
    IconData? icon,
    ToggleButtonSize size = ToggleButtonSize.md,
    Color? activeColor,
    bool isDisabled = false,
  }) {
    return AeroToggleButton(
      key: key,
      value: value,
      onChanged: onChanged,
      style: ToggleButtonStyle.chip,
      size: size,
      label: label,
      icon: icon,
      activeColor: activeColor,
      isDisabled: isDisabled,
    );
  }

  factory AeroToggleButton.button({
    Key? key,
    required bool value,
    required ValueChanged<bool>? onChanged,
    String? activeLabel,
    String? inactiveLabel,
    IconData? activeIcon,
    IconData? inactiveIcon,
    ToggleButtonSize size = ToggleButtonSize.md,
    Color? activeColor,
    Color? inactiveColor,
    bool isDisabled = false,
  }) {
    return AeroToggleButton(
      key: key,
      value: value,
      onChanged: onChanged,
      style: ToggleButtonStyle.button,
      size: size,
      activeLabel: activeLabel,
      inactiveLabel: inactiveLabel,
      activeIcon: activeIcon,
      inactiveIcon: inactiveIcon,
      activeColor: activeColor,
      inactiveColor: inactiveColor,
      isDisabled: isDisabled,
    );
  }

  @override
  State<AeroToggleButton> createState() => _AeroToggleButtonState();
}

class _AeroToggleButtonState extends State<AeroToggleButton>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
      value: widget.value ? 1.0 : 0.0,
    );
  }

  @override
  void didUpdateWidget(AeroToggleButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      if (widget.value) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (!widget.isDisabled && widget.onChanged != null) {
      widget.onChanged!(!widget.value);
    }
  }

  Color _getActiveColor(BuildContext context) {
    return widget.activeColor ?? Theme.of(context).colorScheme.primary;
  }

  Color _getInactiveColor(BuildContext context) {
    return widget.inactiveColor ?? const Color(0xFF64748B);
  }

  double _getSwitchWidth() {
    switch (widget.size) {
      case ToggleButtonSize.sm:
        return 36;
      case ToggleButtonSize.md:
        return 44;
      case ToggleButtonSize.lg:
        return 52;
    }
  }

  double _getSwitchHeight() {
    switch (widget.size) {
      case ToggleButtonSize.sm:
        return 20;
      case ToggleButtonSize.md:
        return 24;
      case ToggleButtonSize.lg:
        return 28;
    }
  }

  double _getThumbSize() {
    switch (widget.size) {
      case ToggleButtonSize.sm:
        return 16;
      case ToggleButtonSize.md:
        return 20;
      case ToggleButtonSize.lg:
        return 24;
    }
  }

  double _getCheckboxSize() {
    switch (widget.size) {
      case ToggleButtonSize.sm:
        return 18;
      case ToggleButtonSize.md:
        return 20;
      case ToggleButtonSize.lg:
        return 24;
    }
  }

  double _getFontSize() {
    switch (widget.size) {
      case ToggleButtonSize.sm:
        return 13;
      case ToggleButtonSize.md:
        return 14;
      case ToggleButtonSize.lg:
        return 16;
    }
  }

  Widget _buildSwitch() {
    final activeColor = _getActiveColor(context);
    final inactiveColor = _getInactiveColor(context);
    final thumbColor = widget.thumbColor ?? Colors.white;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final color = ColorTween(
          begin: inactiveColor,
          end: activeColor,
        ).evaluate(_animationController);

        return Container(
          width: _getSwitchWidth(),
          height: _getSwitchHeight(),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(_getSwitchHeight() / 2),
            boxShadow: _isHovered && !widget.isDisabled
                ? [
                    BoxShadow(
                      color: color!.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: widget.animationDuration,
                curve: Curves.easeInOut,
                left: widget.value
                    ? _getSwitchWidth() - _getThumbSize() - 2
                    : 2,
                top: (_getSwitchHeight() - _getThumbSize()) / 2,
                child: widget.customThumb ??
                    Container(
                      width: _getThumbSize(),
                      height: _getThumbSize(),
                      decoration: BoxDecoration(
                        color: thumbColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCheckbox() {
    final activeColor = _getActiveColor(context);
    final size = _getCheckboxSize();

    return AnimatedContainer(
      duration: widget.animationDuration,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: widget.value ? activeColor : Colors.transparent,
        border: Border.all(
          color: widget.value ? activeColor : const Color(0xFF64748B),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: widget.value
          ? Icon(
              Icons.check,
              size: size * 0.7,
              color: Colors.white,
            )
          : null,
    );
  }

  Widget _buildChip() {
    final activeColor = _getActiveColor(context);
    final fontSize = _getFontSize();

    return AnimatedContainer(
      duration: widget.animationDuration,
      padding: EdgeInsets.symmetric(
        horizontal: widget.size == ToggleButtonSize.sm ? 12 : 16,
        vertical: widget.size == ToggleButtonSize.sm ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: widget.value
            ? activeColor.withOpacity(0.15)
            : Colors.transparent,
        border: Border.all(
          color: widget.value ? activeColor : const Color(0xFF64748B),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.icon != null) ...[
            Icon(
              widget.icon,
              size: fontSize + 4,
              color: widget.value ? activeColor : const Color(0xFF94A3B8),
            ),
            if (widget.label != null) const SizedBox(width: 6),
          ],
          if (widget.label != null)
            Text(
              widget.label!,
              style: TextStyle(
                color: widget.value ? activeColor : const Color(0xFF94A3B8),
                fontSize: fontSize,
                fontWeight: widget.value ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildButton() {
    final activeColor = _getActiveColor(context);
    final inactiveColor = _getInactiveColor(context);
    final fontSize = _getFontSize();

    final displayLabel = widget.value
        ? (widget.activeLabel ?? widget.label ?? 'ON')
        : (widget.inactiveLabel ?? widget.label ?? 'OFF');

    final displayIcon = widget.value
        ? (widget.activeIcon ?? widget.icon)
        : (widget.inactiveIcon ?? widget.icon);

    return AnimatedContainer(
      duration: widget.animationDuration,
      padding: EdgeInsets.symmetric(
        horizontal: widget.size == ToggleButtonSize.sm ? 12 : 16,
        vertical: widget.size == ToggleButtonSize.sm ? 6 : 10,
      ),
      decoration: BoxDecoration(
        color: widget.value ? activeColor : inactiveColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: _isHovered && !widget.isDisabled
            ? [
                BoxShadow(
                  color: (widget.value ? activeColor : inactiveColor)
                      .withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (displayIcon != null) ...[
            Icon(
              displayIcon,
              size: fontSize + 4,
              color: Colors.white,
            ),
            const SizedBox(width: 6),
          ],
          Text(
            displayLabel,
            style: TextStyle(
              color: Colors.white,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggle() {
    switch (widget.style) {
      case ToggleButtonStyle.switch_:
        return _buildSwitch();
      case ToggleButtonStyle.checkbox:
        return _buildCheckbox();
      case ToggleButtonStyle.chip:
        return _buildChip();
      case ToggleButtonStyle.button:
        return _buildButton();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget toggle = MouseRegion(
      cursor: widget.isDisabled
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
      onEnter: (_) {
        if (!widget.isDisabled) {
          setState(() => _isHovered = true);
        }
      },
      onExit: (_) {
        if (!widget.isDisabled) {
          setState(() => _isHovered = false);
        }
      },
      child: GestureDetector(
        onTap: _handleTap,
        child: Opacity(
          opacity: widget.isDisabled ? 0.5 : 1.0,
          child: _buildToggle(),
        ),
      ),
    );

    // Add label if provided and not a chip/button style
    if (widget.label != null &&
        widget.style != ToggleButtonStyle.chip &&
        widget.style != ToggleButtonStyle.button) {
      toggle = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          toggle,
          const SizedBox(width: 12),
          Text(
            widget.label!,
            style: TextStyle(
              color: widget.isDisabled
                  ? Colors.white.withOpacity(0.5)
                  : Colors.white.withOpacity(0.9),
              fontSize: _getFontSize(),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }

    return toggle;
  }
}

/// Example usage
class ToggleButtonExample extends StatefulWidget {
  @override
  _ToggleButtonExampleState createState() => _ToggleButtonExampleState();
}

class _ToggleButtonExampleState extends State<ToggleButtonExample> {
  bool _switch1 = false;
  bool _switch2 = true;
  bool _switch3 = false;
  bool _checkbox1 = false;
  bool _checkbox2 = true;
  bool _chip1 = false;
  bool _chip2 = false;
  bool _chip3 = false;
  bool _button1 = false;
  bool _button2 = true;
  bool _darkMode = false;
  bool _notifications = true;
  bool _autoSave = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Toggle Button Component',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),

            // Switch Style
            _buildSection('Switch Style', [
              AeroToggleButton.switch_(
                value: _switch1,
                onChanged: (val) => setState(() => _switch1 = val),
                label: 'Enable feature',
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  AeroToggleButton.switch_(
                    value: _switch2,
                    onChanged: (val) => setState(() => _switch2 = val),
                    size: ToggleButtonSize.sm,
                  ),
                  const SizedBox(width: 16),
                  AeroToggleButton.switch_(
                    value: _switch2,
                    onChanged: (val) => setState(() => _switch2 = val),
                    size: ToggleButtonSize.md,
                  ),
                  const SizedBox(width: 16),
                  AeroToggleButton.switch_(
                    value: _switch2,
                    onChanged: (val) => setState(() => _switch2 = val),
                    size: ToggleButtonSize.lg,
                  ),
                ],
              ),
            ]),

            // Checkbox Style
            _buildSection('Checkbox Style', [
              AeroToggleButton.checkbox(
                value: _checkbox1,
                onChanged: (val) => setState(() => _checkbox1 = val),
                label: 'Accept terms and conditions',
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  AeroToggleButton.checkbox(
                    value: _checkbox2,
                    onChanged: (val) => setState(() => _checkbox2 = val),
                    size: ToggleButtonSize.sm,
                    activeColor: const Color(0xFF10B981),
                  ),
                  const SizedBox(width: 16),
                  AeroToggleButton.checkbox(
                    value: _checkbox2,
                    onChanged: (val) => setState(() => _checkbox2 = val),
                    size: ToggleButtonSize.md,
                    activeColor: const Color(0xFF10B981),
                  ),
                  const SizedBox(width: 16),
                  AeroToggleButton.checkbox(
                    value: _checkbox2,
                    onChanged: (val) => setState(() => _checkbox2 = val),
                    size: ToggleButtonSize.lg,
                    activeColor: const Color(0xFF10B981),
                  ),
                ],
              ),
            ]),

            // Chip Style
            _buildSection('Chip Style (Filter Chips)', [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  AeroToggleButton.chip(
                    value: _chip1,
                    onChanged: (val) => setState(() => _chip1 = val),
                    label: 'JavaScript',
                    icon: Icons.code,
                  ),
                  AeroToggleButton.chip(
                    value: _chip2,
                    onChanged: (val) => setState(() => _chip2 = val),
                    label: 'Python',
                    icon: Icons.code,
                    activeColor: const Color(0xFFF59E0B),
                  ),
                  AeroToggleButton.chip(
                    value: _chip3,
                    onChanged: (val) => setState(() => _chip3 = val),
                    label: 'Dart',
                    icon: Icons.flutter_dash,
                    activeColor: const Color(0xFF06B6D4),
                  ),
                ],
              ),
            ]),

            // Button Style
            _buildSection('Button Style', [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  AeroToggleButton.button(
                    value: _button1,
                    onChanged: (val) => setState(() => _button1 = val),
                    activeLabel: 'ON',
                    inactiveLabel: 'OFF',
                  ),
                  AeroToggleButton.button(
                    value: _button2,
                    onChanged: (val) => setState(() => _button2 = val),
                    activeLabel: 'Enabled',
                    inactiveLabel: 'Disabled',
                    activeIcon: Icons.check_circle,
                    inactiveIcon: Icons.cancel,
                    activeColor: const Color(0xFF10B981),
                    inactiveColor: const Color(0xFFEF4444),
                  ),
                ],
              ),
            ]),

            // Settings Example
            _buildSection('Settings Panel Example', [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF334155),
                  ),
                ),
                child: Column(
                  children: [
                    _buildSettingRow(
                      'Dark Mode',
                      'Enable dark theme across the app',
                      Icons.dark_mode,
                      _darkMode,
                      (val) => setState(() => _darkMode = val),
                    ),
                    const Divider(height: 32, color: Color(0xFF334155)),
                    _buildSettingRow(
                      'Notifications',
                      'Receive push notifications',
                      Icons.notifications,
                      _notifications,
                      (val) => setState(() => _notifications = val),
                      activeColor: const Color(0xFF8B5CF6),
                    ),
                    const Divider(height: 32, color: Color(0xFF334155)),
                    _buildSettingRow(
                      'Auto Save',
                      'Automatically save changes',
                      Icons.save,
                      _autoSave,
                      (val) => setState(() => _autoSave = val),
                      activeColor: const Color(0xFF10B981),
                    ),
                  ],
                ),
              ),
            ]),

            // Custom Colors
            _buildSection('Custom Colors', [
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  AeroToggleButton.switch_(
                    value: true,
                    onChanged: (val) {},
                    label: 'Success',
                    activeColor: const Color(0xFF10B981),
                  ),
                  AeroToggleButton.switch_(
                    value: true,
                    onChanged: (val) {},
                    label: 'Warning',
                    activeColor: const Color(0xFFF59E0B),
                  ),
                  AeroToggleButton.switch_(
                    value: true,
                    onChanged: (val) {},
                    label: 'Danger',
                    activeColor: const Color(0xFFEF4444),
                  ),
                  AeroToggleButton.switch_(
                    value: true,
                    onChanged: (val) {},
                    label: 'Purple',
                    activeColor: const Color(0xFF8B5CF6),
                  ),
                ],
              ),
            ]),

            // Disabled State
            _buildSection('Disabled State', [
              Row(
                children: [
                  AeroToggleButton.switch_(
                    value: false,
                    onChanged: null,
                    label: 'Disabled Off',
                    isDisabled: true,
                  ),
                  const SizedBox(width: 24),
                  AeroToggleButton.switch_(
                    value: true,
                    onChanged: null,
                    label: 'Disabled On',
                    isDisabled: true,
                  ),
                ],
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        ...content,
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildSettingRow(
    String title,
    String description,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged, {
    Color? activeColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF334155),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white70, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        AeroToggleButton.switch_(
          value: value,
          onChanged: onChanged,
          activeColor: activeColor,
        ),
      ],
    );
  }
}