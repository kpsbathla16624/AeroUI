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

/// Built-in validation presets
class CustomValidation {
  // Phone number validation (10 digits)
  static ValidationPreset phoneNumber({
    int maxLength = 10,
    String? errorMessage,
  }) {
    return ValidationPreset(
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(maxLength),
      ],
      validator: (value) {
        if (value == null || value.isEmpty) return null;
        if (value.length < maxLength) {
          return errorMessage ?? 'Phone number must be $maxLength digits';
        }
        return null;
      },
      keyboardType: TextInputType.phone,
    );
  }

  // Email validation
  static ValidationPreset email({String? errorMessage}) {
    return ValidationPreset(
      validator: (value) {
        if (value == null || value.isEmpty) return null;
        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
        if (!emailRegex.hasMatch(value)) {
          return errorMessage ?? 'Please enter a valid email';
        }
        return null;
      },
      keyboardType: TextInputType.emailAddress,
      autoCapitalize: AutoCapitalize.none,
    );
  }

  // Number only validation
  static ValidationPreset numberOnly({
    int? maxLength,
    int? minValue,
    int? maxValue,
    String? errorMessage,
  }) {
    return ValidationPreset(
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        if (maxLength != null) LengthLimitingTextInputFormatter(maxLength),
      ],
      validator: (value) {
        if (value == null || value.isEmpty) return null;
        final number = int.tryParse(value);
        if (number == null) return 'Please enter a valid number';
        if (minValue != null && number < minValue) {
          return errorMessage ?? 'Value must be at least $minValue';
        }
        if (maxValue != null && number > maxValue) {
          return errorMessage ?? 'Value must not exceed $maxValue';
        }
        return null;
      },
      keyboardType: TextInputType.number,
    );
  }

  // Decimal number validation
  static ValidationPreset decimal({
    int? maxLength,
    double? minValue,
    double? maxValue,
    int decimalPlaces = 2,
    String? errorMessage,
  }) {
    return ValidationPreset(
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
        if (maxLength != null) LengthLimitingTextInputFormatter(maxLength),
        DecimalFormatter(decimalPlaces: decimalPlaces),
      ],
      validator: (value) {
        if (value == null || value.isEmpty) return null;
        final number = double.tryParse(value);
        if (number == null) return 'Please enter a valid number';
        if (minValue != null && number < minValue) {
          return errorMessage ?? 'Value must be at least $minValue';
        }
        if (maxValue != null && number > maxValue) {
          return errorMessage ?? 'Value must not exceed $maxValue';
        }
        return null;
      },
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
    );
  }

  // Text only (no numbers or special characters)
  static ValidationPreset textOnly({
    int? maxLength,
    int? minLength,
    String? errorMessage,
  }) {
    return ValidationPreset(
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
        if (maxLength != null) LengthLimitingTextInputFormatter(maxLength),
      ],
      validator: (value) {
        if (value == null || value.isEmpty) return null;
        if (minLength != null && value.length < minLength) {
          return errorMessage ?? 'Must be at least $minLength characters';
        }
        return null;
      },
      autoCapitalize: AutoCapitalize.words,
    );
  }

  // Username validation (alphanumeric and underscore)
  static ValidationPreset username({
    int minLength = 3,
    int maxLength = 20,
    String? errorMessage,
  }) {
    return ValidationPreset(
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_]')),
        LengthLimitingTextInputFormatter(maxLength),
      ],
      validator: (value) {
        if (value == null || value.isEmpty) return null;
        if (value.length < minLength) {
          return errorMessage ?? 'Username must be at least $minLength characters';
        }
        return null;
      },
      autoCapitalize: AutoCapitalize.none,
    );
  }

  // URL validation
  static ValidationPreset url({String? errorMessage}) {
    return ValidationPreset(
      validator: (value) {
        if (value == null || value.isEmpty) return null;
        final urlRegex = RegExp(
          r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
        );
        if (!urlRegex.hasMatch(value)) {
          return errorMessage ?? 'Please enter a valid URL';
        }
        return null;
      },
      keyboardType: TextInputType.url,
      autoCapitalize: AutoCapitalize.none,
    );
  }

  // Password validation
  static ValidationPreset password({
    int minLength = 8,
    bool requireUppercase = true,
    bool requireLowercase = true,
    bool requireNumber = true,
    bool requireSpecialChar = true,
    String? errorMessage,
  }) {
    return ValidationPreset(
      validator: (value) {
        if (value == null || value.isEmpty) return null;
        if (value.length < minLength) {
          return 'Password must be at least $minLength characters';
        }
        if (requireUppercase && !RegExp(r'[A-Z]').hasMatch(value)) {
          return 'Password must contain an uppercase letter';
        }
        if (requireLowercase && !RegExp(r'[a-z]').hasMatch(value)) {
          return 'Password must contain a lowercase letter';
        }
        if (requireNumber && !RegExp(r'[0-9]').hasMatch(value)) {
          return 'Password must contain a number';
        }
        if (requireSpecialChar && !RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
          return 'Password must contain a special character';
        }
        return null;
      },
      isPassword: true,
      showPasswordToggle: true,
    );
  }

  // Credit card validation
  static ValidationPreset creditCard({String? errorMessage}) {
    return ValidationPreset(
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(16),
        CreditCardFormatter(),
      ],
      validator: (value) {
        if (value == null || value.isEmpty) return null;
        final digitsOnly = value.replaceAll(' ', '');
        if (digitsOnly.length < 13 || digitsOnly.length > 19) {
          return errorMessage ?? 'Please enter a valid credit card number';
        }
        // Luhn algorithm
        if (!_luhnCheck(digitsOnly)) {
          return errorMessage ?? 'Invalid credit card number';
        }
        return null;
      },
      keyboardType: TextInputType.number,
    );
  }

  // Date validation (DD/MM/YYYY)
  static ValidationPreset date({String? errorMessage}) {
    return ValidationPreset(
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(8),
        DateFormatter(),
      ],
      validator: (value) {
        if (value == null || value.isEmpty) return null;
        final dateRegex = RegExp(r'^\d{2}/\d{2}/\d{4}$');
        if (!dateRegex.hasMatch(value)) {
          return errorMessage ?? 'Please enter a valid date (DD/MM/YYYY)';
        }
        // Additional date validation can be added here
        return null;
      },
      keyboardType: TextInputType.number,
      hintText: 'DD/MM/YYYY',
    );
  }

  // ZIP code validation
  static ValidationPreset zipCode({
    int length = 6,
    String? errorMessage,
  }) {
    return ValidationPreset(
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(length),
      ],
      validator: (value) {
        if (value == null || value.isEmpty) return null;
        if (value.length != length) {
          return errorMessage ?? 'ZIP code must be $length digits';
        }
        return null;
      },
      keyboardType: TextInputType.number,
    );
  }

  // Required field validation
  static ValidationPreset required({String? errorMessage}) {
    return ValidationPreset(
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return errorMessage ?? 'This field is required';
        }
        return null;
      },
    );
  }

  // Min/Max length validation
  static ValidationPreset length({
    int? minLength,
    int? maxLength,
    String? errorMessage,
  }) {
    return ValidationPreset(
      inputFormatters: [
        if (maxLength != null) LengthLimitingTextInputFormatter(maxLength),
      ],
      validator: (value) {
        if (value == null || value.isEmpty) return null;
        if (minLength != null && value.length < minLength) {
          return errorMessage ?? 'Must be at least $minLength characters';
        }
        if (maxLength != null && value.length > maxLength) {
          return errorMessage ?? 'Must not exceed $maxLength characters';
        }
        return null;
      },
    );
  }

  // Luhn algorithm for credit card validation
  static bool _luhnCheck(String cardNumber) {
    int sum = 0;
    bool alternate = false;
    for (int i = cardNumber.length - 1; i >= 0; i--) {
      int digit = int.parse(cardNumber[i]);
      if (alternate) {
        digit *= 2;
        if (digit > 9) digit -= 9;
      }
      sum += digit;
      alternate = !alternate;
    }
    return sum % 10 == 0;
  }
}

/// Validation preset class
class ValidationPreset {
  final List<TextInputFormatter>? inputFormatters;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final AutoCapitalize? autoCapitalize;
  final bool? isPassword;
  final bool? showPasswordToggle;
  final String? hintText;

  ValidationPreset({
    this.inputFormatters,
    this.validator,
    this.keyboardType,
    this.autoCapitalize,
    this.isPassword,
    this.showPasswordToggle,
    this.hintText,
  });
}

/// Custom formatters
class DecimalFormatter extends TextInputFormatter {
  final int decimalPlaces;

  DecimalFormatter({this.decimalPlaces = 2});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    final parts = newValue.text.split('.');
    if (parts.length > 2) return oldValue;
    if (parts.length == 2 && parts[1].length > decimalPlaces) {
      return oldValue;
    }

    return newValue;
  }
}

class CreditCardFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if ((i + 1) % 4 == 0 && i + 1 != text.length) {
        buffer.write(' ');
      }
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class DateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    final buffer = StringBuffer();

    for (int i = 0; i < text.length && i < 8; i++) {
      buffer.write(text[i]);
      if (i == 1 || i == 3) {
        buffer.write('/');
      }
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
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

  // Validation Preset
  final ValidationPreset? validationPreset;

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
    this.validationPreset,
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
    _obscureText = _effectiveIsPassword;

    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    if (widget.controller == null) _controller.dispose();
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  bool get _effectiveIsPassword {
    return widget.validationPreset?.isPassword ?? widget.isPassword;
  }

  bool get _effectiveShowPasswordToggle {
    return widget.validationPreset?.showPasswordToggle ?? widget.showPasswordToggle;
  }

  TextInputType? get _effectiveKeyboardType {
    return widget.keyboardType ?? widget.validationPreset?.keyboardType;
  }

  AutoCapitalize get _effectiveAutoCapitalize {
    return widget.validationPreset?.autoCapitalize ?? widget.autoCapitalize;
  }

  String? get _effectiveHintText {
    return widget.hintText ?? widget.validationPreset?.hintText;
  }

  List<TextInputFormatter>? get _effectiveInputFormatters {
    final presetFormatters = widget.validationPreset?.inputFormatters ?? [];
    final customFormatters = widget.inputFormatters ?? [];
    if (presetFormatters.isEmpty && customFormatters.isEmpty) return null;
    return [...presetFormatters, ...customFormatters];
  }

  FormFieldValidator<String>? get _effectiveValidator {
    final presetValidator = widget.validationPreset?.validator;
    final customValidator = widget.validator;

    if (presetValidator == null && customValidator == null) return null;

    return (value) {
      final presetError = presetValidator?.call(value);
      if (presetError != null) return presetError;
      return customValidator?.call(value);
    };
  }

  void _onTextChanged() {
    if (widget.passwordStrengthIndicator && _effectiveIsPassword) {
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

    if (widget.isSuccess && !widget.isLoading && !_isValidating) {
      suffixWidgets.add(
        const Padding(
          padding: EdgeInsets.all(12.0),
          child: Icon(Icons.check_circle, color: Colors.green, size: 20),
        ),
      );
    }

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

    if (_effectiveIsPassword && _effectiveShowPasswordToggle) {
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
    switch (_effectiveAutoCapitalize) {
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
      keyboardType: _effectiveKeyboardType,
      textInputAction: widget.textInputAction,
      maxLength: widget.maxLength,
      maxLines: widget.expands ? null : widget.maxLines,
      minLines: widget.minLines,
      readOnly: widget.readOnly,
      enabled: widget.enabled,
      obscureText: _effectiveIsPassword && _obscureText,
      autocorrect: widget.autoCorrect,
      autofocus: widget.autoFocus,
      textCapitalization: _getTextCapitalization(),
      expands: widget.expands,
      inputFormatters: _effectiveInputFormatters,
      style: widget.textStyle,
      onTap: widget.onTap,
      onSubmitted: widget.onSubmitted,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: _effectiveHintText,
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
              textEditingController.text = _controller.text;
              textEditingController.selection = _controller.selection;
              
              textEditingController.addListener(() {
                if (_controller.text != textEditingController.text) {
                  _controller.value = textEditingController.value;
                }
              });

              return TextField(
                controller: textEditingController,
                focusNode: focusNode,
                keyboardType: _effectiveKeyboardType,
                textInputAction: widget.textInputAction,
                maxLength: widget.maxLength,
                maxLines: widget.expands ? null : widget.maxLines,
                minLines: widget.minLines,
                readOnly: widget.readOnly,
                enabled: widget.enabled,
                obscureText: _effectiveIsPassword && _obscureText,
                autocorrect: widget.autoCorrect,
                autofocus: widget.autoFocus,
                textCapitalization: _getTextCapitalization(),
                expands: widget.expands,
                inputFormatters: _effectiveInputFormatters,
                style: widget.textStyle,
                onTap: widget.onTap,
                onSubmitted: (value) {
                  onFieldSubmitted();
                  widget.onSubmitted?.call(value);
                },
                decoration: InputDecoration(
                  labelText: widget.label,
                  hintText: _effectiveHintText,
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
              _effectiveIsPassword &&
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

// ============================================================================
// USAGE EXAMPLES
// ============================================================================

class AeroTextFieldExamples extends StatefulWidget {
  const AeroTextFieldExamples({Key? key}) : super(key: key);

  @override
  State<AeroTextFieldExamples> createState() => _AeroTextFieldExamplesState();
}

class _AeroTextFieldExamplesState extends State<AeroTextFieldExamples> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AeroTextField Examples'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Built-in Validation Presets',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              // Phone Number
              AeroTextField(
                label: 'Phone Number',
                validationPreset: CustomValidation.phoneNumber(),
                prefixIcon: const Icon(Icons.phone),
              ),
              const SizedBox(height: 16),

              // Email
              AeroTextField(
                label: 'Email',
                validationPreset: CustomValidation.email(),
                prefixIcon: const Icon(Icons.email),
              ),
              const SizedBox(height: 16),

              // Number Only
              AeroTextField(
                label: 'Age',
                validationPreset: CustomValidation.numberOnly(
                  maxLength: 3,
                  minValue: 18,
                  maxValue: 120,
                ),
                prefixIcon: const Icon(Icons.calendar_today),
              ),
              const SizedBox(height: 16),

              // Decimal
              AeroTextField(
                label: 'Price',
                validationPreset: CustomValidation.decimal(
                  decimalPlaces: 2,
                  minValue: 0,
                ),
                prefixIcon: const Icon(Icons.attach_money),
              ),
              const SizedBox(height: 16),

              // Text Only
              AeroTextField(
                label: 'Full Name',
                validationPreset: CustomValidation.textOnly(
                  minLength: 2,
                ),
                prefixIcon: const Icon(Icons.person),
              ),
              const SizedBox(height: 16),

              // Username
              AeroTextField(
                label: 'Username',
                validationPreset: CustomValidation.username(),
                prefixIcon: const Icon(Icons.account_circle),
              ),
              const SizedBox(height: 16),

              // URL
              AeroTextField(
                label: 'Website',
                validationPreset: CustomValidation.url(),
                prefixIcon: const Icon(Icons.link),
              ),
              const SizedBox(height: 16),

              // Password with strength indicator
              AeroTextField(
                label: 'Password',
                validationPreset: CustomValidation.password(),
                passwordStrengthIndicator: true,
                prefixIcon: const Icon(Icons.lock),
              ),
              const SizedBox(height: 16),

              // Credit Card
              AeroTextField(
                label: 'Credit Card',
                validationPreset: CustomValidation.creditCard(),
                prefixIcon: const Icon(Icons.credit_card),
              ),
              const SizedBox(height: 16),

              // Date
              AeroTextField(
                label: 'Date of Birth',
                validationPreset: CustomValidation.date(),
                prefixIcon: const Icon(Icons.calendar_month),
              ),
              const SizedBox(height: 16),

              // ZIP Code
              AeroTextField(
                label: 'ZIP Code',
                validationPreset: CustomValidation.zipCode(),
                prefixIcon: const Icon(Icons.location_on),
              ),
              const SizedBox(height: 16),

              // Required Field
              AeroTextField(
                label: 'Required Field',
                validationPreset: CustomValidation.required(),
                prefixIcon: const Icon(Icons.star),
              ),
              const SizedBox(height: 16),

              // Min/Max Length
              AeroTextField(
                label: 'Description',
                validationPreset: CustomValidation.length(
                  minLength: 10,
                  maxLength: 100,
                ),
                maxLines: 3,
                prefixIcon: const Icon(Icons.description),
              ),
              const SizedBox(height: 24),

              // Combining preset with custom properties
              const Text(
                'Combined Features',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              AeroTextField(
                label: 'Phone with Clear',
                validationPreset: CustomValidation.phoneNumber(),
                clearable: true,
                variant: TextFieldVariant.filled,
                prefixIcon: const Icon(Icons.phone),
              ),
              const SizedBox(height: 16),

              AeroTextField(
                label: 'Email with Success',
                validationPreset: CustomValidation.email(),
                isSuccess: true,
                variant: TextFieldVariant.outlined,
                prefixIcon: const Icon(Icons.email),
              ),
              const SizedBox(height: 32),

              // Submit button
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('All fields are valid!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                child: const Text('Validate Form'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}