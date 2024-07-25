import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:drone_s500/src/app/utils/socket_client.dart';
import 'package:drone_s500/src/app/views/gallery_view.dart';
import 'package:fab_circular_menu/fab_circular_menu.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart';

class GpsView extends StatefulWidget {
  GpsView({Key key}) : super(key: key);

  @override
  _GpsViewState createState() => _GpsViewState();
}

class _GpsViewState extends State<GpsView> with SingleTickerProviderStateMixin {
  StreamSubscription _locationSubscription;
  Location _locationTracker = Location();
  Set<Marker> _markers = new Set<Marker>();
  Marker marker;
  Circle circle;
  GoogleMapController _controller;
  final GlobalKey<FabCircularMenuState> fabKey = GlobalKey();
  final Geolocator geoLocator = Geolocator()..forceAndroidLocationManager;
  String _currentAddress;
  static double latitude = 0, longitude = 0;
  static double latitudeMarker = 0, longitudeMarker = 0;
  bool receivingWaypoints = false;

  @override
  void initState() {
    super.initState();
  }

  static final CameraPosition initialLocation = CameraPosition(
    target: LatLng(45.698355, 25.441895),
    zoom: 14.4746,
  );

  Future<Uint8List> getMarker() async {
    ByteData byteData = await DefaultAssetBundle.of(context)
        .load("assets/images-png/gps_drone.png");
    return byteData.buffer.asUint8List();
  }

  void updateMarkerAndCircle(LocationData newLocalData, Uint8List imageData) {
    LatLng latlng = LatLng(newLocalData.latitude, newLocalData.longitude);
    this.setState(() {
      _markers.add(new Marker(
          markerId: MarkerId("home"),
          position: latlng,
          rotation: newLocalData.heading,
          draggable: false,
          zIndex: 2,
          flat: true,
          anchor: Offset(0.5, 0.5),
          icon: BitmapDescriptor.fromBytes(imageData)));
      circle = Circle(
          circleId: CircleId("drone"),
          radius: newLocalData.accuracy,
          zIndex: 1,
          strokeColor: Colors.blue,
          center: latlng,
          fillColor: Colors.blue.withAlpha(70));
    });
  }

  void updateMarkerAndCircleFromDrone(Uint8List imageData) {
    LatLng latlng = LatLng(latitude, longitude);
    this.setState(() {
      _markers.add(new Marker(
          markerId: MarkerId("home"),
          position: latlng,
          draggable: false,
          zIndex: 2,
          flat: true,
          anchor: Offset(0.5, 0.5),
          icon: BitmapDescriptor.fromBytes(imageData)));
      circle = Circle(
          circleId: CircleId("drone"),
          zIndex: 1,
          strokeColor: Colors.blue,
          center: latlng,
          fillColor: Colors.blue.withAlpha(70));
    });
  }

  void getCurrentLocation() async {
    try {
      Uint8List imageData = await getMarker();
      var location = await _locationTracker.getLocation();
      getDroneWayPoints();

      latitude == 0
          ? updateMarkerAndCircle(location, imageData)
          : updateMarkerAndCircleFromDrone(imageData);

      if (_locationSubscription != null) {
        _locationSubscription.cancel();
      }

      _locationSubscription =
          _locationTracker.onLocationChanged().listen((newLocalData) {
        if (_controller != null) {
          _controller.animateCamera(CameraUpdate.newCameraPosition(
              new CameraPosition(
                  bearing: 192.8334901395799,
                  target: LatLng(
                      latitude == 0 ? newLocalData.latitude : latitude,
                      longitude == 0 ? newLocalData.longitude : longitude),
                  tilt: 0,
                  zoom: 18.00)));
          latitude == 0
              ? updateMarkerAndCircle(newLocalData, imageData)
              : updateMarkerAndCircleFromDrone(imageData);
        }
      });
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        debugPrint("Permission Denied");
      }
    }
  }

  @override
  void dispose() {
    if (_locationSubscription != null) {
      _locationSubscription.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return new Future(() => false);
      },
      child: Scaffold(
        body: Container(
          child: GoogleMap(
            mapType: MapType.hybrid,
            initialCameraPosition: initialLocation,
            markers: _markers,
            circles: Set.of((circle != null) ? [circle] : []),
            onMapCreated: (GoogleMapController controller) {
              _controller = controller;
            },
            onLongPress: _handleTap,
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FabCircularMenu(
          key: fabKey,
          alignment: Alignment.bottomLeft,
          ringColor: Colors.white.withAlpha(25),
          ringDiameter: 500.0,
          ringWidth: 150.0,
          fabSize: 64.0,
          fabElevation: 8.0,
          fabColor: Colors.white,
          fabOpenIcon: Icon(Icons.menu, color: Colors.blueGrey),
          fabCloseIcon: Icon(Icons.close, color: Colors.indigo),
          fabMargin: const EdgeInsets.all(16.0),
          animationDuration: const Duration(milliseconds: 800),
          animationCurve: Curves.easeInOutCirc,
          onDisplayChange: (isOpen) {
            if (fabKey.currentState.isOpen)
              new Future.delayed(const Duration(seconds: 2),
                  () => fabKey.currentState.close());
          },
          children: <Widget>[
            RawMaterialButton(
              onPressed: () async {
                new Future.delayed(
                    const Duration(seconds: 2), () => Navigator.pop(context));
                fabKey.currentState.close();
                SystemChrome.setPreferredOrientations([
                  DeviceOrientation.portraitUp,
                  DeviceOrientation.portraitDown,
                ]);
              },
              shape: CircleBorder(),
              padding: const EdgeInsets.all(24.0),
              child: Icon(Icons.home, color: Colors.white),
            ),
            RawMaterialButton(
              onPressed: () async {
                new Future.delayed(
                    const Duration(seconds: 2),
                    () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => GalleryView())));
                fabKey.currentState.close();
                SystemChrome.setPreferredOrientations([
                  DeviceOrientation.portraitUp,
                  DeviceOrientation.portraitDown,
                ]);
              },
              shape: CircleBorder(),
              padding: const EdgeInsets.all(24.0),
              child: Icon(Icons.terrain, color: Colors.white),
            ),
            RawMaterialButton(
              onPressed: () {
                getCurrentLocation();
              },
              shape: CircleBorder(),
              padding: const EdgeInsets.all(24.0),
              child: Icon(Icons.location_searching, color: Colors.white),
            ),
            RawMaterialButton(
              onPressed: () {
                setState(() {
                  receivingWaypoints = !receivingWaypoints;
                });
                if(!receivingWaypoints) {
                  print("receiving waypoints");
                  //execute();
                }
                else{
                  print("ending long");
                }
              },
              onLongPress: (){
                  ("ending long");
              },
              shape: CircleBorder(),
              padding: const EdgeInsets.all(24.0),
              child: Icon(!receivingWaypoints ? Icons.play_circle_filled : Icons.stop, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget showInSnackBarModel(String value, IconData icon, Color colorType) {
    FocusScope.of(context).requestFocus(new FocusNode());
    return new Flushbar(
      borderRadius: 7,
      margin: EdgeInsets.only(left: 7, right: 7, bottom: 7),
      duration: Duration(milliseconds: 3000),
      shouldIconPulse: true,
      backgroundColor: Colors.black54,
      icon: Icon(icon, size: 40, color: colorType),
      messageText: Text(
        value,
        textAlign: TextAlign.left,
        textScaleFactor: 1.0,
        style: TextStyle(
            color: Colors.white,
            fontSize: 18.0,
            fontFamily: "WorkSans-ExtraLight"),
      ),
    )..show(context);
  }

  _handleTap(LatLng point) async {
    Position position =
        new Position(latitude: point.latitude, longitude: point.longitude);
    _getAddressFromLatLng(position);
    setState(() {
      _markers.add(new Marker(
        markerId: MarkerId(point.toString()),
        position: point,
        visible: true,
        flat: true,
        rotation: -150,
        infoWindow: InfoWindow(
          title: "Waypoint:",
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(40),
      ));
    });
    sendToSocket(point.latitude, point.longitude);
  }

  void sendToSocket(double point1, double point2) {
    try {
      SocketClient.socket.write(point1.toString() + "," + point2.toString());
      showInSnackBarModel("Waypoint added", Icons.gps_fixed, Colors.green);
    } catch (e) {
      showInSnackBarModel(
          "Socket error connection", Icons.error, Colors.redAccent);
    }
  }

  void getDroneWayPoints() {
    try {
      SocketClient.socket.listen((event) {
        String waypoints = new String.fromCharCodes(event).trim();
        List<String> split = waypoints.split(',');
        latitude = double.parse(split.elementAt(0));
        longitude = double.parse(split.elementAt(1));
      });
    } catch (e) {
      showInSnackBarModel(
          "No drone location provided", Icons.error, Colors.redAccent);
    }
  }

  Future<void> execute() async {
    print(receivingWaypoints);
    sleep(Duration(seconds: 2));
    /*var location = await _locationTracker.getLocation();
    setState(() {
      SocketClient.socket.write(
          location.latitude.toString() + "," + location.longitude.toString());
    });*/
  }

  void _getAddressFromLatLng(Position position) async {
    try {
      List<Placemark> p = await geoLocator.placemarkFromCoordinates(
          position.latitude, position.longitude);
      Placemark place = p[0];
      setState(() {
        _currentAddress = "${place.locality}";
      });
    } catch (e) {
      print(e);
    }
  }
}
