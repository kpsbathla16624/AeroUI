import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

/// Enum for text field variants
enum TextFieldVariant {
  outlined,
  filled,
  underlined,
  glass,
  neumorphic,
}

/// Enum for auto-capitalization
enum AutoCapitalize {
  none,
  words,
  sentences,
  characters,
}

/// Custom text field widget with advanced features
class AeroTextField extends StatefulWidget {
  // Core properties
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int? maxLength;
  final int? maxLines;
  final int? minLines;
  final bool readOnly;
  final bool enabled;

  // Labels & Placeholders
  final String? label;
  final String? hintText;
  final String? helperText;
  final String? errorText;

  // Icons & Adornments
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Widget? prefix;
  final Widget? suffix;

  // Styling
  final TextFieldVariant variant;
  final BorderRadius? borderRadius;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? errorBorderColor;
  final Color? backgroundColor;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final EdgeInsetsGeometry? contentPadding;
  final bool dense;

  // Password / Secure Input
  final bool isPassword;
  final bool showPasswordToggle;
  final bool passwordStrengthIndicator;

  // Behavior
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final FormFieldValidator<String>? validator;
  final Future<String?> Function(String)? asyncValidator;
  final Duration debounceDuration;

  // Advanced
  final List<String>? autoComplete;
  final Widget Function(BuildContext, String)? suggestionsBuilder;
  final bool clearable;
  final List<TextInputFormatter>? inputFormatters;
  final bool expands;
  final bool autoCorrect;
  final bool autoFocus;
  final AutoCapitalize autoCapitalize;

  // States
  final bool isLoading;
  final bool isSuccess;
  final bool isWarning;
  final bool isError;

  // Accessibility
  final String? semanticsLabel;
  final String? semanticsHint;

  const AeroTextField({
    Key? key,
    this.controller,
    this.focusNode,
    this.keyboardType,
    this.textInputAction,
    this.maxLength,
    this.maxLines = 1,
    this.minLines,
    this.readOnly = false,
    this.enabled = true,
    this.label,
    this.hintText,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.prefix,
    this.suffix,
    this.variant = TextFieldVariant.outlined,
    this.borderRadius,
    this.borderColor,
    this.focusedBorderColor,
    this.errorBorderColor,
    this.backgroundColor,
    this.textStyle,
    this.hintStyle,
    this.contentPadding,
    this.dense = false,
    this.isPassword = false,
    this.showPasswordToggle = false,
    this.passwordStrengthIndicator = false,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.validator,
    this.asyncValidator,
    this.debounceDuration = const Duration(milliseconds: 300),
    this.autoComplete,
    this.suggestionsBuilder,
    this.clearable = false,
    this.inputFormatters,
    this.expands = false,
    this.autoCorrect = true,
    this.autoFocus = false,
    this.autoCapitalize = AutoCapitalize.none,
    this.isLoading = false,
    this.isSuccess = false,
    this.isWarning = false,
    this.isError = false,
    this.semanticsLabel,
    this.semanticsHint,
  }) : super(key: key);

  @override
  State<AeroTextField> createState() => _AeroTextFieldState();
}

class _AeroTextFieldState extends State<AeroTextField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _obscureText = true;
  Timer? _debounce;
  String? _asyncErrorText;
  bool _isValidating = false;
  double _passwordStrength = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();
    _obscureText = widget.isPassword;

    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    if (widget.controller == null) _controller.dispose();
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (widget.passwordStrengthIndicator && widget.isPassword) {
      setState(() {
        _passwordStrength = _calculatePasswordStrength(_controller.text);
      });
    }

    if (widget.asyncValidator != null) {
      _debounce?.cancel();
      _debounce = Timer(widget.debounceDuration, () {
        _performAsyncValidation();
      });
    }

    widget.onChanged?.call(_controller.text);
  }

  Future<void> _performAsyncValidation() async {
    if (widget.asyncValidator == null) return;

    setState(() {
      _isValidating = true;
      _asyncErrorText = null;
    });

    try {
      final error = await widget.asyncValidator!(_controller.text);
      if (mounted) {
        setState(() {
          _asyncErrorText = error;
          _isValidating = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _asyncErrorText = 'Validation error';
          _isValidating = false;
        });
      }
    }
  }

  double _calculatePasswordStrength(String password) {
    if (password.isEmpty) return 0.0;

    double strength = 0.0;
    if (password.length >= 8) strength += 0.25;
    if (password.length >= 12) strength += 0.25;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength += 0.15;
    if (RegExp(r'[a-z]').hasMatch(password)) strength += 0.15;
    if (RegExp(r'[0-9]').hasMatch(password)) strength += 0.1;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength += 0.1;

    return strength.clamp(0.0, 1.0);
  }

  InputBorder _getBorder({bool focused = false, bool error = false}) {
    final radius = widget.borderRadius ?? BorderRadius.circular(8);
    Color borderColor;

    if (error) {
      borderColor = widget.errorBorderColor ?? Colors.red;
    } else if (widget.isSuccess) {
      borderColor = Colors.green;
    } else if (widget.isWarning) {
      borderColor = Colors.orange;
    } else if (focused) {
      borderColor = widget.focusedBorderColor ?? Colors.blue;
    } else {
      borderColor = widget.borderColor ?? Colors.grey;
    }

    switch (widget.variant) {
      case TextFieldVariant.outlined:
        return OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: borderColor, width: focused ? 2 : 1),
        );
      case TextFieldVariant.filled:
        return OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide.none,
        );
      case TextFieldVariant.underlined:
        return UnderlineInputBorder(
          borderSide: BorderSide(color: borderColor, width: focused ? 2 : 1),
        );
      case TextFieldVariant.glass:
        return OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(
            color: borderColor.withOpacity(0.3),
            width: 1,
          ),
        );
      case TextFieldVariant.neumorphic:
        return OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide.none,
        );
    }
  }

  Color _getBackgroundColor() {
    if (widget.backgroundColor != null) return widget.backgroundColor!;

    switch (widget.variant) {
      case TextFieldVariant.filled:
        return Colors.grey.shade100;
      case TextFieldVariant.glass:
        return Colors.white.withOpacity(0.1);
      case TextFieldVariant.neumorphic:
        return Colors.grey.shade200;
      default:
        return Colors.transparent;
    }
  }

  Widget _buildSuffixIcon() {
    List<Widget> suffixWidgets = [];

    // Loading indicator
    if (widget.isLoading || _isValidating) {
      suffixWidgets.add(
        const Padding(
          padding: EdgeInsets.all(12.0),
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    // Success/Warning/Error indicators
    if (widget.isSuccess && !widget.isLoading && !_isValidating) {
      suffixWidgets.add(
        const Padding(
          padding: EdgeInsets.all(12.0),
          child: Icon(Icons.check_circle, color: Colors.green, size: 20),
        ),
      );
    }

    // Clear button
    if (widget.clearable && _controller.text.isNotEmpty && !widget.readOnly) {
      suffixWidgets.add(
        IconButton(
          icon: const Icon(Icons.clear, size: 20),
          onPressed: () {
            _controller.clear();
            widget.onChanged?.call('');
          },
        ),
      );
    }

    // Password toggle
    if (widget.isPassword && widget.showPasswordToggle) {
      suffixWidgets.add(
        IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility : Icons.visibility_off,
            size: 20,
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
      );
    }

    // Custom suffix icon
    if (widget.suffixIcon != null && suffixWidgets.isEmpty) {
      suffixWidgets.add(widget.suffixIcon!);
    }

    if (suffixWidgets.isEmpty) return const SizedBox.shrink();
    if (suffixWidgets.length == 1) return suffixWidgets[0];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: suffixWidgets,
    );
  }

  TextCapitalization _getTextCapitalization() {
    switch (widget.autoCapitalize) {
      case AutoCapitalize.none:
        return TextCapitalization.none;
      case AutoCapitalize.words:
        return TextCapitalization.words;
      case AutoCapitalize.sentences:
        return TextCapitalization.sentences;
      case AutoCapitalize.characters:
        return TextCapitalization.characters;
    }
  }

  Widget _buildTextField() {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      maxLength: widget.maxLength,
      maxLines: widget.expands ? null : widget.maxLines,
      minLines: widget.minLines,
      readOnly: widget.readOnly,
      enabled: widget.enabled,
      obscureText: widget.isPassword && _obscureText,
      autocorrect: widget.autoCorrect,
      autofocus: widget.autoFocus,
      textCapitalization: _getTextCapitalization(),
      expands: widget.expands,
      inputFormatters: widget.inputFormatters,
      style: widget.textStyle,
      onTap: widget.onTap,
      onSubmitted: widget.onSubmitted,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hintText,
        hintStyle: widget.hintStyle,
        helperText: widget.helperText,
        errorText: _asyncErrorText ?? widget.errorText,
        prefixIcon: widget.prefixIcon,
        prefix: widget.prefix,
        suffix: widget.suffix,
        suffixIcon: _buildSuffixIcon(),
        contentPadding: widget.contentPadding ??
            (widget.dense
                ? const EdgeInsets.all(8)
                : const EdgeInsets.all(16)),
        isDense: widget.dense,
        filled: widget.variant == TextFieldVariant.filled ||
            widget.variant == TextFieldVariant.glass ||
            widget.variant == TextFieldVariant.neumorphic,
        fillColor: _getBackgroundColor(),
        border: _getBorder(),
        enabledBorder: _getBorder(),
        focusedBorder: _getBorder(focused: true),
        errorBorder: _getBorder(error: true),
        focusedErrorBorder: _getBorder(focused: true, error: true),
        counterText: widget.maxLength != null ? null : '',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveErrorText = _asyncErrorText ?? widget.errorText;
    final hasError = effectiveErrorText != null || widget.isError;

    Widget textField;

    // Use Autocomplete if autoComplete is provided
    if (widget.autoComplete != null && widget.autoComplete!.isNotEmpty) {
      textField = LayoutBuilder(
        builder: (context, constraints) {
          return Autocomplete<String>(
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text.isEmpty) {
                return const Iterable<String>.empty();
              }
              return widget.autoComplete!.where((String option) {
                return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
              });
            },
            onSelected: (String selection) {
              _controller.text = selection;
              _controller.selection = TextSelection.fromPosition(
                TextPosition(offset: selection.length),
              );
              widget.onChanged?.call(selection);
            },
            fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
              // Sync our controller with autocomplete's controller
              textEditingController.text = _controller.text;
              textEditingController.selection = _controller.selection;
              
              // Listen to autocomplete controller and sync back to our controller
              textEditingController.addListener(() {
                if (_controller.text != textEditingController.text) {
                  _controller.value = textEditingController.value;
                }
              });

              return TextField(
                controller: textEditingController,
                focusNode: focusNode,
                keyboardType: widget.keyboardType,
                textInputAction: widget.textInputAction,
                maxLength: widget.maxLength,
                maxLines: widget.expands ? null : widget.maxLines,
                minLines: widget.minLines,
                readOnly: widget.readOnly,
                enabled: widget.enabled,
                obscureText: widget.isPassword && _obscureText,
                autocorrect: widget.autoCorrect,
                autofocus: widget.autoFocus,
                textCapitalization: _getTextCapitalization(),
                expands: widget.expands,
                inputFormatters: widget.inputFormatters,
                style: widget.textStyle,
                onTap: widget.onTap,
                onSubmitted: (value) {
                  onFieldSubmitted();
                  widget.onSubmitted?.call(value);
                },
                decoration: InputDecoration(
                  labelText: widget.label,
                  hintText: widget.hintText,
                  hintStyle: widget.hintStyle,
                  helperText: widget.helperText,
                  errorText: _asyncErrorText ?? widget.errorText,
                  prefixIcon: widget.prefixIcon,
                  prefix: widget.prefix,
                  suffix: widget.suffix,
                  suffixIcon: _buildSuffixIcon(),
                  contentPadding: widget.contentPadding ??
                      (widget.dense
                          ? const EdgeInsets.all(8)
                          : const EdgeInsets.all(16)),
                  isDense: widget.dense,
                  filled: widget.variant == TextFieldVariant.filled ||
                      widget.variant == TextFieldVariant.glass ||
                      widget.variant == TextFieldVariant.neumorphic,
                  fillColor: _getBackgroundColor(),
                  border: _getBorder(),
                  enabledBorder: _getBorder(),
                  focusedBorder: _getBorder(focused: true),
                  errorBorder: _getBorder(error: true),
                  focusedErrorBorder: _getBorder(focused: true, error: true),
                  counterText: widget.maxLength != null ? null : '',
                ),
              );
            },
            optionsViewBuilder: (context, onSelected, options) {
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  elevation: 4.0,
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: constraints.maxWidth,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: options.length,
                        itemBuilder: (context, index) {
                          final option = options.elementAt(index);
                          return InkWell(
                            onTap: () => onSelected(option),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 12.0,
                              ),
                              child: Text(option),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      );
    } else {
      textField = _buildTextField();
    }

    return Semantics(
      label: widget.semanticsLabel,
      hint: widget.semanticsHint,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          textField,
          if (widget.passwordStrengthIndicator &&
              widget.isPassword &&
              _controller.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LinearProgressIndicator(
                    value: _passwordStrength,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _passwordStrength < 0.3
                          ? Colors.red
                          : _passwordStrength < 0.6
                              ? Colors.orange
                              : Colors.green,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _passwordStrength < 0.3
                        ? 'Weak'
                        : _passwordStrength < 0.6
                            ? 'Medium'
                            : 'Strong',
                    style: TextStyle(
                      fontSize: 12,
                      color: _passwordStrength < 0.3
                          ? Colors.red
                          : _passwordStrength < 0.6
                              ? Colors.orange
                              : Colors.green,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}