import 'package:flutter/material.dart';

/// A universal toast notification system with support for multiple
/// positions, themes, animations, and queue management.
class AeroToast {
  static final _ToastManager _manager = _ToastManager();

  /// Show a toast notification with various customization options
  static void show(
    BuildContext context, {
    required String message,
    String? title,
    AeroToastType type = AeroToastType.info,
    Duration duration = const Duration(seconds: 3),
    AeroToastPosition position = AeroToastPosition.bottom,
    AeroToastAnimation animation = AeroToastAnimation.slideUp,
    Curve animationCurve = Curves.easeOut,
    Widget? icon,
    Widget? action,
    VoidCallback? onTap,
    TextStyle? titleStyle,
    TextStyle? messageStyle,
    Color? backgroundColor,
    double borderRadius = 12,
    EdgeInsetsGeometry padding =
        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    double? width,
    bool dismissible = true,
    bool showShadow = true,
    bool autoDismiss = true,
    bool queue = true,
  }) {
    final data = AeroToastData(
      title: title,
      message: message,
      type: type,
      position: position,
      animation: animation,
      duration: duration,
      icon: icon,
      action: action,
      onTap: onTap,
      dismissible: dismissible,
      autoDismiss: autoDismiss,
      queue: queue,
      titleStyle: titleStyle,
      messageStyle: messageStyle,
      backgroundColor: backgroundColor,
      borderRadius: borderRadius,
      width: width,
      padding: padding,
      showShadow: showShadow,
      animationCurve: animationCurve,
    );

    _manager.show(context, data);
  }

  /// Show a custom widget as a toast
  static void custom(
    BuildContext context, {
    required Widget child,
    Duration duration = const Duration(seconds: 3),
    AeroToastPosition position = AeroToastPosition.bottom,
    AeroToastAnimation animation = AeroToastAnimation.fade,
    Curve animationCurve = Curves.easeOut,
    bool dismissible = true,
    bool autoDismiss = true,
    bool queue = true,
  }) {
    final data = AeroToastData(
      message: '',
      customWidget: child,
      type: AeroToastType.custom,
      position: position,
      animation: animation,
      duration: duration,
      dismissible: dismissible,
      autoDismiss: autoDismiss,
      queue: queue,
      animationCurve: animationCurve,
    );

    _manager.show(context, data);
  }

  /// Dismiss all active toasts
  static void dismissAll() {
    _manager.dismissAll();
  }

  /// Dismiss the current toast
  static void dismissCurrent() {
    _manager.dismissCurrent();
  }
}

/// Toast notification data model
class AeroToastData {
  final String? title;
  final String message;
  final AeroToastType type;
  final AeroToastPosition position;
  final AeroToastAnimation animation;
  final Duration duration;
  final Widget? icon;
  final Widget? action;
  final VoidCallback? onTap;
  final bool dismissible;
  final bool autoDismiss;
  final bool queue;
  final TextStyle? titleStyle;
  final TextStyle? messageStyle;
  final Color? backgroundColor;
  final double borderRadius;
  final double? width;
  final EdgeInsetsGeometry padding;
  final bool showShadow;
  final Curve animationCurve;
  final Widget? customWidget;

  AeroToastData({
    this.title,
    required this.message,
    this.type = AeroToastType.info,
    this.position = AeroToastPosition.bottom,
    this.animation = AeroToastAnimation.slideUp,
    this.duration = const Duration(seconds: 3),
    this.icon,
    this.action,
    this.onTap,
    this.dismissible = true,
    this.autoDismiss = true,
    this.queue = true,
    this.titleStyle,
    this.messageStyle,
    this.backgroundColor,
    this.borderRadius = 12,
    this.width,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.showShadow = true,
    this.animationCurve = Curves.easeOut,
    this.customWidget,
  });
}

/// Toast type enumeration
enum AeroToastType {
  success,
  error,
  warning,
  info,
  custom,
}

/// Toast position enumeration
enum AeroToastPosition {
  top,
  topLeft,
  topRight,
  center,
  centerLeft,
  centerRight,
  bottom,
  bottomLeft,
  bottomRight,
}

/// Toast animation type enumeration
enum AeroToastAnimation {
  fade,
  slideUp,
  slideDown,
  scale,
}

/// Internal toast entry
class _ToastEntry {
  final OverlayEntry overlayEntry;
  final AeroToastData data;
  final VoidCallback onDismiss;

  _ToastEntry({
    required this.overlayEntry,
    required this.data,
    required this.onDismiss,
  });
}

/// Toast manager - handles queue and display logic
class _ToastManager {
  final List<_ToastEntry> _queue = [];
  _ToastEntry? _currentToast;

  void show(BuildContext context, AeroToastData data) {
    if (data.queue && _currentToast != null) {
      // Add to queue
      final entry = _ToastEntry(
        overlayEntry: _createOverlayEntry(context, data),
        data: data,
        onDismiss: () {},
      );
      _queue.add(entry);
    } else {
      // Show immediately
      _showToast(context, data);
    }
  }

  void _showToast(BuildContext context, AeroToastData data) {
    final overlayEntry = _createOverlayEntry(context, data);

    _currentToast = _ToastEntry(
      overlayEntry: overlayEntry,
      data: data,
      onDismiss: () {
        _dismissToast();
      },
    );

    Overlay.of(context).insert(overlayEntry);

    // Auto dismiss
    if (data.autoDismiss) {
      Future.delayed(data.duration, () {
        _dismissToast();
        _showNextInQueue(context);
      });
    }
  }

  OverlayEntry _createOverlayEntry(BuildContext context, AeroToastData data) {
    return OverlayEntry(
      builder: (context) => _ToastWidget(
        data: data,
        onDismiss: () {
          _dismissToast();
          _showNextInQueue(context);
        },
      ),
    );
  }

  void _dismissToast() {
    if (_currentToast != null) {
      _currentToast!.overlayEntry.remove();
      _currentToast = null;
    }
  }

  void _showNextInQueue(BuildContext context) {
    if (_queue.isNotEmpty) {
      final next = _queue.removeAt(0);
      _showToast(context, next.data);
    }
  }

  void dismissCurrent() {
    _dismissToast();
  }

  void dismissAll() {
    _dismissToast();
    _queue.clear();
  }
}

/// Toast widget with animations
class _ToastWidget extends StatefulWidget {
  final AeroToastData data;
  final VoidCallback onDismiss;

  const _ToastWidget({
    required this.data,
    required this.onDismiss,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  double _dragOffset = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: widget.data.animationCurve,
    );

    // Setup slide animation based on position
    Offset beginOffset;
    switch (widget.data.position) {
      case AeroToastPosition.top:
      case AeroToastPosition.topLeft:
      case AeroToastPosition.topRight:
        beginOffset = const Offset(0, -1);
        break;
      case AeroToastPosition.bottom:
      case AeroToastPosition.bottomLeft:
      case AeroToastPosition.bottomRight:
        beginOffset = const Offset(0, 1);
        break;
      case AeroToastPosition.center:
      case AeroToastPosition.centerLeft:
      case AeroToastPosition.centerRight:
        beginOffset = const Offset(0, 0);
        break;
    }

    if (widget.data.animation == AeroToastAnimation.slideDown) {
      beginOffset = const Offset(0, -1);
    } else if (widget.data.animation == AeroToastAnimation.slideUp) {
      beginOffset = const Offset(0, 1);
    }

    _slideAnimation = Tween<Offset>(
      begin: beginOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.data.animationCurve,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.data.animationCurve,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() {
    _controller.reverse().then((_) {
      widget.onDismiss();
    });
  }

  Color _getBackgroundColor(BuildContext context) {
    if (widget.data.backgroundColor != null) {
      return widget.data.backgroundColor!;
    }

    final colorScheme = Theme.of(context).colorScheme;
    switch (widget.data.type) {
      case AeroToastType.success:
        return const Color(0xFF10B981); // Green
      case AeroToastType.error:
        return const Color(0xFFEF4444); // Red
      case AeroToastType.warning:
        return const Color(0xFFF59E0B); // Orange
      case AeroToastType.info:
        return colorScheme.secondary;
      case AeroToastType.custom:
        return colorScheme.secondary;
    }
  }

  Widget _getIcon(BuildContext context) {
    if (widget.data.icon != null) {
      return widget.data.icon!;
    }

    final colorScheme = Theme.of(context).colorScheme;
    final iconColor = colorScheme.primary ?? Colors.white;

    IconData iconData;
    switch (widget.data.type) {
      case AeroToastType.success:
        iconData = Icons.check_circle;
        break;
      case AeroToastType.error:
        iconData = Icons.error;
        break;
      case AeroToastType.warning:
        iconData = Icons.warning;
        break;
      case AeroToastType.info:
        iconData = Icons.info;
        break;
      case AeroToastType.custom:
        return const SizedBox.shrink();
    }

    return Icon(iconData, color: iconColor, size: 24);
  }

  Widget _buildToastContent(BuildContext context) {
    if (widget.data.customWidget != null) {
      return widget.data.customWidget!;
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Determine text color based on background
    final bgColor = _getBackgroundColor(context);
    final textColor = colorScheme.primary ?? Colors.white;

    return Container(
      width: widget.data.width,
      padding: widget.data.padding,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(widget.data.borderRadius),
        boxShadow: widget.data.showShadow
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _getIcon(context),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.data.title != null) ...[
                  Text(
                    widget.data.title!,
                    style: widget.data.titleStyle ??
                        theme.textTheme.titleMedium?.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  widget.data.message,
                  style: widget.data.messageStyle ??
                      theme.textTheme.bodyMedium?.copyWith(
                        color: textColor,
                      ),
                ),
              ],
            ),
          ),
          if (widget.data.action != null) ...[
            const SizedBox(width: 12),
            widget.data.action!,
          ],
        ],
      ),
    );
  }

  Alignment _getAlignment() {
    switch (widget.data.position) {
      case AeroToastPosition.top:
        return Alignment.topCenter;
      case AeroToastPosition.topLeft:
        return Alignment.topLeft;
      case AeroToastPosition.topRight:
        return Alignment.topRight;
      case AeroToastPosition.center:
        return Alignment.center;
      case AeroToastPosition.centerLeft:
        return Alignment.centerLeft;
      case AeroToastPosition.centerRight:
        return Alignment.centerRight;
      case AeroToastPosition.bottom:
        return Alignment.bottomCenter;
      case AeroToastPosition.bottomLeft:
        return Alignment.bottomLeft;
      case AeroToastPosition.bottomRight:
        return Alignment.bottomRight;
    }
  }

  EdgeInsets _getPadding() {
    switch (widget.data.position) {
      case AeroToastPosition.top:
      case AeroToastPosition.topLeft:
      case AeroToastPosition.topRight:
        return const EdgeInsets.only(top: 50, left: 16, right: 16);
      case AeroToastPosition.center:
      case AeroToastPosition.centerLeft:
      case AeroToastPosition.centerRight:
        return const EdgeInsets.symmetric(horizontal: 16);
      case AeroToastPosition.bottom:
      case AeroToastPosition.bottomLeft:
      case AeroToastPosition.bottomRight:
        return const EdgeInsets.only(bottom: 50, left: 16, right: 16);
    }
  }

  Widget _applyAnimation(Widget child) {
    switch (widget.data.animation) {
      case AeroToastAnimation.fade:
        return FadeTransition(
          opacity: _fadeAnimation,
          child: child,
        );
      case AeroToastAnimation.slideUp:
      case AeroToastAnimation.slideDown:
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: child,
          ),
        );
      case AeroToastAnimation.scale:
        return ScaleTransition(
          scale: _scaleAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: child,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget toast = _buildToastContent(context);

    // Add tap handler
    if (widget.data.onTap != null) {
      toast = GestureDetector(
        onTap: () {
          widget.data.onTap!();
          _dismiss();
        },
        child: toast,
      );
    }

    // Add dismissible gesture
    if (widget.data.dismissible) {
      toast = GestureDetector(
        onVerticalDragUpdate: (details) {
          setState(() {
            _dragOffset += details.delta.dy;
          });
        },
        onVerticalDragEnd: (details) {
          if (_dragOffset.abs() > 50) {
            _dismiss();
          } else {
            setState(() {
              _dragOffset = 0;
            });
          }
        },
        child: Transform.translate(
          offset: Offset(0, _dragOffset),
          child: toast,
        ),
      );
    }

    // Apply animation
    toast = _applyAnimation(toast);

    return SafeArea(
      child: Align(
        alignment: _getAlignment(),
        child: Padding(
          padding: _getPadding(),
          child: Material(
            color: Colors.transparent,
            child: toast,
          ),
        ),
      ),
    );
  }
}

/// Optional: Controller for advanced usage
class AeroToastController extends ChangeNotifier {
  final _ToastManager _manager = _ToastManager();

  void show(BuildContext context, AeroToastData data) {
    _manager.show(context, data);
    notifyListeners();
  }

  void dismiss() {
    _manager.dismissCurrent();
    notifyListeners();
  }

  void clearQueue() {
    _manager.dismissAll();
    notifyListeners();
  }

  bool get hasActiveToast => _manager._currentToast != null;
}