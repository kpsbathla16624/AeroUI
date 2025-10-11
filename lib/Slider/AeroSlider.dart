
import 'package:aero_ui/Slider/AeroRangeSlector.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Enum for slider variants
enum SliderVariant {
  standard,
  filled,
  glass,
}




/// Custom slider widget with modern features
class AeroSlider extends StatefulWidget {
  // Core properties
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final ValueChanged<double>? onChanged;
  final ValueChanged<double>? onChangeStart;
  final ValueChanged<double>? onChangeEnd;

  // Labels
  final bool showLabels;
  final String Function(double)? labelFormatter;
  final bool showTooltip;
  final String Function(double)? tooltipFormatter;

  // Styling
  final SliderVariant variant;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? thumbColor;
  final double trackHeight;
  final ThumbShape  thumbShape;
  final TickMarkShape tickMarkShape;

  // Advanced
  final bool isVertical;
  final bool enableSteps;
  final double? stepSize;
  final bool showTicks;
  final Widget? thumbIcon;
  final Gradient? gradientTrack;

  // State
  final bool disabled;
  final bool isLoading;

  const AeroSlider({
    Key? key,
    required this.value,
    this.min = 0.0,
    this.max = 100.0,
    this.divisions,
    this.onChanged,
    this.onChangeStart,
    this.onChangeEnd,
    this.showLabels = true,
    this.labelFormatter,
    this.showTooltip = true,
    this.tooltipFormatter,
    this.variant = SliderVariant.standard,
    this.activeColor,
    this.inactiveColor,
    this.thumbColor,
    this.trackHeight = 4.0,
    this.thumbShape = ThumbShape.circle,
    this.tickMarkShape = TickMarkShape.line,
    this.isVertical = false,
    this.enableSteps = false,
    this.stepSize,
    this.showTicks = false,
    this.thumbIcon,
    this.gradientTrack,
    this.disabled = false,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<AeroSlider> createState() => _AeroSliderState();
}

class _AeroSliderState extends State<AeroSlider> with SingleTickerProviderStateMixin {
  late double _currentValue;
  bool _isDragging = false;
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value.clamp(widget.min, widget.max);
    
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.linear),
    );
    
    if (widget.isLoading) {
      _shimmerController.repeat();
    }
  }

  @override
  void didUpdateWidget(AeroSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _currentValue = widget.value.clamp(widget.min, widget.max);
    }
    
    if (widget.isLoading != oldWidget.isLoading) {
      if (widget.isLoading) {
        _shimmerController.repeat();
      } else {
        _shimmerController.stop();
      }
    }
  }

  @override
  void dispose() {
    _removeTooltip();
    _shimmerController.dispose();
    super.dispose();
  }

  void _handleChanged(double value) {
    if (widget.disabled) return;

    double newValue = value;
    
    // Apply step size if enabled
    if (widget.enableSteps && widget.stepSize != null) {
      newValue = (value / widget.stepSize!).round() * widget.stepSize!;
    } else if (widget.divisions != null) {
      final step = (widget.max - widget.min) / widget.divisions!;
      newValue = (value / step).round() * step;
    }
    
    newValue = newValue.clamp(widget.min, widget.max);
    
    setState(() {
      _currentValue = newValue;
    });
    
    widget.onChanged?.call(newValue);
    
    if (_isDragging && widget.showTooltip) {
      _showTooltip();
    }
  }

  void _handleChangeStart(double value) {
    if (widget.disabled) return;
    
    setState(() {
      _isDragging = true;
    });
    
    widget.onChangeStart?.call(value);
    
    if (widget.showTooltip) {
      _showTooltip();
    }
  }

  void _handleChangeEnd(double value) {
    if (widget.disabled) return;
    
    setState(() {
      _isDragging = false;
    });
    
    widget.onChangeEnd?.call(value);
    _removeTooltip();
  }

  void _showTooltip() {
    _removeTooltip();
    
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: widget.isVertical ? position.dx + size.width + 10 : position.dx + (size.width / 2) - 40,
        top: widget.isVertical ? position.dy + (size.height / 2) - 15 : position.dy - 35,
        child: IgnorePointer(
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.tooltipFormatter?.call(_currentValue) ?? 
                    _currentValue.toStringAsFixed(0),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeTooltip() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  String _formatLabel(double value) {
    return widget.labelFormatter?.call(value) ?? value.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveActiveColor = widget.activeColor ?? theme.primaryColor;
    final effectiveInactiveColor = widget.inactiveColor ?? Colors.grey.shade300;
    final effectiveThumbColor = widget.thumbColor ?? Colors.white;

    return CompositedTransformTarget(
      link: _layerLink,
      child: Opacity(
        opacity: widget.disabled ? 0.5 : 1.0,
        child: widget.isVertical
            ? _buildVerticalSlider(
                effectiveActiveColor,
                effectiveInactiveColor,
                effectiveThumbColor,
              )
            : _buildHorizontalSlider(
                effectiveActiveColor,
                effectiveInactiveColor,
                effectiveThumbColor,
              ),
      ),
    );
  }

  Widget _buildHorizontalSlider(
    Color activeColor,
    Color inactiveColor,
    Color thumbColor,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 60,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Track
              _buildTrack(activeColor, inactiveColor, false),
              
              // Ticks
              if (widget.showTicks) _buildTicks(false),
              
              // Slider
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: widget.trackHeight,
                  activeTrackColor: Colors.transparent,
                  inactiveTrackColor: Colors.transparent,
                  thumbShape: _getThumbShape(thumbColor),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
                  tickMarkShape: const RoundSliderTickMarkShape(tickMarkRadius: 0),
                  trackShape: const RectangularSliderTrackShape(),
                ),
                child: Slider(
                  value: _currentValue,
                  min: widget.min,
                  max: widget.max,
                  divisions: widget.divisions,
                  onChanged: widget.disabled ? null : _handleChanged,
                  onChangeStart: _handleChangeStart,
                  onChangeEnd: _handleChangeEnd,
                ),
              ),
            ],
          ),
        ),
        
        // Labels
        if (widget.showLabels) _buildLabels(false),
      ],
    );
  }

  Widget _buildVerticalSlider(
    Color activeColor,
    Color inactiveColor,
    Color thumbColor,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Labels
        if (widget.showLabels) _buildLabels(true),
        
        SizedBox(
          width: 60,
          height: 300,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Track
              _buildTrack(activeColor, inactiveColor, true),
              
              // Ticks
              if (widget.showTicks) _buildTicks(true),
              
              // Slider
              RotatedBox(
                quarterTurns: 3,
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: widget.trackHeight,
                    activeTrackColor: Colors.transparent,
                    inactiveTrackColor: Colors.transparent,
                    thumbShape: _getThumbShape(thumbColor),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
                    tickMarkShape: const RoundSliderTickMarkShape(tickMarkRadius: 0),
                    trackShape: const RectangularSliderTrackShape(),
                  ),
                  child: Slider(
                    value: _currentValue,
                    min: widget.min,
                    max: widget.max,
                    divisions: widget.divisions,
                    onChanged: widget.disabled ? null : _handleChanged,
                    onChangeStart: _handleChangeStart,
                    onChangeEnd: _handleChangeEnd,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTrack(Color activeColor, Color inactiveColor, bool isVertical) {
    final progress = (_currentValue - widget.min) / (widget.max - widget.min);
    
    if (widget.isLoading) {
      return AnimatedBuilder(
        animation: _shimmerAnimation,
        builder: (context, child) {
          return Container(
            height: isVertical ? double.infinity : widget.trackHeight,
            width: isVertical ? widget.trackHeight : double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.trackHeight / 2),
              gradient: LinearGradient(
                begin: isVertical ? Alignment.topCenter : Alignment.centerLeft,
                end: isVertical ? Alignment.bottomCenter : Alignment.centerRight,
                stops: [
                  math.max(0, _shimmerAnimation.value - 0.3),
                  _shimmerAnimation.value,
                  math.min(1, _shimmerAnimation.value + 0.3),
                ],
                colors: [
                  inactiveColor,
                  activeColor.withOpacity(0.5),
                  inactiveColor,
                ],
              ),
            ),
          );
        },
      );
    }
    
    return Container(
      height: isVertical ? double.infinity : widget.trackHeight,
      width: isVertical ? widget.trackHeight : double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.trackHeight / 2),
        color: widget.variant == SliderVariant.glass
            ? Colors.white.withOpacity(0.1)
            : null,
      ),
      child: Stack(
        children: [
          // Inactive track
          Container(
            decoration: BoxDecoration(
              color: inactiveColor,
              borderRadius: BorderRadius.circular(widget.trackHeight / 2),
            ),
          ),
          
          // Active track
          if (isVertical)
            Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                heightFactor: progress,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: widget.gradientTrack,
                    color: widget.gradientTrack == null ? activeColor : null,
                    borderRadius: BorderRadius.circular(widget.trackHeight / 2),
                  ),
                ),
              ),
            )
          else
            Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: widget.gradientTrack,
                    color: widget.gradientTrack == null ? activeColor : null,
                    borderRadius: BorderRadius.circular(widget.trackHeight / 2),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTicks(bool isVertical) {
    final tickCount = widget.divisions ?? 10;
    final ticks = List.generate(tickCount + 1, (index) => index);
    
    return isVertical
        ? Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ticks.map((tick) => _buildTickMark()).toList(),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ticks.map((tick) => _buildTickMark()).toList(),
          );
  }

  Widget _buildTickMark() {
    switch (widget.tickMarkShape) {
      case TickMarkShape.circle:
        return Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: Colors.grey,
            shape: BoxShape.circle,
          ),
        );
      case TickMarkShape.square:
        return Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(1),
          ),
        );
      case TickMarkShape.line:
      default:
        return Container(
          width: widget.isVertical ? 12 : 2,
          height: widget.isVertical ? 2 : 12,
          color: Colors.grey,
        );
    }
  }

  Widget _buildLabels(bool isVertical) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: isVertical
          ? Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatLabel(widget.max),
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  _formatLabel(widget.min),
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatLabel(widget.min),
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  _formatLabel(widget.max),
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
    );
  }

  SliderComponentShape _getThumbShape(Color thumbColor) {
    switch (widget.thumbShape) {
      case ThumbShape.square:
        return _SquareSliderThumbShape(
          thumbColor: thumbColor,
          thumbIcon: widget.thumbIcon,
        );
      case ThumbShape.diamond:
        return _DiamondSliderThumbShape(
          thumbColor: thumbColor,
          thumbIcon: widget.thumbIcon,
        );
      case ThumbShape.custom:
        return _CustomSliderThumbShape(
          thumbColor: thumbColor,
          thumbIcon: widget.thumbIcon,
        );
      case ThumbShape.circle:
      default:
        return _CircleSliderThumbShape(
          thumbColor: thumbColor,
          thumbIcon: widget.thumbIcon,
        );
    }
  }
}

// Custom thumb shapes
class _CircleSliderThumbShape extends SliderComponentShape {
  final Color thumbColor;
  final Widget? thumbIcon;

  _CircleSliderThumbShape({required this.thumbColor, this.thumbIcon});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return const Size(24, 24);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    
    final paint = Paint()
      ..color = thumbColor
      ..style = PaintingStyle.fill;
    
    final shadowPaint = Paint()
      ..color = Colors.black26
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    
    canvas.drawCircle(center + const Offset(0, 2), 12, shadowPaint);
    canvas.drawCircle(center, 12, paint);
    
    final borderPaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    canvas.drawCircle(center, 12, borderPaint);
  }
}

class _SquareSliderThumbShape extends SliderComponentShape {
  final Color thumbColor;
  final Widget? thumbIcon;

  _SquareSliderThumbShape({required this.thumbColor, this.thumbIcon});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return const Size(24, 24);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    
    final paint = Paint()
      ..color = thumbColor
      ..style = PaintingStyle.fill;
    
    final rect = Rect.fromCenter(center: center, width: 24, height: 24);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(4));
    
    canvas.drawRRect(rrect, paint);
    
    final borderPaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    canvas.drawRRect(rrect, borderPaint);
  }
}

class _DiamondSliderThumbShape extends SliderComponentShape {
  final Color thumbColor;
  final Widget? thumbIcon;

  _DiamondSliderThumbShape({required this.thumbColor, this.thumbIcon});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return const Size(24, 24);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    
    final paint = Paint()
      ..color = thumbColor
      ..style = PaintingStyle.fill;
    
    final path = Path()
      ..moveTo(center.dx, center.dy - 12)
      ..lineTo(center.dx + 12, center.dy)
      ..lineTo(center.dx, center.dy + 12)
      ..lineTo(center.dx - 12, center.dy)
      ..close();
    
    canvas.drawPath(path, paint);
    
    final borderPaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    canvas.drawPath(path, borderPaint);
  }
}

class _CustomSliderThumbShape extends SliderComponentShape {
  final Color thumbColor;
  final Widget? thumbIcon;

  _CustomSliderThumbShape({required this.thumbColor, this.thumbIcon});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return const Size(28, 28);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    
    final paint = Paint()
      ..color = thumbColor
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, 14, paint);
    
    final borderPaint = Paint()
      ..color = Colors.grey.shade400
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    
    canvas.drawCircle(center, 14, borderPaint);
  }
}