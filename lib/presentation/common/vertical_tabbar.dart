import 'package:flutter/material.dart';
import 'package:meal_planner/domain/enums/tab_position.dart';

enum IndicatorSide { start, end }

/// A vertical tab widget for flutter
class VerticalTabs extends StatefulWidget {
  final Key? key;
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
  final Color? selectedTabBackgroundColor;
  final Color? tabBackgroundColor;
  final TextStyle? selectedTabTextStyle;
  final TextStyle? tabTextStyle;
  final Duration changePageDuration;
  final Curve changePageCurve;
  final Color? tabsShadowColor;
  final double tabsElevation;
  final Function(int tabIndex)? onSelect;
  final Color? backgroundColor;

  VerticalTabs({
    this.key,
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
    this.selectedTabBackgroundColor,
    this.tabBackgroundColor,
    this.selectedTabTextStyle,
    this.tabTextStyle,
    this.changePageCurve = Curves.easeInOut,
    this.changePageDuration = const Duration(milliseconds: 300),
    this.tabsShadowColor,
    this.tabsElevation = 2.0,
    this.onSelect,
    this.backgroundColor,
  })  : assert(tabs.length == contents.length),
        super(key: key);

  @override
  _VerticalTabsState createState() => _VerticalTabsState();
}

class _VerticalTabsState extends State<VerticalTabs>
    with TickerProviderStateMixin {
  late int _selectedIndex;
  bool? _changePageByTapView;

  PageController pageController = PageController();

  List<AnimationController> animationControllers = [];

  ScrollPhysics pageScrollPhysics = AlwaysScrollableScrollPhysics();

  @override
  void initState() {
    _selectedIndex = widget.initialIndex;
    for (int i = 0; i < widget.tabs.length; i++) {
      animationControllers.add(AnimationController(
        duration: const Duration(milliseconds: 400),
        vsync: this,
      ));
    }
    _selectTab(widget.initialIndex);

    if (widget.disabledChangePageFromContentView == true) {
      pageScrollPhysics = NeverScrollableScrollPhysics();
    }

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      pageController.jumpToPage(widget.initialIndex);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Theme-aware Farben mit optionalem Override
    final effectiveIndicatorColor =
        widget.indicatorColor ?? colorScheme.secondary;
    final effectiveSelectedBg =
        widget.selectedTabBackgroundColor ?? colorScheme.surfaceContainer;
    final effectiveTabBg = widget.tabBackgroundColor ?? colorScheme.surface;
    final effectiveShadowColor = widget.tabsShadowColor ?? Colors.transparent;
    final effectiveBgColor = widget.backgroundColor ?? Colors.transparent;
    final effectiveSelectedTextStyle =
        widget.selectedTabTextStyle ?? TextStyle(color: colorScheme.onSurface);
    final effectiveTabTextStyle = widget.tabTextStyle ??
        TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5));

    final direction = widget.tabsPosition == TabPosition.right
        ? TextDirection.rtl
        : TextDirection.ltr;

    return Directionality(
      textDirection: direction,
      child: Container(
        color: effectiveBgColor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Expanded(
              child: Row(
                children: <Widget>[
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Material(
                      clipBehavior: Clip.antiAlias,
                      child: Container(
                        width: widget.tabsWidth,
                        child: ListView.builder(
                          itemCount: widget.tabs.length,
                          itemBuilder: (context, index) {
                            Tab tab = widget.tabs[index];

                            Alignment alignment = Alignment.centerLeft;
                            if (widget.tabsPosition == TabPosition.right) {
                              alignment = Alignment.centerRight;
                            }

                            Widget child;
                            if (tab.child != null) {
                              child = tab.child!;
                            } else {
                              child = Container(
                                padding: EdgeInsets.all(10),
                                child: Row(
                                  children: <Widget>[
                                    (tab.icon != null)
                                        ? Row(
                                            children: <Widget>[
                                              tab.icon!,
                                              SizedBox(width: 5),
                                            ],
                                          )
                                        : Container(),
                                    (tab.text != null)
                                        ? Container(
                                            width: widget.tabsWidth - 50,
                                            child: Text(
                                              tab.text!,
                                              softWrap: true,
                                              style: _selectedIndex == index
                                                  ? effectiveSelectedTextStyle
                                                  : effectiveTabTextStyle,
                                            ),
                                          )
                                        : Container(),
                                  ],
                                ),
                              );
                            }

                            Color itemBGColor = effectiveTabBg;
                            if (_selectedIndex == index) {
                              itemBGColor = effectiveSelectedBg;
                            }

                            double? left, right;
                            if (widget.tabsPosition == TabPosition.left) {
                              left =
                                  (widget.indicatorSide == IndicatorSide.start)
                                      ? 0
                                      : null;
                              right =
                                  (widget.indicatorSide == IndicatorSide.end)
                                      ? 0
                                      : null;
                            } else {
                              left = (widget.indicatorSide == IndicatorSide.end)
                                  ? 0
                                  : null;
                              right =
                                  (widget.indicatorSide == IndicatorSide.start)
                                      ? 0
                                      : null;
                            }

                            return Stack(
                              children: <Widget>[
                                GestureDetector(
                                  onTap: () {
                                    _changePageByTapView = true;
                                    setState(() {
                                      _selectTab(index);
                                    });

                                    pageController.animateToPage(index,
                                        duration: widget.changePageDuration,
                                        curve: widget.changePageCurve);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: itemBGColor,
                                      borderRadius: index == 0
                                          ? BorderRadius.only(
                                              topRight: widget.tabsPosition ==
                                                      TabPosition.left
                                                  ? const Radius.circular(8)
                                                  : Radius.zero,
                                              topLeft: widget.tabsPosition ==
                                                      TabPosition.right
                                                  ? const Radius.circular(8)
                                                  : Radius.zero,
                                            )
                                          : null,
                                    ),
                                    clipBehavior:
                                        index == 0 ? Clip.antiAlias : Clip.none,
                                    alignment: alignment,
                                    padding: EdgeInsets.all(5),
                                    child: child,
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  bottom: 0,
                                  width: widget.indicatorWidth,
                                  left: left,
                                  right: right,
                                  child: ScaleTransition(
                                    child: Container(
                                      color: effectiveIndicatorColor,
                                    ),
                                    scale: Tween(begin: 0.0, end: 1.0).animate(
                                      CurvedAnimation(
                                        parent: animationControllers[index],
                                        curve: Curves.elasticOut,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      elevation: widget.tabsElevation,
                      shadowColor: effectiveShadowColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topRight: widget.tabsPosition == TabPosition.left
                              ? const Radius.circular(8)
                              : Radius.zero,
                          topLeft: widget.tabsPosition == TabPosition.right
                              ? const Radius.circular(8)
                              : Radius.zero,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Directionality(
                      textDirection: TextDirection.ltr,
                      child: PageView.builder(
                        scrollDirection: widget.contentScrollAxis,
                        physics: pageScrollPhysics,
                        onPageChanged: (index) {
                          if (_changePageByTapView == false ||
                              _changePageByTapView == null) {
                            _selectTab(index);
                          }
                          if (_selectedIndex == index) {
                            _changePageByTapView = null;
                          }
                          setState(() {});
                        },
                        controller: pageController,
                        itemCount: widget.contents.length,
                        itemBuilder: (BuildContext context, int index) {
                          return widget.contents[index];
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectTab(index) {
    _selectedIndex = index;
    for (AnimationController animationController in animationControllers) {
      animationController.reset();
    }
    animationControllers[index].forward();

    if (widget.onSelect != null) {
      widget.onSelect!(_selectedIndex);
    }
  }
}

