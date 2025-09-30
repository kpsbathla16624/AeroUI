import 'package:flutter/material.dart';

/// Button variants
enum AeroButtonVariant {
  solid,      // Filled background
  outline,    // Border only
  ghost,      // Transparent with hover effect
  link,       // Text only, no background
  gradient,   // Gradient background
}

/// Button sizes
enum AeroButtonSize {
  xs,   // Extra small
  sm,   // Small
  md,   // Medium (default)
  lg,   // Large
  xl,   // Extra large
}

/// Button configuration class
class AeroButtonConfig {
  final AeroButtonVariant variant;
  final AeroButtonSize size;
  final Color? color;
  final Color? hoverColor;
  final Color? textColor;
  final Gradient? gradient;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final double? borderWidth;
  final IconData? leftIcon;
  final IconData? rightIcon;
  final bool isLoading;
  final bool isDisabled;
  final bool isBlock; // Full width
  final Widget? loadingWidget;
  final double? elevation;
  final List<BoxShadow>? boxShadow;

  const AeroButtonConfig({
    this.variant = AeroButtonVariant.solid,
    this.size = AeroButtonSize.md,
    this.color,
    this.hoverColor,
    this.textColor,
    this.gradient,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
    this.borderWidth,
    this.leftIcon,
    this.rightIcon,
    this.isLoading = false,
    this.isDisabled = false,
    this.isBlock = false,
    this.loadingWidget,
    this.elevation,
    this.boxShadow,
  });

  AeroButtonConfig copyWith({
    AeroButtonVariant? variant,
    AeroButtonSize? size,
    Color? color,
    Color? hoverColor,
    Color? textColor,
    Gradient? gradient,
    double? width,
    double? height,
    EdgeInsets? padding,
    BorderRadius? borderRadius,
    double? borderWidth,
    IconData? leftIcon,
    IconData? rightIcon,
    bool? isLoading,
    bool? isDisabled,
    bool? isBlock,
    Widget? loadingWidget,
    double? elevation,
    List<BoxShadow>? boxShadow,
  }) {
    return AeroButtonConfig(
      variant: variant ?? this.variant,
      size: size ?? this.size,
      color: color ?? this.color,
      hoverColor: hoverColor ?? this.hoverColor,
      textColor: textColor ?? this.textColor,
      gradient: gradient ?? this.gradient,
      width: width ?? this.width,
      height: height ?? this.height,
      padding: padding ?? this.padding,
      borderRadius: borderRadius ?? this.borderRadius,
      borderWidth: borderWidth ?? this.borderWidth,
      leftIcon: leftIcon ?? this.leftIcon,
      rightIcon: rightIcon ?? this.rightIcon,
      isLoading: isLoading ?? this.isLoading,
      isDisabled: isDisabled ?? this.isDisabled,
      isBlock: isBlock ?? this.isBlock,
      loadingWidget: loadingWidget ?? this.loadingWidget,
      elevation: elevation ?? this.elevation,
      boxShadow: boxShadow ?? this.boxShadow,
    );
  }
}

/// Main AeroButton Widget
class AeroButton extends StatefulWidget {
  final String? text;
  final Widget? child;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final AeroButtonConfig config;

  const AeroButton({
    Key? key,
    this.text,
    this.child,
    required this.onPressed,
    this.onLongPress,
    this.config = const AeroButtonConfig(),
  }) : super(key: key);

  // Convenience constructors for common variants
  factory AeroButton.solid({
    Key? key,
    String? text,
    Widget? child,
    required VoidCallback? onPressed,
    VoidCallback? onLongPress,
    Color? color,
    AeroButtonSize size = AeroButtonSize.md,
    IconData? leftIcon,
    IconData? rightIcon,
    bool isLoading = false,
    bool isDisabled = false,
    bool isBlock = false,
  }) {
    return AeroButton(
      key: key,
      text: text,
      child: child,
      onPressed: onPressed,
      onLongPress: onLongPress,
      config: AeroButtonConfig(
        variant: AeroButtonVariant.solid,
        size: size,
        color: color,
        leftIcon: leftIcon,
        rightIcon: rightIcon,
        isLoading: isLoading,
        isDisabled: isDisabled,
        isBlock: isBlock,
      ),
    );
  }

  factory AeroButton.outline({
    Key? key,
    String? text,
    Widget? child,
    required VoidCallback? onPressed,
    VoidCallback? onLongPress,
    Color? color,
    AeroButtonSize size = AeroButtonSize.md,
    IconData? leftIcon,
    IconData? rightIcon,
    bool isLoading = false,
    bool isDisabled = false,
    bool isBlock = false,
  }) {
    return AeroButton(
      key: key,
      text: text,
      child: child,
      onPressed: onPressed,
      onLongPress: onLongPress,
      config: AeroButtonConfig(
        variant: AeroButtonVariant.outline,
        size: size,
        color: color,
        leftIcon: leftIcon,
        rightIcon: rightIcon,
        isLoading: isLoading,
        isDisabled: isDisabled,
        isBlock: isBlock,
      ),
    );
  }

  factory AeroButton.ghost({
    Key? key,
    String? text,
    Widget? child,
    required VoidCallback? onPressed,
    VoidCallback? onLongPress,
    Color? color,
    AeroButtonSize size = AeroButtonSize.md,
    IconData? leftIcon,
    IconData? rightIcon,
    bool isLoading = false,
    bool isDisabled = false,
    bool isBlock = false,
  }) {
    return AeroButton(
      key: key,
      text: text,
      child: child,
      onPressed: onPressed,
      onLongPress: onLongPress,
      config: AeroButtonConfig(
        variant: AeroButtonVariant.ghost,
        size: size,
        color: color,
        leftIcon: leftIcon,
        rightIcon: rightIcon,
        isLoading: isLoading,
        isDisabled: isDisabled,
        isBlock: isBlock,
      ),
    );
  }

  factory AeroButton.link({
    Key? key,
    String? text,
    Widget? child,
    required VoidCallback? onPressed,
    VoidCallback? onLongPress,
    Color? color,
    AeroButtonSize size = AeroButtonSize.md,
    IconData? leftIcon,
    IconData? rightIcon,
    bool isLoading = false,
    bool isDisabled = false,
  }) {
    return AeroButton(
      key: key,
      text: text,
      child: child,
      onPressed: onPressed,
      onLongPress: onLongPress,
      config: AeroButtonConfig(
        variant: AeroButtonVariant.link,
        size: size,
        color: color,
        leftIcon: leftIcon,
        rightIcon: rightIcon,
        isLoading: isLoading,
        isDisabled: isDisabled,
      ),
    );
  }

  factory AeroButton.gradient({
    Key? key,
    String? text,
    Widget? child,
    required VoidCallback? onPressed,
    VoidCallback? onLongPress,
    required Gradient gradient,
    AeroButtonSize size = AeroButtonSize.md,
    IconData? leftIcon,
    IconData? rightIcon,
    bool isLoading = false,
    bool isDisabled = false,
    bool isBlock = false,
  }) {
    return AeroButton(
      key: key,
      text: text,
      child: child,
      onPressed: onPressed,
      onLongPress: onLongPress,
      config: AeroButtonConfig(
        variant: AeroButtonVariant.gradient,
        size: size,
        gradient: gradient,
        leftIcon: leftIcon,
        rightIcon: rightIcon,
        isLoading: isLoading,
        isDisabled: isDisabled,
        isBlock: isBlock,
      ),
    );
  }

  // Icon-only button - circular by default
  factory AeroButton.icon({
    Key? key,
    required IconData icon,
    required VoidCallback? onPressed,
    VoidCallback? onLongPress,
    AeroButtonVariant variant = AeroButtonVariant.solid,
    Color? color,
    AeroButtonSize size = AeroButtonSize.md,
    bool isLoading = false,
    bool isDisabled = false,
    bool isCircular = true,
    double? iconSize,
  }) {
    return AeroButton(
      key: key,
      child: Icon(
        icon,
        size: iconSize ?? _getIconSizeForButton(size),
        color: variant == AeroButtonVariant.solid || variant == AeroButtonVariant.gradient
            ? Colors.white
            : color,
      ),
      onPressed: onPressed,
      onLongPress: onLongPress,
      config: AeroButtonConfig(
        variant: variant,
        size: size,
        color: color,
        isLoading: isLoading,
        isDisabled: isDisabled,
        borderRadius: isCircular ? BorderRadius.circular(1000) : null,
        padding: _getSquarePadding(size),
      ),
    );
  }

  static double _getIconSizeForButton(AeroButtonSize size) {
    switch (size) {
      case AeroButtonSize.xs:
        return 14;
      case AeroButtonSize.sm:
        return 16;
      case AeroButtonSize.md:
        return 18;
      case AeroButtonSize.lg:
        return 20;
      case AeroButtonSize.xl:
        return 22;
    }
  }

  static EdgeInsets _getSquarePadding(AeroButtonSize size) {
    switch (size) {
      case AeroButtonSize.xs:
        return const EdgeInsets.all(6);
      case AeroButtonSize.sm:
        return const EdgeInsets.all(8);
      case AeroButtonSize.md:
        return const EdgeInsets.all(10);
      case AeroButtonSize.lg:
        return const EdgeInsets.all(12);
      case AeroButtonSize.xl:
        return const EdgeInsets.all(16);
    }
  }

  @override
  State<AeroButton> createState() => _AeroButtonState();
}

class _AeroButtonState extends State<AeroButton> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  bool _isPressed = false;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  bool get _isInteractive =>
      !widget.config.isDisabled && !widget.config.isLoading && widget.onPressed != null;

  Color _getBackgroundColor(BuildContext context) {
    final theme = Theme.of(context);
    final config = widget.config;
    final baseColor = config.color ?? theme.colorScheme.primary;

    if (config.isDisabled) {
      return baseColor.withOpacity(0.5);
    }

    if (_isPressed) {
      return _darken(baseColor, 0.2);
    }

    if (_isHovered && config.hoverColor != null) {
      return config.hoverColor!;
    }

    if (_isHovered) {
      return _darken(baseColor, 0.1);
    }

    return baseColor;
  }

  Color _getTextColor(BuildContext context) {
    final theme = Theme.of(context);
    final config = widget.config;

    if (config.textColor != null) {
      return config.textColor!;
    }

    switch (config.variant) {
      case AeroButtonVariant.solid:
      case AeroButtonVariant.gradient:
        return Colors.white;
      case AeroButtonVariant.outline:
      case AeroButtonVariant.ghost:
      case AeroButtonVariant.link:
        return config.color ?? theme.colorScheme.primary;
    }
  }

  Color _darken(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }

  EdgeInsets _getPadding() {
    if (widget.config.padding != null) {
      return widget.config.padding!;
    }

    switch (widget.config.size) {
      case AeroButtonSize.xs:
        return const EdgeInsets.symmetric(horizontal: 8, vertical: 4);
      case AeroButtonSize.sm:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
      case AeroButtonSize.md:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 10);
      case AeroButtonSize.lg:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 12);
      case AeroButtonSize.xl:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
    }
  }

  double _getFontSize() {
    switch (widget.config.size) {
      case AeroButtonSize.xs:
        return 11;
      case AeroButtonSize.sm:
        return 13;
      case AeroButtonSize.md:
        return 14;
      case AeroButtonSize.lg:
        return 16;
      case AeroButtonSize.xl:
        return 18;
    }
  }

  double _getIconSize() {
    switch (widget.config.size) {
      case AeroButtonSize.xs:
        return 14;
      case AeroButtonSize.sm:
        return 16;
      case AeroButtonSize.md:
        return 18;
      case AeroButtonSize.lg:
        return 20;
      case AeroButtonSize.xl:
        return 22;
    }
  }

  BorderRadius _getBorderRadius() {
    if (widget.config.borderRadius != null) {
      return widget.config.borderRadius!;
    }

    switch (widget.config.size) {
      case AeroButtonSize.xs:
      case AeroButtonSize.sm:
        return BorderRadius.circular(6);
      case AeroButtonSize.md:
        return BorderRadius.circular(8);
      case AeroButtonSize.lg:
      case AeroButtonSize.xl:
        return BorderRadius.circular(10);
    }
  }

  BoxDecoration _getDecoration(BuildContext context) {
    final config = widget.config;
    final baseColor = _getBackgroundColor(context);

    switch (config.variant) {
      case AeroButtonVariant.solid:
        return BoxDecoration(
          color: baseColor,
          borderRadius: _getBorderRadius(),
          boxShadow: config.boxShadow ??
              (config.elevation != null
                  ? [
                      BoxShadow(
                        color: baseColor.withOpacity(0.3),
                        blurRadius: config.elevation!,
                        offset: Offset(0, config.elevation! / 2),
                      )
                    ]
                  : null),
        );

      case AeroButtonVariant.outline:
        return BoxDecoration(
          color: _isHovered ? baseColor.withOpacity(0.1) : Colors.transparent,
          border: Border.all(
            color: baseColor,
            width: config.borderWidth ?? 1.5,
          ),
          borderRadius: _getBorderRadius(),
        );

      case AeroButtonVariant.ghost:
        return BoxDecoration(
          color: _isHovered ? baseColor.withOpacity(0.15) : Colors.transparent,
          borderRadius: _getBorderRadius(),
        );

      case AeroButtonVariant.link:
        return const BoxDecoration();

      case AeroButtonVariant.gradient:
        return BoxDecoration(
          gradient: config.gradient,
          borderRadius: _getBorderRadius(),
          boxShadow: config.boxShadow ??
              (config.elevation != null
                  ? [
                      BoxShadow(
                        color: baseColor.withOpacity(0.3),
                        blurRadius: config.elevation!,
                        offset: Offset(0, config.elevation! / 2),
                      )
                    ]
                  : null),
        );
    }
  }

  Widget _buildContent(BuildContext context) {
    final config = widget.config;
    final textColor = _getTextColor(context);
    final fontSize = _getFontSize();
    final iconSize = _getIconSize();

    if (config.isLoading) {
      return config.loadingWidget ??
          SizedBox(
            width: iconSize,
            height: iconSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(textColor),
            ),
          );
    }

    final content = widget.child ??
        Text(
          widget.text ?? '',
          style: TextStyle(
            color: textColor,
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        );

    if (config.leftIcon == null && config.rightIcon == null) {
      return content;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (config.leftIcon != null) ...[
          Icon(config.leftIcon, size: iconSize, color: textColor),
          const SizedBox(width: 8),
        ],
        content,
        if (config.rightIcon != null) ...[
          const SizedBox(width: 8),
          Icon(config.rightIcon, size: iconSize, color: textColor),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.config;

    Widget button = MouseRegion(
      cursor: _isInteractive ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) {
        if (_isInteractive) {
          setState(() => _isHovered = true);
        }
      },
      onExit: (_) {
        if (_isInteractive) {
          setState(() => _isHovered = false);
        }
      },
      child: GestureDetector(
        onTap: _isInteractive ? widget.onPressed : null,
        onLongPress: _isInteractive ? widget.onLongPress : null,
        onTapDown: (_) {
          if (_isInteractive) {
            setState(() => _isPressed = true);
            _scaleController.forward();
          }
        },
        onTapUp: (_) {
          if (_isInteractive) {
            setState(() => _isPressed = false);
            _scaleController.reverse();
          }
        },
        onTapCancel: () {
          if (_isInteractive) {
            setState(() => _isPressed = false);
            _scaleController.reverse();
          }
        },
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            width: config.isBlock ? double.infinity : config.width,
            height: config.height,
            padding: _getPadding(),
            decoration: _getDecoration(context),
            child: Center(
              widthFactor: config.isBlock ? null : 1.0,
              child: _buildContent(context),
            ),
          ),
        ),
      ),
    );

    if (config.isDisabled) {
      button = Opacity(opacity: 0.6, child: button);
    }

    return button;
  }
}

/// Example usage page
class AeroButtonExample extends StatefulWidget {
  @override
  _AeroButtonExampleState createState() => _AeroButtonExampleState();
}

class _AeroButtonExampleState extends State<AeroButtonExample> {
  bool _isLoading = false;

  void _simulateLoading() {
    setState(() => _isLoading = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

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
              'AeroButton Component',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),

            // Variants
            _buildSection('Variants', [
              AeroButton.solid(
                text: 'Solid Button',
                onPressed: () {},
              ),
              AeroButton.outline(
                text: 'Outline Button',
                onPressed: () {},
              ),
              AeroButton.ghost(
                text: 'Ghost Button',
                onPressed: () {},
              ),
              AeroButton.link(
                text: 'Link Button',
                onPressed: () {},
              ),
              AeroButton.gradient(
                text: 'Gradient Button',
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ),
                onPressed: () {},
              ),
            ]),

            // Sizes
            _buildSection('Sizes', [
              AeroButton.solid(
                text: 'XS Button',
                size: AeroButtonSize.xs,
                onPressed: () {},
              ),
              AeroButton.solid(
                text: 'Small Button',
                size: AeroButtonSize.sm,
                onPressed: () {},
              ),
              AeroButton.solid(
                text: 'Medium Button',
                size: AeroButtonSize.md,
                onPressed: () {},
              ),
              AeroButton.solid(
                text: 'Large Button',
                size: AeroButtonSize.lg,
                onPressed: () {},
              ),
              AeroButton.solid(
                text: 'XL Button',
                size: AeroButtonSize.xl,
                onPressed: () {},
              ),
            ]),

            // With Icons
            _buildSection('With Icons', [
              AeroButton.solid(
                text: 'Left Icon',
                leftIcon: Icons.arrow_back,
                onPressed: () {},
              ),
              AeroButton.solid(
                text: 'Right Icon',
                rightIcon: Icons.arrow_forward,
                onPressed: () {},
              ),
              AeroButton.outline(
                text: 'Both Icons',
                leftIcon: Icons.download,
                rightIcon: Icons.arrow_downward,
                onPressed: () {},
              ),
            ]),

            // Icon Only Buttons
            _buildSection('Icon Only Buttons', [
              AeroButton.icon(
                icon: Icons.favorite,
                onPressed: () {},
                size: AeroButtonSize.xs,
              ),
              AeroButton.icon(
                icon: Icons.search,
                onPressed: () {},
                size: AeroButtonSize.sm,
              ),
              AeroButton.icon(
                icon: Icons.add,
                onPressed: () {},
              ),
              AeroButton.icon(
                icon: Icons.edit,
                onPressed: () {},
                size: AeroButtonSize.lg,
              ),
              AeroButton.icon(
                icon: Icons.delete,
                onPressed: () {},
                color: const Color(0xFFEF4444),
                size: AeroButtonSize.xl,
              ),
            ]),

            // Icon Variants
            _buildSection('Icon Button Variants', [
              AeroButton.icon(
                icon: Icons.notifications,
                variant: AeroButtonVariant.solid,
                onPressed: () {},
              ),
              AeroButton.icon(
                icon: Icons.share,
                variant: AeroButtonVariant.outline,
                color: const Color(0xFF6366F1),
                onPressed: () {},
              ),
              AeroButton.icon(
                icon: Icons.more_vert,
                variant: AeroButtonVariant.ghost,
                color: const Color(0xFF10B981),
                onPressed: () {},
              ),
              AeroButton.icon(
                icon: Icons.settings,
                variant: AeroButtonVariant.solid,
                color: const Color(0xFF8B5CF6),
                onPressed: () {},
                isCircular: false,
              ),
            ]),

            // States
            _buildSection('States', [
              AeroButton.solid(
                text: 'Normal',
                onPressed: () {},
              ),
              AeroButton.solid(
                text: 'Loading',
                isLoading: _isLoading,
                onPressed: _simulateLoading,
              ),
              AeroButton.solid(
                text: 'Disabled',
                isDisabled: true,
                onPressed: () {},
              ),
            ]),

            // Colors
            _buildSection('Custom Colors', [
              AeroButton.solid(
                text: 'Success',
                color: const Color(0xFF10B981),
                onPressed: () {},
              ),
              AeroButton.solid(
                text: 'Warning',
                color: const Color(0xFFF59E0B),
                onPressed: () {},
              ),
              AeroButton.solid(
                text: 'Danger',
                color: const Color(0xFFEF4444),
                onPressed: () {},
              ),
            ]),

            // Block Button
            _buildSection('Block Button', [
              AeroButton.solid(
                text: 'Full Width Button',
                isBlock: true,
                onPressed: () {},
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> buttons) {
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
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: buttons,
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}