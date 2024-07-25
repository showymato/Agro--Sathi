import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:swipe_gesture_recognizer/swipe_gesture_recognizer.dart';

class GalleryView extends StatefulWidget {
  @override
  _GalleryViewState createState() => _GalleryViewState();
}

class _GalleryViewState extends State<GalleryView> {

  bool loading;
  bool _imagePageVisibility = false;

  List<String> ids = ['0', '10', '1002'];

  static int position = 0;
  static int count = 0;

  String id;

  double _imagePageHeight = 0;

  @override
  void initState() {
    loading = true;
    ids = [];
    _loadImageIds();
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void dispose(){
    super.dispose();
  }

  void _loadImageIds() async {
    final response =
        await http.get('https://picsum.photos/v2/list?page=3&limit=100');
    final json = jsonDecode(response.body);
    List<String> _ids = [];
    for (var image in json) {
      _ids.add(image['id']);
    }
    if (count == 0)
      new Future.delayed(new Duration(seconds: 3), () {
        setState(() {
          loading = false;
          ids = _ids;
          count++;
        });
      });
    else {
      setState(() {
        loading = false;
        ids = _ids;
        count++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading && _GalleryViewState.count == 0) {
      return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.white,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
                image: DecorationImage(image: AssetImage("assets/gif/load.gif"))),
          ),
        ),
      );
    }
    return WillPopScope(
        onWillPop: () {
      return new Future(() => false);
    },
    child: Stack(
      children: <Widget>[
        Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.black.withAlpha(190),
              leading: BackButton(
                  color: Colors.white,
                  onPressed: () {
                    _GalleryViewState.count=0;
                    Navigator.pop(context);
                  }),
              title: Text(" ", style: TextStyle(color: Colors.white, ),),
            ),
            extendBodyBehindAppBar: true,
            body: AnimationLimiter(
                child: ListView.builder(
                    itemCount: ids.length,
                    itemBuilder: (context, index) =>
                        AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(seconds: 3),
                            child: SlideAnimation(
                                verticalOffset: 100.0,
                                duration: const Duration(seconds: 3),
                                child: FadeInAnimation(
                                  duration: const Duration(seconds: 3),
                                  child: GestureDetector(
                                      onTap: () {
                                        position = int.parse(ids[index]);
                                        setState(() {
                                          id = ids[index];
                                          Future.delayed(const Duration(milliseconds: 200), () {
                                            setState(() {
                                              _imagePageVisibility = true;
                                            });
                                          });
                                          _imagePageHeight = MediaQuery.of(context).size.height;
                                        });
                                      },
                                      child: Image.network(
                                          'http://picsum.photos/id/${ids[index]}/420/300')),
                                )))))),
        Align(
          alignment: Alignment.bottomCenter,
          child: imagePage(context),
        ),
      ],
    ),
    );
  }

  Widget imagePage(BuildContext context) {
    id = id;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent, // navigation bar color
      statusBarColor: Colors.transparent, // status bar color
    ));
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      height: _imagePageHeight,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.black,
            leading: BackButton(
                color: Colors.white,
                onPressed: () {
                  setState(() {
                    _imagePageVisibility = false;
                    Future.delayed(const Duration(milliseconds: 300), () {
                      setState(() {
                        _imagePageHeight = 0;
                      });
                    });
                  });
                }),
          ),
          backgroundColor: Colors.black,
          body: Visibility(
            visible: _imagePageVisibility,
            child: Container(
              child: SwipeGestureRecognizer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: AnimationLimiter(
                        child: AnimationConfiguration.synchronized(
                          child: SlideAnimation(
                            horizontalOffset: -900,
                            verticalOffset: -0,
                            duration: Duration(seconds: 1),
                            child: ScaleAnimation(
                              duration: Duration(seconds: 1),
                              scale: 0.5,
                              child: Center(
                                child: Image.network(
                                  'http://picsum.photos/id/$id/500/500',
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                onSwipeRight: () {
                  var position = int.parse(id) - 1;
                  String previousPosition = position.toString();
                  if (_GalleryViewState.position <= position)
                    setState(() {
                      id = previousPosition;
                    });
                },
                onSwipeDown: () {
                  setState(() {
                    _imagePageVisibility = false;
                    Future.delayed(const Duration(milliseconds: 300), () {
                      setState(() {
                        _imagePageHeight = 0;
                      });
                    });
                  });
                },
                onSwipeLeft: () {
                  var position = int.parse(id) + 1;
                  String nextPosition = position.toString();
                  setState(() {
                    id = nextPosition;
                  });
                },
              ),
            ),
          ),
        ),
    );
  }
}
