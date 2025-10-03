import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

/// Controller for AeroOtpField
class AeroOtpController extends ChangeNotifier {
  String _value = '';
  
  String get value => _value;
  
  set value(String newValue) {
    if (_value != newValue) {
      _value = newValue;
      notifyListeners();
    }
  }
  
  void clear() {
    value = '';
  }
  
  void setValue(String newValue) {
    value = newValue;
  }
  
  bool get isComplete => _value.length == _expectedLength;
  
  int _expectedLength = 6;
  
  void _setExpectedLength(int length) {
    _expectedLength = length;
  }
}

/// Enum for OTP field variants
enum OtpFieldVariant {
  outlined,
  filled,
  underlined,
  box,
}

/// Enum for OTP field shapes
enum OtpFieldShape {
  rectangle,
  circle,
  rounded,
}

/// Custom OTP field widget with modern features
class AeroOtpField extends StatefulWidget {
  // Core properties
  final AeroOtpController? controller;
  final int length;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;
  final TextInputType keyboardType;
  final bool obscureText;
  final String? obscureCharacter;

  // Styling
  final OtpFieldVariant variant;
  final OtpFieldShape shape;
  final double fieldWidth;
  final double fieldHeight;
  final double spacing;
  final Color? fillColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? errorBorderColor;
  final Color? cursorColor;
  final TextStyle? textStyle;
  final double borderWidth;
  final double borderRadius;

  // Behavior
  final bool autoFocus;
  final bool enablePinAutofill;
  final bool readOnly;
  final bool enabled;
  final FocusNode? focusNode;
  
  // Validation
  final FormFieldValidator<String>? validator;
  final String? errorText;
  final bool showError;
  
  // Animation
  final bool animateError;
  final Duration animationDuration;
  
  // Advanced Features
  final bool clearOnComplete;
  final bool allowPaste;
  final bool showCursor;
  final bool hapticFeedback;
  final Duration? autoSubmitDelay;
  
  // States
  final bool isLoading;
  final bool isSuccess;
  final bool isError;

  const AeroOtpField({
    Key? key,
    this.controller,
    this.length = 6,
    this.onChanged,
    this.onCompleted,
    this.keyboardType = TextInputType.number,
    this.obscureText = false,
    this.obscureCharacter,
    this.variant = OtpFieldVariant.outlined,
    this.shape = OtpFieldShape.rounded,
    this.fieldWidth = 50,
    this.fieldHeight = 60,
    this.spacing = 12,
    this.fillColor,
    this.borderColor,
    this.focusedBorderColor,
    this.errorBorderColor,
    this.cursorColor,
    this.textStyle,
    this.borderWidth = 2,
    this.borderRadius = 12,
    this.autoFocus = true,
    this.enablePinAutofill = true,
    this.readOnly = false,
    this.enabled = true,
    this.focusNode,
    this.validator,
    this.errorText,
    this.showError = true,
    this.animateError = true,
    this.animationDuration = const Duration(milliseconds: 300),
    this.clearOnComplete = false,
    this.allowPaste = true,
    this.showCursor = true,
    this.hapticFeedback = true,
    this.autoSubmitDelay,
    this.isLoading = false,
    this.isSuccess = false,
    this.isError = false,
  }) : super(key: key);

  @override
  State<AeroOtpField> createState() => _AeroOtpFieldState();
}

class _AeroOtpFieldState extends State<AeroOtpField> with SingleTickerProviderStateMixin {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;
  late FocusNode _mainFocusNode;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  late AeroOtpController _otpController;
  
  String _currentOtp = '';
  int _currentFocusIndex = 0;
  String? _validationError;
  Timer? _autoSubmitTimer;

  @override
  void initState() {
    super.initState();
    
    _otpController = widget.controller ?? AeroOtpController();
    _otpController._setExpectedLength(widget.length);
    _otpController.addListener(_onControllerChanged);
    
    _controllers = List.generate(
      widget.length,
      (index) => TextEditingController(),
    );
    
    _focusNodes = List.generate(
      widget.length,
      (index) => FocusNode()..addListener(() => _onFocusChange(index)),
    );
    
    _mainFocusNode = widget.focusNode ?? FocusNode();
    
    // Shake animation for errors
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: -10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: -10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticIn,
    ));

    if (widget.autoFocus && widget.enabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNodes[0].requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _otpController.removeListener(_onControllerChanged);
    if (widget.controller == null) {
      _otpController.dispose();
    }
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    if (widget.focusNode == null) {
      _mainFocusNode.dispose();
    }
    _shakeController.dispose();
    _autoSubmitTimer?.cancel();
    super.dispose();
  }

  void _onControllerChanged() {
    final newValue = _otpController.value;
    
    // Clear all fields first
    for (var controller in _controllers) {
      controller.clear();
    }
    
    // Set new values
    if (newValue.isEmpty) {
      _currentOtp = '';
      setState(() {
        _validationError = null;
      });
      if (widget.enabled) {
        _focusNodes[0].requestFocus();
      }
    } else {
      final chars = newValue.split('');
      for (int i = 0; i < chars.length && i < widget.length; i++) {
        _controllers[i].text = chars[i];
      }
      _currentOtp = newValue;
    }
  }

  void _onFocusChange(int index) {
    if (_focusNodes[index].hasFocus) {
      setState(() {
        _currentFocusIndex = index;
      });
    }
  }

  void _onChanged(int index, String value) {
    if (value.isEmpty) return;

    // Handle paste
    if (value.length > 1 && widget.allowPaste) {
      _handlePaste(value, index);
      return;
    }

    // Single character input
    if (value.length == 1) {
      _controllers[index].text = value;
      _updateOtp();
      
      if (widget.hapticFeedback) {
        HapticFeedback.lightImpact();
      }

      // Move to next field
      if (index < widget.length - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        _checkCompletion();
      }
    }
  }

  void _handlePaste(String value, int startIndex) {
    final cleanValue = value.replaceAll(RegExp(r'\s+'), '');
    final chars = cleanValue.split('');
    
    for (int i = 0; i < chars.length && (startIndex + i) < widget.length; i++) {
      _controllers[startIndex + i].text = chars[i];
    }
    
    _updateOtp();
    
    final lastIndex = (startIndex + chars.length - 1).clamp(0, widget.length - 1);
    if (lastIndex < widget.length - 1) {
      _focusNodes[lastIndex + 1].requestFocus();
    } else {
      _focusNodes[lastIndex].unfocus();
      _checkCompletion();
    }
  }

  void _onKeyEvent(int index, KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.backspace) {
        if (_controllers[index].text.isEmpty && index > 0) {
          _focusNodes[index - 1].requestFocus();
          _controllers[index - 1].clear();
          _updateOtp();
        }
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft && index > 0) {
        _focusNodes[index - 1].requestFocus();
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight && index < widget.length - 1) {
        _focusNodes[index + 1].requestFocus();
      }
    }
  }

  void _updateOtp() {
    final otp = _controllers.map((c) => c.text).join();
    _currentOtp = otp;
    _otpController.value = otp;
    widget.onChanged?.call(otp);
    
    setState(() {
      _validationError = null;
    });
  }

  void _checkCompletion() {
    if (_currentOtp.length == widget.length) {
      final error = widget.validator?.call(_currentOtp);
      
      if (error != null) {
        setState(() {
          _validationError = error;
        });
        if (widget.animateError) {
          _shakeController.forward(from: 0);
        }
        if (widget.hapticFeedback) {
          HapticFeedback.heavyImpact();
        }
        return;
      }

      if (widget.autoSubmitDelay != null) {
        _autoSubmitTimer?.cancel();
        _autoSubmitTimer = Timer(widget.autoSubmitDelay!, () {
          widget.onCompleted?.call(_currentOtp);
          if (widget.clearOnComplete) {
            _otpController.clear();
          }
        });
      } else {
        widget.onCompleted?.call(_currentOtp);
        if (widget.clearOnComplete) {
          _otpController.clear();
        }
      }
    }
  }

  BoxDecoration _getFieldDecoration(int index) {
    final isFocused = _focusNodes[index].hasFocus;
    final hasValue = _controllers[index].text.isNotEmpty;
    final hasError = _validationError != null || widget.isError || widget.errorText != null;
    
    Color borderColor;
    if (hasError) {
      borderColor = widget.errorBorderColor ?? Colors.red;
    } else if (widget.isSuccess) {
      borderColor = Colors.green;
    } else if (isFocused) {
      borderColor = widget.focusedBorderColor ?? Colors.blue;
    } else {
      borderColor = widget.borderColor ?? Colors.grey;
    }

    Color? backgroundColor;
    if (widget.variant == OtpFieldVariant.filled) {
      backgroundColor = widget.fillColor ?? Colors.grey.shade100;
    } else if (widget.variant == OtpFieldVariant.box) {
      backgroundColor = hasValue 
          ? (widget.fillColor ?? Colors.blue.withOpacity(0.1))
          : (widget.fillColor ?? Colors.grey.shade50);
    }

    BorderRadius? borderRadius;
    if (widget.shape == OtpFieldShape.rounded) {
      borderRadius = BorderRadius.circular(widget.borderRadius);
    } else if (widget.shape == OtpFieldShape.rectangle) {
      borderRadius = BorderRadius.circular(4);
    }

    BoxBorder? border;
    if (widget.variant != OtpFieldVariant.filled) {
      if (widget.variant == OtpFieldVariant.underlined) {
        border = Border(
          bottom: BorderSide(
            color: borderColor,
            width: isFocused ? widget.borderWidth : widget.borderWidth - 0.5,
          ),
        );
      } else {
        border = Border.all(
          color: borderColor,
          width: isFocused ? widget.borderWidth : widget.borderWidth - 0.5,
        );
      }
    }

    BoxShape? boxShape;
    if (widget.shape == OtpFieldShape.circle) {
      boxShape = BoxShape.circle;
    }

    return BoxDecoration(
      color: backgroundColor,
      border: border,
      borderRadius: boxShape == null ? borderRadius : null,
      shape: boxShape ?? BoxShape.rectangle,
    );
  }

  Widget _buildStateIndicator() {
    if (widget.isLoading) {
      return const Padding(
        padding: EdgeInsets.only(top: 8.0),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    
    if (widget.isSuccess) {
      return Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.check_circle, color: Colors.green, size: 20),
              SizedBox(width: 8),
              Text(
                'Verified',
                style: TextStyle(color: Colors.green, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildErrorText() {
    final errorMessage = _validationError ?? widget.errorText;
    if (!widget.showError || errorMessage == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Text(
        errorMessage,
        style: TextStyle(
          color: widget.errorBorderColor ?? Colors.red,
          fontSize: 12,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: child,
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: List.generate(widget.length, (index) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: widget.spacing / 2),
                child: SizedBox(
                  width: widget.fieldWidth,
                  height: widget.fieldHeight,
                  child: KeyboardListener(
                    focusNode: FocusNode(),
                    onKeyEvent: (event) => _onKeyEvent(index, event),
                    child: Container(
                      decoration: _getFieldDecoration(index),
                      alignment: Alignment.center,
                      child: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        enabled: widget.enabled,
                        readOnly: widget.readOnly,
                        textAlign: TextAlign.center,
                        keyboardType: widget.keyboardType,
                        maxLength: 1,
                        obscureText: widget.obscureText,
                        obscuringCharacter: widget.obscureCharacter ?? '•',
                        showCursor: widget.showCursor,
                        cursorColor: widget.cursorColor ?? Colors.blue,
                        style: widget.textStyle ?? const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(1),
                          if (widget.keyboardType == TextInputType.number)
                            FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          counterText: '',
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: (value) => _onChanged(index, value),
                        autofillHints: widget.enablePinAutofill 
                            ? [AutofillHints.oneTimeCode]
                            : null,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          _buildStateIndicator(),
          _buildErrorText(),
        ],
      ),
    );
  }
}