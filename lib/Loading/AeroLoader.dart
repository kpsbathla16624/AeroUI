import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:ui' show ImageFilter;

enum LoaderType {
  spinner,
  circular,
  linear,
  dots,
  pulse,
  bar,
  wave,
  ring,
  cube,
  heartbeat,
  shimmer,
  custom
}

enum LabelPosition { top, bottom, left, right, overlay }

class AeroLoader extends StatefulWidget {
  // Core
  final LoaderType type;
  final double size;
  final Color? color;
  final Color? secondaryColor;
  final Duration duration;
  final double strokeWidth;
  final bool reverse;

  // Label / Text
  final String? label;
  final LabelPosition labelPosition;
  final TextStyle? labelStyle;

  // Background / Container
  final bool showBackground;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;
  final bool blurBackground;

  // State Control
  final bool isLoading;
  final Duration? autoHideDuration;
  final VoidCallback? onComplete;

  // Layout & Alignment
  final Alignment alignment;
  final bool fullscreen;
  final Color? overlayColor;

  // Advanced
  final Widget Function(BuildContext context, Color color, double size)? customLoader;

  const AeroLoader({
    Key? key,
    this.type = LoaderType.spinner,
    this.size = 48,
    this.color,
    this.secondaryColor,
    this.duration = const Duration(milliseconds: 1200),
    this.strokeWidth = 4.0,
    this.reverse = false,
    this.label,
    this.labelPosition = LabelPosition.bottom,
    this.labelStyle,
    this.showBackground = false,
    this.backgroundColor,
    this.borderRadius,
    this.padding,
    this.blurBackground = false,
    this.isLoading = true,
    this.autoHideDuration,
    this.onComplete,
    this.alignment = Alignment.center,
    this.fullscreen = false,
    this.overlayColor,
    this.customLoader,
  }) : super(key: key);

  @override
  State<AeroLoader> createState() => _AeroLoaderState();
}

class _AeroLoaderState extends State<AeroLoader> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    if (widget.isLoading) {
      _controller.repeat();
    }

    if (widget.autoHideDuration != null) {
      Future.delayed(widget.autoHideDuration!, () {
        if (mounted) {
          _controller.stop();
          widget.onComplete?.call();
        }
      });
    }
  }

  @override
  void didUpdateWidget(AeroLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading != oldWidget.isLoading) {
      if (widget.isLoading) {
        _controller.repeat();
      } else {
        _controller.stop();
        widget.onComplete?.call();
      }
    }
    if (widget.duration != oldWidget.duration) {
      _controller.duration = widget.duration;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _primaryColor => widget.color ?? Theme.of(context).colorScheme.primary;
  Color get _secondaryColor => widget.secondaryColor ?? Theme.of(context).colorScheme.secondary;

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) return const SizedBox.shrink();

    Widget loader = _buildLoader();

    if (widget.label != null) {
      loader = _buildWithLabel(loader);
    }

    if (widget.showBackground) {
      loader = _buildWithBackground(loader);
    }

    if (widget.fullscreen) {
      return Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: widget.overlayColor ?? Colors.black.withOpacity(0.3),
            ),
          ),
          Align(
            alignment: widget.alignment,
            child: loader,
          ),
        ],
      );
    }

    return Align(
      alignment: widget.alignment,
      child: loader,
    );
  }

  Widget _buildLoader() {
    if (widget.type == LoaderType.custom && widget.customLoader != null) {
      return widget.customLoader!(context, _primaryColor, widget.size);
    }

    switch (widget.type) {
      case LoaderType.spinner:
        return _buildSpinner();
      case LoaderType.circular:
        return _buildCircular();
      case LoaderType.linear:
        return _buildLinear();
      case LoaderType.dots:
        return _buildDots();
      case LoaderType.pulse:
        return _buildPulse();
      case LoaderType.bar:
        return _buildBar();
      case LoaderType.wave:
        return _buildWave();
      case LoaderType.ring:
        return _buildRing();
      case LoaderType.cube:
        return _buildCube();
      case LoaderType.heartbeat:
        return _buildHeartbeat();
      case LoaderType.shimmer:
        return _buildShimmer();
      case LoaderType.custom:
        return _buildSpinner(); // Fallback
    }
  }

  Widget _buildSpinner() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: (widget.reverse ? -1 : 1) * _controller.value * 2 * math.pi,
          child: CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _SpinnerPainter(
              color: _primaryColor,
              strokeWidth: widget.strokeWidth,
            ),
          ),
        );
      },
    );
  }

  Widget _buildCircular() {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation(_primaryColor),
        backgroundColor: _secondaryColor,
        strokeWidth: widget.strokeWidth,
      ),
    );
  }

  Widget _buildLinear() {
    return SizedBox(
      width: widget.size * 3,
      height: widget.strokeWidth,
      child: LinearProgressIndicator(
        valueColor: AlwaysStoppedAnimation(_primaryColor),
        backgroundColor: _secondaryColor,
      ),
    );
  }

  Widget _buildDots() {
    return SizedBox(
      width: widget.size * 2,
      height: widget.size / 2,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(3, (index) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final delay = index * 0.2;
              final value = (_controller.value - delay).clamp(0.0, 1.0);
              final scale = math.sin(value * math.pi);
              return Transform.scale(
                scale: 0.5 + scale * 0.5,
                child: Container(
                  width: widget.size / 4,
                  height: widget.size / 4,
                  decoration: BoxDecoration(
                    color: _primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }

  Widget _buildPulse() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scale = 0.5 + (_controller.value * 0.5);
        final opacity = 1.0 - _controller.value;
        return Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: opacity,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _primaryColor,
                  width: widget.strokeWidth,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBar() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size * 2, widget.size),
          painter: _BarPainter(
            color: _primaryColor,
            secondaryColor: _secondaryColor,
            progress: _controller.value,
            strokeWidth: widget.strokeWidth,
          ),
        );
      },
    );
  }

  Widget _buildWave() {
    return SizedBox(
      width: widget.size * 1.5,
      height: widget.size,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(5, (index) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final delay = index * 0.1;
              final value = (_controller.value - delay).clamp(0.0, 1.0);
              final height = math.sin(value * 2 * math.pi) * 0.5 + 0.5;
              return Container(
                width: widget.size / 8,
                height: widget.size * height,
                decoration: BoxDecoration(
                  color: _primaryColor,
                  borderRadius: BorderRadius.circular(widget.size / 16),
                ),
              );
            },
          );
        }),
      ),
    );
  }

  Widget _buildRing() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _RingPainter(
            color: _primaryColor,
            secondaryColor: _secondaryColor,
            progress: _controller.value,
            strokeWidth: widget.strokeWidth,
          ),
        );
      },
    );
  }

  Widget _buildCube() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(_controller.value * 2 * math.pi)
            ..rotateX(_controller.value * 2 * math.pi),
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: _primaryColor,
              borderRadius: BorderRadius.circular(widget.size / 8),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeartbeat() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final beat = _controller.value < 0.5
            ? 1.0 + (math.sin(_controller.value * 4 * math.pi) * 0.2)
            : 1.0;
        return Transform.scale(
          scale: beat,
          child: Icon(
            Icons.favorite,
            size: widget.size,
            color: _primaryColor,
          ),
        );
      },
    );
  }

  Widget _buildShimmer() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.size * 3,
          height: widget.size / 3,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.size / 6),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                _secondaryColor,
                _primaryColor,
                _secondaryColor,
              ],
              stops: [
                _controller.value - 0.3,
                _controller.value,
                _controller.value + 0.3,
              ].map((e) => e.clamp(0.0, 1.0)).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWithLabel(Widget loader) {
    final label = Text(
      widget.label!,
      style: widget.labelStyle ?? const TextStyle(fontSize: 14, color: Colors.grey),
    );

    switch (widget.labelPosition) {
      case LabelPosition.top:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [label, const SizedBox(height: 12), loader],
        );
      case LabelPosition.bottom:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [loader, const SizedBox(height: 12), label],
        );
      case LabelPosition.left:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [label, const SizedBox(width: 12), loader],
        );
      case LabelPosition.right:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [loader, const SizedBox(width: 12), label],
        );
      case LabelPosition.overlay:
        return Stack(
          alignment: Alignment.center,
          children: [loader, label],
        );
    }
  }

  Widget _buildWithBackground(Widget loader) {
    Widget container = Container(
      padding: widget.padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Colors.white,
        borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
      ),
      child: loader,
    );

    if (widget.blurBackground) {
      return ClipRRect(
        borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: container,
        ),
      );
    }

    return container;
  }
}

// Custom Painters

class _SpinnerPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _SpinnerPainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawArc(rect, 0, math.pi * 1.5, false, paint);
  }

  @override
  bool shouldRepaint(_SpinnerPainter oldDelegate) => false;
}

class _BarPainter extends CustomPainter {
  final Color color;
  final Color secondaryColor;
  final double progress;
  final double strokeWidth;

  _BarPainter({
    required this.color,
    required this.secondaryColor,
    required this.progress,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..color = secondaryColor
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final y = size.height / 2;
    canvas.drawLine(Offset(0, y), Offset(size.width, y), backgroundPaint);

    final barWidth = size.width * 0.3;
    final start = (size.width - barWidth) * progress;
    canvas.drawLine(Offset(start, y), Offset(start + barWidth, y), progressPaint);
  }

  @override
  bool shouldRepaint(_BarPainter oldDelegate) => oldDelegate.progress != progress;
}

class _RingPainter extends CustomPainter {
  final Color color;
  final Color secondaryColor;
  final double progress;
  final double strokeWidth;

  _RingPainter({
    required this.color,
    required this.secondaryColor,
    required this.progress,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint1 = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final paint2 = Paint()
      ..color = secondaryColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final angle1 = progress * 2 * math.pi;
    final angle2 = (progress + 0.5) * 2 * math.pi;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle1);
    canvas.drawCircle(Offset.zero, radius * 0.7, paint1);
    canvas.restore();

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle2);
    canvas.drawCircle(Offset.zero, radius * 0.5, paint2);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) => oldDelegate.progress != progress;
}
