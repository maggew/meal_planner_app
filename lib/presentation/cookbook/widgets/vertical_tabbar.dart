import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:meal_planner/domain/enums/tab_position.dart';

enum IndicatorSide { start, end }

class VerticalTabs extends StatefulWidget {
  final int initialIndex;
  final double tabsWidth;
  final double indicatorWidth;
  final IndicatorSide indicatorSide;
  final List<Tab> tabs;
  final List<Widget> contents;
  final TabPosition tabsPosition;
  final Color? indicatorColor;
  final bool disabledChangePageFromContentView;
  final Axis contentScrollAxis;
  final Duration changePageDuration;
  final Curve changePageCurve;
  final Function(int tabIndex)? onSelect;

  const VerticalTabs({
    super.key,
    required this.tabs,
    required this.contents,
    this.tabsWidth = 200,
    this.indicatorWidth = 3,
    this.indicatorSide = IndicatorSide.end,
    this.initialIndex = 0,
    this.tabsPosition = TabPosition.left,
    this.indicatorColor,
    this.disabledChangePageFromContentView = false,
    this.contentScrollAxis = Axis.horizontal,
    this.changePageCurve = Curves.bounceInOut,
    this.changePageDuration = const Duration(milliseconds: 300),
    this.onSelect,
  }) : assert(tabs.length == contents.length);

  @override
  State<VerticalTabs> createState() => _VerticalTabsState();
}

class _VerticalTabsState extends State<VerticalTabs>
    with TickerProviderStateMixin {
  late int _selectedIndex;
  bool? _changePageByTapView;
  int? _fakePageIndex;
  int? _fakeContentIndex;
  late final PageController _pageController;
  late final List<AnimationController> _animationControllers;
  late final ScrollPhysics _pageScrollPhysics;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _pageController = PageController();
    _pageScrollPhysics = widget.disabledChangePageFromContentView
        ? const NeverScrollableScrollPhysics()
        : const AlwaysScrollableScrollPhysics();

    _animationControllers = List.generate(
      widget.tabs.length,
      (_) => AnimationController(
        duration: const Duration(milliseconds: 400),
        vsync: this,
      ),
    );
    _selectTab(widget.initialIndex);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pageController.jumpToPage(widget.initialIndex);
      setState(() {});
    });
  }

  @override
  void didUpdateWidget(covariant VerticalTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tabs.length != _animationControllers.length) {
      // Add controllers for new tabs
      while (_animationControllers.length < widget.tabs.length) {
        _animationControllers.add(
          AnimationController(
            duration: const Duration(milliseconds: 400),
            vsync: this,
          ),
        );
      }
      // Remove controllers for removed tabs
      while (_animationControllers.length > widget.tabs.length) {
        _animationControllers.removeLast().dispose();
      }
      // Clamp selected index
      if (_selectedIndex >= widget.tabs.length) {
        _selectedIndex = widget.tabs.length - 1;
        _pageController.jumpToPage(_selectedIndex);
      }
      _selectTab(_selectedIndex);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (final controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final indicatorColor = widget.indicatorColor ?? colorScheme.secondary;
    final tabsLeft = widget.tabsPosition == TabPosition.left;

    final borderRadius = BorderRadius.only(
      topRight: tabsLeft ? const Radius.circular(8) : Radius.zero,
      topLeft: tabsLeft ? Radius.zero : const Radius.circular(8),
    );

    final direction = tabsLeft ? TextDirection.ltr : TextDirection.rtl;

    return Directionality(
      textDirection: direction,
      child: Row(
        children: [
          // Glass tab bar
          Directionality(
            textDirection: TextDirection.ltr,
            child: ClipRRect(
              borderRadius: borderRadius,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  width: widget.tabsWidth,
                  color: colorScheme.surface.withValues(alpha: 0.4),
                  child: ListView.builder(
                    itemCount: widget.tabs.length,
                    itemBuilder: (context, index) => _buildTab(
                      context,
                      index: index,
                      indicatorColor: indicatorColor,
                      borderRadius: borderRadius,
                      tabsLeft: tabsLeft,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Content area
          Expanded(
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: PageView.builder(
                scrollDirection: widget.contentScrollAxis,
                physics: _pageScrollPhysics,
                controller: _pageController,
                itemCount: widget.contents.length,
                onPageChanged: (index) {
                  if (_changePageByTapView != true) {
                    _selectTab(index);
                  }
                  if (_selectedIndex == index) {
                    _changePageByTapView = null;
                  }
                  setState(() {});
                },
                itemBuilder: (_, index) {
                  if (index == _fakePageIndex && _fakeContentIndex != null) {
                    return KeyedSubtree(
                      key: ValueKey('fake_$index'),
                      child: widget.contents[_fakeContentIndex!],
                    );
                  }
                  return widget.contents[index];
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(
    BuildContext context, {
    required int index,
    required Color indicatorColor,
    required BorderRadius borderRadius,
    required bool tabsLeft,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final tab = widget.tabs[index];
    final isSelected = _selectedIndex == index;
    final isFirst = index == 0;

    final alignment = Alignment.center;
    final itemBgColor = isSelected
        ? colorScheme.surface.withValues(alpha: 0.3)
        : Colors.transparent;

    // Indicator position
    final double? left;
    final double? right;
    if (tabsLeft) {
      left = widget.indicatorSide == IndicatorSide.start ? 0 : null;
      right = widget.indicatorSide == IndicatorSide.end ? 0 : null;
    } else {
      left = widget.indicatorSide == IndicatorSide.end ? 0 : null;
      right = widget.indicatorSide == IndicatorSide.start ? 0 : null;
    }

    // Tab content
    final Widget tabContent;
    if (tab.child != null) {
      tabContent = tab.child!;
    } else {
      tabContent = Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            if (tab.icon != null) ...[tab.icon!, const SizedBox(width: 5)],
            if (tab.text != null)
              SizedBox(
                width: widget.tabsWidth - 50,
                child: Text(
                  tab.text!,
                  softWrap: true,
                  style: TextStyle(
                    color: isSelected
                        ? colorScheme.onSurface
                        : colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            final previousIndex = _selectedIndex;
            _changePageByTapView = true;
            setState(() => _selectTab(index));

            final distance = (index - previousIndex).abs();
            if (distance > 1) {
              final forward = index > previousIndex;
              final adjacentPage = forward ? index - 1 : index + 1;
              setState(() {
                _fakePageIndex = adjacentPage;
                _fakeContentIndex = previousIndex;
              });
              _pageController.jumpToPage(adjacentPage);
            }
            _pageController
                .animateToPage(
              index,
              duration: widget.changePageDuration,
              curve: widget.changePageCurve,
            )
                .then((_) {
              if (mounted) {
                setState(() {
                  _fakePageIndex = null;
                  _fakeContentIndex = null;
                });
              }
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: itemBgColor,
              borderRadius: isFirst ? borderRadius : null,
            ),
            clipBehavior: isFirst ? Clip.antiAlias : Clip.none,
            alignment: alignment,
            padding: const EdgeInsets.all(5),
            child: tabContent,
          ),
        ),
        Positioned(
          top: 0,
          bottom: 0,
          width: widget.indicatorWidth,
          left: left,
          right: right,
          child: ScaleTransition(
            scale: Tween(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: _animationControllers[index],
                curve: Curves.elasticOut,
              ),
            ),
            child: Container(color: indicatorColor),
          ),
        ),
      ],
    );
  }

  void _selectTab(int index) {
    _selectedIndex = index;
    for (final controller in _animationControllers) {
      controller.reset();
    }
    _animationControllers[index].forward();
    widget.onSelect?.call(_selectedIndex);
  }
}
