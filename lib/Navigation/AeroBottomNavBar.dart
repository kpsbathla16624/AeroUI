import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum AeroNavbarStyle { glass, solid, gradient }
enum AeroLabelMode { none, always, active }
enum AeroBadgeType { count, dot, custom }
enum AeroBadgeShape { circle, roundedRect }

// AeroBadge Model
class AeroBadge {
  final String? count;
  final bool show;
  final Color? color;
  final Color? textColor;
  final Widget? customBadge;
  final AeroBadgeShape shape;
  final AeroBadgeType type;

  const AeroBadge({
    this.count,
    this.show = true,
    this.color,
    this.textColor,
    this.customBadge,
    this.shape = AeroBadgeShape.circle,
    this.type = AeroBadgeType.count,
  });
}

// AeroNavItem Model
class AeroNavItem {
  final IconData icon;
  final String? label;
  final Widget? customIcon;
  final Color? activeColor;
  final Color? inactiveColor;
  final AeroBadge? badge;

  const AeroNavItem({
    required this.icon,
    this.label,
    this.customIcon,
    this.activeColor,
    this.inactiveColor,
    this.badge,
  });
}

// AeroNavbarController
class AeroNavbarController extends ChangeNotifier {
  AeroNavbarController({this.initialIndex = 0}) : _currentIndex = initialIndex;

  final int initialIndex;
  int _currentIndex;
  AeroNavbarStyle _style = AeroNavbarStyle.glass;
  double _magnification = 1.6;
  bool _glowEnabled = true;
  final Map<int, AeroBadge> _badges = {};

  int get currentIndex => _currentIndex;
  AeroNavbarStyle get style => _style;
  double get magnification => _magnification;
  bool get glowEnabled => _glowEnabled;

  AeroBadge? getBadge(int index) => _badges[index];

  // Navigation Control
  void jumpTo(int index) {
    if (index != _currentIndex) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  Future<void> animateTo(int index) async {
    if (index == _currentIndex) return;
    _currentIndex = index;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300));
  }

  void next() {
    jumpTo((_currentIndex + 1));
  }

  void previous() {
    if (_currentIndex > 0) jumpTo(_currentIndex - 1);
  }

  // Style Control
  void setStyle(AeroNavbarStyle style) {
    _style = style;
    notifyListeners();
  }

  void setMagnification(double value) {
    _magnification = value;
    notifyListeners();
  }

  void setGlow(bool enable) {
    _glowEnabled = enable;
    notifyListeners();
  }

  // Badge Control
  void showBadge(int index) {
    if (_badges[index] != null) {
      _badges[index] = AeroBadge(
        count: _badges[index]!.count,
        show: true,
        color: _badges[index]!.color,
        textColor: _badges[index]!.textColor,
        shape: _badges[index]!.shape,
        type: _badges[index]!.type,
      );
      notifyListeners();
    }
  }

  void hideBadge(int index) {
    if (_badges[index] != null) {
      _badges[index] = AeroBadge(
        count: _badges[index]!.count,
        show: false,
        color: _badges[index]!.color,
        textColor: _badges[index]!.textColor,
        shape: _badges[index]!.shape,
        type: _badges[index]!.type,
      );
      notifyListeners();
    }
  }

  void updateBadge(int index, {String? count}) {
    _badges[index] = AeroBadge(
      count: count,
      show: true,
      color: _badges[index]?.color,
      textColor: _badges[index]?.textColor,
    );
    notifyListeners();
  }

  void clearAllBadges() {
    _badges.clear();
    notifyListeners();
  }
}

// AeroNavbar Widget
class AeroNavbar extends StatefulWidget {
  final AeroNavbarController? controller;
  final List<AeroNavItem> items;

  // Style
  final AeroNavbarStyle style;
  final Color? backgroundColor;
  final Gradient? gradient;
  final double blur;
  final double borderRadius;
  final double elevation;
  final bool floating;
  final bool notchForFab;

  // Animation
  final double magnification;
  final double proximityScale;
  final bool bounceOnSelect;
  final bool glowEffect;
  final Color? glowColor;
  final Duration animationDuration;
  final Curve curve;

  // Labels & Interaction
  final AeroLabelMode labelMode;
  final bool draggable;
  final bool hideOnScroll;
  final bool hapticFeedback;

  // Default Colors for All Items
  final Color? defaultActiveColor;
  final Color? defaultInactiveColor;

  // Advanced Glass Settings
  final double glassSaturation;
  final double glassLightness;

  // Callbacks
  final ValueChanged<int>? onItemSelected;

  const AeroNavbar({
    Key? key,
    this.controller,
    required this.items,
    this.style = AeroNavbarStyle.glass,
    this.backgroundColor,
    this.gradient,
    this.blur = 20,
    this.borderRadius = 24,
    this.elevation = 8,
    this.floating = true,
    this.notchForFab = false,
    this.magnification = 1.6,
    this.proximityScale = 0.25,
    this.bounceOnSelect = true,
    this.glowEffect = true,
    this.glowColor,
    this.animationDuration = const Duration(milliseconds: 250),
    this.curve = Curves.easeOutBack,
    this.labelMode = AeroLabelMode.active,
    this.draggable = false,
    this.hideOnScroll = false,
    this.hapticFeedback = true,
    this.defaultActiveColor,
    this.defaultInactiveColor,
    this.glassSaturation = 1.0,
    this.glassLightness = 1.0,
    this.onItemSelected,
  }) : super(key: key);

  @override
  State<AeroNavbar> createState() => _AeroNavbarState();
}

class _AeroNavbarState extends State<AeroNavbar> with SingleTickerProviderStateMixin {
  late AeroNavbarController _controller;
  int? _hoveredIndex;
  Offset? _hoverPosition;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? AeroNavbarController();
    _controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(AeroNavbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_onControllerChanged);
      _controller = widget.controller ?? AeroNavbarController();
      _controller.addListener(_onControllerChanged);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _onItemTap(int index) {
    if (widget.hapticFeedback) {
      HapticFeedback.lightImpact();
    }

    _controller.jumpTo(index);
    widget.onItemSelected?.call(index);
  }

  Color get _effectiveBackgroundColor {
    if (widget.backgroundColor != null) return widget.backgroundColor!;
    final theme = Theme.of(context);
    return theme.brightness == Brightness.dark
        ? Colors.black.withOpacity(0.8)
        : Colors.white.withOpacity(0.8);
  }

  Color _getActiveColor(AeroNavItem item) {
    return item.activeColor ?? widget.defaultActiveColor ?? Colors.white;
  }

  Color _getInactiveColor(AeroNavItem item) {
    return item.inactiveColor ?? widget.defaultInactiveColor ?? Colors.white70;
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: widget.floating ? 16 + bottomPadding : bottomPadding,
      ),
      child: _buildDockContainer(),
    );
  }

  Widget _buildDockContainer() {
    Widget navContent = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.items.length,
        (index) => _buildDockItem(index),
      ),
    );

    Widget container;

    // Use enhanced glass effect for glass style
    if (widget.style == AeroNavbarStyle.glass) {
      container = ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: widget.blur,
            sigmaY: widget.blur,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
            decoration: BoxDecoration(
              color: _effectiveBackgroundColor,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: widget.elevation * 2,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.1),
                  blurRadius: widget.elevation,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: navContent,
          ),
        ),
      );
    } else {
      // For solid and gradient styles
      container = Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        decoration: _buildDecoration(),
        child: navContent,
      );
    }

    return Center(
      child: IntrinsicWidth(
        child: container,
      ),
    );
  }

  BoxDecoration _buildDecoration() {
    switch (widget.style) {
      case AeroNavbarStyle.glass:
        // Fallback if BackdropFilter isn't used
        return BoxDecoration(
          color: _effectiveBackgroundColor,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: widget.elevation * 2,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.1),
              blurRadius: widget.elevation,
              offset: const Offset(0, -2),
            ),
          ],
        );
      case AeroNavbarStyle.solid:
        return BoxDecoration(
          color: _effectiveBackgroundColor.withOpacity(1.0),
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: widget.elevation * 2,
              offset: const Offset(0, 4),
            ),
          ],
        );
      case AeroNavbarStyle.gradient:
        return BoxDecoration(
          gradient: widget.gradient ??
              LinearGradient(
                colors: [Colors.blueAccent, Colors.purpleAccent],
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
              ),
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: widget.elevation * 2,
              offset: const Offset(0, 4),
            ),
          ],
        );
    }
  }

  Widget _buildDockItem(int index) {
    final item = widget.items[index];
    final isActive = _controller.currentIndex == index;
    final badge = _controller.getBadge(index) ?? item.badge;

    return MouseRegion(
      onEnter: (event) {
        setState(() {
          _hoveredIndex = index;
          _hoverPosition = event.position;
        });
      },
      onExit: (event) {
        setState(() {
          _hoveredIndex = null;
          _hoverPosition = null;
        });
      },
      onHover: (event) {
        setState(() {
          _hoverPosition = event.position;
        });
      },
      child: GestureDetector(
        onTap: () => _onItemTap(index),
        child: AnimatedContainer(
          duration: widget.animationDuration,
          curve: widget.curve,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          child: _buildItemContent(index, item, isActive, badge),
        ),
      ),
    );
  }

  Widget _buildItemContent(int index, AeroNavItem item, bool isActive, AeroBadge? badge) {
    final scale = _calculateScale(index);
    final shouldShowLabel = widget.labelMode == AeroLabelMode.always ||
        (widget.labelMode == AeroLabelMode.active && isActive);

    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedScale(
          scale: scale,
          duration: widget.animationDuration,
          curve: widget.curve,
          child: _buildIcon(item, isActive, badge),
        ),
        if (shouldShowLabel && item.label != null) ...[
          const SizedBox(height: 4),
          AnimatedOpacity(
            opacity: isActive ? 1.0 : 0.7,
            duration: widget.animationDuration,
            child: Text(
              item.label!,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                color: isActive ? _getActiveColor(item) : _getInactiveColor(item),
              ),
            ),
          ),
        ],
      ],
    );

    if (widget.glowEffect && isActive && _controller.glowEnabled) {
      content = Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: (widget.glowColor ?? Colors.white).withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: content,
      );
    }

    return content;
  }

  Widget _buildIcon(AeroNavItem item, bool isActive, AeroBadge? badge) {
    Widget icon = item.customIcon ??
        Icon(
          item.icon,
          size: 28,
          color: isActive ? _getActiveColor(item) : _getInactiveColor(item),
        );

    if (badge != null && badge.show) {
      icon = Stack(
        clipBehavior: Clip.none,
        children: [
          icon,
          Positioned(
            top: -4,
            right: -4,
            child: _buildBadge(badge),
          ),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      child: icon,
    );
  }

  Widget _buildBadge(AeroBadge badge) {
    if (badge.customBadge != null) {
      return badge.customBadge!;
    }

    if (badge.type == AeroBadgeType.dot) {
      return Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: badge.color ?? Colors.red,
          shape: BoxShape.circle,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: badge.color ?? Colors.red,
        borderRadius: badge.shape == AeroBadgeShape.circle
            ? BorderRadius.circular(12)
            : BorderRadius.circular(4),
      ),
      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
      child: Text(
        badge.count ?? '',
        style: TextStyle(
          color: badge.textColor ?? Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  double _calculateScale(int index) {
    if (_hoveredIndex == null) {
      return _controller.currentIndex == index ? 1.1 : 1.0;
    }

    final distance = (index - _hoveredIndex!).abs();
    if (distance == 0) {
      return widget.magnification;
    }

    final proximityEffect = 1.0 + (widget.proximityScale * (1.0 - (distance / widget.items.length)));
    return math.max(1.0, proximityEffect);
  }
}