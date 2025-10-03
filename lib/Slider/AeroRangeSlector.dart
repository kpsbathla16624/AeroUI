import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Enum for thumb shapes
enum ThumbShape {
  circle,
  square,
  diamond,
  custom,
}

/// Enum for tick mark shapes
enum TickMarkShape {
  line,
  circle,
  square,
}

/// Constraint for range distance
class RangeConstraint {
  final double? minDistance;
  final double? maxDistance;

  const RangeConstraint({
    this.minDistance,
    this.maxDistance,
  });
}

/// Custom range selector widget with modern features
class AeroRangeSelector extends StatefulWidget {
  // Core properties
  final RangeValues values;
  final double min;
  final double max;
  final int? divisions;
  final ValueChanged<RangeValues>? onChanged;
  final ValueChanged<RangeValues>? onChangeStart;
  final ValueChanged<RangeValues>? onChangeEnd;

  // Labels
  final bool showLabels;
  final String Function(double)? startLabelFormatter;
  final String Function(double)? endLabelFormatter;
  final bool showTooltip;
  final String Function(double, double)? tooltipFormatter;

  // Styling
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? thumbColor;
  final double trackHeight;
  final ThumbShape startThumbShape;
  final ThumbShape endThumbShape;
  final TickMarkShape tickMarkShape;
  final Gradient? gradientTrack;

  // Advanced
  final bool isVertical;
  final bool enableSteps;
  final double? stepSize;
  final bool showTicks;
  final RangeConstraint? distanceConstraint;

  // State
  final bool disabled;
  final bool isLoading;

  const AeroRangeSelector({
    Key? key,
    required this.values,
    this.min = 0.0,
    this.max = 100.0,
    this.divisions,
    this.onChanged,
    this.onChangeStart,
    this.onChangeEnd,
    this.showLabels = true,
    this.startLabelFormatter,
    this.endLabelFormatter,
    this.showTooltip = true,
    this.tooltipFormatter,
    this.activeColor,
    this.inactiveColor,
    this.thumbColor,
    this.trackHeight = 4.0,
    this.startThumbShape = ThumbShape.circle,
    this.endThumbShape = ThumbShape.circle,
    this.tickMarkShape = TickMarkShape.line,
    this.gradientTrack,
    this.isVertical = false,
    this.enableSteps = false,
    this.stepSize,
    this.showTicks = false,
    this.distanceConstraint,
    this.disabled = false,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<AeroRangeSelector> createState() => _AeroRangeSelectorState();
}

class _AeroRangeSelectorState extends State<AeroRangeSelector> with SingleTickerProviderStateMixin {
  late RangeValues _currentValues;
  bool _isDragging = false;
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _currentValues = _clampValues(widget.values);
    
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
  void didUpdateWidget(AeroRangeSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.values != oldWidget.values) {
      _currentValues = _clampValues(widget.values);
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

  RangeValues _clampValues(RangeValues values) {
    double start = values.start.clamp(widget.min, widget.max);
    double end = values.end.clamp(widget.min, widget.max);
    
    // Ensure start is less than or equal to end
    if (start > end) {
      final temp = start;
      start = end;
      end = temp;
    }
    
    // Apply distance constraints
    if (widget.distanceConstraint != null) {
      final distance = (end - start).abs();
      
      if (widget.distanceConstraint!.minDistance != null && 
          distance < widget.distanceConstraint!.minDistance!) {
        final minDist = widget.distanceConstraint!.minDistance!;
        final mid = (start + end) / 2;
        start = (mid - minDist / 2).clamp(widget.min, widget.max);
        end = (mid + minDist / 2).clamp(widget.min, widget.max);
      }
      
      if (widget.distanceConstraint!.maxDistance != null && 
          distance > widget.distanceConstraint!.maxDistance!) {
        final maxDist = widget.distanceConstraint!.maxDistance!;
        final mid = (start + end) / 2;
        start = (mid - maxDist / 2).clamp(widget.min, widget.max);
        end = (mid + maxDist / 2).clamp(widget.min, widget.max);
      }
    }
    
    return RangeValues(start, end);
  }

  void _handleChanged(RangeValues values) {
    if (widget.disabled) return;

    double start = values.start;
    double end = values.end;
    
    // Apply step size if enabled
    if (widget.enableSteps && widget.stepSize != null) {
      start = (start / widget.stepSize!).round() * widget.stepSize!;
      end = (end / widget.stepSize!).round() * widget.stepSize!;
    } else if (widget.divisions != null) {
      final step = (widget.max - widget.min) / widget.divisions!;
      start = (start / step).round() * step;
      end = (end / step).round() * step;
    }
    
    final newValues = _clampValues(RangeValues(start, end));
    
    setState(() {
      _currentValues = newValues;
    });
    
    widget.onChanged?.call(newValues);
    
    if (_isDragging && widget.showTooltip) {
      _showTooltip();
    }
  }

  void _handleChangeStart(RangeValues values) {
    if (widget.disabled) return;
    
    setState(() {
      _isDragging = true;
    });
    
    widget.onChangeStart?.call(values);
    
    if (widget.showTooltip) {
      _showTooltip();
    }
  }

  void _handleChangeEnd(RangeValues values) {
    if (widget.disabled) return;
    
    setState(() {
      _isDragging = false;
    });
    
    widget.onChangeEnd?.call(values);
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
        left: widget.isVertical ? position.dx + size.width + 10 : position.dx + (size.width / 2) - 60,
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
                widget.tooltipFormatter?.call(_currentValues.start, _currentValues.end) ?? 
                    '${_currentValues.start.toStringAsFixed(0)} – ${_currentValues.end.toStringAsFixed(0)}',
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

  String _formatStartLabel(double value) {
    return widget.startLabelFormatter?.call(value) ?? value.toStringAsFixed(0);
  }

  String _formatEndLabel(double value) {
    return widget.endLabelFormatter?.call(value) ?? value.toStringAsFixed(0);
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
            ? _buildVerticalRangeSlider(
                effectiveActiveColor,
                effectiveInactiveColor,
                effectiveThumbColor,
              )
            : _buildHorizontalRangeSlider(
                effectiveActiveColor,
                effectiveInactiveColor,
                effectiveThumbColor,
              ),
      ),
    );
  }

  Widget _buildHorizontalRangeSlider(
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
              
              // Range Slider
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: widget.trackHeight,
                  activeTrackColor: Colors.transparent,
                  inactiveTrackColor: Colors.transparent,
                  rangeTrackShape: const RectangularRangeSliderTrackShape(),
                  rangeThumbShape: RoundRangeSliderThumbShape(
                    enabledThumbRadius: 12,
                    thumbColor: thumbColor,
                  ),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
                  tickMarkShape: const RoundSliderTickMarkShape(tickMarkRadius: 0),
                ),
                child: RangeSlider(
                  values: _currentValues,
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

  Widget _buildVerticalRangeSlider(
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
              
              // Note: RangeSlider doesn't support vertical orientation natively
              // This is a simplified representation
              Center(
                child: Text(
                  'Vertical range\nnot fully\nsupported',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTrack(Color activeColor, Color inactiveColor, bool isVertical) {
    final startProgress = (_currentValues.start - widget.min) / (widget.max - widget.min);
    final endProgress = (_currentValues.end - widget.min) / (widget.max - widget.min);
    
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
            Positioned(
              top: (1 - endProgress) * 300,
              bottom: (1 - startProgress) * 300,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: widget.gradientTrack,
                  color: widget.gradientTrack == null ? activeColor : null,
                  borderRadius: BorderRadius.circular(widget.trackHeight / 2),
                ),
              ),
            )
          else
            Positioned(
              left: startProgress * MediaQuery.of(context).size.width * 0.8,
              right: (1 - endProgress) * MediaQuery.of(context).size.width * 0.8,
              top: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: widget.gradientTrack,
                  color: widget.gradientTrack == null ? activeColor : null,
                  borderRadius: BorderRadius.circular(widget.trackHeight / 2),
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
                  _formatEndLabel(widget.max),
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  _formatStartLabel(widget.min),
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatStartLabel(_currentValues.start),
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  _formatEndLabel(_currentValues.end),
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
    );
  }
}

// Custom thumb shape for range slider
class RoundRangeSliderThumbShape extends RangeSliderThumbShape {
  final double enabledThumbRadius;
  final Color thumbColor;

  const RoundRangeSliderThumbShape({
    this.enabledThumbRadius = 10.0,
    required this.thumbColor,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(enabledThumbRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    bool isDiscrete = false,
    bool isEnabled = false,
    bool? isOnTop,
    TextDirection? textDirection,
    required SliderThemeData sliderTheme,
    Thumb? thumb,
    bool? isPressed,
  }) {
    final canvas = context.canvas;
    
    final paint = Paint()
      ..color = thumbColor
      ..style = PaintingStyle.fill;
    
    final shadowPaint = Paint()
      ..color = Colors.black26
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    
    canvas.drawCircle(center + const Offset(0, 2), enabledThumbRadius, shadowPaint);
    canvas.drawCircle(center, enabledThumbRadius, paint);
    
    final borderPaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    canvas.drawCircle(center, enabledThumbRadius, borderPaint);
  }
}