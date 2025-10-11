import 'dart:ui';
import 'package:flutter/material.dart';

// Enums
enum CardVariant { elevated, outlined, flat, glass, bordered }
enum CardAnimation { fadeIn, slideUp, scale, none }
enum BadgePosition { topLeft, topRight, bottomLeft, bottomRight }

// Badge Model
class AeroCardBadge {
  final String text;
  final BadgePosition position;
  final Color backgroundColor;
  final Color textColor;
  final double? size;
  final Widget? customBadge;

  const AeroCardBadge({
    required this.text,
    this.position = BadgePosition.topRight,
    this.backgroundColor = Colors.red,
    this.textColor = Colors.white,
    this.size,
    this.customBadge,
  });
}

// AeroCard Widget
class AeroCard extends StatefulWidget {
  // Core
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isClickable;

  // Visual Style
  final CardVariant variant;
  final Color? color;
  final BorderRadius? borderRadius;
  final double elevation;
  final Color? shadowColor;
  final Border? border;

  // Hover / Focus / Press Effects
  final double? hoverElevation;
  final Color? hoverColor;
  final double pressScale;
  final Color? pressColor;
  final Color? hoverShadowColor;

  // Padding / Margin
  final EdgeInsets? padding;
  final EdgeInsets? margin;

  // Image / Media
  final Widget? leading;
  final ImageProvider? headerImage;
  final Widget? footer;
  final double? headerImageHeight;

  // Animations
  final CardAnimation animationType;
  final Duration animationDuration;
  final Curve curve;

  // Overlay / Badge
  final AeroCardBadge? badge;

  // Interaction
  final bool enableRipple;

  // Shadow / Glass
  final bool glassEffect;
  final double blurSigma;
  final Color? blurBackgroundColor;

  // Constraints
  final double? width;
  final double? height;

  const AeroCard({
    Key? key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.isClickable = true,
    this.variant = CardVariant.elevated,
    this.color,
    this.borderRadius,
    this.elevation = 2,
    this.shadowColor,
    this.border,
    this.hoverElevation,
    this.hoverColor,
    this.pressScale = 0.98,
    this.pressColor,
    this.hoverShadowColor,
    this.padding,
    this.margin,
    this.leading,
    this.headerImage,
    this.footer,
    this.headerImageHeight = 200,
    this.animationType = CardAnimation.none,
    this.animationDuration = const Duration(milliseconds: 300),
    this.curve = Curves.easeOut,
    this.badge,
    this.enableRipple = true,
    this.glassEffect = false,
    this.blurSigma = 10,
    this.blurBackgroundColor,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  State<AeroCard> createState() => _AeroCardState();
}

class _AeroCardState extends State<AeroCard> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  bool _isPressed = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: widget.curve,
    );

    if (widget.animationType != CardAnimation.none) {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color get _effectiveColor {
    if (widget.color != null) return widget.color!;
    final theme = Theme.of(context);
    return theme.cardColor;
  }

  Color get _currentColor {
    if (_isPressed && widget.pressColor != null) return widget.pressColor!;
    if (_isHovered && widget.hoverColor != null) return widget.hoverColor!;
    return _effectiveColor;
  }

  double get _currentElevation {
    if (_isHovered && widget.hoverElevation != null) {
      return widget.hoverElevation!;
    }
    return widget.elevation;
  }

  Color get _currentShadowColor {
    if (_isHovered && widget.hoverShadowColor != null) {
      return widget.hoverShadowColor!;
    }
    return widget.shadowColor ?? Colors.black.withOpacity(0.2);
  }

  BorderRadius get _effectiveBorderRadius {
    return widget.borderRadius ?? BorderRadius.circular(12);
  }

  @override
  Widget build(BuildContext context) {
    Widget card = _buildCardContent();

    // Apply animation wrapper
    if (widget.animationType != CardAnimation.none) {
      card = _buildAnimatedCard(card);
    }

    // Apply margin
    if (widget.margin != null) {
      card = Padding(padding: widget.margin!, child: card);
    }

    return card;
  }

  Widget _buildAnimatedCard(Widget child) {
    switch (widget.animationType) {
      case CardAnimation.fadeIn:
        return FadeTransition(
          opacity: _animation,
          child: child,
        );
      case CardAnimation.slideUp:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.1),
            end: Offset.zero,
          ).animate(_animation),
          child: FadeTransition(
            opacity: _animation,
            child: child,
          ),
        );
      case CardAnimation.scale:
        return ScaleTransition(
          scale: _animation,
          child: child,
        );
      case CardAnimation.none:
        return child;
    }
  }

  Widget _buildCardContent() {
    Widget content = _buildCard();

    // Add badge overlay
    if (widget.badge != null) {
      content = Stack(
        clipBehavior: Clip.none,
        children: [
          content,
          _buildBadge(),
        ],
      );
    }

    return content;
  }

  Widget _buildCard() {
    Widget cardBody = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.headerImage != null) _buildHeaderImage(),
        _buildMainContent(),
        if (widget.footer != null) _buildFooter(),
      ],
    );

    // Apply glass effect if enabled
    if (widget.glassEffect) {
      cardBody = ClipRRect(
        borderRadius: _effectiveBorderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: widget.blurSigma,
            sigmaY: widget.blurSigma,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: widget.blurBackgroundColor ??
                  _currentColor.withOpacity(0.3),
              borderRadius: _effectiveBorderRadius,
              border: widget.border,
            ),
            child: cardBody,
          ),
        ),
      );
    } else {
      cardBody = Container(
        decoration: _buildDecoration(),
        child: cardBody,
      );
    }

    // Apply size constraints
    if (widget.width != null || widget.height != null) {
      cardBody = SizedBox(
        width: widget.width,
        height: widget.height,
        child: cardBody,
      );
    }

    // Wrap with press scale animation
    cardBody = AnimatedScale(
      scale: _isPressed ? widget.pressScale : 1.0,
      duration: const Duration(milliseconds: 100),
      child: cardBody,
    );

    // Add interaction handlers
    if (widget.isClickable && (widget.onTap != null || widget.onLongPress != null)) {
      if (widget.enableRipple) {
        cardBody = Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            onLongPress: widget.onLongPress,
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapUp: (_) => setState(() => _isPressed = false),
            onTapCancel: () => setState(() => _isPressed = false),
            borderRadius: _effectiveBorderRadius,
            child: cardBody,
          ),
        );
      } else {
        cardBody = GestureDetector(
          onTap: widget.onTap,
          onLongPress: widget.onLongPress,
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          child: cardBody,
        );
      }
    }

    // Add hover effect
    cardBody = MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.isClickable && widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: cardBody,
    );

    return cardBody;
  }

  Widget _buildHeaderImage() {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: _effectiveBorderRadius.topLeft,
        topRight: _effectiveBorderRadius.topRight,
      ),
      child: Image(
        image: widget.headerImage!,
        height: widget.headerImageHeight,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildMainContent() {
    return Padding(
      padding: widget.padding ?? const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.leading != null) ...[
            widget.leading!,
            const SizedBox(width: 12),
          ],
          Expanded(child: widget.child),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: widget.footer!,
    );
  }

  BoxDecoration _buildDecoration() {
    switch (widget.variant) {
      case CardVariant.elevated:
        return BoxDecoration(
          color: _currentColor,
          borderRadius: _effectiveBorderRadius,
          boxShadow: [
            BoxShadow(
              color: _currentShadowColor,
              blurRadius: _currentElevation * 2,
              offset: Offset(0, _currentElevation / 2),
            ),
          ],
        );

      case CardVariant.outlined:
        return BoxDecoration(
          color: _currentColor,
          borderRadius: _effectiveBorderRadius,
          border: widget.border ??
              Border.all(
                color: Colors.grey.withOpacity(0.3),
                width: 1,
              ),
        );

      case CardVariant.flat:
        return BoxDecoration(
          color: _currentColor,
          borderRadius: _effectiveBorderRadius,
        );

      case CardVariant.glass:
        return BoxDecoration(
          color: _currentColor.withOpacity(0.7),
          borderRadius: _effectiveBorderRadius,
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        );

      case CardVariant.bordered:
        return BoxDecoration(
          color: _currentColor,
          borderRadius: _effectiveBorderRadius,
          border: widget.border ??
              Border.all(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
        );
    }
  }

  Widget _buildBadge() {
    final badge = widget.badge!;
    
    double? top, bottom, left, right;
    
    switch (badge.position) {
      case BadgePosition.topLeft:
        top = -8;
        left = -8;
        break;
      case BadgePosition.topRight:
        top = -8;
        right = -8;
        break;
      case BadgePosition.bottomLeft:
        bottom = -8;
        left = -8;
        break;
      case BadgePosition.bottomRight:
        bottom = -8;
        right = -8;
        break;
    }

    Widget badgeWidget = badge.customBadge ??
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: badge.backgroundColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            badge.text,
            style: TextStyle(
              color: badge.textColor,
              fontSize: badge.size ?? 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        );

    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: badgeWidget,
    );
  }
}