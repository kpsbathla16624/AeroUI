import 'package:flutter/material.dart';

/// A model class to represent each section in the TocNavigator
class NavSection {
  final String title;
  final String? subtitle;
  final int level; // 0 = main, 1 = sub-section, 2 = sub-sub-section
  final GlobalKey key;
  final VoidCallback? onTap;

  NavSection({
    required this.title,
    this.subtitle,
    this.level = 0,
    required this.key,
    this.onTap,
  });
}

/// Table of Contents Navigator - Automatically highlights current section while scrolling
class TocNavigator extends StatefulWidget {
  /// List of sections to display in the TocNavigator
  final List<NavSection> sections;
  
  /// ScrollController for the main content
  final ScrollController scrollController;
  
  /// Width of the TocNavigator sidebar
  final double width;
  
  /// Title shown at the top of the TocNavigator
  final String title;
  
  /// Background color of the TocNavigator
  final Color? backgroundColor;
  
  /// Text color for inactive items
  final Color? inactiveColor;
  
  /// Text color for active items
  final Color? activeColor;
  
  /// Color of the active indicator line
  final Color? indicatorColor;
  
  /// Thickness of the active indicator line
  final double indicatorThickness;
  
  /// Duration for smooth scrolling animation
  final Duration scrollDuration;
  
  /// Curve for smooth scrolling animation
  final Curve scrollCurve;
  
  /// Custom widget to show at the bottom (like promotional content)
  final Widget? bottomWidget;
  
  /// Padding around the TocNavigator content
  final EdgeInsets padding;
  
  /// Whether to show border on the right side
  final bool showBorder;
  
  /// Border color
  final Color? borderColor;

  // offser from top when scrolling to section
   final double scrollOffset;

  const TocNavigator({
    Key? key,
    required this.sections,
    required this.scrollController,
    this.width = 250,
    this.title = 'On this page',
    this.backgroundColor = Colors.transparent,
    this.inactiveColor,
    this.activeColor,
    this.indicatorColor,
    this.indicatorThickness = 2,
    this.scrollDuration = const Duration(milliseconds: 500),
    this.scrollCurve = Curves.easeInOut,
    this.bottomWidget,
    this.padding = const EdgeInsets.all(20),
    this.showBorder = true,
    this.borderColor,
    this.scrollOffset = 100,
  }) : super(key: key);

  @override
  State<TocNavigator> createState() => _TocNavigatorState();
}

class _TocNavigatorState extends State<TocNavigator> {
  int _activeIndex = 0;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
    // Set initial active section after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateActiveSection();
    });
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    if (!mounted) return;
    _updateActiveSection();
  }

  void _updateActiveSection() {
    if (!mounted) return;
    
    final screenHeight = MediaQuery.of(context).size.height;
    final centerY = screenHeight / 2;
    
    int newActiveIndex = 0;
    double closestDistance = double.infinity;
    
    // Find the section whose top is closest to the center of the screen
    for (int i = 0; i < widget.sections.length; i++) {
      final section = widget.sections[i];
      final RenderBox? renderBox = 
          section.key.currentContext?.findRenderObject() as RenderBox?;
      
      if (renderBox != null) {
        final position = renderBox.localToGlobal(Offset.zero);
        final sectionTop = position.dy;
        final sectionBottom = sectionTop + renderBox.size.height;
        
        // Calculate distance from section to center
        double distanceToCenter;
        
        if (sectionTop <= centerY && sectionBottom >= centerY) {
          // Section contains the center - this should definitely be active
          distanceToCenter = 0;
        } else if (sectionTop > centerY) {
          // Section is below center
          distanceToCenter = sectionTop - centerY;
        } else {
          // Section is above center
          distanceToCenter = centerY - sectionBottom;
        }
        
        // Only consider sections that are close to or contain the center
        if (distanceToCenter < closestDistance) {
          closestDistance = distanceToCenter;
          newActiveIndex = i;
        }
      }
    }
    
    if (newActiveIndex != _activeIndex) {
      setState(() {
        _activeIndex = newActiveIndex;
      });
    }
  }

  void _scrollToSection(int index) {
    final section = widget.sections[index];
    final RenderBox? renderBox = 
        section.key.currentContext?.findRenderObject() as RenderBox?;
    
    if (renderBox != null) {
      final position = renderBox.localToGlobal(Offset.zero);
      final currentScrollPosition = widget.scrollController.position.pixels;
      final screenHeight = MediaQuery.of(context).size.height;
      
      // Calculate target position to center the section on screen
      final targetScrollPosition = currentScrollPosition + position.dy  - widget.scrollOffset ;
      
      widget.scrollController.animateTo(
        targetScrollPosition.clamp(
          0.0, 
          widget.scrollController.position.maxScrollExtent,
        ),
        duration: widget.scrollDuration,
        curve: widget.scrollCurve,
      );
    }
    
    // Call custom onTap if provided
    section.onTap?.call();
  }

  Color get _backgroundColor => widget.backgroundColor ?? 
      Theme.of(context).colorScheme.surface;
  
  Color get _inactiveColor => widget.inactiveColor ?? 
      Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6) ?? 
      Colors.grey;
  
  Color get _activeColor => widget.activeColor ?? 
      Theme.of(context).colorScheme.primary;
  
  Color get _indicatorColor => widget.indicatorColor ?? 
      Theme.of(context).colorScheme.primary;
  
  Color get _borderColor => widget.borderColor ?? 
      Theme.of(context).dividerColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      decoration: BoxDecoration(
        color: _backgroundColor,
        // border: widget.showBorder 
        //     ? Border(right: BorderSide(color: _borderColor, width: 1))
        //     : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: widget.padding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    widget.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Sections
                  ...List.generate(widget.sections.length, (index) {
                    final section = widget.sections[index];
                    final isActive = _activeIndex == index;
                    
                    return _NavItem(
                      section: section,
                      isActive: isActive,
                      onTap: () => _scrollToSection(index),
                      activeColor: _activeColor,
                      inactiveColor: _inactiveColor,
                      indicatorColor: _indicatorColor,
                      indicatorThickness: widget.indicatorThickness,
                    );
                  }),
                ],
              ),
            ),
          ),
          
          // Bottom widget (promotional content, etc.)
          if (widget.bottomWidget != null) ...[
            Padding(
              padding: widget.padding,
              child: widget.bottomWidget!,
            ),
          ],
        ],
      ),
    );
  }
}

/// Individual TocNavigator item widget
class _NavItem extends StatelessWidget {
  final NavSection section;
  final bool isActive;
  final VoidCallback onTap;
  final Color activeColor;
  final Color inactiveColor;
  final Color indicatorColor;
  final double indicatorThickness;

  const _NavItem({
    required this.section,
    required this.isActive,
    required this.onTap,
    required this.activeColor,
    required this.inactiveColor,
    required this.indicatorColor,
    required this.indicatorThickness,
  });

  @override
  Widget build(BuildContext context) {
    final leftPadding = section.level * 16.0;
    
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            // Active indicator
            Container(
              width: indicatorThickness,
              height: 20,
              color: isActive ? indicatorColor : Colors.transparent,
            ),
            const SizedBox(width: 12),
            
            // Left padding for nested levels
            SizedBox(width: leftPadding),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    section.title,
                    style: TextStyle(
                      color: isActive ? activeColor : inactiveColor,
                      fontSize: _getFontSize(section.level),
                      fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                  if (section.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      section.subtitle!,
                      style: TextStyle(
                        color: inactiveColor,
                        fontSize: _getFontSize(section.level) - 2,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _getFontSize(int level) {
    switch (level) {
      case 0:
        return 14;
      case 1:
        return 13;
      case 2:
        return 12;
      default:
        return 12;
    }
  }
}

/// Example usage widget
class TocNavigatorExample extends StatefulWidget {
  @override
  _TocNavigatorExampleState createState() => _TocNavigatorExampleState();
}

class _TocNavigatorExampleState extends State<TocNavigatorExample> {
  final ScrollController _scrollController = ScrollController();
  late List<NavSection> _sections;

  @override
  void initState() {
    super.initState();
    _sections = [
      NavSection(title: 'Installation', key: GlobalKey()),
      NavSection(title: 'Import', key: GlobalKey()),
      NavSection(title: 'Usage', key: GlobalKey()),
      NavSection(title: 'Disabled', subtitle: 'State handling', level: 1, key: GlobalKey()),
      NavSection(title: 'Horizontal', key: GlobalKey()),
      NavSection(title: 'Controlled', level: 1, key: GlobalKey()),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _sections.map((section) {
                  return Container(
                    key: section.key,
                    margin: const EdgeInsets.only(bottom: 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          section.title,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 20),
                        // Add your content here
                        Container(
                          height: 400,
                          color: Colors.grey[200],
                          child: Center(
                            child: Text('${section.title} Content'),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          TocNavigator(
            sections: _sections,
            scrollController: _scrollController,
          ),
        ],
      ),
    );
  }
}