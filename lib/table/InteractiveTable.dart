import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Configuration for a table column
///
/// [T] is the type of data being displayed in the table
class TableColumnConfig<T> {
  /// Unique identifier for the column
  final String id;

  /// Display title for the column header
  final String title;

  /// Flex value for column width distribution (default: 1)
  final int flex;

  /// Whether this column can be sorted (default: true)
  final bool sortable;

  /// Whether this column is visible (default: true)
  final bool visible;

  /// Widget builder function for the column content
  final Widget Function(T item) builder;

  /// Custom comparator function for sorting
  final int Function(T a, T b)? sortComparator;

  /// Text alignment for the column content
  final TextAlign textAlign;

  /// Whether this column should be pinned to the left
  final bool pinned;

  /// Custom header widget builder (overrides title if provided)
  final Widget Function()? headerBuilder;

  /// Tooltip text for the column header
  final String? tooltip;

  const TableColumnConfig({
    required this.id,
    required this.title,
    required this.builder,
    this.flex = 1,
    this.sortable = true,
    this.visible = true,
    this.sortComparator,
    this.textAlign = TextAlign.start,
    this.pinned = false,
    this.headerBuilder,
    this.tooltip,
  });
}

/// Selection mode for the table
enum SelectionMode {
  /// No selection allowed
  none,

  /// Single row selection
  single,

  /// Multiple row selection
  multiple,
}

/// Configuration for table pagination
class PaginationConfig<T> {
  /// Number of items per page
  final int itemsPerPage;

  /// Available page size options
  final List<int> pageSizeOptions;

  /// Whether to show page size selector
  final bool showPageSizeSelector;

  /// Whether to show page info (e.g., "1-10 of 100")
  final bool showPageInfo;

  /// Total number of items (for server-side pagination)
  final int? totalItems;

  /// Callback for fetching data for a specific page
  /// Parameters: pageNumber (0-based), pageSize
  /// Returns: Future<List<T>> - the data for that page
 final Future<List<T>> Function(int pageNumber, int pageSize, String? searchQuery)? onPageChanged;

  /// Whether to use server-side pagination
  final bool serverSide;
  /// Debounce duration for search queries (server-side only)
    final Duration searchDebounce;

  const PaginationConfig({
    this.itemsPerPage = 10,
    this.pageSizeOptions = const [5, 10, 25, 50, 100],
    this.showPageSizeSelector = true,
    this.showPageInfo = true,
    this.totalItems,
    this.onPageChanged,
    this.serverSide = false,
    this.searchDebounce = const Duration(milliseconds: 300),
  });
}

/// Modern futuristic interactive table widget
class InteractiveTable<T> extends StatefulWidget {
  /// List of items to display in the table
  final List<T> items;

  /// Column configurations for the table
  final List<TableColumnConfig<T>> columns;

  /// Callback when a row is tapped
  final Function(T item)? onItemTap;

  /// Callback when a row is double-tapped
  final Function(T item)? onItemDoubleTap;

  /// Callback when row selection changes
  final Function(List<T> selectedItems)? onSelectionChanged;

  /// Builder for leading widget in each row
  final Widget Function(T item)? leadingBuilder;

  /// Builder for trailing widget in each row
  final Widget Function(T item)? trailingBuilder;
  final double trailingColumnWidth;

  /// Builder for expanded content when row is expanded
  final Widget Function(T item)? expandedBuilder;

  /// Builder for custom row content (overrides column builders)
  final Widget Function(T item, int index, bool isSelected, bool isHovered)?
  rowBuilder;

  /// Selection mode for the table
  final SelectionMode selectionMode;

  /// Initially selected items
  final List<T> initialSelection;

  /// Pagination configuration
  final PaginationConfig<T>? paginationConfig;

  /// Whether the table is in loading state
  final bool isLoading;

  /// Loading widget to display
  final Widget? loadingWidget;

  /// Search query to filter items
  final String? searchQuery;

  /// Custom filter function
  final bool Function(T item, String query)? searchFilter;

  /// Whether to show search bar
  final bool showSearch;

  /// Search bar placeholder text
  final String searchPlaceholder;

  /// Whether rows can be expanded
  final bool expandableRows;

  /// Initially expanded items
  final Set<T> initiallyExpanded;

  // Modern futuristic styling properties
  final Color primaryColor;
  final Color surfaceColor;
  final Color backgroundColor;
  final Color onSurfaceColor;
  final Color onBackgroundColor;
  final Color accentColor;
  final Color successColor;
  final Color warningColor;
  final Color errorColor;
  final Widget? emptyStateWidget;
  final String? emptyStateMessage;
  final IconData? emptyStateIcon;
  final bool enableGlow;
  final bool enableNeumorphism;
  final bool enableGlassmorphism;

  /// Table height (if null, takes available space)
  final double? height;

  /// Whether to show column borders
  final bool showColumnBorders;

  /// Whether to enable row hover effects
  final bool enableHover;

  /// Whether to show row numbers
  final bool showRowNumbers;

  /// Custom row number builder
  final Widget Function(int index)? rowNumberBuilder;

  const InteractiveTable({
    Key? key,
    required this.items,
    required this.columns,
    this.onItemTap,
    this.onItemDoubleTap,
    this.onSelectionChanged,
    this.leadingBuilder,
    this.trailingBuilder,
    this.trailingColumnWidth = 120.0,
    this.expandedBuilder,
    this.rowBuilder,
    this.selectionMode = SelectionMode.none,
    this.initialSelection = const [],
    this.paginationConfig,
    this.isLoading = false,
    this.loadingWidget,
    this.searchQuery,
    this.searchFilter,
    this.showSearch = false,
    this.searchPlaceholder = 'Search...',
    this.expandableRows = false,
    this.initiallyExpanded = const {},
    this.primaryColor = const Color(0xFFFFFFFF), // White (main highlight)
    this.surfaceColor = const Color(0xFF1E1E1E), // Dark Gray Surface
    this.backgroundColor = const Color(0xFF121212), // Near Black Background
    this.onSurfaceColor = const Color(0xFFE5E5E5), // Light Gray Text
    this.onBackgroundColor = const Color(
      0xFF9CA3AF,
    ), // Medium Gray for secondary text
    this.accentColor = const Color(0xFFFFFFFF), // White (same as primary)
    this.successColor = const Color(0xFF22C55E), // (optional) Green feedback
    this.warningColor = const Color(0xFFFACC15), // (optional) Yellow feedback
    this.errorColor = const Color(0xFFEF4444), // (optional) Red feedback
    this.emptyStateWidget,
    this.emptyStateMessage = 'No data available',
    this.emptyStateIcon = Icons.data_array,
    this.enableGlow = false,
    this.enableNeumorphism = false,
    this.enableGlassmorphism = true,
    this.height,
    this.showColumnBorders = false,
    this.enableHover = true,
    this.showRowNumbers = false,
    this.rowNumberBuilder,
  }) : super(key: key);

  @override
  State<InteractiveTable<T>> createState() => _InteractiveTableState<T>();
}

class _InteractiveTableState<T> extends State<InteractiveTable<T>>
    with TickerProviderStateMixin {
  // Existing state variables
  int? hoveredIndex;
  String? sortColumn;
  bool isAscending = true;
  List<T> sortedItems = [];
  List<T> filteredItems = [];
  Set<T> selectedItems = <T>{};
  Set<T> expandedItems = <T>{};
  late TextEditingController searchController;

  // Animation controllers for modern effects
  late AnimationController _glowController;
  late AnimationController _pulseController;
  late Animation<double> _glowAnimation;
  late Animation<double> _pulseAnimation;

  // Pagination state
  int currentPage = 1;
  int itemsPerPage = 10;
  List<T> currentPageData = [];
  bool isLoadingPage = false;
  int? totalServerItems;
  String? lastError;

  Timer ? _searchDebounceTimer;
  String _currentSearchQuery = '';

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController(text: widget.searchQuery);
    selectedItems = Set.from(widget.initialSelection);
    expandedItems = Set.from(widget.initiallyExpanded);
      _currentSearchQuery = widget.searchQuery ?? '';
    // Initialize animation controllers
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.elasticOut),
    );

    if (widget.enableGlow) {
      _glowController.repeat(reverse: true);
    }

    if (widget.paginationConfig != null) {
      itemsPerPage = widget.paginationConfig!.itemsPerPage;
      totalServerItems = widget.paginationConfig!.totalItems;
    }

    if (widget.paginationConfig?.serverSide == true) {
      _loadServerPage();
    } else {
      _updateItems();
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    _glowController.dispose();
    _pulseController.dispose();
    _searchDebounceTimer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(InteractiveTable<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.items != oldWidget.items ||
        widget.searchQuery != oldWidget.searchQuery) {
      if (widget.paginationConfig?.serverSide != true) {
        _updateItems();
         } else if (widget.searchQuery != oldWidget.searchQuery) {
        // Update search query for server-side
        _currentSearchQuery = widget.searchQuery ?? '';
        searchController.text = _currentSearchQuery;
        currentPage = 1;
        _loadServerPage();
      
      }
    }

    if (widget.paginationConfig != oldWidget.paginationConfig) {
      if (widget.paginationConfig?.serverSide == true) {
        totalServerItems = widget.paginationConfig!.totalItems;
        if (oldWidget.paginationConfig?.serverSide != true) {
          currentPage = 1;
          _loadServerPage();
        }
      } else {
        _updateItems();
      }
    }

    if (widget.searchQuery != oldWidget.searchQuery &&
        widget.searchQuery != null) {
      searchController.text = widget.searchQuery!;
        _currentSearchQuery = widget.searchQuery!;
    }
  }

  Future<void> _loadServerPage() async {
    if (widget.paginationConfig?.onPageChanged == null) return;

    setState(() {
      isLoadingPage = true;
      lastError = null;
    });

    try {
      final newData = await widget.paginationConfig!.onPageChanged!(
        currentPage,
        itemsPerPage,
         _currentSearchQuery.isEmpty ? null : _currentSearchQuery,
      );

      if (mounted) {
        setState(() {
          currentPageData = newData;
           filteredItems = List.from(newData);
          isLoadingPage = false;
          selectedItems.retainWhere((item) => newData.contains(item));
          expandedItems.retainWhere((item) => newData.contains(item));
        });

        widget.onSelectionChanged?.call(selectedItems.toList());
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          isLoadingPage = false;
          lastError = error.toString();
          currentPageData = [];
        });
      }
    }
  }

   void _updateItems() {
    if (widget.paginationConfig?.serverSide == true) return;

    sortedItems = List.from(widget.items);
    if (widget.paginationConfig?.serverSide == true) {
      // For server-side pagination, work with current page data
      sortedItems = List.from(currentPageData);
    } else {
      // For client-side pagination, work with widget.items
      sortedItems = List.from(widget.items);
    }
    
    _applyFiltering();
    _applySorting();
    setState(() {});
  }
  
  void _applyFiltering() {
       final query = _currentSearchQuery;
    if (query.isEmpty) {
      filteredItems = List.from(sortedItems);
    } else {
     filteredItems = sortedItems.where((item) {
        if (widget.searchFilter != null) {
          return widget.searchFilter!(item, query);
        }
        return item.toString().toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
  }

  void _applySorting() {
    if (sortColumn == null) return;

    final column = widget.columns.firstWhere(
      (col) => col.id == sortColumn,
      orElse: () => widget.columns.first,
    );

    if (column.sortComparator != null) {
      filteredItems.sort((a, b) {
        final result = column.sortComparator!(a, b);
        return isAscending ? result : -result;
      });
    }
  }

  void _onSort(String columnId) {
    setState(() {
      if (sortColumn == columnId) {
        isAscending = !isAscending;
      } else {
        sortColumn = columnId;
        isAscending = true;
      }

      
    });
    _updateItems();

    // Trigger pulse animation
    _pulseController.forward().then((_) => _pulseController.reverse());
  }

  void _onItemSelected(T item, bool selected) {
    setState(() {
      if (selected) {
        if (widget.selectionMode == SelectionMode.single) {
          selectedItems.clear();
        }
        selectedItems.add(item);
      } else {
        selectedItems.remove(item);
      }
    });
    widget.onSelectionChanged?.call(selectedItems.toList());
  }

  void _onSelectAll(bool selectAll) {
    setState(() {
      if (selectAll) {
        selectedItems.addAll(currentPageItems);
      } else {
        selectedItems.removeWhere((item) => currentPageItems.contains(item));
      }
    });
    widget.onSelectionChanged?.call(selectedItems.toList());
  }

  void _onSearchChanged(String query) {
    _searchDebounceTimer?.cancel();
    
    if (widget.paginationConfig?.serverSide == true) {
      // For server-side pagination, debounce the search
      _searchDebounceTimer = Timer(
        widget.paginationConfig!.searchDebounce,
        () {
          setState(() {
            _currentSearchQuery = query;
            currentPage = 1; // Reset to first page
          });
          _loadServerPage();
        },
      );
    } else {
      // For client-side pagination, apply filtering immediately
      setState(() {
        _currentSearchQuery = query;
        currentPage = 1; // Reset to first page
        _applyFiltering();
      }
      );
    }
  }

  void _toggleExpanded(T item) {
    setState(() {
      if (expandedItems.contains(item)) {
        expandedItems.remove(item);
      } else {
        expandedItems.add(item);
      }
    });
  }

  Future<void> _goToPage(int page) async {
    if (page < 0 || page > totalPages) return;

    setState(() {
      currentPage = page;
    });

    if (widget.paginationConfig?.serverSide == true) {
      await _loadServerPage();
    }
  }

  Future<void> _changePageSize(int newSize) async {
    setState(() {
      itemsPerPage = newSize;
      currentPage = 1;
    });

    if (widget.paginationConfig?.serverSide == true) {
      await _loadServerPage();
    }
  }

  Future<void> _refreshData() async {
    if (widget.paginationConfig?.serverSide == true) {
      await _loadServerPage();
    } else {
      _updateItems();
    }
  }

  List<T> get currentPageItems {
    if (widget.paginationConfig?.serverSide == true) {
      return filteredItems;
    }

    if (widget.paginationConfig == null) return filteredItems;

    final startIndex = (currentPage - 1) * itemsPerPage;
    final endIndex = (startIndex + itemsPerPage).clamp(0, filteredItems.length);
    return filteredItems.sublist(startIndex, endIndex);
  }

  int get totalPages {
    if (widget.paginationConfig?.serverSide == true) {
      if (totalServerItems == null || totalServerItems! <= 0) return 1;
      return (totalServerItems! / itemsPerPage).ceil();
    }

    if (widget.paginationConfig == null) return 1;
    return (filteredItems.length / itemsPerPage).ceil();
  }

  int get totalItems {
    if (widget.paginationConfig?.serverSide == true) {
      return totalServerItems ?? 0;
    }
    return filteredItems.length;
  }

  Widget _buildSearchBar() {
    if (!widget.showSearch) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          color: widget.surfaceColor.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.primaryColor.withOpacity(0.3),
            width: 1,
          ),
          boxShadow:
              widget.enableGlow
                  ? [
                    BoxShadow(
                      color: widget.primaryColor.withOpacity(0.2),
                      blurRadius: 8,
                      spreadRadius: 0,
                    ),
                  ]
                  : [],
        ),
        child: TextField(
          controller: searchController,
          onChanged: _onSearchChanged,
          style: TextStyle(color: widget.onSurfaceColor, fontSize: 14),
          decoration: InputDecoration(
            hintText: widget.searchPlaceholder,
            hintStyle: TextStyle(color: widget.onSurfaceColor.withOpacity(0.6)),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: widget.primaryColor,
              size: 20,
            ),
            suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Show loading indicator for server-side search
              if (widget.paginationConfig?.serverSide == true && 
                  isLoadingPage && 
                  _currentSearchQuery.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: widget.accentColor,
                    ),
                  ),
                ),
              // Clear button
              if (searchController.text.isNotEmpty)
                IconButton(
                  icon: Icon(Icons.clear, color: widget.primaryColor),
                  onPressed: () {
                    searchController.clear();
                    _onSearchChanged('');
                  },
                ),
            ],
          ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCell(TableColumnConfig<T> column) {
    if (!column.visible) return const SizedBox.shrink();

    final isSorted = sortColumn == column.id;
    final canSort = column.sortable && column.sortComparator != null;

    Widget headerContent =
        column.headerBuilder?.call() ??
        Text(
          column.title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: isSorted ? widget.accentColor : widget.onSurfaceColor,
            letterSpacing: 0.5,
          ),
          textAlign: column.textAlign,
        );

    if (column.tooltip != null) {
      headerContent = Tooltip(message: column.tooltip!, child: headerContent);
    }

    return Expanded(
      flex: column.flex,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: isSorted ? _pulseAnimation.value : 1.0,
            child: GestureDetector(
              onTap: canSort ? () => _onSort(column.id) : null,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration:
                    widget.showColumnBorders
                        ? BoxDecoration(
                          border: Border(
                            right: BorderSide(
                              color: widget.primaryColor.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                        )
                        : null,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(child: headerContent),
                    if (canSort)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        child: Icon(
                          isSorted
                              ? (isAscending
                                  ? Icons.arrow_upward_rounded
                                  : Icons.arrow_downward_rounded)
                              : Icons.unfold_more_rounded,
                          size: 16,
                          color:
                              isSorted
                                  ? widget.accentColor
                                  : widget.onSurfaceColor.withOpacity(0.5),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSelectionCheckbox() {
    if (widget.selectionMode != SelectionMode.multiple) {
      return const SizedBox.shrink();
    }

    final currentItems = currentPageItems;
    if (currentItems.isEmpty) {
      return const SizedBox(width: 56);
    }

    final allSelected = currentItems.every(
      (item) => selectedItems.contains(item),
    );
    final someSelected = currentItems.any(
      (item) => selectedItems.contains(item),
    );

    return SizedBox(
      width: 56,
      child: Center(
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: allSelected ? widget.primaryColor : Colors.transparent,
            border: Border.all(color: widget.primaryColor, width: 2),
            borderRadius: BorderRadius.circular(4),
          ),
          child:
              allSelected
                  ? Icon(
                    Icons.check_rounded,
                    size: 14,
                    color: widget.onSurfaceColor,
                  )
                  : someSelected
                  ? Icon(
                    Icons.remove_rounded,
                    size: 14,
                    color: widget.primaryColor,
                  )
                  : null,
        ),
      ),
    );
  }

  Widget _buildRowNumberColumn() {
    if (!widget.showRowNumbers) return const SizedBox.shrink();

    return SizedBox(
      width: 60,
      child: Center(
        child: Text(
          '#',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: widget.onSurfaceColor.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    if (widget.emptyStateWidget != null) {
      return widget.emptyStateWidget!;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: widget.surfaceColor.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: widget.primaryColor.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Icon(
                widget.emptyStateIcon,
                size: 48,
                color: widget.onSurfaceColor.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              widget.emptyStateMessage!,
              style: TextStyle(
                fontSize: 16,
                color: widget.onSurfaceColor.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    if (widget.loadingWidget != null) {
      return widget.loadingWidget!;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: widget.surfaceColor.withOpacity(0.5),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: widget.primaryColor.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: widget.primaryColor,
                    strokeWidth: 3,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Loading data...',
              style: TextStyle(
                fontSize: 14,
                color: widget.onSurfaceColor.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: widget.errorColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: widget.errorColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: widget.errorColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Error loading data',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: widget.onSurfaceColor,
              ),
            ),
            if (lastError != null) ...[
              const SizedBox(height: 8),
              Text(
                lastError!,
                style: TextStyle(
                  fontSize: 12,
                  color: widget.onSurfaceColor.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: widget.primaryColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: widget.primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _refreshData,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.refresh_rounded,
                          size: 18,
                          color: widget.onSurfaceColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Retry',
                          style: TextStyle(
                            color: widget.onSurfaceColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataRow(T item, int index) {
    final isSelected = selectedItems.contains(item);
    final isHovered = widget.enableHover && hoveredIndex == index;
    final isExpanded = expandedItems.contains(item);
    final showSelection = widget.selectionMode != SelectionMode.none;

    if (widget.rowBuilder != null) {
      return widget.rowBuilder!(item, index, isSelected, isHovered);
    }

    return MouseRegion(
      onEnter:
          widget.enableHover
              ? (_) => setState(() => hoveredIndex = index)
              : null,
      onExit:
          widget.enableHover
              ? (_) => setState(() => hoveredIndex = null)
              : null,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? widget.primaryColor.withOpacity(0.1)
                      : (isHovered
                          ? widget.surfaceColor.withOpacity(0.5)
                          : Colors.transparent),
              borderRadius: BorderRadius.circular(12),
              border:
                  isSelected
                      ? Border.all(
                        color: widget.primaryColor.withOpacity(0.3),
                        width: 1,
                      )
                      : null,
              boxShadow:
                  isHovered && widget.enableGlow
                      ? [
                        BoxShadow(
                          color: widget.primaryColor.withOpacity(0.1),
                          blurRadius: 8,
                          spreadRadius: 0,
                        ),
                      ]
                      : [],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  if (showSelection &&
                      widget.selectionMode == SelectionMode.single) {
                    _onItemSelected(item, !isSelected);
                  }
                  widget.onItemTap?.call(item);
                },
                onDoubleTap:
                    widget.onItemDoubleTap != null
                        ? () => widget.onItemDoubleTap!(item)
                        : null,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      // Selection checkbox
                      if (showSelection &&
                          widget.selectionMode == SelectionMode.multiple)
                        GestureDetector(
                          onTap: () => _onItemSelected(item, !isSelected),
                          child: Container(
                            width: 56,
                            height: 40,
                            child: Center(
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color:
                                      isSelected
                                          ? widget.primaryColor
                                          : Colors.transparent,
                                  border: Border.all(
                                    color: widget.primaryColor,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child:
                                    isSelected
                                        ? Icon(
                                          Icons.check_rounded,
                                          size: 14,
                                          color: widget.onSurfaceColor,
                                        )
                                        : null,
                              ),
                            ),
                          ),
                        ),

                      // Row number
                      if (widget.showRowNumbers)
                        SizedBox(
                          width: 60,
                          child: Center(
                            child:
                                widget.rowNumberBuilder?.call(index) ??
                                Text(
                                   '${(currentPage - 1) * itemsPerPage + index + 1}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: widget.onSurfaceColor.withOpacity(
                                      0.6,
                                    ),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                          ),
                        ),

                      // Expandable arrow
                      if (widget.expandableRows &&
                          widget.expandedBuilder != null)
                        SizedBox(
                          width: 40,
                          child: IconButton(
                            icon: AnimatedRotation(
                              turns: isExpanded ? 0.5 : 0,
                              duration: const Duration(milliseconds: 200),
                              child: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 20,
                                color: widget.onSurfaceColor.withOpacity(0.7),
                              ),
                            ),
                            onPressed: () => _toggleExpanded(item),
                          ),
                        ),

                      // Leading widget
                      if (widget.leadingBuilder != null)
                        widget.leadingBuilder!(item),

                      // Data columns
                      ...widget.columns
                          .where((col) => col.visible)
                          .map(
                            (column) => Expanded(
                              flex: column.flex,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration:
                                    widget.showColumnBorders
                                        ? BoxDecoration(
                                          border: Border(
                                            right: BorderSide(
                                              color: widget.primaryColor
                                                  .withOpacity(0.1),
                                              width: 1,
                                            ),
                                          ),
                                        )
                                        : null,
                                child: DefaultTextStyle(
                                  style: TextStyle(
                                    color: widget.onSurfaceColor.withOpacity(
                                      0.9,
                                    ),
                                    fontSize: 13,
                                  ),
                                  child: column.builder(item),
                                ),
                              ),
                            ),
                          ),

                      // Trailing widget
                      if (widget.trailingBuilder != null)
                        Container(
                          width: widget.trailingColumnWidth,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: widget.trailingBuilder!(item),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Expanded content
          if (isExpanded && widget.expandedBuilder != null)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              margin: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: widget.surfaceColor.withOpacity(0.3),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
                border: Border.all(
                  color: widget.primaryColor.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: DefaultTextStyle(
                  style: TextStyle(
                    color: widget.onSurfaceColor.withOpacity(0.8),
                    fontSize: 13,
                  ),
                  child: widget.expandedBuilder!(item),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPagination() {
    if (widget.paginationConfig == null || totalPages < 1) {
      return const SizedBox.shrink();
    }

    final isServerSide = widget.paginationConfig!.serverSide;
    final showLoading = isLoadingPage && isServerSide;

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.backgroundColor.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.primaryColor.withOpacity(0.2),
          width: 1,
        ),
        boxShadow:
            widget.enableGlow
                ? [
                  BoxShadow(
                    color: widget.primaryColor.withOpacity(0.1),
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                ]
                : [],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Page info
          if (widget.paginationConfig!.showPageInfo)
            Row(
              children: [
                Text(
                  '${(currentPage-1) * itemsPerPage +1 }-${((currentPage  * itemsPerPage)).clamp(0, totalItems)} of $totalItems',
                  style: TextStyle(
                    color: widget.onSurfaceColor.withOpacity(0.7),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (showLoading) ...[
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: widget.primaryColor,
                    ),
                  ),
                ],
              ],
            ),

          // Page size selector
          if (widget.paginationConfig!.showPageSizeSelector)
            Row(
              children: [
                Text(
                  'Show: ',
                  style: TextStyle(
                    color: widget.onSurfaceColor.withOpacity(0.7),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: widget.backgroundColor.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: widget.primaryColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: DropdownButton<int>(
                    value: itemsPerPage,
                    items:
                        widget.paginationConfig!.pageSizeOptions
                            .map(
                              (size) => DropdownMenuItem(
                                value: size,
                                child: Text(
                                  '$size',
                                  style: TextStyle(
                                    color: widget.onSurfaceColor,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                    onChanged:
                        showLoading
                            ? null
                            : (value) {
                              if (value != null) {
                                _changePageSize(value);
                              }
                            },
                    underline: const SizedBox.shrink(),
                    icon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: widget.onSurfaceColor.withOpacity(0.7),
                      size: 18,
                    ),
                    dropdownColor: widget.surfaceColor,
                  ),
                ),
              ],
            ),

          // Page navigation
          Row(
            children: [
              _buildPaginationButton(
                icon: Icons.chevron_left_rounded,
                onPressed:
                    (currentPage > 1 && !showLoading)
                        ? () => _goToPage(currentPage - 1)
                        : null,
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: widget.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: widget.primaryColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  '${currentPage } of $totalPages',
                  style: TextStyle(
                    color: widget.primaryColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _buildPaginationButton(
                icon: Icons.chevron_right_rounded,
                onPressed:
                    (currentPage < totalPages  && !showLoading)
                        ? () => _goToPage(currentPage + 1)
                        : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color:
            onPressed != null
                ? widget.primaryColor.withOpacity(0.1)
                : widget.backgroundColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color:
              onPressed != null
                  ? widget.primaryColor.withOpacity(0.3)
                  : widget.onSurfaceColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(
              icon,
              size: 18,
              color:
                  onPressed != null
                      ? widget.primaryColor
                      : widget.onSurfaceColor.withOpacity(0.3),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isServerSide = widget.paginationConfig?.serverSide == true;
    final showMainLoading =
        widget.isLoading ||
        (isServerSide &&
            isLoadingPage &&
            currentPageData.isEmpty &&
            lastError == null);
    final showError = lastError != null && currentPageData.isEmpty;

    Widget tableBody;

    if (showMainLoading) {
      tableBody = _buildLoadingState();
    } else if (showError) {
      tableBody = _buildErrorState();
    } else if (currentPageItems.isEmpty) {
      tableBody = _buildEmptyState();
    } else {
      tableBody = ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: currentPageItems.length,
        itemBuilder:
            (context, index) => _buildDataRow(currentPageItems[index], index),
      );
    }

    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.primaryColor.withOpacity(0.2),
              width: 1,
            ),
            boxShadow:
                widget.enableGlow
                    ? [
                      BoxShadow(
                        color: widget.primaryColor.withOpacity(
                          _glowAnimation.value * 0.1,
                        ),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                    : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Search bar
              _buildSearchBar(),

              // Table header
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: widget.surfaceColor.withOpacity(0.8),
                  border: Border(
                    bottom: BorderSide(
                      color: widget.primaryColor.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    // Selection header
                    _buildSelectionCheckbox(),

                    // Row number header
                    _buildRowNumberColumn(),

                    // Expandable header space
                    if (widget.expandableRows && widget.expandedBuilder != null)
                      const SizedBox(width: 40),

                    // Leading space
                    if (widget.leadingBuilder != null)
                      const SizedBox(width: 40),

                    // Column headers
                    ...widget.columns
                        .where((col) => col.visible)
                        .map(_buildHeaderCell),

                    // Trailing space
                    if (widget.trailingBuilder != null)
                      Container(
                        width: widget.trailingColumnWidth,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        child: Text(
                          'Actions',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: widget.accentColor,
                            fontSize: 13,
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ),

              // Table body
              Expanded(child: tableBody),

              // Pagination
              _buildPagination(),
            ],
          ),
        );
      },
    );
  }
}

/// Modern status badge with futuristic styling
class StatusBadge extends StatelessWidget {
  final String text;
  final Color color;
  final double fontSize;
  final EdgeInsets padding;
  final double borderRadius;
  final IconData? icon;
  final bool enableGlow;

  const StatusBadge({
    Key? key,
    required this.text,
    required this.color,
    this.fontSize = 11,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    this.borderRadius = 16,
    this.icon,
    this.enableGlow = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
        boxShadow:
            enableGlow
                ? [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 4,
                    spreadRadius: 0,
                  ),
                ]
                : [],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: fontSize, color: color),
            const SizedBox(width: 6),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: color,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

/// Modern avatar with gradient background
class AvatarWithInitial extends StatelessWidget {
  final String text;
  final double radius;
  final Color backgroundColor;
  final Color textColor;
  final String? imageUrl;
  final Widget? child;
  final bool enableGlow;

  const AvatarWithInitial({
    Key? key,
    required this.text,
    this.radius = 18,
    required this.backgroundColor,
    required this.textColor,
    this.imageUrl,
    this.child,
    this.enableGlow = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            backgroundColor.withOpacity(0.8),
            backgroundColor.withOpacity(0.4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: backgroundColor.withOpacity(0.3), width: 1),
        boxShadow:
            enableGlow
                ? [
                  BoxShadow(
                    color: backgroundColor.withOpacity(0.2),
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                ]
                : [],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child:
            imageUrl != null
                ? Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => _buildInitial(),
                )
                : (child ?? _buildInitial()),
      ),
    );
  }

  Widget _buildInitial() {
    return Center(
      child: Text(
        text.isNotEmpty ? text.substring(0, 1).toUpperCase() : '?',
        style: TextStyle(
          fontSize: radius * 0.7,
          fontWeight: FontWeight.w700,
          color: textColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// Modern progress indicator with gradient
class CustomProgressIndicator extends StatelessWidget {
  final double value;
  final Color color;
  final Color backgroundColor;
  final double height;
  final double borderRadius;
  final bool showPercentage;
  final TextStyle? percentageStyle;
  final bool enableGlow;

  const CustomProgressIndicator({
    Key? key,
    required this.value,
    this.color = const Color(0xFF6366F1),
    this.backgroundColor = const Color(0xFF374151),
    this.height = 6,
    this.borderRadius = 3,
    this.showPercentage = false,
    this.percentageStyle,
    this.enableGlow = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final percentage = (value * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: height,
          decoration: BoxDecoration(
            color: backgroundColor.withOpacity(0.3),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: backgroundColor.withOpacity(0.2),
              width: 0.5,
            ),
          ),
          child: Stack(
            children: [
              FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: value.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withOpacity(0.7)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(borderRadius),
                    boxShadow:
                        enableGlow
                            ? [
                              BoxShadow(
                                color: color.withOpacity(0.4),
                                blurRadius: 4,
                                spreadRadius: 0,
                              ),
                            ]
                            : [],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showPercentage) ...[
          const SizedBox(height: 6),
          Text(
            '$percentage%',
            style:
                percentageStyle ??
                TextStyle(
                  fontSize: 11,
                  color: const Color(0xFFE5E7EB),
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ],
    );
  }
}

/// Modern action buttons with enhanced styling
class ActionButtons extends StatelessWidget {
  final List<ActionButtonConfig> actions;
  final double spacing;
  final bool iconOnly;
  final bool enableGlow;

  const ActionButtons({
    Key? key,
    required this.actions,
    this.spacing = 8,
    this.iconOnly = true,
    this.enableGlow = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children:
          actions.map((action) {
            if (iconOnly) {
              return Container(
                margin: EdgeInsets.only(right: spacing),
                decoration: BoxDecoration(
                  color: (action.color ?? const Color(0xFF6366F1)).withOpacity(
                    0.1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: (action.color ?? const Color(0xFF6366F1))
                        .withOpacity(0.3),
                    width: 1,
                  ),
                  boxShadow:
                      enableGlow
                          ? [
                            BoxShadow(
                              color: (action.color ?? const Color(0xFF6366F1))
                                  .withOpacity(0.2),
                              blurRadius: 4,
                              spreadRadius: 0,
                            ),
                          ]
                          : [],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: action.onPressed,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        action.icon,
                        size: 16,
                        color: action.color ?? const Color(0xFF6366F1),
                      ),
                    ),
                  ),
                ),
              );
            } else {
              return Container(
                margin: EdgeInsets.only(right: spacing),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      (action.color ?? const Color(0xFF6366F1)),
                      (action.color ?? const Color(0xFF6366F1)).withOpacity(
                        0.8,
                      ),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow:
                      enableGlow
                          ? [
                            BoxShadow(
                              color: (action.color ?? const Color(0xFF6366F1))
                                  .withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                          : [],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: action.onPressed,
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(action.icon, size: 16, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            action.label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }
          }).toList(),
    );
  }
}

/// Configuration for action buttons
class ActionButtonConfig {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? color;

  const ActionButtonConfig({
    required this.icon,
    required this.label,
    this.onPressed,
    this.tooltip,
    this.color,
  });
}

/// Enhanced table column builders with modern styling
class TableColumnBuilders {
  static Widget text(String value, {TextStyle? style, int? maxLines}) {
    return Text(
      value,
      style:
          style ??
          const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
          ),
      maxLines: maxLines,
      overflow: maxLines != null ? TextOverflow.ellipsis : null,
    );
  }

  static Widget number(
    num value, {
    String? prefix,
    String? suffix,
    int? decimals,
    Color? color,
  }) {
    String formatted =
        decimals != null ? value.toStringAsFixed(decimals) : value.toString();

    return Text(
      '${prefix ?? ''}$formatted${suffix ?? ''}',
      textAlign: TextAlign.end,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 13,
        color: color ?? const Color(0xFFE5E7EB),
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }

  static Widget currency(
    double value, {
    String symbol = '\$',
    int decimals = 2,
  }) {
    return Text(
      '$symbol${value.toStringAsFixed(decimals)}',
      textAlign: TextAlign.end,
      style: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 13,
        color: value >= 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }

  static Widget date(DateTime date, {String format = 'MMM d, yyyy'}) {
    return Text(
      '${date.day}/${date.month}/${date.year}',
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: Color(0xFFE5E7EB),
      ),
    );
  }

  static Widget boolean(bool value, {IconData? trueIcon, IconData? falseIcon}) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: (value ? const Color(0xFF10B981) : const Color(0xFFEF4444))
            .withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: (value ? const Color(0xFF10B981) : const Color(0xFFEF4444))
              .withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Icon(
        value
            ? (trueIcon ?? Icons.check_rounded)
            : (falseIcon ?? Icons.close_rounded),
        color: value ? const Color(0xFF10B981) : const Color(0xFFEF4444),
        size: 16,
      ),
    );
  }

  static Widget image(String? imageUrl, {double size = 32}) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFF374151).withOpacity(0.5),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: const Color(0xFF6366F1).withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Icon(
          Icons.image_rounded,
          color: const Color(0xFF9CA3AF),
          size: size * 0.6,
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: const Color(0xFF6366F1).withOpacity(0.2),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Image.network(
          imageUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder:
              (context, error, stackTrace) => Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF374151).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Icon(
                  Icons.broken_image_rounded,
                  color: const Color(0xFF9CA3AF),
                  size: size * 0.6,
                ),
              ),
        ),
      ),
    );
  }

  static Widget tags(List<String> tags, {int maxTags = 3}) {
    final displayTags = tags.take(maxTags).toList();
    final remainingCount = tags.length - maxTags;

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: [
        ...displayTags.map(
          (tag) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF6366F1).withOpacity(0.2),
                  const Color(0xFF6366F1).withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF6366F1).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              tag,
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF6366F1),
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
        if (remainingCount > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF9CA3AF).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF9CA3AF).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              '+$remainingCount',
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF9CA3AF),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}

/// Utility class for common sort comparators
class TableSortComparators {
  /// String comparator (case-insensitive)
  static int string(String a, String b) =>
      a.toLowerCase().compareTo(b.toLowerCase());

  /// Numeric comparator
  static int number(num a, num b) => a.compareTo(b);

  /// Date comparator
  static int date(DateTime a, DateTime b) => a.compareTo(b);

  /// Boolean comparator (true comes first)
  static int boolean(bool a, bool b) => b ? (a ? 0 : 1) : (a ? -1 : 0);

  /// Custom comparator for nullable values
  static int nullable<T extends Comparable>(T? a, T? b) {
    if (a == null && b == null) return 0;
    if (a == null) return 1;
    if (b == null) return -1;
    return a.compareTo(b);
  }
}

/// Modern futuristic theme configuration
class InteractiveTableTheme {
  static const Color darkPrimary = Color(
    0xFFFFFFFF,
  ); // White (primary highlight)
  static const Color darkSurface = Color(0xFF1E1E1E); // Dark gray surface
  static const Color darkBackground = Color(
    0xFF121212,
  ); // Near black background
  static const Color darkOnSurface = Color(0xFFE5E5E5); // Light gray text
  static const Color darkOnBackground = Color(0xFF9CA3AF); // Medium gray text
  static const Color darkAccent = Color(0xFFFFFFFF); // White (same as primary)
  static const Color darkSuccess = Color(0xFF22C55E); // Optional green feedback
  static const Color darkWarning = Color(
    0xFFFACC15,
  ); // Optional yellow feedback
  static const Color darkError = Color(0xFFEF4444); // Optional red feedback

  // Light Theme (Monochrome)
  static const Color lightPrimary = Color(
    0xFF000000,
  ); // Black (primary highlight)
  static const Color lightSurface = Color(0xFFF3F4F6); // Light gray surface
  static const Color lightBackground = Color(0xFFFFFFFF); // White background
  static const Color lightOnSurface = Color(0xFF1F2937); // Dark gray text
  static const Color lightOnBackground = Color(0xFF4B5563); // Medium gray text
  static const Color lightAccent = Color(0xFF000000); // Black (same as primary)
  static const Color lightSuccess = Color(
    0xFF16A34A,
  ); // Optional green feedback
  static const Color lightWarning = Color(
    0xFFEAB308,
  ); // Optional yellow feedback
  static const Color lightError = Color(0xFFDC2626); // Optional red feedback

  /// Get dark theme configuration
  static InteractiveTable<T> darkTheme<T>({
    required List<T> items,
    required List<TableColumnConfig<T>> columns,
    Function(T item)? onItemTap,
    Function(T item)? onItemDoubleTap,
    Function(List<T> selectedItems)? onSelectionChanged,
    Widget Function(T item)? leadingBuilder,
    Widget Function(T item)? trailingBuilder,
    double trailingColumnWidth = 170.0,
    Widget Function(T item)? expandedBuilder,
    Widget Function(T item, int index, bool isSelected, bool isHovered)?
    rowBuilder,
    SelectionMode selectionMode = SelectionMode.none,
    List<T> initialSelection = const [],
    PaginationConfig<T>? paginationConfig,
    bool isLoading = false,
    Widget? loadingWidget,
    String? searchQuery,
    bool Function(T item, String query)? searchFilter,
    bool showSearch = false,
    String searchPlaceholder = 'Search...',
    bool expandableRows = false,
    Set<T> initiallyExpanded = const {},
    Widget? emptyStateWidget,
    String? emptyStateMessage = 'No data available',
    IconData? emptyStateIcon = Icons.data_array,
    double? height,
    bool showColumnBorders = false,
    bool enableHover = true,
    bool showRowNumbers = false,
    Widget Function(int index)? rowNumberBuilder,
    bool enableGlow = false,
    bool enableNeumorphism = false,
    bool enableGlassmorphism = true,
  }) {
    return InteractiveTable<T>(
      items: items,
      columns: columns,
      onItemTap: onItemTap,
      onItemDoubleTap: onItemDoubleTap,
      onSelectionChanged: onSelectionChanged,
      leadingBuilder: leadingBuilder,
      trailingBuilder: trailingBuilder,
      trailingColumnWidth: trailingColumnWidth,
      expandedBuilder: expandedBuilder,
      rowBuilder: rowBuilder,
      selectionMode: selectionMode,
      initialSelection: initialSelection,
      paginationConfig: paginationConfig,
      isLoading: isLoading,
      loadingWidget: loadingWidget,
      searchQuery: searchQuery,
      searchFilter: searchFilter,
      showSearch: showSearch,
      searchPlaceholder: searchPlaceholder,
      expandableRows: expandableRows,
      initiallyExpanded: initiallyExpanded,
      primaryColor: darkPrimary,
      surfaceColor: darkSurface,
      backgroundColor: darkBackground,
      onSurfaceColor: darkOnSurface,
      onBackgroundColor: darkOnBackground,
      accentColor: darkAccent,
      successColor: darkSuccess,
      warningColor: darkWarning,
      errorColor: darkError,
      emptyStateWidget: emptyStateWidget,
      emptyStateMessage: emptyStateMessage,
      emptyStateIcon: emptyStateIcon,
      enableGlow: enableGlow,
      enableNeumorphism: enableNeumorphism,
      enableGlassmorphism: enableGlassmorphism,
      height: height,
      showColumnBorders: showColumnBorders,
      enableHover: enableHover,
      showRowNumbers: showRowNumbers,
      rowNumberBuilder: rowNumberBuilder,
    );
  }

  /// Get light theme configuration
  static InteractiveTable<T> lightTheme<T>({
    required List<T> items,
    required List<TableColumnConfig<T>> columns,
    Function(T item)? onItemTap,
    Function(T item)? onItemDoubleTap,
    Function(List<T> selectedItems)? onSelectionChanged,
    Widget Function(T item)? leadingBuilder,
    Widget Function(T item)? trailingBuilder,
    double trailingColumnWidth = 170.0,
    Widget Function(T item)? expandedBuilder,
    Widget Function(T item, int index, bool isSelected, bool isHovered)?
    rowBuilder,
    SelectionMode selectionMode = SelectionMode.none,
    List<T> initialSelection = const [],
    PaginationConfig<T>? paginationConfig,
    bool isLoading = false,
    Widget? loadingWidget,
    String? searchQuery,
    bool Function(T item, String query)? searchFilter,
    bool showSearch = false,
    String searchPlaceholder = 'Search...',
    bool expandableRows = false,
    Set<T> initiallyExpanded = const {},
    Widget? emptyStateWidget,
    String? emptyStateMessage = 'No data available',
    IconData? emptyStateIcon = Icons.data_array,
    double? height,
    bool showColumnBorders = false,
    bool enableHover = true,
    bool showRowNumbers = false,
    Widget Function(int index)? rowNumberBuilder,
    bool enableGlow = false,
    bool enableNeumorphism = true,
    bool enableGlassmorphism = false,
  }) {
    return InteractiveTable<T>(
      items: items,
      columns: columns,
      onItemTap: onItemTap,
      onItemDoubleTap: onItemDoubleTap,
      onSelectionChanged: onSelectionChanged,
      leadingBuilder: leadingBuilder,
      trailingBuilder: trailingBuilder,
      trailingColumnWidth: trailingColumnWidth,
      expandedBuilder: expandedBuilder,
      rowBuilder: rowBuilder,
      selectionMode: selectionMode,
      initialSelection: initialSelection,
      paginationConfig: paginationConfig,
      isLoading: isLoading,
      loadingWidget: loadingWidget,
      searchQuery: searchQuery,
      searchFilter: searchFilter,
      showSearch: showSearch,
      searchPlaceholder: searchPlaceholder,
      expandableRows: expandableRows,
      initiallyExpanded: initiallyExpanded,
      primaryColor: lightPrimary,
      surfaceColor: lightSurface,
      backgroundColor: lightBackground,
      onSurfaceColor: lightOnSurface,
      onBackgroundColor: lightOnBackground,
      accentColor: lightAccent,
      successColor: lightSuccess,
      warningColor: lightWarning,
      errorColor: lightError,
      emptyStateWidget: emptyStateWidget,
      emptyStateMessage: emptyStateMessage,
      emptyStateIcon: emptyStateIcon,
      enableGlow: enableGlow,
      enableNeumorphism: enableNeumorphism,
      enableGlassmorphism: enableGlassmorphism,
      height: height,
      showColumnBorders: showColumnBorders,
      enableHover: enableHover,
      showRowNumbers: showRowNumbers,
      rowNumberBuilder: rowNumberBuilder,
    );
  }
}
