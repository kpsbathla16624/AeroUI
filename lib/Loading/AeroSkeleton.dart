import 'dart:math' as math;
import 'package:flutter/material.dart';

enum SkeletonType { box, circle, text, avatar, list, grid, image, card, custom }

enum ShimmerDirection { ltr, rtl, ttb, btt , custom}

class AeroSkeleton extends StatefulWidget {
  // Type & Layout
  final SkeletonType type;
  final int count;
  final Axis direction;
  final double spacing;

  // Dimensions
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final double? aspectRatio;

  // Colors
  final Color? baseColor;
  final Color? highlightColor;
  final double shimmerAngle;
  final Duration shimmerSpeed;

  // Animation
  final bool shimmer;
  final bool reverse;
  final bool loop;

  // Layout Variants
  final int listCount;
  final int gridCrossAxisCount;
  final double gridSpacing;

  // Text Placeholder Options
  final int lines;
  final double lineHeight;
  final double lineSpacing;
  final bool randomLineWidth;

  // Custom Child
  final Widget? child;
  final bool isLoading;
  final ShimmerDirection shimmerDirection;

  // Effects / Decoration
  final Gradient? gradient;
  final double elevation;
  final EdgeInsets padding;
  final EdgeInsets margin;

  // Callbacks
  final VoidCallback? onCompleted;

  const AeroSkeleton({
    Key? key,
    this.type = SkeletonType.box,
    this.count = 1,
    this.direction = Axis.vertical,
    this.spacing = 12.0,
    this.width,
    this.height,
    this.borderRadius,
    this.aspectRatio,
    this.baseColor,
    this.highlightColor,
    this.shimmerAngle = 0.3,
    this.shimmerSpeed = const Duration(milliseconds: 800),
    this.shimmer = true,
    this.reverse = false,
    this.loop = true,
    this.listCount = 5,
    this.gridCrossAxisCount = 2,
    this.gridSpacing = 12.0,
    this.lines = 3,
    this.lineHeight = 14,
    this.lineSpacing = 6,
    this.randomLineWidth = true,
    this.child,
    this.isLoading = true,
    this.shimmerDirection = ShimmerDirection.ltr,
    this.gradient,
    this.elevation = 0,
    this.padding = EdgeInsets.zero,
    this.margin = EdgeInsets.zero,
    this.onCompleted,
  }) : super(key: key);

  @override
  State<AeroSkeleton> createState() => _AeroSkeletonState();
}

class _AeroSkeletonState extends State<AeroSkeleton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _hasCalledOnCompleted = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.shimmerSpeed,
    );

    if (widget.isLoading && widget.shimmer) {
      if (widget.loop) {
        _controller.repeat();
      } else {
        _controller.forward();
      }
    }
  }

  @override
  void didUpdateWidget(AeroSkeleton oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isLoading != oldWidget.isLoading) {
      if (widget.isLoading) {
        _hasCalledOnCompleted = false;
        if (widget.shimmer) {
          if (widget.loop) {
            _controller.repeat();
          } else {
            _controller.forward();
          }
        }
      } else {
        _controller.stop();
        if (!_hasCalledOnCompleted && widget.onCompleted != null) {
          _hasCalledOnCompleted = true;
          widget.onCompleted!();
        }
      }
    }

    if (widget.shimmerSpeed != oldWidget.shimmerSpeed) {
      _controller.duration = widget.shimmerSpeed;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
Color get _baseColor => widget.baseColor ?? 
    (Theme.of(context).brightness == Brightness.dark 
        ? Colors.grey.shade800 
        : Colors.grey.shade300);

Color get _highlightColor => widget.highlightColor ?? 
    (Theme.of(context).brightness == Brightness.dark 
        ? Colors.grey.shade700 
        : Colors.grey.shade100);

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading && widget.child != null) {
      return widget.child!;
    }

    if (!widget.isLoading) {
      return const SizedBox.shrink();
    }

    Widget skeleton = _buildSkeleton();

    return Container(
      margin: widget.margin,
      padding: widget.padding,
      child: skeleton,
    );
  }

  Widget _buildSkeleton() {
    switch (widget.type) {
      case SkeletonType.box:
        return _buildBox();
      case SkeletonType.circle:
        return _buildCircle();
      case SkeletonType.text:
        return _buildText();
      case SkeletonType.avatar:
        return _buildAvatar();
      case SkeletonType.list:
        return _buildList();
      case SkeletonType.grid:
        return _buildGrid();
      case SkeletonType.image:
        return _buildImage();
      case SkeletonType.card:
        return _buildCard();
      case SkeletonType.custom:
        return _buildBox(); // Fallback
    }
  }

  Widget _buildBox() {
    if (widget.count > 1) {
      return widget.direction == Axis.vertical
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(
                widget.count,
                (index) => Padding(
                  padding: EdgeInsets.only(
                    bottom: index < widget.count - 1 ? widget.spacing : 0,
                  ),
                  child: _buildSingleBox(),
                ),
              ),
            )
          : Row(
              children: List.generate(
                widget.count,
                (index) => Padding(
                  padding: EdgeInsets.only(
                    right: index < widget.count - 1 ? widget.spacing : 0,
                  ),
                  child: _buildSingleBox(),
                ),
              ),
            );
    }
    return _buildSingleBox();
  }

  Widget _buildSingleBox() {
    return _buildShimmerContainer(
      width: widget.width ?? 120,
      height: widget.height ?? 20,
      borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
    );
  }

  Widget _buildCircle() {
    final size = widget.width ?? widget.height ?? 60;
    return _buildShimmerContainer(
      width: size,
      height: size,
      borderRadius: BorderRadius.circular(size / 2),
    );
  }

  Widget _buildText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(widget.lines, (index) {
        double lineWidth = widget.width ?? 200;
        if (widget.randomLineWidth) {
          // Last line is typically shorter
          if (index == widget.lines - 1) {
            lineWidth = lineWidth * 0.6;
          } else {
            lineWidth = lineWidth * (0.85 + math.Random(index).nextDouble() * 0.15);
          }
        }

        return Padding(
          padding: EdgeInsets.only(
            bottom: index < widget.lines - 1 ? widget.lineSpacing : 0,
          ),
          child: _buildShimmerContainer(
            width: lineWidth,
            height: widget.lineHeight,
            borderRadius: BorderRadius.circular(widget.lineHeight / 2),
          ),
        );
      }),
    );
  }

  Widget _buildAvatar() {
    final avatarSize = widget.height ?? 60;
    return Row(
      children: [
        _buildShimmerContainer(
          width: avatarSize,
          height: avatarSize,
          borderRadius: BorderRadius.circular(avatarSize / 2),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildShimmerContainer(
                width: double.infinity,
                height: 16,
                borderRadius: BorderRadius.circular(8),
              ),
              const SizedBox(height: 8),
              _buildShimmerContainer(
                width: 120,
                height: 12,
                borderRadius: BorderRadius.circular(6),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildList() {
    return Column(
      children: List.generate(widget.listCount, (index) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: index < widget.listCount - 1 ? widget.spacing : 0,
          ),
          child: _buildAvatar(),
        );
      }),
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.gridCrossAxisCount,
        crossAxisSpacing: widget.gridSpacing,
        mainAxisSpacing: widget.gridSpacing,
        childAspectRatio: widget.aspectRatio ?? 1.0,
      ),
      itemCount: widget.count,
      itemBuilder: (context, index) {
        return _buildShimmerContainer(
          width: double.infinity,
          height: double.infinity,
          borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
        );
      },
    );
  }

  Widget _buildImage() {
    return _buildShimmerContainer(
      width: widget.width ?? double.infinity,
      height: widget.height ?? 200,
      borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
    );
  }

  Widget _buildCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildShimmerContainer(
          width: widget.width ?? double.infinity,
          height: 160,
          borderRadius: BorderRadius.circular(12),
        ),
        const SizedBox(height: 12),
        _buildShimmerContainer(
          width: double.infinity,
          height: 16,
          borderRadius: BorderRadius.circular(8),
        ),
        const SizedBox(height: 8),
        _buildShimmerContainer(
          width: 180,
          height: 14,
          borderRadius: BorderRadius.circular(7),
        ),
        const SizedBox(height: 8),
        _buildShimmerContainer(
          width: 120,
          height: 12,
          borderRadius: BorderRadius.circular(6),
        ),
      ],
    );
  }

  Widget _buildShimmerContainer({
    required double width,
    required double height,
    required BorderRadius borderRadius,
  }) {
    Widget container = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: _baseColor,
        borderRadius: borderRadius,
      ),
    );

    if (widget.elevation > 0) {
      container = Material(
        elevation: widget.elevation,
        borderRadius: borderRadius,
        child: container,
      );
    }

    if (!widget.shimmer) {
      return container;
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return _buildShimmerGradient(bounds).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: container,
        );
      },
    );
  }

  Gradient _buildShimmerGradient(Rect bounds) {
  if (widget.gradient != null) {
    return widget.gradient!;
  }

  final progress = _controller.value;
  final direction = widget.shimmerDirection;

  Alignment begin;
  Alignment end;

  if (direction == ShimmerDirection.custom) {
    // Use shimmerAngle for custom direction
    final angle = widget.shimmerAngle;
    begin = Alignment(
      math.cos(angle) * (-1.0 - 2 * progress),
      math.sin(angle) * (-1.0 - 2 * progress),
    );
    end = Alignment(
      math.cos(angle) * (1.0 - 2 * progress),
      math.sin(angle) * (1.0 - 2 * progress),
    );
  } else {
    // Use preset directions
    switch (direction) {
      case ShimmerDirection.ltr:
        begin = Alignment(-1.0 - 2 * progress, 0);
        end = Alignment(1.0 - 2 * progress, 0);
        break;
      case ShimmerDirection.rtl:
        begin = Alignment(1.0 + 2 * progress, 0);
        end = Alignment(-1.0 + 2 * progress, 0);
        break;
      case ShimmerDirection.ttb:
        begin = Alignment(0, -1.0 - 2 * progress);
        end = Alignment(0, 1.0 - 2 * progress);
        break;
      case ShimmerDirection.btt:
        begin = Alignment(0, 1.0 + 2 * progress);
        end = Alignment(0, -1.0 + 2 * progress);
        break;
      case ShimmerDirection.custom:
        // Already handled above
        begin = Alignment.centerLeft;
        end = Alignment.centerRight;
        break;
    }
  }

  return LinearGradient(
    begin: begin,
    end: end,
    colors: [
      _baseColor,
      _highlightColor,
      _baseColor,
    ],
    stops: const [0.0, 0.5, 1.0],
  );
}
}
