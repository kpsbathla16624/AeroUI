import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Sidebar menu item model
enum SidebarItemType {
  item,
  header,
}

class SidebarItem {
  final String id;
  final String title;
  final IconData? icon;

  final SidebarItemType type;

  final String? route;
  final VoidCallback? onTap;
  final bool isActive;
  final bool isVisible;

  final int? badgeCount;
  final Color? badgeColor;

  final List<SidebarItem>? children;
  final String? tooltip;

  // IS EXANDED BY DEFAULT IF IT HAS CHILDREN
  final bool initiallyExpanded;

  final bool reorderable;
final Function(int oldIndex, int newIndex)? onReorder;

  const SidebarItem({
    required this.id,
    required this.title,
    this.icon,
    this.type = SidebarItemType.item,
    this.route,
    this.onTap,
    this.isActive = false,
    this.isVisible = true,
    this.badgeCount,
    this.badgeColor,
    this.children,
    this.tooltip,  this.reorderable = false,
  this.onReorder,
    this.initiallyExpanded = false,
  });

  bool get hasChildren => children != null && children!.isNotEmpty;
  bool get isHeader => type == SidebarItemType.header;

  static SidebarItem header(String title) {
  return SidebarItem(
    id: title,
    title: title,
    type: SidebarItemType.header,
  );
}
}


/// Sidebar display modes
enum SidebarMode {
  expanded,  // Full width with text
  collapsed, // Mini width with icons only
  hidden,    // Completely hidden
}

/// Sidebar position
enum SidebarPosition { left, right }

/// Sidebar behavior on different screen sizes
enum SidebarBehavior {
  fixed,     // Always visible, pushes content
  overlay,   // Overlays content
  adaptive,  // Changes based on screen size
}

class SidebarConfig {
  final double expandedWidth;
  final double collapsedWidth;
  final Color backgroundColor;
  final Color surfaceColor;
  final Color primaryColor;
  final Color textColor;
  final Color iconColor;
  final Color dividerColor;
  final Color hoverColor;
  final Color activeColor;
  final double borderRadius;
  final Duration animationDuration;
  final bool showShadow;
  final bool enableResize;
  final double minWidth;
  final double maxWidth;

  const SidebarConfig({
    this.expandedWidth = 280.0,
    this.collapsedWidth = 80.0,
    this.backgroundColor = const Color(0xFF1A1A1A),
    this.surfaceColor = const Color(0xFF2D2D2D),
    this.primaryColor = const Color(0xFF3B82F6),
    this.textColor = const Color(0xFFFFFFFF),
    this.iconColor = const Color(0xFFBBBBBB),
    this.dividerColor = const Color(0xFF404040),
    this.hoverColor = const Color(0xFF404040),
    this.activeColor = const Color(0xFF3B82F6),
    this.borderRadius = 12.0,
    this.animationDuration = const Duration(milliseconds: 200),
    this.showShadow = true,
    this.enableResize = true,
    this.minWidth = 60.0,
    this.maxWidth = 400.0,
  });

  // Add this copyWith method
  SidebarConfig copyWith({
    double? expandedWidth,
    double? collapsedWidth,
    Color? backgroundColor,
    Color? surfaceColor,
    Color? primaryColor,
    Color? textColor,
    Color? iconColor,
    Color? dividerColor,
    Color? hoverColor,
    Color? activeColor,
    double? borderRadius,
    Duration? animationDuration,
    bool? showShadow,
    bool? enableResize,
    double? minWidth,
    double? maxWidth,
  }) {
    return SidebarConfig(
      expandedWidth: expandedWidth ?? this.expandedWidth,
      collapsedWidth: collapsedWidth ?? this.collapsedWidth,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      surfaceColor: surfaceColor ?? this.surfaceColor,
      primaryColor: primaryColor ?? this.primaryColor,
      textColor: textColor ?? this.textColor,
      iconColor: iconColor ?? this.iconColor,
      dividerColor: dividerColor ?? this.dividerColor,
      hoverColor: hoverColor ?? this.hoverColor,
      activeColor: activeColor ?? this.activeColor,
      borderRadius: borderRadius ?? this.borderRadius,
      animationDuration: animationDuration ?? this.animationDuration,
      showShadow: showShadow ?? this.showShadow,
      enableResize: enableResize ?? this.enableResize,
      minWidth: minWidth ?? this.minWidth,
      maxWidth: maxWidth ?? this.maxWidth,
    );
  }
}
/// Modern animated sidebar controller
class SidebarController extends ChangeNotifier {
  SidebarMode _mode = SidebarMode.expanded;
  double _currentWidth = 280.0;
  String? _activeItemId;
  Set<String> _expandedItems = {};
  String _searchQuery = '';

  SidebarMode get mode => _mode;
  double get currentWidth => _currentWidth;
  String? get activeItemId => _activeItemId;
  Set<String> get expandedItems => _expandedItems;
  String get searchQuery => _searchQuery;

  bool get isExpanded => _mode == SidebarMode.expanded;
  bool get isCollapsed => _mode == SidebarMode.collapsed;
  bool get isHidden => _mode == SidebarMode.hidden;

  void setMode(SidebarMode mode, {double? width}) {
    _mode = mode;
    if (width != null) _currentWidth = width;
    notifyListeners();
  }

  void toggle() {
    switch (_mode) {
      case SidebarMode.expanded:
        setMode(SidebarMode.collapsed, width: 80.0);
        break;
      case SidebarMode.collapsed:
        setMode(SidebarMode.expanded, width: 280.0);
        break;
      case SidebarMode.hidden:
        setMode(SidebarMode.expanded, width: 280.0);
        break;
    }
  }

  void expand() => setMode(SidebarMode.expanded, width: 280.0);
  void collapse() => setMode(SidebarMode.collapsed, width: 80.0);
  void hide() => setMode(SidebarMode.hidden, width: 0.0);

  void setWidth(double width) {
    //if new width is less than 100 set mode to collapsed
    if (width < 100) {
      setMode(SidebarMode.collapsed, width: 80.0);
      return;
    }
    _currentWidth = width;
    notifyListeners();
  }

  void setActiveItem(String? itemId) {
    _activeItemId = itemId;
    notifyListeners();
  }

  void toggleExpanded(String itemId) {
    if (_expandedItems.contains(itemId)) {
      _expandedItems.remove(itemId);
    } else {
      _expandedItems.add(itemId);
    }
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void reset() {
    _mode = SidebarMode.expanded;
    _currentWidth = 280.0;
    _activeItemId = null;
    _expandedItems.clear();
    _searchQuery = '';
    notifyListeners();
  }
}

/// Main sidebar widget
class ModernSidebar extends StatefulWidget {
  final List<SidebarItem> items;
  final SidebarController? controller;
  final SidebarConfig config;
  final SidebarPosition position;
  
  final Widget? header;
  final Widget? footer;
  final bool showSearch;
  final String searchHint;
  final Function(SidebarItem)? onItemTapped;
  final Function(SidebarMode)? onModeChanged;
  final Function(double)? onWidthChanged;
  final double breakpoint;
  final bool autoCollapse;
  // custom toggle button
  final Widget? toggleButton;
  final bool showToggleButton;

  // show border on items 
  final bool showItemBorder;
  final bool showItemIconsOnExpanded;

  const ModernSidebar({
    Key? key,
    required this.items,
    this.controller,
    this.config = const SidebarConfig(),
    this.position = SidebarPosition.left,
    this.header,
    this.footer,
    this.showSearch = false,
    this.searchHint = 'Search...',
    this.onItemTapped,
    this.onModeChanged,
    this.onWidthChanged,
    this.breakpoint = 768.0,
    this.toggleButton,
    this.showToggleButton = true,
    this.showItemBorder = false,
    this.showItemIconsOnExpanded = true,
    this.autoCollapse = true,
  }) : super(key: key);

  @override
  State<ModernSidebar> createState() => _ModernSidebarState();
}

class _ModernSidebarState extends State<ModernSidebar>
    with TickerProviderStateMixin {
  late SidebarController _controller;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late AnimationController _hoverController;
  late TextEditingController _searchController;

  bool _isResizing = false;
  double _resizeStartX = 0;
  double _resizeStartWidth = 0;
  String? _hoveredItemId;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? SidebarController();

_initializeInitiallyExpanded(widget.items);
    _searchController = TextEditingController();

    _animationController = AnimationController(
      duration: widget.config.animationDuration,
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    ));

    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _controller.addListener(_onControllerChanged);
    _searchController.addListener(_onSearchChanged);
  

    if (_controller.isExpanded) {
      _animationController.value = 1.0;
    }
   
  }

  void _initializeInitiallyExpanded(List<SidebarItem> items) {
  for (final item in items) {

    if (item.initiallyExpanded) {
      _controller.expandedItems.add(item.id);
    }

    if (item.hasChildren) {
      _initializeInitiallyExpanded(item.children!);
    }
  }
}

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _searchController.removeListener(_onSearchChanged);
    _animationController.dispose();
    _hoverController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (_controller.isExpanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    widget.onModeChanged?.call(_controller.mode);
    widget.onWidthChanged?.call(_controller.currentWidth);
    setState(() {});
  }

  void _onSearchChanged() {
    _controller.setSearchQuery(_searchController.text);
  }



  List<SidebarItem> _filterItems(List<SidebarItem> items) {
    if (_controller.searchQuery.isEmpty) return items;
    
    List<SidebarItem> filtered = [];
    for (final item in items) {
      if (!item.isVisible) continue;
      
      if (item.title.toLowerCase().contains(_controller.searchQuery.toLowerCase())) {
        filtered.add(item);
      } else if (item.hasChildren) {
        final filteredChildren = _filterItems(item.children!);
        if (filteredChildren.isNotEmpty) {
          filtered.add(SidebarItem(
            id: item.id,
            title: item.title,
            icon: item.icon,
            route: item.route,
            onTap: item.onTap,
            isActive: item.isActive,
            children: filteredChildren,
            tooltip: item.tooltip,
          ));
        }
      }
    }
    return filtered;
  }

  Widget _buildToggleButton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        elevation: widget.config.showShadow ? 4 : 0,
        borderRadius: BorderRadius.circular(widget.config.borderRadius),
        color: widget.config.surfaceColor,
        child: InkWell(
          borderRadius: BorderRadius.circular(widget.config.borderRadius),
          onTap: () {
            HapticFeedback.lightImpact();
            _controller.toggle();
            setState(() {
              
            });
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            child: AnimatedRotation(
              turns: _controller.isCollapsed ? 0.5 : 0.0,
              duration: widget.config.animationDuration,
              child: Icon(
                Icons.menu,
                color: widget.config.iconColor,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    if (!widget.showSearch || _controller.isCollapsed) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.config.surfaceColor,
        borderRadius: BorderRadius.circular(widget.config.borderRadius),
        border: Border.all(color: widget.config.dividerColor),
      ),
      child: TextField(
        controller: _searchController,
        style: TextStyle(color: widget.config.textColor),
        decoration: InputDecoration(
          hintText: widget.searchHint,
          hintStyle: TextStyle(color: widget.config.textColor.withOpacity(0.6)),
          prefixIcon: Icon(
            Icons.search,
            color: widget.config.iconColor,
            size: 20,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: widget.config.iconColor,
                    size: 18,
                  ),
                  onPressed: () => _searchController.clear(),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

Widget _buildMenuItem(SidebarItem item, {int level = 0, int? index , bool isReorderable = false}){
    if (!item.isVisible) return const SizedBox.shrink();

    if (item.isHeader ) {
  return Padding(
    padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
    child: Text(
      item.title.toUpperCase(),
      style: TextStyle(
        color: widget.config.iconColor.withOpacity(0.6),
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
      ),
    ),
  );
}

    final isExpanded = _controller.expandedItems.contains(item.id);
    final isActive = _controller.activeItemId == item.id || item.isActive;
    final isHovered = _hoveredItemId == item.id;

    Widget content = MouseRegion(
      onEnter: (_) => setState(() => _hoveredItemId = item.id),
      onExit: (_) => setState(() => _hoveredItemId = null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 2,
        ).copyWith(left: 8 + (level * 16.0)),
        decoration: BoxDecoration(
          color: isActive
              ? widget.config.activeColor.withOpacity(0.1)
              : isHovered
                  ? widget.config.hoverColor.withOpacity(0.5)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(widget.config.borderRadius),
          border: widget.showItemBorder ? ( isActive
              ? Border.all(color: widget.config.activeColor.withOpacity(0.3))
              : null ): null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(widget.config.borderRadius),
            onTap: () {
              HapticFeedback.selectionClick();
              if (item.hasChildren) {
                _controller.toggleExpanded(item.id);
              } else {
                _controller.setActiveItem(item.id);
                item.onTap?.call();
                widget.onItemTapped?.call(item);
              }
            },
            child: Container(
              constraints: const BoxConstraints(minHeight: 40),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: _controller.isCollapsed
                  ? _buildCollapsedItem(item, isActive)
                  : _buildExpandedItem(item, isActive, isExpanded , index: index, isReorderable: isReorderable),
            ),
          ),
        ),
      ),
    );

    if (_controller.isCollapsed && item.tooltip != null) {
      content = Tooltip(
        message: item.tooltip!,
        child: content,
      );
    }

    return Column(
      children: [
        content,
       if (item.hasChildren && isExpanded && !_controller.isCollapsed)
  if (item.reorderable)
    _buildReorderableChildren(item, level)
  else
    ...item.children!.map(
      (child) => _buildMenuItem(child, level: level + 1, isReorderable: child.reorderable),
    ),
      ],
    );
  }
Widget _buildReorderableChildren(SidebarItem parent, int level) {
  final children = parent.children!;

  return ReorderableListView(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
 buildDefaultDragHandles: false, 
    onReorder: (oldIndex, newIndex) {

      /// Fix Flutter's index behavior internally
      if (newIndex > oldIndex) {
        newIndex--;
      }

      parent.onReorder?.call(oldIndex, newIndex);
    },

     children: List.generate(children.length, (index) {
      final child = children[index];

      return Container(
        key: ValueKey(child.id),   // VERY IMPORTANT
        child: _buildMenuItem(child, level: level + 1 , index: index , isReorderable: true),
      );
    }),
  );
}

  Widget _buildCollapsedItem(SidebarItem item, bool isActive) {
    return Stack(
      children: [
        Center(
          child: Icon(
            item.icon,
            color: isActive ? widget.config.activeColor : widget.config.iconColor,
            size: 22,
          ),
        ),
        if (item.badgeCount != null && item.badgeCount! > 0)
          Positioned(
            top: -2,
            right: -2,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: item.badgeColor ?? Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                '${item.badgeCount! > 9 ? '9+' : item.badgeCount}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildExpandedItem(SidebarItem item,  bool isActive, bool isExpanded , {int? index , bool isReorderable = false}) {
    return Row(
      children: [
      if (widget.showItemIconsOnExpanded) ...[
  isReorderable && index != null
      ? ReorderableDragStartListener(
          index: index,
          child: Icon(
            Icons.drag_indicator,
            color: widget.config.iconColor,
            size: 20,
          ),
        )
      : Icon(
          item.icon,
          color: isActive
              ? widget.config.activeColor
              : widget.config.iconColor,
          size: 20,
        ),
  const SizedBox(width: 12),
],
        Expanded(
          child: Text(
            item.title,
            style: TextStyle(
              color: isActive ? widget.config.activeColor : widget.config.textColor,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (item.badgeCount != null && item.badgeCount! > 0) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: item.badgeColor ?? Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${item.badgeCount! > 99 ? '99+' : item.badgeCount}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
        if (item.hasChildren) ...[
          const SizedBox(width: 8),
          AnimatedRotation(
            turns: isExpanded ? 0.5 : 0.0,
            duration: widget.config.animationDuration,
            child: Icon(
              Icons.expand_more,
              color: widget.config.iconColor,
              size: 18,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildResizeHandle() {
    if (!widget.config.enableResize || _controller.isHidden || _controller.isCollapsed) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: 0,
      bottom: 0,
      right: widget.position == SidebarPosition.left ? 0 : null,
      left: widget.position == SidebarPosition.right ? 0 : null,
      child: GestureDetector(
        onPanStart: (details) {
          _isResizing = true;
          _resizeStartX = details.globalPosition.dx;
          _resizeStartWidth = _controller.currentWidth;
        },
        onPanUpdate: (details) {
          if (!_isResizing) return;
          
          double delta = details.globalPosition.dx - _resizeStartX;
          if (widget.position == SidebarPosition.right) delta = -delta;
          
          double newWidth = (_resizeStartWidth + delta)
              .clamp(widget.config.minWidth, widget.config.maxWidth);
          
          _controller.setWidth(newWidth);
        },
        onPanEnd: (details) {
          _isResizing = false;
        },
        child: MouseRegion(
          cursor: SystemMouseCursors.resizeColumn,
          child: Container(
            width: 6,
            color: Colors.transparent,
            child: Center(
              child: Container(
                width: 2,
                decoration: BoxDecoration(
                  color: widget.config.dividerColor,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarContent() {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return AnimatedContainer(
          duration: widget.config.animationDuration,
          
          width: _controller.currentWidth,
          decoration: BoxDecoration(
            color: widget.config.backgroundColor,
            borderRadius: widget.position == SidebarPosition.left
                ? BorderRadius.only(
                    topRight: Radius.circular(widget.config.borderRadius),
                    bottomRight: Radius.circular(widget.config.borderRadius),
                  )
                : BorderRadius.only(
                    topLeft: Radius.circular(widget.config.borderRadius),
                    bottomLeft: Radius.circular(widget.config.borderRadius),
                  ),
            boxShadow: widget.config.showShadow
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(widget.position == SidebarPosition.left ? 2 : -2, 0),
                    ),
                  ]
                : null,
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
              

                    if(_controller.isExpanded) // if expanded show header and toggle button in a row , else in column
                 Row(
                  children: [


                    if (widget.position == SidebarPosition.right && widget.showToggleButton && widget.header != null)  Align(
                     alignment: _controller.isExpanded ? widget.position == SidebarPosition.left ? Alignment.centerRight : Alignment.centerLeft : Alignment.topCenter,
                    child: _buildToggleButton()),


                    if (widget.header != null) Expanded(child: widget.header!),


                    if (widget.position == SidebarPosition.left && widget.showToggleButton && widget.header != null)  Align(
                     alignment: _controller.isExpanded ? widget.position == SidebarPosition.left ? Alignment.centerRight : Alignment.centerLeft : Alignment.topCenter,
                    child: _buildToggleButton()),



                  ],
                 ),
                 if(!_controller.isExpanded) // if expanded show header and toggle button in a row , else in column
                 Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.showToggleButton )  _buildToggleButton(),
                    if (widget.header != null) widget.header!,
                  ],
                  ),
                  _buildSearchBar(),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      children: _filterItems(widget.items)
                          .map((item) => _buildMenuItem(item))
                          .toList(),
                    ),
                  ),
                  if (widget.footer != null) widget.footer!,
                ],
              ),
             
              _buildResizeHandle(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBackdrop() {
    return GestureDetector(
      onTap: () => _controller.collapse(),
      child: Container(
        color: Colors.black.withOpacity(0.5),
      ),
    );
  }
  
  double? _lastWidth;


  @override
  Widget build(BuildContext context) {
 final screenWidth = MediaQuery.of(context).size.width;

  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!mounted) return;
    if (!widget.autoCollapse) return;
    // Only trigger collapse/expand if width crosses breakpoint AND width actually changed
    if (_lastWidth != screenWidth) {
      _lastWidth = screenWidth;

      if (screenWidth < widget.breakpoint && !_controller.isCollapsed) {
        _controller.collapse();
      } else if (screenWidth >= widget.breakpoint && !_controller.isExpanded) {
        _controller.expand();
      }
    }
  });

    if (widget.showToggleButton && _controller.isHidden) {
      return Align(
        alignment: Alignment.topLeft,
        child: widget.toggleButton ?? _buildToggleButton());
    }



      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.position == SidebarPosition.left) _buildSidebarContent(),
          if (widget.position == SidebarPosition.right) _buildSidebarContent(),
        ],
      );
    }
  }


/// Predefined sidebar themes
class SidebarThemes {
  static const SidebarConfig darkTheme = SidebarConfig(
    backgroundColor:  Colors.black,
    surfaceColor: Color(0xFF2D2D2D),
    primaryColor: Color(0xFF3B82F6),
    textColor: Color(0xFFFFFFFF),
    iconColor: Color(0xFFBBBBBB),
    dividerColor: Color.fromARGB(255, 34, 34, 34),
    hoverColor: Color(0xFF404040),
    activeColor: Color(0xFF3B82F6),

  );

  static const SidebarConfig lightTheme = SidebarConfig(
    backgroundColor: Color(0xFFFFFFFF),
    surfaceColor: Color(0xFFF8F9FA),
    primaryColor: Color(0xFF3B82F6),
    textColor: Color(0xFF1F2937),
    iconColor: Color(0xFF6B7280),
    dividerColor: Color(0xFFE5E7EB),
    hoverColor: Color(0xFFF3F4F6),
    activeColor: Color(0xFF3B82F6),
  );

  static const SidebarConfig glassMorphismTheme = SidebarConfig(
    backgroundColor: Color(0x40000000),
    surfaceColor: Color(0x60FFFFFF),
    primaryColor: Color(0xFF00D4AA),
    textColor: Color(0xFFFFFFFF),
    iconColor: Color(0xFFCCCCCC),
    dividerColor: Color(0x30FFFFFF),
    hoverColor: Color(0x30FFFFFF),
    activeColor: Color(0xFF00D4AA),
    borderRadius: 16.0,
  );


}

/// Helper class for creating common sidebar items
class SidebarItems {
  static SidebarItem home({
    bool isActive = false,
    VoidCallback? onTap,
  }) =>
      SidebarItem(
        id: 'home',
        title: 'Home',
        icon: Icons.home_outlined,
        isActive: isActive,
        onTap: onTap,
        tooltip: 'Home',
      );

  static SidebarItem dashboard({
    bool isActive = false,
    VoidCallback? onTap,
  }) =>
      SidebarItem(
        id: 'dashboard',
        title: 'Dashboard',
        icon: Icons.dashboard_outlined,
        isActive: isActive,
        onTap: onTap,
        tooltip: 'Dashboard',
      );

  static SidebarItem analytics({
    bool isActive = false,
    VoidCallback? onTap,
    int? badgeCount,
  }) =>
      SidebarItem(
        id: 'analytics',
        title: 'Analytics',
        icon: Icons.analytics_outlined,
        isActive: isActive,
        onTap: onTap,
        badgeCount: badgeCount,
        tooltip: 'Analytics',
      );

  static SidebarItem settings({
    bool isActive = false,
    VoidCallback? onTap,
    List<SidebarItem>? children,
  }) =>
      SidebarItem(
        id: 'settings',
        title: 'Settings',
        icon: Icons.settings_outlined,
        isActive: isActive,
        onTap: onTap,
        children: children,
        tooltip: 'Settings',
      );

  static SidebarItem profile({
    bool isActive = false,
    VoidCallback? onTap,
  }) =>
      SidebarItem(
        id: 'profile',
        title: 'Profile',
        icon: Icons.person_outline,
        isActive: isActive,
        onTap: onTap,
        tooltip: 'Profile',
      );

  static SidebarItem notifications({
    bool isActive = false,
    VoidCallback? onTap,
    int? badgeCount,
  }) =>
      SidebarItem(
        id: 'notifications',
        title: 'Notifications',
        icon: Icons.notifications_outlined,
        isActive: isActive,
        onTap: onTap,
        badgeCount: badgeCount,
        badgeColor: Colors.red,
        tooltip: 'Notifications',
      );

  static SidebarItem messages({
    bool isActive = false,
    VoidCallback? onTap,
    int? badgeCount,
  }) =>
      SidebarItem(
        id: 'messages',
        title: 'Messages',
        icon: Icons.message_outlined,
        isActive: isActive,
        onTap: onTap,
        badgeCount: badgeCount,
        badgeColor: Colors.green,
        tooltip: 'Messages',
      );
}

/// Usage example widget
class SidebarDemo extends StatefulWidget {
  const SidebarDemo({Key? key}) : super(key: key);

  @override
  State<SidebarDemo> createState() => _SidebarDemoState();
}

class _SidebarDemoState extends State<SidebarDemo> {
  late SidebarController _controller;
  String _selectedPage = 'Home';
  SidebarMode _currentMode = SidebarMode.expanded;

  @override
  void initState() {
    super.initState();
    _controller = SidebarController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: Row(
        children: [

           Expanded(
        child: Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF2D2D2D)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: const Color(0xFF2D2D2D)),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      _selectedPage,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () {
                        _controller.toggle();
                        setState(() {
                          
                        });
                      },
                      icon: const Icon(Icons.menu),
                      label: const Text('Toggle Sidebar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.dashboard_outlined,
                        size: 64,
                        color: Colors.grey.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Welcome to $_selectedPage',
                        style: TextStyle(
                          color: Colors.grey.withOpacity(0.8),
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This is the $_selectedPage content area.',
                        style: TextStyle(
                          color: Colors.grey.withOpacity(0.6),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () => _controller.expand(),
                            child: const Text('Expand'),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: () => _controller.collapse(),
                            child: const Text('Collapse'),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: () => _controller.hide(),
                            child: const Text('Hide'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    
          ModernSidebar(
            onModeChanged: (mode) {
              setState(() {
                _currentMode = mode;
              });

            },
            
            controller: _controller,
            config: SidebarThemes.darkTheme,
            position: SidebarPosition.right,
          
            showSearch: true,
            searchHint: 'Search menu...',
            header: Container(
              height: 80,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.flutter_dash, color: Colors.white),
                  ),
                if(_currentMode == SidebarMode.expanded) ...[
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Flutter App',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'v1.0.0',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                ]
                ],
              ),
            ) ,
            items: [
              SidebarItems.home(
                isActive: _selectedPage == 'Home',
                onTap: () => setState(() => _selectedPage = 'Home'),
              ),
              SidebarItems.dashboard(
                isActive: _selectedPage == 'Dashboard',
                onTap: () => setState(() => _selectedPage = 'Dashboard'),
              ),
              SidebarItems.analytics(
                isActive: _selectedPage == 'Analytics',
                onTap: () => setState(() => _selectedPage = 'Analytics'),
                badgeCount: 5,
              ),
              SidebarItems.messages(
                isActive: _selectedPage == 'Messages',
                onTap: () => setState(() => _selectedPage = 'Messages'),
                badgeCount: 12,
              ),
              SidebarItem(
                id: 'projects',
                title: 'Projects',
                icon: Icons.folder_outlined,
                isActive: _selectedPage.startsWith('Projects'),
                tooltip: 'Projects',
                children: [
                 SidebarItem(
                id: 'active-projects',
                title: 'Active Projects',
                icon: Icons.work_outline,
                isActive: _selectedPage == 'Active Projects',
                onTap: () => setState(() => _selectedPage = 'Active Projects'),
              ),
              SidebarItem(
                id: 'archived-projects',
                title: 'Archived',
                icon: Icons.archive_outlined,
                isActive: _selectedPage == 'Archived',
                onTap: () => setState(() => _selectedPage = 'Archived'),
              ),
            ],
          ),
          SidebarItems.notifications(
            isActive: _selectedPage == 'Notifications',
            onTap: () => setState(() => _selectedPage = 'Notifications'),
            badgeCount: 3,
          ),
          SidebarItems.settings(
            isActive: _selectedPage.startsWith('Settings'),
            children: [
              SidebarItem(
                id: 'general-settings',
                title: 'General',
                icon: Icons.tune,
                isActive: _selectedPage == 'General Settings',
                onTap: () => setState(() => _selectedPage = 'General Settings'),
              ),
              SidebarItem(
                id: 'security-settings',
                title: 'Security',
                icon: Icons.security,
                isActive: _selectedPage == 'Security Settings',
                onTap: () => setState(() => _selectedPage = 'Security Settings'),
              ),
            ],
          ),
          SidebarItems.profile(
            isActive: _selectedPage == 'Profile',
            onTap: () => setState(() => _selectedPage = 'Profile'),
          ),
        ],
        footer: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.blue,
                child: const Text('JD', style: TextStyle(fontSize: 12)),
              ),
               if(_currentMode == SidebarMode.expanded) ...[
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'John Doe',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'john@example.com',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.logout, size: 18),
                  color: Colors.grey,
                  onPressed: () {},
                ),
              ],
            ],
          ),
        ),
        onItemTapped: (item) {
          print('Tapped: ${item.title}');
        },
      ),
     ],
  ),
);
  }
}


/// Advanced sidebar with custom animations
class AdvancedSidebar extends StatefulWidget {
  final List<SidebarItem> items;
  final SidebarController? controller;
  final SidebarConfig config;
  final Widget? logo;
  final String? title;
  final String? subtitle;
  final Widget? userWidget;
  final bool showAnimatedBackground;
  final bool enableGestures;

  const AdvancedSidebar({
    Key? key,
    required this.items,
    this.controller,
    this.config = const SidebarConfig(),
    this.logo,
    this.title,
    this.subtitle,
    this.userWidget,
    this.showAnimatedBackground = false,
    this.enableGestures = true,
  }) : super(key: key);

  @override
  State<AdvancedSidebar> createState() => _AdvancedSidebarState();
}

class _AdvancedSidebarState extends State<AdvancedSidebar>
    with TickerProviderStateMixin {
  late SidebarController _controller;
  late AnimationController _backgroundAnimationController;
  late Animation<double> _backgroundAnimation;
  late List<AnimationController> _itemAnimationControllers;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? SidebarController();

    // Background animation
    _backgroundAnimationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );
    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_backgroundAnimationController);

    // Item animations
    _itemAnimationControllers = List.generate(
      widget.items.length,
      (index) => AnimationController(
        duration: Duration(milliseconds: 300 + (index * 100)),
        vsync: this,
      ),
    );

    if (widget.showAnimatedBackground) {
      _backgroundAnimationController.repeat();
    }

    // Stagger item animations
    _animateItemsIn();
  }

  @override
  void dispose() {
    _backgroundAnimationController.dispose();
    for (final controller in _itemAnimationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _animateItemsIn() {
    for (int i = 0; i < _itemAnimationControllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 50), () {
        if (mounted) {
          _itemAnimationControllers[i].forward();
        }
      });
    }
  }

  Widget _buildAnimatedBackground() {
    if (!widget.showAnimatedBackground) return const SizedBox.shrink();

    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _backgroundAnimation,
        builder: (context, child) {
          return CustomPaint(
            painter: AnimatedBackgroundPainter(
              progress: _backgroundAnimation.value,
              color: widget.config.primaryColor,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ModernSidebar(
      items: widget.items,
      controller: _controller,
      config: widget.config,
      header: widget.logo != null || widget.title != null
          ? Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (widget.logo != null) widget.logo!,
                  if (widget.title != null && !_controller.isCollapsed) ...[
                    if (widget.logo != null) const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title!,
                            style: TextStyle(
                              color: widget.config.textColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (widget.subtitle != null)
                            Text(
                              widget.subtitle!,
                              style: TextStyle(
                                color: widget.config.textColor.withOpacity(0.7),
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            )
          : null,
      footer: widget.userWidget,
      showSearch: true,
    );
  }
}

/// Custom painter for animated background
class AnimatedBackgroundPainter extends CustomPainter {
  final double progress;
  final Color color;

  AnimatedBackgroundPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.8;

    // Animated circles
    for (int i = 0; i < 3; i++) {
      final animatedRadius = radius * (progress + i * 0.3) % 1.0;
      final opacity = (1.0 - (progress + i * 0.3) % 1.0) * 0.1;

      canvas.drawCircle(
        center,
        animatedRadius,
        paint..color = color.withOpacity(opacity),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Responsive sidebar wrapper
class ResponsiveSidebarLayout extends StatelessWidget {
  final Widget sidebar;
  final Widget body;
  final double breakpoint;

  const ResponsiveSidebarLayout({
    Key? key,
    required this.sidebar,
    required this.body,
    this.breakpoint = 768.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= breakpoint;

    return Scaffold(
      body: isDesktop
          ? Row(
              children: [
                sidebar,
                Expanded(child: body),
              ],
            )
          : Stack(
              children: [
                body,
                sidebar,
              ],
            ),
    );
  }
}

/// Sidebar with custom themes and presets
class ThemedSidebar extends StatelessWidget {
  final List<SidebarItem> items;
  final SidebarController? controller;
  final String theme;
  final Widget? header;
  final Widget? footer;

  const ThemedSidebar({
    Key? key,
    required this.items,
    this.controller,
    this.theme = 'dark',
    this.header,
    this.footer,
  }) : super(key: key);

  SidebarConfig _getThemeConfig() {
    switch (theme.toLowerCase()) {
      case 'light':
        return SidebarThemes.lightTheme;
      case 'glass':
        return SidebarThemes.glassMorphismTheme;
      case 'dark':
      default:
        return SidebarThemes.darkTheme;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModernSidebar(
      items: items,
      controller: controller,
      config: _getThemeConfig(),
      header: header,
      footer: footer,
      showSearch: true,
    );
  }
}

/// Sidebar layout builder for common patterns
class SidebarLayoutBuilder {
  static List<SidebarItem> createAdminLayout({
    required Function(String) onNavigate,
    String? activeRoute,
  }) {
    return [
      SidebarItems.dashboard(
        isActive: activeRoute == 'dashboard',
        onTap: () => onNavigate('dashboard'),
      ),
      SidebarItems.analytics(
        isActive: activeRoute == 'analytics',
        onTap: () => onNavigate('analytics'),
        badgeCount: 12,
      ),
      SidebarItem(
        id: 'users',
        title: 'Users',
        icon: Icons.people_outline,
        isActive: activeRoute == 'users',
        onTap: () => onNavigate('users'),
        tooltip: 'User Management',
      ),
      SidebarItem(
        id: 'content',
        title: 'Content',
        icon: Icons.article_outlined,
        tooltip: 'Content Management',
        children: [
          SidebarItem(
            id: 'posts',
            title: 'Posts',
            icon: Icons.post_add_outlined,
            isActive: activeRoute == 'posts',
            onTap: () => onNavigate('posts'),
          ),
          SidebarItem(
            id: 'pages',
            title: 'Pages',
            icon: Icons.web,
            isActive: activeRoute == 'pages',
            onTap: () => onNavigate('pages'),
          ),
        ],
      ),
      SidebarItems.settings(
        isActive: activeRoute?.startsWith('settings') ?? false,
        children: [
          SidebarItem(
            id: 'general',
            title: 'General',
            icon: Icons.tune,
            isActive: activeRoute == 'settings/general',
            onTap: () => onNavigate('settings/general'),
          ),
          SidebarItem(
            id: 'security',
            title: 'Security',
            icon: Icons.security,
            isActive: activeRoute == 'settings/security',
            onTap: () => onNavigate('settings/security'),
          ),
        ],
      ),
    ];
  }

  static List<SidebarItem> createAppLayout({
    required Function(String) onNavigate,
    String? activeRoute,
    int? notificationCount,
    int? messageCount,
  }) {
    return [
      SidebarItems.home(
        isActive: activeRoute == 'home',
        onTap: () => onNavigate('home'),
      ),
      SidebarItem(
        id: 'workspace',
        title: 'Workspace',
        icon: Icons.work_outline,
        tooltip: 'Workspace',
        children: [
          SidebarItem(
            id: 'projects',
            title: 'Projects',
            icon: Icons.folder_outlined,
            isActive: activeRoute == 'projects',
            onTap: () => onNavigate('projects'),
          ),
          SidebarItem(
            id: 'tasks',
            title: 'Tasks',
            icon: Icons.task_alt_outlined,
            isActive: activeRoute == 'tasks',
            onTap: () => onNavigate('tasks'),
            badgeCount: 5,
            badgeColor: Colors.orange,
          ),
        ],
      ),
      SidebarItems.messages(
        isActive: activeRoute == 'messages',
        onTap: () => onNavigate('messages'),
        badgeCount: messageCount,
      ),
      SidebarItems.notifications(
        isActive: activeRoute == 'notifications',
        onTap: () => onNavigate('notifications'),
        badgeCount: notificationCount,
      ),
    ];
  }
}