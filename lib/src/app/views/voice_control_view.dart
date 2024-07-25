import 'dart:ui';

import 'package:drone_s500/src/app/utils/socket_client.dart';
import 'package:intl/intl.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:drone_s500/src/app/views/dashboard_page.dart';
import 'package:drone_s500/src/app/views/video_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:ssh/ssh.dart';
import 'package:video_player/video_player.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VoiceControl extends StatefulWidget {
  VoiceControl({Key key}) : super(key: key);

  @override
  _VoiceControlState createState() => new _VoiceControlState();
}

enum TtsState { playing, stopped }

class _VoiceControlState extends State<VoiceControl>
    with SingleTickerProviderStateMixin {
  static String textHistory = "";
  static List<String> parametersList = List();

  VideoPlayerController _controller;

  var clientProxy = new SSHClient(
    host: "192.168.43.124",
    port: 22,
    username: "pi",
    passwordOrKey: "raspberry",
  );

  var clientServer = new SSHClient(
    host: "192.168.43.124",
    port: 22,
    username: "pi",
    passwordOrKey: "raspberry",
  );

  bool parametersVisibility = false;
  bool _parametersVisibility = false;
  bool helpVisibility = false;
  bool micTextState = false;
  bool micState = false;
  bool _hasSpeech = false;
  bool _openHistory = false;
  bool _openCamera = false;
  bool _openMode = false;
  bool _cDropDown = false;
  bool _inOutDoor = true;
  bool _stabilize = false;
  bool _guided = false;
  bool _positionHold = false;
  bool _autoMode = false;
  bool _visibleMode = false;
  bool _batteryLow = false;
  double _parametersHeight = 45;
  double _parametersWidth = 110;
  double _helpHeight = 45;
  double _helpWidth = 110;
  double level = 0.0;
  double _bLevel = 50;
  double _batteryLevelPercents = 20;
  double minSoundLevel = 50000;
  double maxSoundLevel = -50000;
  double _historyHeight = 0;
  double _historyWidth = 0;
  double _cameraHeight = 0;
  double _cameraWidth = 0;
  double volume = 1.0;
  double pitch = 1.0;
  double rate = 0.8;
  double _modeHeight = 0;
  double _modeWidth = 0;
  double _signalLevel = 0;

  String lastWords = "";
  String lastError = "";
  String lastStatus = "";
  String _currentLocaleId = "en_US";
  String option;
  String _signalStatus = "Pure";
  final SpeechToText speech = SpeechToText();

  FlutterTts flutterTts;
  dynamic languages;
  String language;
  String _newVoiceText;
  TtsState ttsState = TtsState.stopped;

  get isPlaying => ttsState == TtsState.playing;

  get isStopped => ttsState == TtsState.stopped;

  String textSpeech = "";
  List<ListTile> historyWord;
  List<String> parametersFromDrone = List();
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    initTts();
    initSpeechState();
    _controller =
        VideoPlayerController.asset('assets/video-mp4/drone_intro.mp4')
          ..initialize().then((_) {
            _controller.setLooping(true);
            _controller.setVolume(0);
            _controller.pause();
            setState(() {});
          });

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SocketClient.socketParameters.write("100");
    synchronizeParameters();
    welcomeMessage();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return new Future(() => false);
      },
      child: new Scaffold(
        body: GestureDetector(
          onTap: () {
            Future.delayed(const Duration(milliseconds: 400), () {
              setState(() {
                _openHistory = false;
                _openCamera = false;
                _openMode = false;
                _cDropDown = false;
              });
            });
            setState(() {
              _historyHeight = 0;
              _parametersHeight = 45;
              _parametersWidth = 110;
              _helpHeight = 45;
              _helpWidth = 110;
              _cameraHeight = 0;
              _historyWidth = 0;
              _cameraWidth = 0;
              _modeHeight = 0;
              _modeWidth = 0;
              _visibleMode = false;
              helpVisibility = false;
              _parametersVisibility = false;
            });
          },
          child: Container(
            decoration: BoxDecoration(
                image: DecorationImage(
              image: AssetImage('assets/images-jpg/blue_mountains.jpg'),
              fit: BoxFit.cover,
            )),
            child: Stack(
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                        padding: EdgeInsets.only(top: 40.0, left: 10.0),
                        child: _buttonDropDown(context)),
                    Padding(
                        padding: EdgeInsets.only(top: 0.0, left: 10.0),
                        child: _controlsDropDown(context)),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(top: 40.0, right: 20.0),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: _batteryLevel(context),
                  ),
                ),
                Padding(
                    padding: EdgeInsets.only(top: 90.0, right: 10.0),
                    child: Column(
                      children: <Widget>[
                        Align(
                          alignment: Alignment.topRight,
                          child: _parametersView(context),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: _helpView(context),
                        ),
                      ],
                    )),
                Padding(
                  padding: EdgeInsets.only(top: 47.0, right: 60.0),
                  child: Column(
                    children: <Widget>[
                      Align(
                        alignment: Alignment.topRight,
                        child: _signalStrength(context),
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: _message(context),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: _microphone(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _controlsDropDown(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 400),
      height: 185 + _historyHeight + _cameraHeight + _modeHeight,
      width: MediaQuery.of(context).size.width / 1.5,
      child: Visibility(
          visible: _cDropDown,
          child: Row(
            children: [
              AnimatedContainer(
                duration: Duration(milliseconds: 400),
                width: 5,
                height: 200 + _historyHeight + _cameraHeight + _modeHeight,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.white, Colors.blueAccent],
                      stops: [0.1, 0.5],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(3.0)),
              ),
              Expanded(
                child: ScrollConfiguration(
                  behavior: MyBehavior(),
                  child: ListView(
                    padding: EdgeInsets.all(0),
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          _buttonHistory(context),
                          _commandsHistory(context),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          _buttonCamera(context),
                          _cameraView(context),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          _buttonMode(context),
                          _modeView(context),
                        ],
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: _buttonHome(context),
                      )
                    ],
                  ),
                ),
              ),
            ],
          )),
    );
  }

  Widget _buttonDropDown(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_cDropDown == false) {
          setState(() {
            _cDropDown = true;
          });
        } else {
          setState(() {
            _cameraHeight = 0;
            _cameraWidth = 0;
            _historyHeight = 0;
            _historyWidth = 0;
            _modeWidth = 0;
            _modeHeight = 0;
            _openMode = false;
            _openHistory = false;
            _openCamera = false;
            _visibleMode = false;
            Future.delayed(const Duration(milliseconds: 300), () {
              setState(() {
                _cDropDown = false;
              });
            });
          });
        }
      },
      child: Visibility(
        visible: true,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.4),
                spreadRadius: 0,
                blurRadius: 4,
                offset: Offset(0, 1), // changes position of shadow
              ),
            ],
          ),
          child: Icon(
            !_cDropDown ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
            color: Colors.blueAccent,
            size: 35,
          ),
        ),
      ),
    );
  }

  Widget _buttonHistory(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Visibility(
      visible: true,
      child: MaterialButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        child: ButtonWithText(
          icon: (Icons.history),
          text: !_openHistory ? 'Commands\nHistory' : '',
        ),
        onPressed: () {
          if (_historyHeight == 0) {
            setState(() {
              _openHistory = !_openHistory;
              _openCamera = false;
              _openMode = false;
              _historyWidth = width / 2.5;
              _historyHeight = height / 4;
              _cameraHeight = 0;
              _cameraWidth = 0;
              _modeHeight = 0;
              _modeWidth = 0;
              _visibleMode = false;
            });
          } else {
            Future.delayed(const Duration(milliseconds: 400), () {
              setState(() {
                _openHistory = !_openHistory;
                _openCamera = false;
                _openMode = false;
              });
            });
            setState(() {
              _historyHeight = 0;
              _historyWidth = 0;
              _visibleMode = false;
            });
          }
        },
      ),
    );
  }

  Widget _buttonCamera(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Visibility(
      visible: true,
      child: MaterialButton(
        child: ButtonWithText(
          icon: (Icons.linked_camera),
          text: !_openCamera ? 'Camera' : '',
        ),
        onPressed: () {
          if (_cameraHeight == 0) {
            setState(() {
              _openCamera = !_openCamera;
              _openHistory = false;
              _openMode = false;
              _cameraWidth = width / 3.5;
              _cameraHeight = height / 4;
              _historyHeight = 0;
              _historyWidth = 0;
              _modeHeight = 0;
              _modeWidth = 0;
              _visibleMode = false;
            });
          } else {
            Future.delayed(const Duration(milliseconds: 400), () {
              setState(() {
                _openCamera = !_openCamera;
                _openHistory = false;
                _openMode = false;
              });
            });
            setState(() {
              _cameraHeight = 0;
              _cameraWidth = 0;
              _visibleMode = false;
            });
          }
        },
      ),
    );
  }

  Widget _buttonMode(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Visibility(
      visible: true,
      child: MaterialButton(
        child: ButtonWithText(
          icon: (Icons.developer_mode),
          text: !_openMode ? 'Mode' : '',
        ),
        onPressed: () {
          if (_modeHeight == 0) {
            setState(() {
              Future.delayed(const Duration(milliseconds: 400), () {
                setState(() {
                  _visibleMode = true;
                });
              });
              _openMode = !_openMode;
              _openHistory = false;
              _openCamera = false;
              _modeWidth = width / 3.5;
              _modeHeight = height / 4;
              _cameraWidth = 0;
              _cameraHeight = 0;
              _historyHeight = 0;
              _historyWidth = 0;
            });
          } else {
            Future.delayed(const Duration(milliseconds: 400), () {
              setState(() {
                _openMode = !_openMode;
                _openHistory = false;
                _openCamera = false;
              });
            });
            setState(() {
              _modeHeight = 0;
              _modeWidth = 0;
              _visibleMode = false;
            });
          }
        },
      ),
    );
  }

  Widget _buttonHome(BuildContext context) {
    return Visibility(
      visible: true,
      child: MaterialButton(
        child: ButtonWithText(
          icon: (Icons.home),
          text: 'Home',
        ),
        onPressed: () {
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
          ]);
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _commandsHistory(BuildContext context) {
    return Visibility(
      visible: true,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 400),
        height: _historyHeight,
        width: _historyWidth,
        child: Card(
          color: Colors.black.withAlpha(90),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
              side: BorderSide(
                  width: 3.0,
                  color: Colors.blueAccent,
                  style: BorderStyle.solid)),
          elevation: 10,
          child: Stack(
            children: <Widget>[
              Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.all(2),
                    child: Text(
                      "HISTORY",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontFamily: "WorkSansSemiBold",
                      ),
                    ),
                  )),
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: EdgeInsets.only(top: 22),
                  child: Container(
                    height: 2,
                    width: 200,
                    color: Colors.blueAccent,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: textHistory == ""
                    ? Container(
                        child: Text(
                          "History is empty!",
                          style: TextStyle(
                            fontFamily: 'WorkSansSemiBold',
                            color: Colors.red,
                          ),
                        ),
                      )
                    : Container(
                        margin: EdgeInsets.only(top: 20),
                        height: 70,
                        width: 180,
                        child: ScrollConfiguration(
                          behavior: ScrollBehavior(),
                          child: ListView(
                            padding: EdgeInsets.only(top: 2),
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Text(
                                    textHistory,
                                    textScaleFactor: 1.0,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12.0,
                                        fontFamily: 'WorkSansMedium'),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cameraView(BuildContext context) {
    return AnimatedContainer(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
      ),
      duration: Duration(milliseconds: 400),
      height: _cameraHeight,
      width: _cameraWidth,
      child: Card(
        color: Colors.black.withAlpha(90),
        shape: RoundedRectangleBorder(
            side: BorderSide(
                width: 3.0,
                color: Colors.blueAccent,
                style: BorderStyle.solid)),
        elevation: 10,
        child: Stack(
          children: <Widget>[
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller.value.size?.width ?? 0,
                  height: _controller.value.size?.height ?? 0,
                  child: Tooltip(
                    showDuration: Duration(seconds: 3),
                    message:
                        'Camera can only be opened from the Dashboard page',
                    child: MyVideoView(),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Text(
                "Camera",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontFamily: "WorkSansSemiBold",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _modeView(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 400),
      height: _modeHeight,
      width: _modeWidth,
      child: Card(
          color: Colors.black.withAlpha(90),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
              side: BorderSide(
                  width: 3.0,
                  color: Colors.blueAccent,
                  style: BorderStyle.solid)),
          elevation: 10,
          child: Visibility(
              visible: _visibleMode ? true : false,
              child: Column(
                children: <Widget>[
                  Expanded(
                      child: Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text(
                      'Mode',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'WorkSansMedium',
                        fontSize: 14,
                      ),
                      textScaleFactor: 1.0,
                    ),
                  )),
                  Expanded(
                    flex: 3,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: GestureDetector(
                              onTap: () {},
                              child: ScrollConfiguration(
                                behavior: MyBehavior(),
                                child: ListView(
                                  padding: EdgeInsets.only(top: 0, left: 5),
                                  children: <Widget>[
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _inOutDoor = !_inOutDoor;
                                        });
                                      },
                                      child: Column(
                                        children: <Widget>[
                                          Row(
                                            children: [
                                              Text(
                                                'Indoor ',
                                                style: TextStyle(
                                                  fontFamily: 'WorkSansMedium',
                                                  color: _inOutDoor
                                                      ? Colors.white
                                                      : Colors.blueAccent,
                                                  fontSize: 10,
                                                ),
                                                textScaleFactor: 1.0,
                                              ),
                                              Text(
                                                '/ ',
                                                style: TextStyle(
                                                  fontFamily: 'WorkSansMedium',
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                ),
                                                textScaleFactor: 1.0,
                                              ),
                                              Text(
                                                'Outdoor',
                                                style: TextStyle(
                                                  fontFamily: 'WorkSansMedium',
                                                  color: _inOutDoor
                                                      ? Colors.blueAccent
                                                      : Colors.white,
                                                  fontSize: 10,
                                                ),
                                                textScaleFactor: 1.0,
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 15,
                                          ),
                                          Icon(
                                            _inOutDoor
                                                ? FontAwesomeIcons.tree
                                                : FontAwesomeIcons.warehouse,
                                            size: 20,
                                            color: Colors.white,
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 15),
                                    Visibility(
                                      visible: true,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _stabilize = !_stabilize;
                                            _guided = false;
                                            _positionHold = false;
                                            _autoMode = false;
                                          });
                                        },
                                        child: ModeText(
                                          icon: _stabilize
                                              ? Icons.adjust
                                              : Icons.blur_circular,
                                          text: 'Stabilize',
                                          color: _stabilize
                                              ? Colors.blueAccent
                                              : Colors.white,
                                        ),
                                      ),
                                    ),
                                    Visibility(
                                      visible: _inOutDoor,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _stabilize = false;
                                            _guided = !_guided;
                                            _positionHold = false;
                                            _autoMode = false;
                                          });
                                        },
                                        child: ModeText(
                                            icon: _guided
                                                ? Icons.adjust
                                                : Icons.blur_circular,
                                            text: 'Guided',
                                            color: _guided
                                                ? Colors.blueAccent
                                                : Colors.white),
                                      ),
                                    ),
                                    Visibility(
                                      visible: true,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _stabilize = false;
                                            _guided = false;
                                            _positionHold = !_positionHold;
                                            _autoMode = false;
                                          });
                                        },
                                        child: ModeText(
                                          icon: _positionHold
                                              ? Icons.adjust
                                              : Icons.blur_circular,
                                          text: 'Position\nhold',
                                          color: _positionHold
                                              ? Colors.blueAccent
                                              : Colors.white,
                                        ),
                                      ),
                                    ),
                                    Visibility(
                                      visible: _inOutDoor,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _stabilize = false;
                                            _guided = false;
                                            _positionHold = false;
                                            _autoMode = !_autoMode;
                                          });
                                        },
                                        child: ModeText(
                                            icon: _autoMode
                                                ? Icons.adjust
                                                : Icons.blur_circular,
                                            text: 'Auto',
                                            color: _autoMode
                                                ? Colors.blueAccent
                                                : Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(top: 0),
                            child: Column(
                              children: <Widget>[
                                Text(
                                  'Return Home',
                                  style: TextStyle(
                                    fontFamily: 'WorkSansMedium',
                                    color: Colors.white,
                                    fontSize: 10,
                                  ),
                                  textScaleFactor: 1.0,
                                ),
                                IconButton(
                                    onPressed: () {},
                                    icon: new Icon(
                                      FontAwesomeIcons.home,
                                      size: 20,
                                      color: Colors.white,
                                    )),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ))),
    );
  }

  Widget _parametersView(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () {
        if (_parametersHeight == 45) {
          setState(() {
            _parametersWidth = width / 2.5;
            _parametersHeight = 180;
            _helpWidth = 110;
            _helpHeight = 45;
            helpVisibility = false;
            Future.delayed(const Duration(milliseconds: 200), () {
              setState(() {
                _parametersVisibility = true;
              });
            });
          });
        } else {
          setState(() {
            _parametersWidth = 110;
            _parametersHeight = 45;
            _parametersVisibility = false;
          });
        }
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        margin: EdgeInsets.only(left: 5),
        height: _parametersHeight,
        width: _parametersWidth,
        child: Card(
          color: Colors.black.withAlpha(90),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
              side: BorderSide(
                  width: 3.0,
                  color: Colors.blueAccent,
                  style: BorderStyle.solid)),
          elevation: 10,
          child: Stack(
            children: <Widget>[
              Align(
                alignment: Alignment.bottomCenter,
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  width: 3,
                  height: _parametersHeight - 45,
                  color: Colors.blue,
                ),
              ),
              Column(
                children: <Widget>[
                  SizedBox(
                    height: 5,
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Text(
                      "Parameters",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontFamily: "WorkSansSemiBold",
                      ),
                      textScaleFactor: 1.0,
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    width: _parametersWidth - 30,
                    height: 3,
                    color: Colors.blue,
                  ),
                  !_parametersVisibility
                      ? Container()
                      : !parametersVisibility
                          ? Container()
                          : Row(
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Align(
                                    alignment: Alignment.bottomRight,
                                    child: Container(
                                      width: _parametersWidth / 2 - 25,
                                      height: _parametersHeight - 60,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Row(
                                            children: <Widget>[
                                              Text(
                                                "Velocity: ",
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.white,
                                                  fontFamily:
                                                      "WorkSansSemiBold",
                                                ),
                                                textScaleFactor: 1.0,
                                              ),
                                              Text(
                                                parametersList[0] +
                                                    parametersList[1]+
                                                    parametersList[2],
                                                style: TextStyle(
                                                  fontSize: 8.5,
                                                  color: Colors.green,
                                                  fontFamily:
                                                      "WorkSansSemiBold",
                                                ),
                                                textScaleFactor: 1.0,
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: <Widget>[
                                              Text(
                                                "GPS: ",
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.white,
                                                  fontFamily:
                                                      "WorkSansSemiBold",
                                                ),
                                                textScaleFactor: 1.0,
                                              ),
                                              Text(
                                                replaceGpsText(
                                                    parametersList[4]),
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.green,
                                                  fontFamily:
                                                      "WorkSansSemiBold",
                                                ),
                                                textScaleFactor: 1.0,
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: <Widget>[
                                              Text(
                                                "Groundspeed: ",
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.white,
                                                  fontFamily:
                                                      "WorkSansSemiBold",
                                                ),
                                                textScaleFactor: 1.0,
                                              ),
                                              Text(
                                                divideBy10(parametersList[5]),
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.green,
                                                  fontFamily:
                                                      "WorkSansSemiBold",
                                                ),
                                                textScaleFactor: 1.0,
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: <Widget>[
                                              Text(
                                                "Airspeed: ",
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.white,
                                                  fontFamily:
                                                      "WorkSansSemiBold",
                                                ),
                                                textScaleFactor: 1.0,
                                              ),
                                              Text(
                                                divideBy10(parametersList[6]),
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.green,
                                                  fontFamily:
                                                      "WorkSansSemiBold",
                                                ),
                                                textScaleFactor: 1.0,
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: <Widget>[
                                              Text(
                                                "Battery: ",
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.white,
                                                  fontFamily:
                                                      "WorkSansSemiBold",
                                                ),
                                                textScaleFactor: 1.0,
                                              ),
                                              Text(
                                                "70%",
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.green,
                                                  fontFamily:
                                                      "WorkSansSemiBold",
                                                ),
                                                textScaleFactor: 1.0,
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: <Widget>[
                                              Text(
                                                "EKF OK: ",
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.white,
                                                  fontFamily:
                                                      "WorkSansSemiBold",
                                                ),
                                                textScaleFactor: 1.0,
                                              ),
                                              Text(
                                                parametersList[10],
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.green,
                                                  fontFamily:
                                                      "WorkSansSemiBold",
                                                ),
                                                textScaleFactor: 1.0,
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: <Widget>[
                                              Text(
                                                "Last hearbeat: ",
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.white,
                                                  fontFamily:
                                                      "WorkSansSemiBold",
                                                ),
                                                textScaleFactor: 1.0,
                                              ),
                                              Text(
                                                divideBy6(parametersList[11]),
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.green,
                                                  fontFamily:
                                                      "WorkSansSemiBold",
                                                ),
                                                textScaleFactor: 1.0,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Container(
                                      width: _parametersWidth / 2 - 25,
                                      height: _parametersHeight - 60,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Row(
                                            children: <Widget>[
                                              Text(
                                                "Mode: ",
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.white,
                                                  fontFamily:
                                                      "WorkSansSemiBold",
                                                ),
                                                textScaleFactor: 1.0,
                                              ),
                                              Text(
                                                parametersList[12],
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.green,
                                                  fontFamily:
                                                      "WorkSansSemiBold",
                                                ),
                                                textScaleFactor: 1.0,
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: <Widget>[
                                              Text(
                                                "Armed: ",
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.white,
                                                  fontFamily:
                                                      "WorkSansSemiBold",
                                                ),
                                                textScaleFactor: 1.0,
                                              ),
                                              Text(
                                                parametersList[13],
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.green,
                                                  fontFamily:
                                                      "WorkSansSemiBold",
                                                ),
                                                textScaleFactor: 1.0,
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: <Widget>[
                                              Text(
                                                "Is armable: ",
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.white,
                                                  fontFamily:
                                                      "WorkSansSemiBold",
                                                ),
                                                textScaleFactor: 1.0,
                                              ),
                                              Text(
                                                parametersList[14],
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.green,
                                                  fontFamily:
                                                      "WorkSansSemiBold",
                                                ),
                                                textScaleFactor: 1.0,
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: <Widget>[
                                              Text(
                                                "System Status: ",
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.white,
                                                  fontFamily:
                                                      "WorkSansSemiBold",
                                                ),
                                                textScaleFactor: 1.0,
                                              ),
                                              Text(
                                                parametersList[15],
                                                style: TextStyle(
                                                  fontSize: 8.5,
                                                  color: Colors.green,
                                                  fontFamily:
                                                      "WorkSansSemiBold",
                                                ),
                                                textScaleFactor: 1.0,
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: <Widget>[
                                              Text(
                                                "Heading: ",
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.white,
                                                  fontFamily:
                                                      "WorkSansSemiBold",
                                                ),
                                                textScaleFactor: 1.0,
                                              ),
                                              Text(
                                                parametersList[16],
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.green,
                                                  fontFamily:
                                                      "WorkSansSemiBold",
                                                ),
                                                textScaleFactor: 1.0,
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: <Widget>[
                                              Text(
                                                "Altitude: ",
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.white,
                                                  fontFamily:
                                                      "WorkSansSemiBold",
                                                ),
                                                textScaleFactor: 1.0,
                                              ),
                                              Text(
                                                parametersList[19],
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.green,
                                                  fontFamily:
                                                      "WorkSansSemiBold",
                                                ),
                                                textScaleFactor: 1.0,
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: <Widget>[
                                              Text(
                                                "DISTANCE: ",
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.white,
                                                  fontFamily:
                                                      "WorkSansSemiBold",
                                                ),
                                                textScaleFactor: 1.0,
                                              ),
                                              Text(
                                                parametersList[20],
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.green,
                                                  fontFamily:
                                                      "WorkSansSemiBold",
                                                ),
                                                textScaleFactor: 1.0,
                                              ),
                                            ],
                                          ),
                                        ],
                                      )),
                                ),
                              ],
                            ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _helpView(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () {
        if (_helpHeight == 45) {
          setState(() {
            _helpWidth = width / 2.5;
            _helpHeight = 190;
            _parametersWidth = 110;
            _parametersHeight = 45;
            _parametersVisibility = false;
            Future.delayed(const Duration(milliseconds: 200), () {
              setState(() {
                helpVisibility = true;
              });
            });
          });
        } else {
          setState(() {
            _helpWidth = 110;
            _helpHeight = 45;
            helpVisibility = false;
          });
        }
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        margin: EdgeInsets.only(left: 5),
        height: _helpHeight,
        width: _helpWidth,
        child: Card(
          color: Colors.black.withAlpha(90),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
              side: BorderSide(
                  width: 3.0,
                  color: Colors.blueAccent,
                  style: BorderStyle.solid)),
          elevation: 10,
          child: Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  SizedBox(
                    height: 5,
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Text(
                      helpVisibility ? "Usefull commands" : "Help",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontFamily: "WorkSansSemiBold",
                      ),
                      textScaleFactor: 1.0,
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    width: _helpWidth - 30,
                    height: 3,
                    color: Colors.blue,
                  ),
                  !helpVisibility
                      ? Container()
                      : Padding(
                          padding: EdgeInsets.all(10),
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: Container(
                              width: _helpWidth - 20,
                              height: _helpHeight - 65,
                              child: Column(
                                children: <Widget>[
                                  Container(
                                    color: Colors.white70.withAlpha(60),
                                    child: Text(
                                      'Start the Drone!',
                                      textScaleFactor: 1.0,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.green,
                                        fontFamily: "WorkSansSemiBold",
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 8.0,
                                  ),
                                  Container(
                                    color: Colors.white70.withAlpha(60),
                                    child: Text(
                                      'Stop the Drone!',
                                      textScaleFactor: 1.0,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.green,
                                        fontFamily: "WorkSansSemiBold",
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 8.0,
                                  ),
                                  Container(
                                    color: Colors.white70.withAlpha(60),
                                    child: Text(
                                      'Fly',
                                      textScaleFactor: 1.0,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.green,
                                        fontFamily: "WorkSansSemiBold",
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 8.0,
                                  ),
                                  Container(
                                    color: Colors.white70.withAlpha(60),
                                    child: Text(
                                      'Land',
                                      textScaleFactor: 1.0,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.green,
                                        fontFamily: "WorkSansSemiBold",
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 8.0,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _batteryLevel(BuildContext context) {
    _bLevel = _batteryLevelPercents / 3.38; //Maximum Battery value is 29.5
    if (_bLevel <= 6)
      _batteryLow = true;
    else
      _batteryLow = false;
    return Tooltip(
      message:
          "Battery Level: " + _batteryLevelPercents.toInt().toString() + "%",
      child: RotatedBox(
        quarterTurns: 2,
        child: Stack(
          children: <Widget>[
            RotatedBox(
              quarterTurns: 2,
              child: Icon(
                Icons.battery_full,
                size: 40,
                color: Colors.black.withAlpha(90),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 11.5, top: 3.5),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2.5),
                  color: _batteryLow
                      ? Colors.red.withAlpha(150)
                      : Colors.green.withAlpha(150),
                ),
                width: 17,
                height: _bLevel,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _signalStrength(BuildContext context) {
    _signalLevel = 3; // Maximum Signal level is 5
    if (_signalLevel < 2)
      _signalStatus = "Pure";
    else if (_signalLevel < 4)
      _signalStatus = "Okay";
    else if (_signalLevel < 5)
      _signalStatus = "Good";
    else
      _signalStatus = "Very Good";
    return Container(
      width: 50,
      child: Tooltip(
        message: "Signal Strength: " + _signalStatus,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Container(
              alignment: Alignment.bottomLeft,
              decoration: BoxDecoration(
                  color: _signalLevel >= 1
                      ? Colors.white.withAlpha(190)
                      : Colors.black.withAlpha(90),
                  borderRadius: BorderRadius.circular(3)),
              width: 5,
              height: 10,
            ),
            SizedBox(
              width: 4,
            ),
            Container(
              alignment: Alignment.bottomLeft,
              decoration: BoxDecoration(
                  color: _signalLevel >= 2
                      ? Colors.white.withAlpha(190)
                      : Colors.black.withAlpha(90),
                  borderRadius: BorderRadius.circular(3)),
              width: 5,
              height: 15,
            ),
            SizedBox(
              width: 4,
            ),
            Container(
              alignment: Alignment.bottomLeft,
              decoration: BoxDecoration(
                  color: _signalLevel >= 3
                      ? Colors.white.withAlpha(190)
                      : Colors.black.withAlpha(90),
                  borderRadius: BorderRadius.circular(3)),
              width: 5,
              height: 20,
            ),
            SizedBox(
              width: 4,
            ),
            Container(
              alignment: Alignment.bottomLeft,
              decoration: BoxDecoration(
                  color: _signalLevel >= 4
                      ? Colors.white.withAlpha(190)
                      : Colors.black.withAlpha(90),
                  borderRadius: BorderRadius.circular(3)),
              width: 5,
              height: 25,
            ),
            SizedBox(
              width: 4,
            ),
            Container(
              alignment: Alignment.bottomLeft,
              decoration: BoxDecoration(
                  color: _signalLevel >= 5
                      ? Colors.white.withAlpha(190)
                      : Colors.black.withAlpha(90),
                  borderRadius: BorderRadius.circular(3)),
              width: 5,
              height: 30,
            ),
          ],
        ),
      ),
    );
  }

  Widget _message(BuildContext context) {
    return Visibility(
      visible: micTextState,
      child: Card(
        color: Colors.white.withAlpha(90),
        shadowColor: Colors.blueAccent,
        elevation: 5,
        child: SizedBox(
          child: Text(lastWords,
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontFamily: "WorkSansSemiBold",
              )),
        ),
      ),
    );
  }

  Widget _microphone(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              setState(() {
                micState = !micState;
                micTextState = !micTextState;
                if (!(_hasSpeech || speech.isListening) == null)
                  print("Speech called on null");
                else {
                  startListening();
                }
              });
            },
            child: micState
                ? new AvatarGlow(
                    startDelay: Duration(milliseconds: 10),
                    glowColor: Colors.white,
                    endRadius: 50.0,
                    duration: Duration(milliseconds: 1500),
                    repeat: true,
                    showTwoGlows: true,
                    repeatPauseDuration: Duration(milliseconds: 50),
                    child: Icon(Icons.mic, color: Colors.blueAccent, size: 50),
                  )
                : Container(
                    padding: EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.mic_off,
                        color: Colors.blueAccent, size: 50)),
          ),
        ],
      ),
    );
  }

  Future<void> welcomeMessage() async {
    await Future.delayed(const Duration(seconds: 2), () async {
      user = await _auth.currentUser();
      if(user.displayName == null)
        _command("Welcome to the bot assistant," +
            ". We are ready to get you started");
      else
        _command("Welcome to the bot assistant," +
            user.displayName +
            ". We are ready to get you started");
    });
  }

  String divideBy10(String text) {
    double val = double.parse(text);
    return val.toStringAsFixed(3);
  }

  String divideBy6(String text) {
    double val = double.parse(text);
    val = val.truncateToDouble();
    return val.toStringAsFixed(3);
  }

  Future _command(String text) async {
    await flutterTts.setVolume(volume);
    await flutterTts.setSpeechRate(rate);
    await flutterTts.setPitch(pitch);

    if (text != null) {
      if (text.isNotEmpty) {
        var result = await flutterTts.speak(text);
        if (result == 1) setState(() => ttsState = TtsState.playing);
      }
    }
  }

  Future _speak() async {
    await flutterTts.setVolume(volume);
    await flutterTts.setSpeechRate(rate);
    await flutterTts.setPitch(pitch);
    if (_newVoiceText != null) {
      if (_newVoiceText.isNotEmpty) {
        var result = await flutterTts.speak(_newVoiceText);
        if (result == 1) setState(() => ttsState = TtsState.playing);
      }
    }
  }

  initTts() {
    flutterTts = FlutterTts();

    flutterTts.setStartHandler(() {
      setState(() {
        print("playing");
        ttsState = TtsState.playing;
      });
    });

    flutterTts.setCompletionHandler(() {
      setState(() {
        print("Complete");
        ttsState = TtsState.stopped;
      });
    });

    flutterTts.setErrorHandler((msg) {
      setState(() {
        print("error: $msg");
        ttsState = TtsState.stopped;
      });
    });
  }

  Future<void> initSpeechState() async {
    bool hasSpeech = await speech.initialize(
        onError: errorListener, onStatus: statusListener);
    if (hasSpeech) {}

    if (!mounted) return;

    setState(() {
      _hasSpeech = hasSpeech;
    });
  }

  void startListening() {
    lastWords = "";
    lastError = "";
    speech.listen(
        onResult: resultListener,
        listenFor: Duration(milliseconds: 5000),
        localeId: _currentLocaleId,
        onSoundLevelChange: soundLevelListener,
        cancelOnError: true,
        partialResults: true);
    setState(() {});
  }

  void stopListening() {
    speech.stop();
    setState(() {
      level = 0.0;
    });
  }

  void cancelListening() {
    speech.cancel();
    setState(() {
      level = 0.0;
    });
  }

  void resultListener(SpeechRecognitionResult result) {
    String text;
    setState(() {
      //micTextState =! micTextState;
      lastWords = "${result.recognizedWords} - ${result.finalResult}";
    });

    if (lastWords.contains("true")) {
      lastWords = lastWords.substring(0, lastWords.length - 6);
      text = lastWords.toString();
      _newVoiceText = "Command received." + text;
      var now = new DateTime.now();
      checkHistoryList(new DateFormat("H:m:s").format(now) + ": " + text);

      setState(() {
        micTextState = !micTextState;
        micState = !micState;
      });

      lastWords = "";
      if (getOption(text..toString().trim()) == "-1")
        _command("Unknown command!");
      else {
        _speak();
        SocketClient.socket.write(getOption(text.toString().trim()));
      }
    }
  }

  String getOption(String text) {
    switch (text.toString().trim()) {
      case "start the drone":
        {
          return "1";
        }
      case "stop the drone":
        {
          return "2";
        }
      case "fly":
        {
          return "3";
        }
      case "land":
        {
          return "4";
        }
      case "forward":
        {
          return "5";
        }
      case "backward":
        {
          return "6";
        }
      case "left":
        {
          return "7";
        }
      case "right":
        {
          return "8";
        }
      default:
        {
          return "-1";
        }
    }
  }

  void soundLevelListener(double level) {
    minSoundLevel = min(minSoundLevel, level);
    maxSoundLevel = max(maxSoundLevel, level);
    // print("sound level $level: $minSoundLevel - $maxSoundLevel ");
    setState(() {
      this.level = level;
    });
  }

  void errorListener(SpeechRecognitionError error) {
    print("Received error status: $error, listening: ${speech.isListening}");
    setState(() {
      lastError = "${error.errorMsg} - ${error.permanent}";
    });
  }

  void statusListener(String status) {
    print(
        "Received listener status: $status, listening: ${speech.isListening}");
    setState(() {
      lastStatus = "$status";
    });
  }

  void syncParameters(data) {
    String parameters = new String.fromCharCodes(data).trim();
    parametersList = parameters.split(',');
    setState(() {
      parametersVisibility = true;
    });
  }

  void synchronizeParameters(){
    SocketClient.socketParameters.listen((data) {
      syncParameters(data);
    });
  }

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    flutterTts.stop();
  }

  checkHistoryList(String text) {
    if (text != null) {
      if (textHistory == null)
        textHistory = text + "\n";
      else {
        textHistory = textHistory + text + "\n";
      }
    }
  }

  String replaceStringBattery(String parametersList) {
    parametersList.replaceAll("Battery:voltage=", "");
    return parametersList;
  }

  String replaceGpsText(String parametersList) {
    parametersList.replaceAll("GPSInfo:fix=3", "");
    return parametersList;
  }

  void startServer() async {
    await clientProxy.connectSFTP();
    await clientServer.connectSFTP();

    await clientProxy.writeToShell("sudo -s");
    await clientProxy.writeToShell("mavproxy.py --master=127.0.0.1:14550");
    await clientServer.writeToShell("python server.py");
  }
}

class ButtonWithText extends StatelessWidget {
  final IconData icon;
  final String text;

  const ButtonWithText({Key key, this.icon, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.3),
                  spreadRadius: 4,
                  blurRadius: 4,
                  offset: Offset(0, 1), // changes position of shadow
                ),
              ],
            ),
            child: Icon(icon, size: 30, color: Colors.blueAccent),
          ),
          SizedBox(
            width: 5,
          ),
          Stack(
            children: <Widget>[
              Text(
                text,
                textScaleFactor: 1.0,
                style: TextStyle(
                  foreground: Paint()
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 3
                    ..color = Colors.blueAccent,
                ),
              ),
              Text(
                text,
                textScaleFactor: 1.0,
                style: TextStyle(color: Colors.white),
              )
            ],
          ),
        ],
      ),
    );
  }
}

class TextWithIcon extends StatelessWidget {
  final IconData icon;
  final String text;
  final double spacing;

  const TextWithIcon({Key key, this.icon, this.text, this.spacing = 2})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 14,
            color: Colors.white,
          ),
          SizedBox(
            height: spacing,
            width: 2,
          ),
          Text(
            text,
            textScaleFactor: 1.0,
            style: TextStyle(
                color: Colors.white,
                fontSize: 12.0,
                fontFamily: 'WorkSansMedium'),
          ),
        ],
      ),
    );
  }
}

class ModeText extends StatelessWidget {
  final IconData icon;
  final String text;
  final double spacing;
  final Color color;

  const ModeText({Key key, this.icon, this.text, this.spacing = 1, this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          SizedBox(
            height: spacing,
            width: 2,
          ),
          Text(
            text,
            textScaleFactor: 1.0,
            style: TextStyle(
                color: color, fontSize: 12.0, fontFamily: 'WorkSansMedium'),
          ),
        ],
      ),
    );
  }
}
