import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quiver/iterables.dart';

class LoadingText extends StatefulWidget {
  final Key key;
  final String text;
  final String dots;
  final TextStyle textStyle;
  final Duration duration;

  LoadingText(
      {this.key,
        this.text = "Loading",
        this.dots = ".",
        Duration duration,
        this.textStyle})
      : this.duration = duration ?? Duration(milliseconds: 1000);

  @override
  State<StatefulWidget> createState() {
    return new LoadingTextState();
  }
}

class LoadingTextState extends State<LoadingText> {
  static int _dotsNum = 3;
  int _count = 0;
  bool _disposed = false;

  LoadingTextState();

  @override
  void initState() {
    super.initState();
    Timer.periodic(widget.duration, (timer) {
      if (!_disposed)
      this.setState(() {
        this._count += 1;
        if (this._count > 3) this._count = 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    final textView = Text(widget.text, style: widget.textStyle);

    children.add(textView);

    range(LoadingTextState._dotsNum).forEach((i) {
      var textStyle = widget.textStyle;

      if (i >= this._count) {
        textStyle = textStyle.copyWith(color: Colors.transparent);
      }
      final dot = Text(widget.dots, style: textStyle);
      children.add(dot);
    });

    return Flex(
      key: widget.key,
      children: children,
      mainAxisSize: MainAxisSize.min,
      direction: Axis.horizontal,
    );
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
