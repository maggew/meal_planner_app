import 'package:flutter/material.dart';
import 'package:meal_planner/presentation/show_recipe/widgets/cooking_mode/cooking_mode_instructions.dart';
import 'package:meal_planner/presentation/show_recipe/widgets/cooking_mode/cooking_mode_timer_widget.dart';

class CookingModeStepWidget extends StatefulWidget {
  final String recipeId;
  final String instructionStep;
  final int stepNumber;
  final int totalSteps;

  const CookingModeStepWidget({
    super.key,
    required this.recipeId,
    required this.instructionStep,
    required this.stepNumber,
    required this.totalSteps,
  });

  @override
  State<CookingModeStepWidget> createState() => _CookingModeStepWidgetState();
}

class _CookingModeStepWidgetState extends State<CookingModeStepWidget> {
  late final ScrollController _scrollController;
  bool _isScrollable = false;
  bool _isAtTop = true;
  bool _isAtBottom = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkScrollable());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _checkScrollable() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    final scrollable = position.maxScrollExtent > 0;
    final atTop = position.pixels <= 0;
    final atBottom = position.pixels >= position.maxScrollExtent;

    if (scrollable != _isScrollable ||
        atTop != _isAtTop ||
        atBottom != _isAtBottom) {
      setState(() {
        _isScrollable = scrollable;
        _isAtTop = atTop;
        _isAtBottom = atBottom;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CookingModeTimerWidget(
          recipeId: widget.recipeId,
          stepIndex: widget.stepNumber,
        ),
        Expanded(
          child: ShaderMask(
            shaderCallback: (Rect bounds) {
              if (!_isScrollable || (_isAtTop && _isAtBottom)) {
                return LinearGradient(colors: [Colors.white, Colors.white])
                    .createShader(bounds);
              }
              return LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _isAtTop ? Colors.white : Colors.transparent,
                  Colors.white,
                  Colors.white,
                  _isAtBottom ? Colors.white : Colors.transparent,
                ],
                stops: [0.0, 0.04, 0.85, 1.0],
              ).createShader(bounds);
            },
            blendMode: BlendMode.dstIn,
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                _checkScrollable();
                return false;
              },
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: EdgeInsets.only(bottom: 10, top: 8),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 100),
                      child: CookingModeInstructions(
                        instructionStep: widget.instructionStep,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
