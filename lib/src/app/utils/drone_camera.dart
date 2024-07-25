import 'dart:async';
import 'dart:typed_data';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:cryptoutils/cryptoutils.dart';
import 'package:flutter/services.dart';

enum PlayingState { STOPPED, BUFFERING, PLAYING }

class Size {
  final double width;
  final double height;

  static const zero = const Size(0.0, 0);

  const Size(double width, double height)
      : this.width = width,
        this.height = height;
}

class DroneCameraPlayer extends StatefulWidget {
  final String url;
  final Widget placeholder;
  final DroneCameraController controller;

  const DroneCameraPlayer({
    Key key,
    @required this.controller,
    @required this.url,
    this.placeholder,
  });

  @override
  _DroneCameraPlayerState createState() => _DroneCameraPlayerState();
}

class _DroneCameraPlayerState extends State<DroneCameraPlayer>
    with AutomaticKeepAliveClientMixin {
  DroneCameraController _controller;
  int videoRenderId;
  bool playerInitialized = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
  }

  @override
  // ignore: must_call_super
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width - 200,
      height: MediaQuery.of(context).size.height - 200,
      child: Stack(
        children: <Widget>[
          Offstage(
            offstage: playerInitialized,
            child: widget.placeholder ??
                Center(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage("assets/gif/load.gif"))),
                    ),
                  ),
                ),
          ),
          Offstage(
            offstage: !playerInitialized,
            child: _createPlatformView(),
          ),
        ],
      ),
    );
  }

  Widget _createPlatformView() {
    if (Platform.isIOS) {
      return UiKitView(
          viewType: "flutter_video_plugin/getVideoView",
          onPlatformViewCreated: _onPlatformViewCreated);
    } else if (Platform.isAndroid) {
      return AndroidView(
          viewType: "flutter_video_plugin/getVideoView",
          hitTestBehavior: PlatformViewHitTestBehavior.transparent,
          onPlatformViewCreated: _onPlatformViewCreated);
    }

    throw new Exception(
        "DroneCamera has not been implemented on your platform.");
  }

  void _onPlatformViewCreated(int id) async {
    _controller = widget.controller;
    _controller.registerChannels(id);

    _controller.addListener(() {
      if (!mounted) return;
      if (playerInitialized != _controller.initialized)
        setState(() {
          playerInitialized = _controller.initialized;
        });
    });
    if (_controller.hasClients) {
      await _controller._initialize(widget.url);
    }
  }

  @override
  void deactivate() {
    _controller.dispose();
    playerInitialized = false;
    super.deactivate();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class DroneCameraController {
  MethodChannel _methodChannel;
  EventChannel _eventChannel;

  VoidCallback _onInit;
  List<VoidCallback> _eventHandlers;

  bool hasClients = false;

  bool get initialized => _initialized;
  bool _initialized = false;

  PlayingState get playingState => _playingState;
  PlayingState _playingState;

  int _position;
  Duration get position =>
      _position != null ? new Duration(milliseconds: _position) : Duration.zero;

  int _duration;

  Duration get duration =>
      _duration != null ? new Duration(milliseconds: _duration) : Duration.zero;

  Size get size => _size != null ? _size : Size.zero;
  Size _size;
  double _playbackSpeed;
  double get playbackSpeed => _playbackSpeed;

  DroneCameraController({VoidCallback onInit}) {
    _onInit = onInit;
    _eventHandlers = new List();
  }

  void registerChannels(int id) {
    _methodChannel = MethodChannel("flutter_video_plugin/getVideoView_$id");
    _eventChannel = EventChannel("flutter_video_plugin/getVideoEvents_$id");
    hasClients = true;
  }

  void addListener(VoidCallback listener) {
    _eventHandlers.add(listener);
  }

  void removeListener(VoidCallback listener) {
    _eventHandlers.remove(listener);
  }

  void clearListeners() {
    _eventHandlers.clear();
  }

  void _fireEventHandlers() {
    _eventHandlers.forEach((handler) => handler());
  }

  Future<void> _initialize(String url) async {
    //if(initialized) throw new Exception("Player already initialized!");

    await _methodChannel.invokeMethod("initialize", {'url': url});
    _position = 0;

    _eventChannel.receiveBroadcastStream().listen((event) {
      switch (event['name']) {
        case 'playing':
          if (event['width'] != null && event['height'] != null)
            _size = new Size(event['width'] + 200, event['height']);
          if (event['length'] != null) _duration = event['length'];

          _playingState =
              event['value'] ? PlayingState.PLAYING : PlayingState.STOPPED;

          _fireEventHandlers();
          break;

        case 'buffering':
          if (event['value']) _playingState = PlayingState.BUFFERING;
          _fireEventHandlers();
          break;

        case 'timeChanged':
          _position = event['value'];
          _playbackSpeed = event['speed'];
          _fireEventHandlers();
          break;
      }
    });

    _initialized = true;
    _fireEventHandlers();
    _onInit();
  }

  Future<void> setStreamUrl(String url) async {
    _initialized = false;
    _fireEventHandlers();

    bool wasPlaying = _playingState != PlayingState.STOPPED;
    await _methodChannel.invokeMethod("changeURL", {'url': url});
    if (wasPlaying) play();

    _initialized = true;
    _fireEventHandlers();
  }

  Future<void> play() async {
    await _methodChannel
        .invokeMethod("setPlaybackState", {'playbackState': 'play'});
  }

  Future<void> pause() async {
    await _methodChannel
        .invokeMethod("setPlaybackState", {'playbackState': 'pause'});
  }

  Future<void> stop() async {
    await _methodChannel
        .invokeMethod("setPlaybackState", {'playbackState': 'stop'});
  }

  Future<void> setTime(int time) async {
    await _methodChannel.invokeMethod("setTime", {'time': time.toString()});
  }

  Future<void> setPlaybackSpeed(double speed) async {
    await _methodChannel
        .invokeMethod("setPlaybackSpeed", {'speed': speed.toString()});
  }

  Future<Uint8List> takeSnapshot() async {
    var result = await _methodChannel.invokeMethod("getSnapshot");
    var base64String = result['snapshot'];
    Uint8List imageBytes = CryptoUtils.base64StringToBytes(base64String);
    return imageBytes;
  }

  void dispose() {
    _methodChannel.invokeMethod("dispose");
  }
}
