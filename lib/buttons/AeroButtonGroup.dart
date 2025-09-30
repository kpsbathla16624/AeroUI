import 'package:flutter/material.dart';

/// Button group orientation
enum ButtonGroupOrientation {
  horizontal,
  vertical,
}

/// Button group item configuration
class ButtonGroupItem {
  final String? text;
  final Widget? child;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isSelected;
  final bool isDisabled;
  final dynamic value; // For tracking selected value

  const ButtonGroupItem({
    this.text,
    this.child,
    this.icon,
    this.onPressed,
    this.isSelected = false,
    this.isDisabled = false,
    this.value,
  });
}

/// AeroButtonGroup - Group buttons together
class AeroButtonGroup extends StatefulWidget {
  final List<ButtonGroupItem> items;
  final ButtonGroupOrientation orientation;
  final Color? backgroundColor;
  final Color? selectedColor;
  final Color? borderColor;
  final Color? textColor;
  final Color? selectedTextColor;
  final double spacing;
  final bool allowMultipleSelection;
  final Function(List<int>)? onSelectionChanged;
  final Function(dynamic)? onValueChanged;
  final EdgeInsets? padding;
  final double? fontSize;
  final BorderRadius? borderRadius;
  final double? borderWidth;

  const AeroButtonGroup({
    Key? key,
    required this.items,
    this.orientation = ButtonGroupOrientation.horizontal,
    this.backgroundColor,
    this.selectedColor,
    this.borderColor,
    this.textColor,
    this.selectedTextColor,
    this.spacing = 0,
    this.allowMultipleSelection = false,
    this.onSelectionChanged,
    this.onValueChanged,
    this.padding,
    this.fontSize,
    this.borderRadius,
    this.borderWidth,
  }) : super(key: key);

  @override
  State<AeroButtonGroup> createState() => _AeroButtonGroupState();
}

class _AeroButtonGroupState extends State<AeroButtonGroup> {
  late List<bool> _selectedStates;

  @override
  void initState() {
    super.initState();
    _selectedStates = widget.items.map((item) => item.isSelected).toList();
  }

  @override
  void didUpdateWidget(AeroButtonGroup oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items.length != widget.items.length) {
      _selectedStates = widget.items.map((item) => item.isSelected).toList();
    }
  }

  void _handleTap(int index) {
    if (widget.items[index].isDisabled) return;

    setState(() {
      if (widget.allowMultipleSelection) {
        _selectedStates[index] = !_selectedStates[index];
      } else {
        _selectedStates = List.generate(
          widget.items.length,
          (i) => i == index,
        );
      }
    });

    widget.items[index].onPressed?.call();

    if (widget.onSelectionChanged != null) {
      final selectedIndices = <int>[];
      for (int i = 0; i < _selectedStates.length; i++) {
        if (_selectedStates[i]) selectedIndices.add(i);
      }
      widget.onSelectionChanged!(selectedIndices);
    }

    if (widget.onValueChanged != null && widget.items[index].value != null) {
      widget.onValueChanged!(widget.items[index].value);
    }
  }

  Color _getBackgroundColor(int index, bool isHovered) {
    final theme = Theme.of(context);
    if (_selectedStates[index]) {
      return widget.selectedColor ?? theme.colorScheme.primary;
    }
    if (isHovered) {
      return (widget.backgroundColor ?? theme.colorScheme.surface)
          .withOpacity(0.8);
    }
    return widget.backgroundColor ?? theme.colorScheme.surface;
  }

  Color _getTextColor(int index) {
    final theme = Theme.of(context);
    if (_selectedStates[index]) {
      return widget.selectedTextColor ?? Colors.white;
    }
    return widget.textColor ?? theme.colorScheme.onSurface;
  }

  BorderRadius _getBorderRadius(int index) {
    if (widget.borderRadius != null) return widget.borderRadius!;
    
    final radius = Radius.circular(8);
    final isFirst = index == 0;
    final isLast = index == widget.items.length - 1;

    if (widget.orientation == ButtonGroupOrientation.horizontal) {
      if (isFirst && isLast) {
        return BorderRadius.circular(8);
      } else if (isFirst) {
        return BorderRadius.only(topLeft: radius, bottomLeft: radius);
      } else if (isLast) {
        return BorderRadius.only(topRight: radius, bottomRight: radius);
      }
      return BorderRadius.zero;
    } else {
      if (isFirst && isLast) {
        return BorderRadius.circular(8);
      } else if (isFirst) {
        return BorderRadius.only(topLeft: radius, topRight: radius);
      } else if (isLast) {
        return BorderRadius.only(bottomLeft: radius, bottomRight: radius);
      }
      return BorderRadius.zero;
    }
  }

  Widget _buildButton(int index) {
    final item = widget.items[index];
    final isSelected = _selectedStates[index];
    
    return _HoverButton(
      onTap: () => _handleTap(index),
      isDisabled: item.isDisabled,
      builder: (isHovered) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: _getBackgroundColor(index, isHovered),
            borderRadius: _getBorderRadius(index),
            border: Border.all(
              color: widget.borderColor ?? Theme.of(context).dividerColor,
              width: widget.borderWidth ?? 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (item.icon != null) ...[
                Icon(
                  item.icon,
                  size: 18,
                  color: _getTextColor(index),
                ),
                if (item.text != null || item.child != null) const SizedBox(width: 8),
              ],
              if (item.child != null)
                DefaultTextStyle(
                  style: TextStyle(
                    color: _getTextColor(index),
                    fontSize: widget.fontSize ?? 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                  child: item.child!,
                )
              else if (item.text != null)
                Text(
                  item.text!,
                  style: TextStyle(
                    color: _getTextColor(index),
                    fontSize: widget.fontSize ?? 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.orientation == ButtonGroupOrientation.horizontal) {
      return IntrinsicHeight(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(widget.items.length, (index) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildButton(index),
                if (index < widget.items.length - 1 && widget.spacing > 0)
                  SizedBox(width: widget.spacing),
              ],
            );
          }),
        ),
      );
    } else {
      return IntrinsicWidth(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: List.generate(widget.items.length, (index) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildButton(index),
                if (index < widget.items.length - 1 && widget.spacing > 0)
                  SizedBox(height: widget.spacing),
              ],
            );
          }),
        ),
      );
    }
  }
}

/// Helper widget for hover detection
class _HoverButton extends StatefulWidget {
  final VoidCallback onTap;
  final bool isDisabled;
  final Widget Function(bool isHovered) builder;

  const _HoverButton({
    required this.onTap,
    required this.isDisabled,
    required this.builder,
  });

  @override
  State<_HoverButton> createState() => _HoverButtonState();
}

class _HoverButtonState extends State<_HoverButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.isDisabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
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
        onTap: widget.isDisabled ? null : widget.onTap,
        child: Opacity(
          opacity: widget.isDisabled ? 0.5 : 1.0,
          child: widget.builder(_isHovered),
        ),
      ),
    );
  }
}

/// Example usage
class ButtonGroupExample extends StatefulWidget {
  @override
  _ButtonGroupExampleState createState() => _ButtonGroupExampleState();
}

class _ButtonGroupExampleState extends State<ButtonGroupExample> {
  String _selectedView = 'grid';
  List<String> _selectedFilters = [];

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
              'Button Group Component',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),

            // Basic Button Group
            _buildSection('Basic Button Group', [
              AeroButtonGroup(
                items: [
                  ButtonGroupItem(text: 'Option 1', onPressed: () {}),
                  ButtonGroupItem(text: 'Option 2', onPressed: () {}),
                  ButtonGroupItem(text: 'Option 3', onPressed: () {}),
                ],
              ),
            ]),

            // View Switcher
            _buildSection('View Switcher', [
              AeroButtonGroup(
                items: [
                  ButtonGroupItem(
                    icon: Icons.grid_view,
                    value: 'grid',
                    isSelected: _selectedView == 'grid',
                    onPressed: () {},
                  ),
                  ButtonGroupItem(
                    icon: Icons.view_list,
                    value: 'list',
                    isSelected: _selectedView == 'list',
                    onPressed: () {},
                  ),
                  ButtonGroupItem(
                    icon: Icons.view_column,
                    value: 'column',
                    isSelected: _selectedView == 'column',
                    onPressed: () {},
                  ),
                ],
                onValueChanged: (value) {
                  setState(() => _selectedView = value);
                },
              ),
            ]),

            // Text Alignment
            _buildSection('Text Alignment', [
              AeroButtonGroup(
                items: [
                  ButtonGroupItem(icon: Icons.format_align_left, onPressed: () {}),
                  ButtonGroupItem(icon: Icons.format_align_center, onPressed: () {}),
                  ButtonGroupItem(icon: Icons.format_align_right, onPressed: () {}),
                  ButtonGroupItem(icon: Icons.format_align_justify, onPressed: () {}),
                ],
                selectedColor: const Color(0xFF6366F1),
              ),
            ]),

            // Vertical Button Group
            _buildSection('Vertical Orientation', [
              AeroButtonGroup(
                orientation: ButtonGroupOrientation.vertical,
                items: [
                  ButtonGroupItem(text: 'Dashboard', icon: Icons.dashboard, onPressed: () {}),
                  ButtonGroupItem(text: 'Analytics', icon: Icons.analytics, onPressed: () {}),
                  ButtonGroupItem(text: 'Settings', icon: Icons.settings, onPressed: () {}),
                ],
              ),
            ]),

            // Multiple Selection
            _buildSection('Multiple Selection (Filters)', [
              AeroButtonGroup(
                allowMultipleSelection: true,
                items: [
                  ButtonGroupItem(text: 'Active', onPressed: () {}),
                  ButtonGroupItem(text: 'Pending', onPressed: () {}),
                  ButtonGroupItem(text: 'Completed', onPressed: () {}),
                  ButtonGroupItem(text: 'Archived', onPressed: () {}),
                ],
                selectedColor: const Color(0xFF10B981),
                onSelectionChanged: (indices) {
                  print('Selected indices: $indices');
                },
              ),
            ]),

            // With Spacing
            _buildSection('With Spacing', [
              AeroButtonGroup(
                spacing: 8,
                items: [
                  ButtonGroupItem(text: 'Day', onPressed: () {}),
                  ButtonGroupItem(text: 'Week', onPressed: () {}),
                  ButtonGroupItem(text: 'Month', onPressed: () {}),
                  ButtonGroupItem(text: 'Year', onPressed: () {}),
                ],
                borderRadius: BorderRadius.circular(8),
              ),
            ]),

            // Custom Colors
            _buildSection('Custom Colors', [
              AeroButtonGroup(
                items: [
                  ButtonGroupItem(text: 'Small', onPressed: () {}),
                  ButtonGroupItem(text: 'Medium', onPressed: () {}, isSelected: true),
                  ButtonGroupItem(text: 'Large', onPressed: () {}),
                ],
                backgroundColor: const Color(0xFF1E293B),
                selectedColor: const Color(0xFFF59E0B),
                borderColor: const Color(0xFF334155),
              ),
            ]),

            // Disabled Items
            _buildSection('With Disabled Items', [
              AeroButtonGroup(
                items: [
                  ButtonGroupItem(text: 'Enabled', onPressed: () {}),
                  ButtonGroupItem(text: 'Disabled', onPressed: () {}, isDisabled: true),
                  ButtonGroupItem(text: 'Enabled', onPressed: () {}),
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
}