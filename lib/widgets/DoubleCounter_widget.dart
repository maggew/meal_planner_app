import 'package:flutter/material.dart';

class DoubleCounter extends StatefulWidget {
  final bool supportFraction;
  final dynamic initialValue, stepValue, maxLimit, minLimit;
  final double width, height, borderWidth;
  final Function(dynamic value) onChanged;
  final EdgeInsetsGeometry margin;
  final TextStyle style;
  final Color buttonColor, counterColor, borderColor;
  final bool isNavButton;
  final bool enabled;
  DoubleCounter(
      {this.maxLimit = 99999,
      this.minLimit = -99999,
      this.borderWidth = 1,
      this.width = 120,
      this.height = 35,
      this.initialValue = 0,
      this.stepValue = 1,
      this.supportFraction = false,
      this.buttonColor = Colors.white,
      this.counterColor = Colors.white,
      this.borderColor = Colors.black,
      this.isNavButton = false,
      this.enabled = true,
      this.margin = const EdgeInsets.all(5.0),
      this.style = const TextStyle(
        fontFamily: 'SegoeUI',
        color: Color(0xff000000),
        fontSize: 18,
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ),
      required this.onChanged});
  @override
  _DoubleCounterState createState() => _DoubleCounterState();
}

class _DoubleCounterState extends State<DoubleCounter> {
  late String counter;
  @override
  void initState() {
    counter = widget.initialValue.toString();
    super.initState();
  }

  TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //TODO: Generalization
    _controller.text = counter;
    _controller.addListener(() {
      String newText = _controller.text;
      counter = ((newText.isEmpty) ? 0.0 : double.parse(newText))
          .toStringAsFixed(widget.supportFraction ? 1 : 0);
      _controller.selection = TextSelection(
          baseOffset: newText.length, extentOffset: newText.length);
    });
    return Container(
      width: widget.width,
      height: widget.height,
      margin: widget.margin,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          !widget.enabled && double.parse(counter) <= widget.minLimit
              ? Container(
                  width: widget.width * 0.32,
                )
              : InkWell(
                  onTap: () {
                    if (double.parse(counter) > widget.minLimit)
                      setState(() {
                        counter = (double.parse(counter) - widget.stepValue)
                            .toStringAsFixed(widget.supportFraction ? 1 : 0);

                        widget.onChanged(counter);
                      });
                  },
                  child: Container(
                    width: widget.width * 0.32,
                    height: widget.height,
                    decoration: BoxDecoration(
                        color: widget.buttonColor,
                        border: Border.all(
                            color: widget.borderColor,
                            width: widget.borderWidth),
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(3),
                            bottomLeft: Radius.circular(3))),
                    child: Center(
                      child: widget.isNavButton
                          ? Icon(Icons.keyboard_arrow_left)
                          : Text(
                              "-",
                              style: widget.style,
                            ),
                    ),
                  ),
                ),
          Container(
            width: widget.width * 0.36,
            height: widget.height,
            decoration: BoxDecoration(
              color: widget.counterColor,
              border: Border(
                top: BorderSide(
                  color: widget.borderColor,
                  width: widget.borderWidth,
                ),
                bottom: BorderSide(
                  color: widget.borderColor,
                  width: widget.borderWidth,
                ),
              ),
            ),
            child: Center(
              child: TextFormField(
                onChanged: ((value) {
                  widget.onChanged(value);
                }),
                enabled: widget.enabled,
                controller: _controller,
                /*onSubmitted: ((value) {
                  widget.onChanged(value);
                }),*/
                style: widget.style,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 1.0),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          !widget.enabled && double.parse(counter) >= widget.maxLimit
              ? Container(
                  width: widget.width * 0.32,
                )
              : InkWell(
                  onTap: () {
                    if (double.parse(counter) < widget.maxLimit)
                      setState(() {
                        counter = (double.parse(counter) + widget.stepValue)
                            .toStringAsFixed(widget.supportFraction ? 1 : 0);
                        widget.onChanged(counter);
                      });
                  },
                  child: Container(
                    width: widget.width * 0.32,
                    height: widget.height,
                    decoration: BoxDecoration(
                        color: widget.buttonColor,
                        border: Border.all(
                            color: widget.borderColor,
                            width: widget.borderWidth),
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(3),
                            bottomRight: Radius.circular(3))),
                    child: Center(
                      child: widget.isNavButton
                          ? Icon(Icons.keyboard_arrow_right)
                          : Text(
                              "+",
                              style: widget.style,
                            ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
