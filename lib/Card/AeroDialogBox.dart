import 'dart:ui';
import 'package:flutter/material.dart';

// Enums
enum DialogType { standard, bottomSheet, fullScreen }
enum DialogAnimation { scale, fade, slideUp, slideDown, slideLeft, slideRight }
enum AeroButtonStyle { filled, outlined, ghost }

// AeroDialog Widget
class AeroDialog extends StatefulWidget {
  // Core
  final String? title;
  final Widget? content;
  final IconData? icon;
  final DialogType dialogType;

  // Buttons / Actions - Now accepts any Widget
  final List<Widget>? actions;

  // Layout & Styling
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final double elevation;
  final Color? shadowColor;

  // Animation
  final DialogAnimation animationType;
  final Duration animationDuration;
  final Curve curve;

  // Glass / Blur
  final bool glassEffect;
  final double blurSigma;
  final Color? blurBackgroundColor;

  // Behavior
  final bool dismissible;
  final Color? barrierColor;
  final bool barrierDismissible;
  final bool autoDismiss;
  final Duration? autoDismissDuration;

  // Custom Builder
  final Widget Function(BuildContext)? customBuilder;

  // Actions Layout
  final MainAxisAlignment actionsAlignment;
  final double actionsSpacing;

  const AeroDialog({
    Key? key,
    this.title,
    this.content,
    this.icon,
    this.dialogType = DialogType.standard,
    this.actions,
    this.width = 400,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.backgroundColor,
    this.elevation = 12,
    this.shadowColor,
    this.animationType = DialogAnimation.scale,
    this.animationDuration = const Duration(milliseconds: 300),
    this.curve = Curves.easeOutBack,
    this.glassEffect = false,
    this.blurSigma = 10,
    this.blurBackgroundColor,
    this.dismissible = true,
    this.barrierColor,
    this.barrierDismissible = true,
    this.autoDismiss = false,
    this.autoDismissDuration,
    this.customBuilder,
    this.actionsAlignment = MainAxisAlignment.end,
    this.actionsSpacing = 12,
  }) : super(key: key);

  @override
  State<AeroDialog> createState() => _AeroDialogState();

  // Helper method to show dialog
  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    Widget? content,
    IconData? icon,
    DialogType dialogType = DialogType.standard,
    List<Widget>? actions,
    double? width = 400,
    double? height,
    EdgeInsets? padding,
    EdgeInsets? margin,
    BorderRadius? borderRadius,
    Color? backgroundColor,
    double elevation = 12,
    Color? shadowColor,
    DialogAnimation animationType = DialogAnimation.scale,
    Duration animationDuration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeOutBack,
    bool glassEffect = false,
    double blurSigma = 10,
    Color? blurBackgroundColor,
    bool dismissible = true,
    Color? barrierColor,
    bool barrierDismissible = true,
    bool autoDismiss = false,
    Duration? autoDismissDuration,
    Widget Function(BuildContext)? customBuilder,
    MainAxisAlignment actionsAlignment = MainAxisAlignment.end,
    double actionsSpacing = 12,
  }) {
    final dialog = AeroDialog(
      title: title,
      content: content,
      icon: icon,
      dialogType: dialogType,
      actions: actions,
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      borderRadius: borderRadius,
      backgroundColor: backgroundColor,
      elevation: elevation,
      shadowColor: shadowColor,
      animationType: animationType,
      animationDuration: animationDuration,
      curve: curve,
      glassEffect: glassEffect,
      blurSigma: blurSigma,
      blurBackgroundColor: blurBackgroundColor,
      dismissible: dismissible,
      barrierColor: barrierColor,
      barrierDismissible: barrierDismissible,
      autoDismiss: autoDismiss,
      autoDismissDuration: autoDismissDuration,
      customBuilder: customBuilder,
      actionsAlignment: actionsAlignment,
      actionsSpacing: actionsSpacing,
    );

    if (dialogType == DialogType.bottomSheet) {
      return showModalBottomSheet<T>(
        context: context,
        backgroundColor: Colors.transparent,
        isDismissible: barrierDismissible,
        isScrollControlled: true,
        builder: (context) => dialog,
      );
    } else if (dialogType == DialogType.fullScreen) {
      return Navigator.of(context).push<T>(
        MaterialPageRoute(
          builder: (context) => dialog,
          fullscreenDialog: true,
        ),
      );
    } else {
      return showDialog<T>(
        context: context,
        barrierDismissible: barrierDismissible,
        barrierColor: barrierColor ?? Colors.black54,
        builder: (context) => dialog,
      );
    }
  }

  // Helper method to build AeroDialogButton widget
}
class _AeroDialogState extends State<AeroDialog> with SingleTickerProviderStateMixin {
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

    _animationController.forward();

    // Auto dismiss
    if (widget.autoDismiss && widget.autoDismissDuration != null) {
      Future.delayed(widget.autoDismissDuration!, () {
        if (mounted && Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color get _effectiveBackgroundColor {
    return widget.backgroundColor ?? Theme.of(context).dialogBackgroundColor;
  }

  BorderRadius get _effectiveBorderRadius {
    return widget.borderRadius ?? BorderRadius.circular(16);
  }

  EdgeInsets get _effectivePadding {
    return widget.padding ?? const EdgeInsets.all(20);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.dialogType == DialogType.fullScreen) {
      return _buildFullScreenDialog();
    } else if (widget.dialogType == DialogType.bottomSheet) {
      return _buildBottomSheet();
    } else {
      return _buildStandardDialog();
    }
  }

  Widget _buildStandardDialog() {
    Widget dialog = Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: widget.margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: _buildDialogContent(),
    );

    return _buildAnimatedDialog(dialog);
  }

  Widget _buildBottomSheet() {
    Widget sheet = Container(
      margin: widget.margin,
      child: _buildDialogContent(),
    );

    return _buildAnimatedDialog(sheet);
  }

  Widget _buildFullScreenDialog() {
    return Scaffold(
      backgroundColor: _effectiveBackgroundColor,
      appBar: widget.title != null
          ? AppBar(
              title: Text(widget.title!),
              backgroundColor: _effectiveBackgroundColor,
              elevation: 0,
            )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            if (widget.icon != null && widget.title == null) ...[
              Padding(
                padding: const EdgeInsets.all(20),
                child: Icon(
                  widget.icon,
                  size: 48,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
            Expanded(
              child: SingleChildScrollView(
                padding: _effectivePadding,
                child: widget.customBuilder != null
                    ? widget.customBuilder!(context)
                    : widget.content ?? const SizedBox.shrink(),
              ),
            ),
            if (widget.actions != null && widget.actions!.isNotEmpty)
              _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedDialog(Widget child) {
    switch (widget.animationType) {
      case DialogAnimation.scale:
        return ScaleTransition(
          scale: _animation,
          child: child,
        );
      case DialogAnimation.fade:
        return FadeTransition(
          opacity: _animation,
          child: child,
        );
      case DialogAnimation.slideUp:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(_animation),
          child: child,
        );
      case DialogAnimation.slideDown:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1),
            end: Offset.zero,
          ).animate(_animation),
          child: child,
        );
      case DialogAnimation.slideLeft:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(_animation),
          child: child,
        );
      case DialogAnimation.slideRight:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1, 0),
            end: Offset.zero,
          ).animate(_animation),
          child: child,
        );
    }
  }

  Widget _buildDialogContent() {
    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.icon != null) ...[
          Center(
            child: Icon(
              widget.icon,
              size: 56,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 20),
        ],
        if (widget.title != null) ...[
          Text(
            widget.title!,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
        ],
        if (widget.customBuilder != null)
          widget.customBuilder!(context)
        else if (widget.content != null)
          DefaultTextStyle(
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
              fontSize: 15,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
            child: widget.content!,
          ),
        if (widget.actions != null && widget.actions!.isNotEmpty) ...[
          const SizedBox(height: 28),
          _buildActions(),
        ],
      ],
    );

    // Apply glass effect if enabled
    if (widget.glassEffect) {
      content = ClipRRect(
        borderRadius: _effectiveBorderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: widget.blurSigma,
            sigmaY: widget.blurSigma,
          ),
          child: Container(
            padding: _effectivePadding,
            decoration: BoxDecoration(
              color: widget.blurBackgroundColor ??
                  _effectiveBackgroundColor.withOpacity(0.7),
              borderRadius: _effectiveBorderRadius,
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: content,
          ),
        ),
      );
    } else {
      content = Container(
        padding: _effectivePadding,
        decoration: BoxDecoration(
          color: _effectiveBackgroundColor,
          borderRadius: _effectiveBorderRadius,
          boxShadow: [
            BoxShadow(
              color: widget.shadowColor ?? Colors.black26,
              blurRadius: widget.elevation,
              offset: Offset(0, widget.elevation / 2),
            ),
          ],
        ),
        child: content,
      );
    }

    // Apply size constraints
    if (widget.width != null || widget.height != null) {
      content = SizedBox(
        width: widget.width,
        height: widget.height,
        child: widget.height != null
            ? SingleChildScrollView(child: content)
            : content,
      );
    }

    return content;
  }

  Widget _buildActions() {
    if (widget.actions == null || widget.actions!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: widget.dialogType == DialogType.fullScreen
          ? const EdgeInsets.all(16)
          : EdgeInsets.zero,
      decoration: widget.dialogType == DialogType.fullScreen
          ? BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.grey.withOpacity(0.2),
                  width: 1,
                ),
              ),
            )
          : null,
      child: Row(
        mainAxisAlignment: widget.actionsAlignment,
        children: [
          for (int i = 0; i < widget.actions!.length; i++) ...[
            // Wrap each action to support both Expanded and non-Expanded widgets
            if (widget.actionsAlignment == MainAxisAlignment.end ||
                widget.actionsAlignment == MainAxisAlignment.start)
              widget.actions![i]
            else
              Expanded(child: widget.actions![i]),
            if (i < widget.actions!.length - 1)
              SizedBox(width: widget.actionsSpacing),
          ],
        ],
      ),
    );
  }
}