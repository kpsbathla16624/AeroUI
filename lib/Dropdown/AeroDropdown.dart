import 'package:flutter/material.dart';

/// A powerful, customizable, and animated dropdown widget
/// with support for async data, filtering, sorting, multi-select,
/// custom builders, and controller-based management.
class AeroDropdown<T> extends StatefulWidget {
  const AeroDropdown({
    Key? key,
    required this.items,
    required this.itemBuilder,
    required this.onChanged,
    this.value,
    this.selectedBuilder,
    this.asyncItems,
    this.loadingIndicator,
    this.emptyState,
    this.errorState,
    this.searchable = false,
    this.searchLabel,
    this.filterFn,
    this.caseSensitiveSearch = false,
    this.searchByStartsWith = false,
    this.highlightSearchText = true,
    this.autoSort = false,
    this.sortComparator,
    this.sortAscending = true,
    this.multiSelect = false,
    this.showCheckmark = true,
    this.clearable = false,
    this.closeOnSelect = true,
    this.enabled = true,
    this.hintText,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.leading,
    this.trailing,
    this.style = AeroDropdownStyle.solid,
    this.textStyle,
    this.backgroundColor,
    this.dropdownColor,
    this.borderColor,
    this.elevation = 4.0,
    this.borderRadius = 12.0,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.dropdownWidthFactor = 1.0,
    this.dropdownMaxHeight,
    this.decoration,
    this.animationType = AeroDropdownAnimation.fade,
    this.animationDuration = const Duration(milliseconds: 220),
    this.animationCurve = Curves.easeOut,
    this.dropdownAlignment = Alignment.topLeft,
    this.offsetY = 8.0,
    this.controller,
    this.semanticsLabel,
  }) : super(key: key);

  final List<T> items;
  final Widget Function(T item) itemBuilder;
  final Widget Function(T item)? selectedBuilder;
  final ValueChanged<T> onChanged;
  final T? value;
  final Future<List<T>> Function()? asyncItems;
  final Widget? loadingIndicator;
  final Widget? emptyState;
  final Widget? errorState;
  final bool searchable;
  final String Function(T item)? searchLabel;
  final bool Function(T item, String query)? filterFn;
  final bool caseSensitiveSearch;
  final bool searchByStartsWith;
  final bool highlightSearchText;
  final bool autoSort;
  final int Function(T a, T b)? sortComparator;
  final bool sortAscending;
  final bool multiSelect;
  final bool showCheckmark;
  final bool clearable;
  final bool closeOnSelect;
  final bool enabled;
  final String? hintText;
  final Widget? hint;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Widget? leading;
  final Widget? trailing;
  final AeroDropdownStyle style;
  final TextStyle? textStyle;
  final Color? backgroundColor;
  final Color? dropdownColor;
  final Color? borderColor;
  final double elevation;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final double dropdownWidthFactor;
  final double? dropdownMaxHeight;
  final BoxDecoration? decoration;
  final AeroDropdownAnimation animationType;
  final Duration animationDuration;
  final Curve animationCurve;
  final Alignment dropdownAlignment;
  final double offsetY;
  final AeroDropdownController<T>? controller;
  final String? semanticsLabel;

  @override
  State<AeroDropdown<T>> createState() => _AeroDropdownState<T>();
}

class _AeroDropdownState<T> extends State<AeroDropdown<T>>
    with SingleTickerProviderStateMixin {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  late AnimationController _animController;
  late Animation<double> _animation;
  late AeroDropdownController<T> _controller;
  List<T> _displayItems = [];
  List<T> _asyncLoadedItems = [];
  bool _isLoading = false;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  void Function(void Function())? _overlaySetState;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? AeroDropdownController<T>();
    _controller.addListener(_onControllerChanged);
    _animController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _animation = CurvedAnimation(
      parent: _animController,
      curve: widget.animationCurve,
    );
    _displayItems = List.from(widget.items);
    _loadAsyncItems();
    _applySorting();
    
    // Add listener to search controller for UI updates
    _searchController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void didUpdateWidget(AeroDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      _displayItems = List.from(widget.items);
      _applySorting();
    }
  }

  @override
  void dispose() {
    // Remove overlay first before disposing anything
    _overlayEntry?.remove();
    _overlayEntry = null;
    
    // Clear search
    _searchController.dispose();
    _searchFocusNode.dispose();
    
    // Remove listener before disposing controller
    _controller.removeListener(_onControllerChanged);
    
    // Only dispose if we own the controller
    if (widget.controller == null) {
      _controller.dispose();
    }
    
    // Dispose animation controller
    _animController.dispose();
    
    super.dispose();
  }

  void _onControllerChanged() {
    // Prevent infinite loop by checking current state
    if (_controller.isOpen && _overlayEntry == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _overlayEntry == null) {
          _showOverlay();
        }
      });
    } else if (!_controller.isOpen && _overlayEntry != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _overlayEntry != null) {
          _hideOverlay();
        }
      });
    }
  }

  Future<void> _loadAsyncItems() async {
    if (widget.asyncItems == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final items = await widget.asyncItems!();
      setState(() {
        _asyncLoadedItems = items;
        _displayItems = List.from(items);
        _isLoading = false;
        _applySorting();
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  void _applySorting() {
    if (widget.autoSort && widget.sortComparator != null) {
      _displayItems.sort((a, b) {
        final result = widget.sortComparator!(a, b);
        return widget.sortAscending ? result : -result;
      });
    }
  }

  void _filterItems(String query) {
    final source = widget.asyncItems != null ? _asyncLoadedItems : widget.items;

    if (query.isEmpty) {
      _displayItems = List.from(source);
      _applySorting();
      // Update overlay
      if (_overlaySetState != null) {
        _overlaySetState!(() {});
      }
      return;
    }

    _displayItems = source.where((item) {
      if (widget.filterFn != null) {
        return widget.filterFn!(item, query);
      }

      if (widget.searchLabel != null) {
        final label = widget.searchLabel!(item);
        final searchQuery =
            widget.caseSensitiveSearch ? query : query.toLowerCase();
        final searchIn =
            widget.caseSensitiveSearch ? label : label.toLowerCase();

        if (widget.searchByStartsWith) {
          return searchIn.startsWith(searchQuery);
        }
        return searchIn.contains(searchQuery);
      }

      // Fallback: try to convert item to string
      final itemString = item.toString();
      final searchQuery =
          widget.caseSensitiveSearch ? query : query.toLowerCase();
      final searchIn =
          widget.caseSensitiveSearch ? itemString : itemString.toLowerCase();
      
      return searchIn.contains(searchQuery);
    }).toList();
    _applySorting();
    
    // Update overlay
    if (_overlaySetState != null) {
      _overlaySetState!(() {});
    }
  }

  void _toggleDropdown() {
    if (!widget.enabled || !mounted) return;

    if (_overlayEntry == null) {
      _showOverlay();
    } else {
      _hideOverlay();
    }
  }

  void _showOverlay() {
    if (!mounted || _overlayEntry != null) return; // Prevent duplicate overlays
    
    _controller._isOpen = true;
    
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    _animController.forward();
  }

  void _hideOverlay() {
    if (!mounted) return;
    _animController.reverse().then((_) {
      if (mounted) {
        _removeOverlay();
      }
    });
  }

  void _removeOverlay() {
    if (!mounted) return;
    _overlayEntry?.remove();
    _overlayEntry = null;
    _overlaySetState = null;
    _controller._isOpen = false;
    _searchController.clear();
    if (mounted) {
      _filterItems('');
    }
  }

  OverlayEntry _createOverlayEntry() {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    return OverlayEntry(
      builder: (context) => StatefulBuilder(
        builder: (context, overlaySetState) {
          _overlaySetState = overlaySetState;
          return GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _hideOverlay,
            child: Stack(
              children: [
                Positioned(
                  width: size.width * widget.dropdownWidthFactor,
                  child: CompositedTransformFollower(
                    link: _layerLink,
                    showWhenUnlinked: false,
                    offset: Offset(0, size.height + widget.offsetY),
                    child: Material(
                      elevation: widget.elevation,
                      borderRadius: BorderRadius.circular(widget.borderRadius),
                      color: widget.dropdownColor ??
                          Theme.of(context).colorScheme.surface,
                      child: _buildAnimatedDropdown(size),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedDropdown(Size triggerSize) {
    Widget child = _buildDropdownContent();

    switch (widget.animationType) {
      case AeroDropdownAnimation.fade:
        return FadeTransition(opacity: _animation, child: child);
      case AeroDropdownAnimation.slide:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -0.1),
            end: Offset.zero,
          ).animate(_animation),
          child: FadeTransition(opacity: _animation, child: child),
        );
      case AeroDropdownAnimation.scale:
        return ScaleTransition(
          scale: _animation,
          alignment: widget.dropdownAlignment,
          child: child,
        );
      case AeroDropdownAnimation.expand:
        return SizeTransition(
          sizeFactor: _animation,
          axisAlignment: -1,
          child: child,
        );
    }
  }

  Widget _buildDropdownContent() {
    return Container(
      color: widget.dropdownColor ?? Theme.of(context).colorScheme.surface,
      constraints: BoxConstraints(
        maxHeight: widget.dropdownMaxHeight ?? 300,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.searchable) _buildSearchBar(),
          Flexible(
            child: _isLoading
                ? _buildLoadingState()
                : _errorMessage != null
                    ? _buildErrorState()
                    : _displayItems.isEmpty
                        ? _buildEmptyState()
                        : _buildItemsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        autofocus: true,
        onChanged: (value) {
          _filterItems(value);
        },
        decoration: InputDecoration(
          hintText: 'Search...',
          prefixIcon: Icon(Icons.search,
              color: Theme.of(context).colorScheme.secondary),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear,
                      color: Theme.of(context).colorScheme.secondary),
                  onPressed: () {
                    _searchController.clear();
                    _filterItems('');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return widget.loadingIndicator ??
        Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        );
  }

  Widget _buildErrorState() {
    return widget.errorState ??
        Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline,
                    size: 48, color: Theme.of(context).colorScheme.error),
                const SizedBox(height: 8),
                Text(
                  'Error loading items',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
            ),
          ),
        );
  }

  Widget _buildEmptyState() {
    return widget.emptyState ??
        Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              'No items found',
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
        );
  }

  Widget _buildItemsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      shrinkWrap: true,
      itemCount: _displayItems.length,
      itemBuilder: (context, index) {
        final item = _displayItems[index];
        final isSelected = widget.multiSelect 
            ? _controller.selectedValues.contains(item)
            : widget.value == item;

        return InkWell(
          onTap: () => _onItemSelected(item),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: isSelected 
                ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                : null,
            child: Row(
              children: [
                if (widget.multiSelect) ...[
                  // Show checkbox for multi-select
                  Checkbox(
                    value: isSelected,
                    onChanged: (_) => _onItemSelected(item),
                    activeColor: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                ] else if (widget.showCheckmark && isSelected) ...[
                  // Show checkmark only for selected item in single-select
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Icon(
                      Icons.check,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
                Expanded(child: widget.itemBuilder(item)),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onItemSelected(T item) {
    if (widget.multiSelect) {
      // Handle multi-select
      final selectedValues = List<T>.from(_controller.selectedValues);
      
      if (selectedValues.contains(item)) {
        selectedValues.remove(item);
      } else {
        selectedValues.add(item);
      }
      
      _controller.selectMultiple(selectedValues);
      
      // Trigger overlay rebuild to show updated checkboxes
      if (_overlaySetState != null) {
        _overlaySetState!(() {});
      }
    } else {
      // Handle single select
      _controller.select(item);
    }
    
    // Call the onChanged callback
    widget.onChanged(item);

    if (widget.closeOnSelect && !widget.multiSelect) {
      _hideOverlay();
    }
  }

  BoxDecoration _getDecoration() {
    if (widget.decoration != null) return widget.decoration!;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    switch (widget.style) {
      case AeroDropdownStyle.solid:
        return BoxDecoration(
          color: widget.backgroundColor ?? colorScheme.secondary,
          borderRadius: BorderRadius.circular(widget.borderRadius),
        );
      case AeroDropdownStyle.outline:
        return BoxDecoration(
          color: widget.backgroundColor ?? Colors.transparent,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(
            color: widget.borderColor ?? colorScheme.outline,
            width: 1.5,
          ),
        );
      case AeroDropdownStyle.glass:
        return BoxDecoration(
          color: (widget.backgroundColor ?? colorScheme.surface)
              .withOpacity(0.7),
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(
            color:
                (widget.borderColor ?? colorScheme.outline).withOpacity(0.3),
            width: 1,
          ),
        );
      case AeroDropdownStyle.gradient:
        return BoxDecoration(
          gradient: LinearGradient(
            colors: [
              widget.backgroundColor ?? colorScheme.primaryContainer,
              (widget.backgroundColor ?? colorScheme.primaryContainer)
                  .withOpacity(0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(widget.borderRadius),
        );
      case AeroDropdownStyle.minimal:
        return BoxDecoration(
          color: Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: widget.borderColor ?? colorScheme.outline,
              width: 1.5,
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Semantics(
      label: widget.semanticsLabel,
      child: Container(
        width: widget.width,
        height: widget.height,
        margin: widget.margin,
        child: CompositedTransformTarget(
          link: _layerLink,
          child: InkWell(
            onTap: _toggleDropdown,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: Container(
              padding: widget.padding ??
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: _getDecoration(),
              child: Row(
                children: [
                  if (widget.leading != null) ...[
                    widget.leading!,
                    const SizedBox(width: 12),
                  ],
                  if (widget.prefixIcon != null) ...[
                    widget.prefixIcon!,
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: _buildSelectedContent(colorScheme),
                  ),
                  if (widget.clearable && (widget.multiSelect 
                      ? _controller.selectedValues.isNotEmpty 
                      : widget.value != null)) ...[
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () {
                        if (widget.multiSelect) {
                          _controller.clear();
                          if (_overlaySetState != null) {
                            _overlaySetState!(() {});
                          }
                        } else {
                          widget.onChanged(null as T);
                          _controller.clear();
                        }
                        setState(() {});
                      },
                      child: Icon(
                        Icons.clear,
                        size: 20,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  if (widget.suffixIcon != null) ...[
                    const SizedBox(width: 8),
                    widget.suffixIcon!,
                  ] else ...[
                    const SizedBox(width: 8),
                    AnimatedRotation(
                      turns: _controller.isOpen ? 0.5 : 0,
                      duration: widget.animationDuration,
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  if (widget.trailing != null) ...[
                    const SizedBox(width: 12),
                    widget.trailing!,
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedContent(ColorScheme colorScheme) {
    if (widget.multiSelect) {
      // Multi-select mode
      final selectedCount = _controller.selectedValues.length;
      
      if (selectedCount > 0) {
        return Text(
          '$selectedCount item${selectedCount != 1 ? 's' : ''} selected',
          style: widget.textStyle ??
              TextStyle(
                color: colorScheme.onSurface,
              ),
        );
      }
    } else if (widget.value != null) {
      // Single select mode with value
      return widget.selectedBuilder?.call(widget.value as T) ??
          widget.itemBuilder(widget.value as T);
    }

    // No selection - show hint
    return widget.hint ??
        Text(
          widget.hintText ?? 'Select an item',
          style: widget.textStyle ??
              TextStyle(
                color: colorScheme.onSurfaceVariant,
              ),
        );
  }
}

class AeroDropdownController<T> extends ChangeNotifier {
  T? _value;
  List<T> _selectedValues = [];
  bool _isOpen = false;

  T? get value => _value;
  List<T> get selectedValues => _selectedValues;
  bool get isOpen => _isOpen;

  void open() {
    if (_isOpen) return;
    _isOpen = true;
    notifyListeners();
  }

  void close() {
    if (!_isOpen) return;
    _isOpen = false;
    notifyListeners();
  }

  void toggle() => _isOpen ? close() : open();

  void clear() {
    _value = null;
    _selectedValues.clear();
    notifyListeners();
  }

  void select(T value) {
    _value = value;
    _selectedValues = [value];
    notifyListeners();
  }

  void selectMultiple(List<T> values) {
    _selectedValues = values;
    notifyListeners();
  }
}

enum AeroDropdownStyle {
  solid,
  outline,
  glass,
  gradient,
  minimal,
}

enum AeroDropdownAnimation {
  fade,
  slide,
  scale,
  expand,
}