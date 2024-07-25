import 'dart:io';

import 'package:camera/camera.dart';
import 'package:drone_s500/src/app/utils/drone_camera.dart' as DroneCamera;
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'detector_painters.dart';
import 'scanner_utils.dart';

class CameraPreviewScanner extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _CameraPreviewScannerState();
}

class _CameraPreviewScannerState extends State<CameraPreviewScanner> {
  dynamic _scanResults;

  bool _dropDown = false;

  CameraController _camera;
  Detector _currentDetector = Detector.barcode;
  bool _isDetecting = false;
  CameraLensDirection _direction = CameraLensDirection.back;
  final String urlToStreamVideo = 'http://192.168.43.124:8558/';
  DroneCamera.DroneCameraController controller;
  final BarcodeDetector _barcodeDetector =
      FirebaseVision.instance.barcodeDetector();
  final FaceDetector _faceDetector = FirebaseVision.instance.faceDetector();
  final ImageLabeler _imageLabeler = FirebaseVision.instance.imageLabeler();
  final ImageLabeler _cloudImageLabeler =
      FirebaseVision.instance.cloudImageLabeler();
  final TextRecognizer _recognizer = FirebaseVision.instance.textRecognizer();
  final TextRecognizer _cloudRecognizer =
      FirebaseVision.instance.cloudTextRecognizer();

  Future<void> saveToPath() async {
    final Directory path = await getApplicationDocumentsDirectory();
    print(path.toString());
    try {
      await _camera.takePicture(
          "/data/picturesss/");
    } catch (e) {
      // If an error occurs, log the error to the console.
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    controller = new DroneCamera.DroneCameraController(onInit: () {
      controller.play();
    });
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void _initializeCamera() async {
    final CameraDescription description =
        await ScannerUtils.getCamera(_direction);

    _camera = CameraController(
      description,
      defaultTargetPlatform == TargetPlatform.iOS
          ? ResolutionPreset.low
          : ResolutionPreset.medium,
    );
    await _camera.initialize();

    _camera.startImageStream((CameraImage image) {
      if (_isDetecting) return;

      _isDetecting = true;

      ScannerUtils.detect(
        image: image,
        detectInImage: _getDetectionMethod(),
        imageRotation: description.sensorOrientation,
      ).then(
        (dynamic results) {
          if (_currentDetector == null) return;
          setState(() {
            _scanResults = results;
          });
        },
      ).whenComplete(() => _isDetecting = false);
    });
  }

  Widget _buildResults() {
    const Text noResultsText = Text('.');

    if (_scanResults == null ||
        _camera == null ||
        !_camera.value.isInitialized) {
      return noResultsText;
    }

    CustomPainter painter;

    final Size imageSize = Size(
      _camera.value.previewSize.height,
      _camera.value.previewSize.width,
    );

    switch (_currentDetector) {
      case Detector.barcode:
        if (_scanResults is! List<Barcode>) return noResultsText;
        painter = BarcodeDetectorPainter(imageSize, _scanResults);
        break;
      case Detector.face:
        if (_scanResults is! List<Face>) return noResultsText;
        painter = FaceDetectorPainter(imageSize, _scanResults);
        break;
      case Detector.label:
        if (_scanResults is! List<ImageLabel>) return noResultsText;
        painter = LabelDetectorPainter(imageSize, _scanResults);
        break;
      case Detector.cloudLabel:
        if (_scanResults is! List<ImageLabel>) return noResultsText;
        painter = LabelDetectorPainter(imageSize, _scanResults);
        break;
      default:
        assert(_currentDetector == Detector.barcode ||
            _currentDetector == Detector.text);
        if (_scanResults is! VisionText) return noResultsText;
        painter = TextDetectorPainter(imageSize, _scanResults);
    }

    return CustomPaint(
      painter: painter,
    );
  }

  Future<dynamic> Function(FirebaseVisionImage image) _getDetectionMethod() {
    switch (_currentDetector) {
      case Detector.text:
        return _recognizer.processImage;
      case Detector.cloudText:
        return _cloudRecognizer.processImage;
      case Detector.barcode:
        return _barcodeDetector.detectInImage;
      case Detector.label:
        return _imageLabeler.processImage;
      case Detector.cloudLabel:
        return _cloudImageLabeler.processImage;
      case Detector.face:
        return _faceDetector.processImage;
    }

    return null;
  }

  Widget _buildImage() {
    return Container(
      alignment: Alignment.bottomCenter,
      child: RotatedBox(
              quarterTurns: 0,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: new DroneCamera.DroneCameraPlayer(
                      url: urlToStreamVideo,
                      controller: controller,
                      placeholder: Center(
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
                  ),
                  RotatedBox(
                    quarterTurns: 3,
                    child: _buildResults(),
                  ),
                  RotatedBox(
                    quarterTurns: 0,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 25.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Spacer(),
                          Row(
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {
                                  print('Take Video');
                                },
                                child: Padding(
                                  padding: EdgeInsets.only(bottom: 10),
                                  child: Image(
                                    image: AssetImage(
                                        'assets/images-png/take_video.png'),
                                    width: 40,
                                    height: 40,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 30,
                              ),
                              GestureDetector(
                                onTap: () {
                                  print('Take Photo');
                                  saveToPath();
                                  //_camera.stopImageStream();
                                },
                                child: Image(
                                  image: AssetImage(
                                      'assets/images-png/camera.png'),
                                  width: 40,
                                  height: 40,
                                ),
                              )
                            ],
                          ),
                          Spacer(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () {
          setState(() {
            _dropDown = false;
            print(_dropDown);
          });
        },
        child: Stack(
          children: <Widget>[
            _buildImage(),
            Column(children: [
              Padding(
                padding: EdgeInsets.only(top: 40.0, left: 18.0),
                child: GestureDetector(
                  child: Row(
                    children: <Widget>[
                      PopupMenuButton<Detector>(
                        onCanceled: () {
                          setState(() {
                            _dropDown = false;
                            print(_dropDown);
                          });
                        },
                        onSelected: (Detector result) {
                          print(_dropDown);
                          setState(() {
                            _dropDown = false;
                          });
                          _currentDetector = result;
                        },
                        padding: EdgeInsets.all(0),
                        color: Colors.black.withAlpha(0),
                        elevation: 0,
                        icon: new Image.asset(
                          !_dropDown ? 'assets/images-png/menu.png' : '',
                          height: 25,
                          width: 25,
                        ),
                        itemBuilder: (BuildContext context) {
                          _dropDown = true;
                          print(_dropDown);
                          return <PopupMenuEntry<Detector>>[
                            const PopupMenuItem<Detector>(
                              child: Padding(
                                padding: EdgeInsets.all(2),
                                child: ButtonWithText(
                                  text: 'Detect Face',
                                  image: 'assets/images-png/face_detect.png',
                                ),
                              ),
                              value: Detector.face,
                            ),
                            const PopupMenuItem<Detector>(
                              child: Padding(
                                padding: EdgeInsets.all(2),
                                child: ButtonWithText(
                                  text: 'Detect Objects',
                                  image: 'assets/images-png/objects_detect.png',
                                ),
                              ),
                              value: Detector.label,
                            ),
                            const PopupMenuItem<Detector>(
                              child: Padding(
                                padding: EdgeInsets.all(2),
                                child: ButtonWithText(
                                  text: 'Detect Text',
                                  image: 'assets/images-png/detect_text.png',
                                ),
                              ),
                              value: Detector.text,
                            ),
                            const PopupMenuItem<Detector>(
                              child: Padding(
                                padding: EdgeInsets.all(2),
                                child: ButtonWithText(
                                  text: 'Stop Detecting',
                                  image: 'assets/images-png/stop.png',
                                ),
                              ),
                              value: Detector.barcode,
                            ),
                          ];
                        },
                      ),
                      SizedBox(
                        width: 3,
                      ),
                      Stack(
                        children: <Widget>[
                          Text(
                            'Options',
                            textScaleFactor: 1.0,
                            style: TextStyle(
                                fontSize: 22,
                                color: _dropDown
                                    ? Colors.transparent
                                    : Color(0xffCEE8FA),
                                fontFamily: 'WorkSansSemiBold'),
                          ),
                          Text(
                            'Options',
                            textScaleFactor: 1.0,
                            style: TextStyle(
                              fontSize: 22,
                              fontFamily: 'WorkSansSemiBold',
                              foreground: Paint()
                                ..style = PaintingStyle.stroke
                                ..strokeWidth = 1.4
                                ..color = _dropDown
                                    ? Colors.transparent
                                    : Color(0xff2D527C),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ]),
          ],
        ),
      ),
      extendBodyBehindAppBar: true,
    );
  }

  @override
  void dispose() {
    _camera.dispose().then((_) {
      _barcodeDetector.close();
      _faceDetector.close();
      _imageLabeler.close();
      _cloudImageLabeler.close();
      _recognizer.close();
      _cloudRecognizer.close();
    });

    _currentDetector = null;
    super.dispose();
  }
}

class ButtonWithText extends StatelessWidget {
  final String image;
  final String text;

  const ButtonWithText({Key key, this.image, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image(
            image: AssetImage(image),
            width: 20,
            height: 20,
          ),
          SizedBox(
            width: 15,
          ),
          Stack(
            children: <Widget>[
              Text(
                text,
                textScaleFactor: 1.0,
                style: TextStyle(
                    fontSize: 18,
                    color: Color(0xffCEE8FA),
                    fontFamily: 'WorkSansSemiBold'),
              ),
              Text(
                text,
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
        ],
      ),
    );
  }
}
