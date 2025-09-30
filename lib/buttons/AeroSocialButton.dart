import 'package:flutter/material.dart';

/// Social platform providers
enum SocialProvider {
  google,
  apple,
  facebook,
  twitter,
  github,
  linkedin,
  microsoft,
  discord,
  slack,
  spotify,
}

/// Social button style
enum SocialButtonStyle {
  filled,    // Brand color background
  outlined,  // Border with brand color
  light,     // Light background with brand color
  dark,      // Dark background
}

/// Social button size
enum SocialButtonSize {
  sm,
  md,
  lg,
}

/// AeroSocialButton - Pre-styled buttons for social logins
class AeroSocialButton extends StatefulWidget {
  final SocialProvider provider;
  final VoidCallback onPressed;
  final SocialButtonStyle style;
  final SocialButtonSize size;
  final String? customText;
  final bool showIcon;
  final bool isLoading;
  final bool isDisabled;
  final double? width;
  final bool isBlock;

  const AeroSocialButton({
    Key? key,
    required this.provider,
    required this.onPressed,
    this.style = SocialButtonStyle.filled,
    this.size = SocialButtonSize.md,
    this.customText,
    this.showIcon = true,
    this.isLoading = false,
    this.isDisabled = false,
    this.width,
    this.isBlock = false,
  }) : super(key: key);

  // Convenience constructors
  factory AeroSocialButton.google({
    required VoidCallback onPressed,
    SocialButtonStyle style = SocialButtonStyle.filled,
    SocialButtonSize size = SocialButtonSize.md,
    String? customText,
    bool isLoading = false,
    bool isBlock = false,
  }) {
    return AeroSocialButton(
      provider: SocialProvider.google,
      onPressed: onPressed,
      style: style,
      size: size,
      customText: customText,
      isLoading: isLoading,
      isBlock: isBlock,
    );
  }

  factory AeroSocialButton.apple({
    required VoidCallback onPressed,
    SocialButtonStyle style = SocialButtonStyle.filled,
    SocialButtonSize size = SocialButtonSize.md,
    String? customText,
    bool isLoading = false,
    bool isBlock = false,
  }) {
    return AeroSocialButton(
      provider: SocialProvider.apple,
      onPressed: onPressed,
      style: style,
      size: size,
      customText: customText,
      isLoading: isLoading,
      isBlock: isBlock,
    );
  }

  factory AeroSocialButton.facebook({
    required VoidCallback onPressed,
    SocialButtonStyle style = SocialButtonStyle.filled,
    SocialButtonSize size = SocialButtonSize.md,
    String? customText,
    bool isLoading = false,
    bool isBlock = false,
  }) {
    return AeroSocialButton(
      provider: SocialProvider.facebook,
      onPressed: onPressed,
      style: style,
      size: size,
      customText: customText,
      isLoading: isLoading,
      isBlock: isBlock,
    );
  }

  factory AeroSocialButton.github({
    required VoidCallback onPressed,
    SocialButtonStyle style = SocialButtonStyle.filled,
    SocialButtonSize size = SocialButtonSize.md,
    String? customText,
    bool isLoading = false,
    bool isBlock = false,
  }) {
    return AeroSocialButton(
      provider: SocialProvider.github,
      onPressed: onPressed,
      style: style,
      size: size,
      customText: customText,
      isLoading: isLoading,
      isBlock: isBlock,
    );
  }

  @override
  State<AeroSocialButton> createState() => _AeroSocialButtonState();
}

class _AeroSocialButtonState extends State<AeroSocialButton> {
  bool _isHovered = false;

  bool get _isInteractive => !widget.isDisabled && !widget.isLoading;

  // Brand colors for each provider
  Color _getBrandColor() {
    switch (widget.provider) {
      case SocialProvider.google:
        return const Color(0xFF4285F4);
      case SocialProvider.apple:
        return const Color(0xFF000000);
      case SocialProvider.facebook:
        return const Color(0xFF1877F2);
      case SocialProvider.twitter:
        return const Color(0xFF1DA1F2);
      case SocialProvider.github:
        return const Color(0xFF181717);
      case SocialProvider.linkedin:
        return const Color(0xFF0A66C2);
      case SocialProvider.microsoft:
        return const Color(0xFF00A4EF);
      case SocialProvider.discord:
        return const Color(0xFF5865F2);
      case SocialProvider.slack:
        return const Color(0xFF4A154B);
      case SocialProvider.spotify:
        return const Color(0xFF1DB954);
    }
  }

  String _getProviderName() {
    switch (widget.provider) {
      case SocialProvider.google:
        return 'Google';
      case SocialProvider.apple:
        return 'Apple';
      case SocialProvider.facebook:
        return 'Facebook';
      case SocialProvider.twitter:
        return 'Twitter';
      case SocialProvider.github:
        return 'GitHub';
      case SocialProvider.linkedin:
        return 'LinkedIn';
      case SocialProvider.microsoft:
        return 'Microsoft';
      case SocialProvider.discord:
        return 'Discord';
      case SocialProvider.slack:
        return 'Slack';
      case SocialProvider.spotify:
        return 'Spotify';
    }
  }

  String _getDefaultText() {
    return widget.customText ?? 'Continue with ${_getProviderName()}';
  }

  IconData _getProviderIcon() {
    // Using Material Icons as placeholders
    // In production, you'd use custom SVG icons or icon fonts
    switch (widget.provider) {
      case SocialProvider.google:
        return Icons.g_mobiledata;
      case SocialProvider.apple:
        return Icons.apple;
      case SocialProvider.facebook:
        return Icons.facebook;
      case SocialProvider.twitter:
        return Icons.tag; // Twitter/X placeholder
      case SocialProvider.github:
        return Icons.code;
      case SocialProvider.linkedin:
        return Icons.work;
      case SocialProvider.microsoft:
        return Icons.window;
      case SocialProvider.discord:
        return Icons.chat;
      case SocialProvider.slack:
        return Icons.chat_bubble;
      case SocialProvider.spotify:
        return Icons.music_note;
    }
  }

  Color _getBackgroundColor() {
    final brandColor = _getBrandColor();

    if (widget.isDisabled) {
      return brandColor.withOpacity(0.5);
    }

    switch (widget.style) {
      case SocialButtonStyle.filled:
        return _isHovered ? _darken(brandColor, 0.1) : brandColor;
      case SocialButtonStyle.outlined:
        return _isHovered ? brandColor.withOpacity(0.1) : Colors.transparent;
      case SocialButtonStyle.light:
        return _isHovered
            ? brandColor.withOpacity(0.15)
            : brandColor.withOpacity(0.1);
      case SocialButtonStyle.dark:
        return _isHovered
            ? const Color(0xFF1E293B)
            : const Color(0xFF0F172A);
    }
  }

  Color _getTextColor() {
    final brandColor = _getBrandColor();

    switch (widget.style) {
      case SocialButtonStyle.filled:
        // Special case for light backgrounds
        if (widget.provider == SocialProvider.google) {
          return Colors.white;
        }
        return Colors.white;
      case SocialButtonStyle.outlined:
      case SocialButtonStyle.light:
        return brandColor;
      case SocialButtonStyle.dark:
        return Colors.white;
    }
  }

  Color _darken(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }

  EdgeInsets _getPadding() {
    switch (widget.size) {
      case SocialButtonSize.sm:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
      case SocialButtonSize.md:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
      case SocialButtonSize.lg:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 14);
    }
  }

  double _getFontSize() {
    switch (widget.size) {
      case SocialButtonSize.sm:
        return 13;
      case SocialButtonSize.md:
        return 14;
      case SocialButtonSize.lg:
        return 16;
    }
  }

  double _getIconSize() {
    switch (widget.size) {
      case SocialButtonSize.sm:
        return 18;
      case SocialButtonSize.md:
        return 20;
      case SocialButtonSize.lg:
        return 22;
    }
  }

  BoxDecoration _getDecoration() {
    final brandColor = _getBrandColor();

    return BoxDecoration(
      color: _getBackgroundColor(),
      border: widget.style == SocialButtonStyle.outlined
          ? Border.all(color: brandColor, width: 1.5)
          : null,
      borderRadius: BorderRadius.circular(8),
      boxShadow: widget.style == SocialButtonStyle.filled && _isHovered
          ? [
              BoxShadow(
                color: brandColor.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ]
          : null,
    );
  }

  Widget _buildContent() {
    final textColor = _getTextColor();
    final fontSize = _getFontSize();
    final iconSize = _getIconSize();

    if (widget.isLoading) {
      return SizedBox(
        width: iconSize,
        height: iconSize,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(textColor),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.showIcon) ...[
          Icon(
            _getProviderIcon(),
            size: iconSize,
            color: textColor,
          ),
          const SizedBox(width: 12),
        ],
        Text(
          _getDefaultText(),
          style: TextStyle(
            color: textColor,
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
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
        child: Opacity(
          opacity: widget.isDisabled ? 0.6 : 1.0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            width: widget.isBlock ? double.infinity : widget.width,
            padding: _getPadding(),
            decoration: _getDecoration(),
            child: Center(
              widthFactor: widget.isBlock ? null : 1.0,
              child: _buildContent(),
            ),
          ),
        ),
      ),
    );
  }
}

/// Social Button Group - Multiple social buttons in a row
class SocialButtonGroup extends StatelessWidget {
  final List<SocialProvider> providers;
  final Function(SocialProvider) onProviderSelected;
  final SocialButtonStyle style;
  final SocialButtonSize size;
  final bool iconOnly;
  final MainAxisAlignment alignment;
  final double spacing;

  const SocialButtonGroup({
    Key? key,
    required this.providers,
    required this.onProviderSelected,
    this.style = SocialButtonStyle.outlined,
    this.size = SocialButtonSize.md,
    this.iconOnly = false,
    this.alignment = MainAxisAlignment.center,
    this.spacing = 12,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      alignment: WrapAlignment.center,
      children: providers.map((provider) {
        return AeroSocialButton(
          provider: provider,
          onPressed: () => onProviderSelected(provider),
          style: style,
          size: size,
          customText: iconOnly ? '' : null,
          showIcon: true,
        );
      }).toList(),
    );
  }
}

/// Example usage
class SocialButtonExample extends StatefulWidget {
  @override
  _SocialButtonExampleState createState() => _SocialButtonExampleState();
}

class _SocialButtonExampleState extends State<SocialButtonExample> {
  bool _isLoading = false;
  SocialProvider? _selectedProvider;

  void _handleSocialLogin(SocialProvider provider) {
    setState(() {
      _isLoading = true;
      _selectedProvider = provider;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _selectedProvider = null;
        });
        _showMessage('Logged in with ${_getProviderName(provider)}');
      }
    });
  }

  String _getProviderName(SocialProvider provider) {
    switch (provider) {
      case SocialProvider.google:
        return 'Google';
      case SocialProvider.apple:
        return 'Apple';
      case SocialProvider.facebook:
        return 'Facebook';
      case SocialProvider.twitter:
        return 'Twitter';
      case SocialProvider.github:
        return 'GitHub';
      case SocialProvider.linkedin:
        return 'LinkedIn';
      case SocialProvider.microsoft:
        return 'Microsoft';
      case SocialProvider.discord:
        return 'Discord';
      case SocialProvider.slack:
        return 'Slack';
      case SocialProvider.spotify:
        return 'Spotify';
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1E293B),
      ),
    );
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
              'Social Button Component',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),

            // Popular Providers
            _buildSection('Popular Providers (Filled)', [
              AeroSocialButton.google(
                onPressed: () => _handleSocialLogin(SocialProvider.google),
                isLoading: _isLoading && _selectedProvider == SocialProvider.google,
                isBlock: true,
              ),
              const SizedBox(height: 12),
              AeroSocialButton.apple(
                onPressed: () => _handleSocialLogin(SocialProvider.apple),
                isLoading: _isLoading && _selectedProvider == SocialProvider.apple,
                isBlock: true,
              ),
              const SizedBox(height: 12),
              AeroSocialButton.facebook(
                onPressed: () => _handleSocialLogin(SocialProvider.facebook),
                isLoading: _isLoading && _selectedProvider == SocialProvider.facebook,
                isBlock: true,
              ),
              const SizedBox(height: 12),
              AeroSocialButton.github(
                onPressed: () => _handleSocialLogin(SocialProvider.github),
                isLoading: _isLoading && _selectedProvider == SocialProvider.github,
                isBlock: true,
              ),
            ]),

            // All Providers
            _buildSection('All Providers', [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  AeroSocialButton(
                    provider: SocialProvider.google,
                    onPressed: () => _handleSocialLogin(SocialProvider.google),
                  ),
                  AeroSocialButton(
                    provider: SocialProvider.apple,
                    onPressed: () => _handleSocialLogin(SocialProvider.apple),
                  ),
                  AeroSocialButton(
                    provider: SocialProvider.facebook,
                    onPressed: () => _handleSocialLogin(SocialProvider.facebook),
                  ),
                  AeroSocialButton(
                    provider: SocialProvider.twitter,
                    onPressed: () => _handleSocialLogin(SocialProvider.twitter),
                  ),
                  AeroSocialButton(
                    provider: SocialProvider.github,
                    onPressed: () => _handleSocialLogin(SocialProvider.github),
                  ),
                  AeroSocialButton(
                    provider: SocialProvider.linkedin,
                    onPressed: () => _handleSocialLogin(SocialProvider.linkedin),
                  ),
                  AeroSocialButton(
                    provider: SocialProvider.microsoft,
                    onPressed: () => _handleSocialLogin(SocialProvider.microsoft),
                  ),
                  AeroSocialButton(
                    provider: SocialProvider.discord,
                    onPressed: () => _handleSocialLogin(SocialProvider.discord),
                  ),
                  AeroSocialButton(
                    provider: SocialProvider.slack,
                    onPressed: () => _handleSocialLogin(SocialProvider.slack),
                  ),
                  AeroSocialButton(
                    provider: SocialProvider.spotify,
                    onPressed: () => _handleSocialLogin(SocialProvider.spotify),
                  ),
                ],
              ),
            ]),

            // Outlined Style
            _buildSection('Outlined Style', [
              AeroSocialButton(
                provider: SocialProvider.google,
                style: SocialButtonStyle.outlined,
                onPressed: () => _handleSocialLogin(SocialProvider.google),
                isBlock: true,
              ),
              const SizedBox(height: 12),
              AeroSocialButton(
                provider: SocialProvider.github,
                style: SocialButtonStyle.outlined,
                onPressed: () => _handleSocialLogin(SocialProvider.github),
                isBlock: true,
              ),
            ]),

            // Light Style
            _buildSection('Light Style', [
              AeroSocialButton(
                provider: SocialProvider.google,
                style: SocialButtonStyle.light,
                onPressed: () => _handleSocialLogin(SocialProvider.google),
                isBlock: true,
              ),
              const SizedBox(height: 12),
              AeroSocialButton(
                provider: SocialProvider.apple,
                style: SocialButtonStyle.light,
                onPressed: () => _handleSocialLogin(SocialProvider.apple),
                isBlock: true,
              ),
            ]),

            // Dark Style
            _buildSection('Dark Style', [
              AeroSocialButton(
                provider: SocialProvider.google,
                style: SocialButtonStyle.dark,
                onPressed: () => _handleSocialLogin(SocialProvider.google),
                isBlock: true,
              ),
              const SizedBox(height: 12),
              AeroSocialButton(
                provider: SocialProvider.facebook,
                style: SocialButtonStyle.dark,
                onPressed: () => _handleSocialLogin(SocialProvider.facebook),
                isBlock: true,
              ),
            ]),

            // Sizes
            _buildSection('Sizes', [
              AeroSocialButton(
                provider: SocialProvider.google,
                size: SocialButtonSize.sm,
                onPressed: () => _handleSocialLogin(SocialProvider.google),
              ),
              const SizedBox(height: 12),
              AeroSocialButton(
                provider: SocialProvider.google,
                size: SocialButtonSize.md,
                onPressed: () => _handleSocialLogin(SocialProvider.google),
              ),
              const SizedBox(height: 12),
              AeroSocialButton(
                provider: SocialProvider.google,
                size: SocialButtonSize.lg,
                onPressed: () => _handleSocialLogin(SocialProvider.google),
              ),
            ]),

            // Custom Text
            _buildSection('Custom Text', [
              AeroSocialButton(
                provider: SocialProvider.google,
                customText: 'Sign in with Google',
                onPressed: () => _handleSocialLogin(SocialProvider.google),
                isBlock: true,
              ),
              const SizedBox(height: 12),
              AeroSocialButton(
                provider: SocialProvider.github,
                customText: 'Login using GitHub',
                onPressed: () => _handleSocialLogin(SocialProvider.github),
                isBlock: true,
              ),
            ]),

            // Login Form Example
            _buildSection('Login Form Example', [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF334155),
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Welcome Back',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in to continue',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 32),
                    AeroSocialButton.google(
                      onPressed: () => _handleSocialLogin(SocialProvider.google),
                      isBlock: true,
                      isLoading: _isLoading && _selectedProvider == SocialProvider.google,
                    ),
                    const SizedBox(height: 12),
                    AeroSocialButton.apple(
                      onPressed: () => _handleSocialLogin(SocialProvider.apple),
                      isBlock: true,
                      isLoading: _isLoading && _selectedProvider == SocialProvider.apple,
                    ),
                    const SizedBox(height: 12),
                    AeroSocialButton.github(
                      onPressed: () => _handleSocialLogin(SocialProvider.github),
                      isBlock: true,
                      isLoading: _isLoading && _selectedProvider == SocialProvider.github,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'OR',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.email_outlined,
                            color: Colors.white.withOpacity(0.6),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Continue with Email',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ]),

            // Social Button Group
            _buildSection('Social Button Group', [
              SocialButtonGroup(
                providers: [
                  SocialProvider.google,
                  SocialProvider.apple,
                  SocialProvider.facebook,
                  SocialProvider.github,
                ],
                onProviderSelected: _handleSocialLogin,
                style: SocialButtonStyle.outlined,
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