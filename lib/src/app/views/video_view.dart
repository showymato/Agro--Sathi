import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:drone_s500/src/app/utils/camera_preview_scanner.dart';

class MyVideoView extends StatefulWidget {
  MyVideoView({Key key}) : super(key: key);

  @override
  _MyVideoViewState createState() => _MyVideoViewState();
}

class _MyVideoViewState extends State<MyVideoView> {

  double _rightDirection = 0;
  double _leftDirection = 0;

  bool _upLeft = false;
  bool _downLeft = false;
  bool _rightLeft = false;
  bool _leftLeft = false;
  bool _upRight = false;
  bool _downRight = false;
  bool _rightRight = false;
  bool _leftRight = false;
  bool _labelVisibility = false;

  int ch1 = 1500, ch2 = 1500, ch3 = 1000, ch4 = 1500;

  @override
  void initState() {
    super.initState();
    connectToServer1();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  Socket socket;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return new Future(() => false);
      },
      child: Scaffold(
        body: Center(
          child: Stack(
            children: <Widget>[
              Directionality(
                textDirection: TextDirection.ltr,
                child: Stack(
                  children: <Widget>[
                    CameraPreviewScanner(),
                    Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(top: 35, right: 40),
                          child: Align(
                            alignment: Alignment.topRight,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _labelVisibility = !_labelVisibility;
                                    });
                                  },
                                  child: Tooltip(
                                    message: 'Show/Hide Label',
                                    child: Image(
                                      image: AssetImage(!_labelVisibility
                                          ? 'assets/images-png/extend_left.png'
                                          : 'assets/images-png/extend_right.png'),
                                      width: 25,
                                      height: 25,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                    SystemChrome.setPreferredOrientations([
                                      DeviceOrientation.portraitUp,
                                      DeviceOrientation.portraitDown,
                                    ]);
                                  },
                                  child: Row(
                                    children: <Widget>[
                                      Tooltip(
                                        message: 'Home',
                                        child: Image(
                                          image: AssetImage(
                                              'assets/images-png/home_button.png'),
                                          width: 30,
                                          height: 30,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 8,
                                      ),
                                      Visibility(
                                        visible: _labelVisibility,
                                        child: Stack(
                                          children: <Widget>[
                                            Text(
                                              'Home',
                                              textScaleFactor: 1.0,
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  color: Color(0xffCEE8FA),
                                                  fontFamily:
                                                      'WorkSansSemiBold'),
                                            ),
                                            Text(
                                              'Home',
                                              textScaleFactor: 1.0,
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontFamily: 'WorkSansSemiBold',
                                                foreground: Paint()
                                                  ..style = PaintingStyle.stroke
                                                  ..strokeWidth = 1.4
                                                  ..color = Color(0xff2D527C),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    print('Stop Engine');
                                  },
                                  child: Row(
                                    children: <Widget>[
                                      Tooltip(
                                        message: 'Stop Engine',
                                        child: Image(
                                          image: AssetImage(
                                              'assets/images-png/stop_engine.png'),
                                          width: 30,
                                          height: 30,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 8,
                                      ),
                                      Visibility(
                                        visible: _labelVisibility,
                                        child: Stack(
                                          children: <Widget>[
                                            Text(
                                              'Stop Engine',
                                              textScaleFactor: 1.0,
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  color: Color(0xffCEE8FA),
                                                  fontFamily:
                                                      'WorkSansSemiBold'),
                                            ),
                                            Text(
                                              'Stop Engine',
                                              textScaleFactor: 1.0,
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontFamily: 'WorkSansSemiBold',
                                                foreground: Paint()
                                                  ..style = PaintingStyle.stroke
                                                  ..strokeWidth = 1.4
                                                  ..color = Color(0xff2D527C),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    print('Stop Engine');
                                  },
                                  child: Row(
                                    children: <Widget>[
                                      Tooltip(
                                        message: 'Return Home',
                                        child: Image(
                                          image: AssetImage(
                                              'assets/images-png/home.png'),
                                          width: 35,
                                          height: 35,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 8,
                                      ),
                                      Visibility(
                                        visible: _labelVisibility,
                                        child: Stack(
                                          children: <Widget>[
                                            Text(
                                              'Return Home',
                                              textScaleFactor: 1.0,
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  color: Color(0xffCEE8FA),
                                                  fontFamily:
                                                      'WorkSansSemiBold'),
                                            ),
                                            Text(
                                              'Return Home',
                                              textScaleFactor: 1.0,
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontFamily: 'WorkSansSemiBold',
                                                foreground: Paint()
                                                  ..style = PaintingStyle.stroke
                                                  ..strokeWidth = 1.4
                                                  ..color = Color(0xff2D527C),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Spacer(),
                        SizedBox(height: 20),
                        Row(
                          children: <Widget>[
                            SizedBox(width: 48),
                            Spacer(),
                            Image(
                              image: AssetImage(
                                  'assets/images-png/joyPadRight.png'),
                              width: 120,
                              height: 120,
                            ),
                            SizedBox(width: 48),
                          ],
                        ),
                        SizedBox(height: 24),
                      ],
                    ),
                  ],
                ),
              ),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Stack(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Spacer(),
                        Row(
                          children: <Widget>[
                            Spacer(),
                            SizedBox(
                              child: Container(
                                color: Colors.white.withAlpha(150),
                                child: Text(_upLeft
                                    ? 'Left JoyPad moved up'
                                    : _downLeft
                                        ? 'Left JoyPad moved down'
                                        : _leftLeft
                                            ? 'Left JoyPad moved left'
                                            : _rightLeft
                                                ? 'Left JoyPad moved right'
                                                : ""),
                              ),
                            ),
                            Spacer(),
                            SizedBox(
                              child: Container(
                                color: Colors.white.withAlpha(150),
                                child: Text(_upRight
                                    ? 'Right JoyPad moved up'
                                    : _downRight
                                        ? 'Right JoyPad moved down'
                                        : _leftRight
                                            ? 'Right JoyPad moved left'
                                            : _rightRight
                                                ? 'Right JoyPad moved right'
                                                : ""),
                              ),
                            ),
                            Spacer(),
                          ],
                        ),
                        Spacer(),
                        SizedBox(height: 20),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            SizedBox(width: 48),
                            Column(
                              children: <Widget>[
                                GestureDetector(
                                  child: Icon(
                                    Icons.arrow_upward,
                                    size: 50,
                                    color: Colors.blue,
                                  ),
                                  onTap: () {
                                    updateCh3Up(50);
                                  },
                                ),
                                Row(
                                  children: <Widget>[
                                    GestureDetector(
                                      child: Icon(
                                        Icons.arrow_back,
                                        size: 50,
                                        color: Colors.blue,
                                      ),
                                      onTap: () {
                                        print("tapped ch3 to left");
                                      },
                                    ),
                                    SizedBox(
                                      width: 40,
                                    ),
                                    GestureDetector(
                                      child: Icon(
                                        Icons.arrow_forward,
                                        size: 50,
                                        color: Colors.blue,
                                      ),
                                      onTap: () {
                                        print("tapped ch3 to right");
                                      },
                                    ),
                                  ],
                                ),
                                GestureDetector(
                                  child: Icon(
                                    Icons.arrow_downward,
                                    size: 50,
                                    color: Colors.blue,
                                  ),
                                  onTap: () {
                                    updateCh3Down(-50);
                                  },
                                ),
                              ],
                            ),
                            Spacer(),
                            JoyPadRight(
                              onChange: onRightJoyPadChange,
                            ),
                            SizedBox(width: 48),
                          ],
                        ),
                        SizedBox(height: 24),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void onLeftJoyPadChange(Offset offset) {
    print(_leftDirection);
    if (offset == Offset.zero) {
      setState(() {
        _downLeft = false;
        _leftLeft = false;
        _rightLeft = false;
        _upLeft = false;
      });
    } else {
      _leftDirection = offset.direction;
      if (_leftDirection < -1.39 &&
          _leftDirection > -1.81) // Up Movement on the left joyPad
        setState(() {
          _downLeft = false;
          _leftLeft = false;
          _rightLeft = false;
          _upLeft = true;
        });
      else if (_leftDirection < 1.39 &&
          _leftDirection > 0.59) // Down Movement on the left joyPad
      {
        setState(() {
          _downLeft = true;
          _leftLeft = false;
          _rightLeft = false;
          _upLeft = false;
        });
      } else if (_leftDirection < 3.14 &&
          _leftDirection > 2.99) // Left Movement on the left joyPad
      {
        setState(() {
          _downLeft = false;
          _leftLeft = true;
          _rightLeft = false;
          _upLeft = false;
        });
      } else if (_leftDirection < -0.13 &&
          _leftDirection > -0.38) // Right Movement on the left joyPad
      {
        setState(() {
          _downLeft = false;
          _leftLeft = false;
          _rightLeft = true;
          _upLeft = false;
        });
      }
    }
  }

  void onRightJoyPadChange(Offset offset) {
    print(_rightDirection);
    if (offset == Offset.zero) {
      setState(() {
        _downRight = false;
        _leftRight = false;
        _rightRight = false;
        _upRight = false;
      });
    } else {
      _rightDirection = offset.direction;
      if (_rightDirection < -1.39 &&
          _rightDirection > -1.81) // Up Movement on the Right joyPad
        setState(() {
          _downRight = true;
          _leftRight = false;
          _rightRight = false;
          _upRight = true;
        });
      else if (_rightDirection < 1.39 &&
          _rightDirection > 0.59) // Down Movement on the Right joyPad
      {
        setState(() {
          _downRight = true;
          _leftRight = false;
          _rightRight = false;
          _upRight = false;
        });
      } else if (_rightDirection < 3.14 &&
          _rightDirection > 2.99) // Left Movement on the Right joyPad
      {
        setState(() {
          _downRight = false;
          _leftRight = true;
          _rightRight = false;
          _upRight = false;
        });
      } else if (_rightDirection < -0.13 &&
          _rightDirection > -0.38) // Right Movement on the Right joyPad
      {
        setState(() {
          _downRight = false;
          _leftRight = false;
          _rightRight = true;
          _upRight = false;
        });
      }
    }
  }

  void updateCh3Up(int value) {
    if (value >= 1000 && value <= 2000) socket.write(50);
  }

  void updateCh3Down(int value) {
    if (value >= 1000 && value <= 2000) socket.write(-50);
  }

  Future<void> connectToServer1() async {
    Socket.connect('192.168.43.124', 8190).then((Socket sock) {
      socket = sock;
      socket.listen(dataHandlerVoice,
          onError: errorHandlerVoice,
          onDone: doneHandlerVoice,
          cancelOnError: false);
    });
  }

  void dataHandlerVoice(data) {
    print(new String.fromCharCodes(data).trim());
  }

  void errorHandlerVoice(error, StackTrace trace) {
    print(error);
  }

  void doneHandlerVoice() {
    socket.destroy();
  }
}

class JoyPadLeft extends StatefulWidget {
  final void Function(Offset) onChange;

  const JoyPadLeft({
    Key key,
    @required this.onChange,
  }) : super(key: key);

  JoyPadLeftState createState() => JoyPadLeftState();
}

class JoyPadLeftState extends State<JoyPadLeft> {
  Offset delta = Offset.zero;

  void updateDelta(Offset newDelta) {
    widget.onChange(newDelta);
    setState(() {
      delta = newDelta;
    });
  }

  void calculateDelta(Offset offset) {
    Offset newDelta = offset - Offset(60, 60);
    updateDelta(
      Offset.fromDirection(
        newDelta.direction,
        min(40, newDelta.distance),
      ),
    );
  }

  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      width: 120,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: GestureDetector(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue.withAlpha(110),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Center(
              child: Transform.translate(
                offset: delta,
                child: SizedBox(
                  height: 40,
                  width: 40,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xccCEE8FA),
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
            ),
          ),
          onPanDown: onDragDown,
          onPanUpdate: onDragUpdate,
          //onPanEnd: onDragEnd,
          onPanCancel: onDragCancel,
        ),
      ),
    );
  }

  void onDragDown(DragDownDetails d) {
    calculateDelta(d.localPosition);
  }

  void onDragUpdate(DragUpdateDetails d) {
    calculateDelta(d.localPosition);
  }

  void onDragEnd(DragEndDetails d) {
    updateDelta(Offset.zero);
  }

  void onDragCancel() {
    updateDelta(Offset.zero);
  }
}

class JoyPadRight extends StatefulWidget {
  final void Function(Offset) onChange;

  const JoyPadRight({
    Key key,
    @required this.onChange,
  }) : super(key: key);

  JoyPadRightState createState() => JoyPadRightState();
}

class JoyPadRightState extends State<JoyPadRight> {
  Offset delta = Offset.zero;

  void updateDelta(Offset newDelta) {
    widget.onChange(newDelta);
    setState(() {
      delta = newDelta;
    });
  }

  void calculateDelta(Offset offset) {
    Offset newDelta = offset - Offset(60, 60);
    updateDelta(
      Offset.fromDirection(
        newDelta.direction,
        min(60, newDelta.distance),
      ),
    );
  }

  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      width: 120,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: GestureDetector(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue.withAlpha(110),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Center(
              child: Transform.translate(
                offset: delta,
                child: SizedBox(
                  height: 40,
                  width: 40,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xccCEE8FA),
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
            ),
          ),
          onPanDown: onDragDown,
          onPanUpdate: onDragUpdate,
          onPanEnd: onDragEnd,
          onPanCancel: onDragCancel,
        ),
      ),
    );
  }

  void onDragDown(DragDownDetails d) {
    calculateDelta(d.localPosition);
  }

  void onDragUpdate(DragUpdateDetails d) {
    calculateDelta(d.localPosition);
  }

  void onDragEnd(DragEndDetails d) {
    updateDelta(Offset.zero);
  }

  void onDragCancel() {
    updateDelta(Offset.zero);
  }
}

class ButtonHome extends StatelessWidget {
  const ButtonHome({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(0),
      child: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(
              image: AssetImage('assets/images-png/home_button.png'),
              width: 30,
              height: 30,
            ),
            SizedBox(
              width: 15,
            ),
            Stack(
              children: <Widget>[
                Text(
                  'Home',
                  textScaleFactor: 1.0,
                  style: TextStyle(
                      fontSize: 22,
                      color: Color(0xffCEE8FA),
                      fontFamily: 'WorkSansSemiBold'),
                ),
                Text(
                  'Home',
                  textScaleFactor: 1.0,
                  style: TextStyle(
                    fontSize: 22,
                    fontFamily: 'WorkSansSemiBold',
                    foreground: Paint()
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = 1.4
                      ..color = Color(0xff2D527C),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
