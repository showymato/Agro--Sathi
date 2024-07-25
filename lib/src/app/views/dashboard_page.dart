import 'dart:ui';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:custom_dropdown/custom_dropdown.dart';
import 'package:drone_s500/src/app/model/connection_crud_model.dart';
import 'package:drone_s500/src/app/model/connection_model.dart';
import 'package:drone_s500/src/app/model/user_settings_crud_model.dart';
import 'package:drone_s500/src/app/model/user_settings_model.dart';
import 'package:drone_s500/src/app/utils/firebase_auth.dart';
import 'package:drone_s500/src/app/utils/socket_client.dart';
import 'package:drone_s500/src/app/views/login_page.dart';
import 'package:drone_s500/src/app/views/video_view.dart';
import 'package:drone_s500/src/app/views/voice_control_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:animated_dialog_box/animated_dialog_box.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/socket_client.dart';
import 'gallery_view.dart';
import 'gps_view.dart';
import '../utils/loading_text.dart';

class DashboardPage extends StatefulWidget {
  DashboardPage({Key key}) : super(key: key);

  @override
  _DashboardPageState createState() => new _DashboardPageState();
}

Future<bool> logOut = FirebaseAuthProvider().logOut();

final _auth = FirebaseAuth.instance;
dynamic user;
String userEmail;
String userId;
SocketClient socketClient;
int connectedToServers = 0;
final GlobalKey _bottomNavigationKey = new GlobalKey();

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

class _DashboardPageState extends State<DashboardPage>
    with TickerProviderStateMixin {

  @override
  void initState() {
    super.initState();
    getCurrentUserInfo();
    if (_configured == false) connectToSockets();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  UserSetting userSetting;
  UserSettingCrud userSettingCrud = new UserSettingCrud();
  ConnectionModel connectionModel;
  ConnectionCrud connectionModelCrud = new ConnectionCrud();
  List<String> _connectionList = ["SSH", "SERIAL", "TELEMETRY"];
  List<String> _modelList = [
    "BeagleBone Blue",
    "Navio2",
    "Pixhawk Cube",
    "Pixhawk"
  ];

  int _connection;
  int _model;
  int _page = 1;
  int index = 1;

  double _hDown = 0;
  double _height = 400;

  bool _unConf = false;
  bool _cancel = false;
  bool _dConfig = false;
  bool _obscurePassword = true;
  bool notifications = true;
  bool newsletter = false;
  bool _area = false;
  bool _func = false;
  bool _safe = false;
  bool _tap = false;
  bool _dTap = true;
  bool _tech = false;
  bool _keysOn = false;
  bool _configured = false;
  bool _connected = false;
  bool _gridVisible = false;
  bool loaderVisibility = false;
  TextEditingController connectionHostname = new TextEditingController();
  TextEditingController connectionPort = new TextEditingController();
  TextEditingController connectionSettingHostname = new TextEditingController();
  TextEditingController connectionSettingPort = new TextEditingController();
  String connectionFromHost;
  int connectionFromPort;

    @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      statusBarColor: Colors.transparent,
    ));
    return WillPopScope(
      onWillPop: () {
        return new Future(() => false);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar: CurvedNavigationBar(
          key: _bottomNavigationKey,
          height: 53,
          items: <Widget>[
            Icon(Icons.info, color: Colors.blueAccent, size: 30),
            Icon(Icons.clear_all, color: Colors.blueAccent, size: 30),
            Icon(Icons.settings, color: Colors.blueAccent, size: 30),
          ],
          index: index,
          onTap: (index) {
            setState(() {
              _page = index;
            });
          },
        ),
        body: _pageView(context),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    this.dispose();
    }

  void dashboardContent(index){
      Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar: CurvedNavigationBar(
          key: _bottomNavigationKey,
          height: 53,
          items: <Widget>[
            Icon(Icons.info, color: Colors.blueAccent, size: 30),
            Icon(Icons.clear_all, color: Colors.blueAccent, size: 30),
            Icon(Icons.settings, color: Colors.blueAccent, size: 30),
          ],
          index: index,
          onTap: (index) {
            setState(() {
              _page = index;
            });
          },
        ),
        body: _pageView(context),
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

  Widget _droneConfig() {
    double height = MediaQuery.of(context).size.height;
    return Form(
      child: Column(
        children: <Widget>[
          Stack(
            alignment: Alignment.topCenter,
            overflow: Overflow.visible,
            children: <Widget>[
              Card(
                margin: new EdgeInsets.symmetric(vertical: 23.0),
                elevation: 2.0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: AnimatedContainer(
                  duration: Duration(seconds: 1),
                  width: 300.0,
                  height: _height,
                  child: Stack(
                    children: [
                      Visibility(
                        visible: _cancel ? false : _dConfig ? false : true,
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(
                                  top: 30, bottom: 20, left: 25.0, right: 25.0),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.settings_input_antenna,
                                    size: 29.0,
                                    color: Colors.black,
                                  ),
                                  SizedBox(
                                    width: 10.0,
                                  ),
                                  Expanded(
                                    child: CustomDropdown(
                                      openColor: Colors.white,
                                      valueIndex: _connection,
                                      enabledIconColor: Colors.black,
                                      disabledIconColor: Colors.black,
                                      hint: "Connection",
                                      items: [
                                        CustomDropdownItem(text: "SSH"),
                                        CustomDropdownItem(text: "SERIAL"),
                                        CustomDropdownItem(text: "TELEMETRY"),
                                      ],
                                      onChanged: (newValue) {
                                        setState(() => _connection = newValue);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 250.0,
                              height: 1.0,
                              color: Colors.blueGrey[400],
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  top: 30, bottom: 20, left: 25.0, right: 25.0),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.find_replace,
                                    size: 29.0,
                                    color: Colors.black,
                                  ),
                                  SizedBox(
                                    width: 10.0,
                                  ),
                                  Expanded(
                                    child: CustomDropdown(
                                      openColor: Colors.white,
                                      valueIndex: _model,
                                      enabledIconColor: Colors.black,
                                      disabledIconColor: Colors.black,
                                      hint: "Model",
                                      items: [
                                        CustomDropdownItem(
                                            text: "BeagleBone Blue"),
                                        CustomDropdownItem(text: "Navio2"),
                                        CustomDropdownItem(
                                            text: "Pixhawk Cube"),
                                        CustomDropdownItem(text: "Pixhawk"),
                                      ],
                                      onChanged: (newValue) {
                                        setState(() => _model = newValue);
                                        print(_model);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 250.0,
                              height: 1.0,
                              color: Colors.blueGrey[400],
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 25.0, right: 25.0),
                              child: TextFormField(
                                controller: connectionHostname,
                                onTap: () {
                                  setState(() {
                                    _keysOn = true;
                                    print(_keysOn);
                                  });
                                },
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  WhitelistingTextInputFormatter(
                                      RegExp("[. 0-9]"))
                                ],
                                style: TextStyle(
                                    fontFamily: "WorkSansSemiBold",
                                    fontSize: 16.0,
                                    color: Colors.black),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  icon: Icon(
                                    Icons.find_in_page,
                                    color: Colors.black,
                                  ),
                                  labelText: "Hostname or IP-adress",
                                  hintText: "Ex: 192.168.1.10",
                                  contentPadding:
                                      EdgeInsets.only(top: 30, bottom: 20.0),
                                  hintStyle: TextStyle(
                                      fontFamily: "WorkSansSemiBold",
                                      fontSize: 16.0),
                                ),
                              ),
                            ),
                            Container(
                              width: 250.0,
                              height: 1.0,
                              color: Colors.blueGrey[400],
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 25.0, right: 25.0),
                              child: TextFormField(
                                controller: connectionPort,
                                onTap: () {
                                  setState(() {
                                    _keysOn = true;
                                    print(_keysOn);
                                  });
                                },
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  WhitelistingTextInputFormatter(
                                      RegExp("[. 0-9]"))
                                ],
                                style: TextStyle(
                                    fontFamily: "WorkSansSemiBold",
                                    fontSize: 16.0,
                                    color: Colors.black),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  icon: Icon(
                                    FontAwesomeIcons.lock,
                                    color: Colors.black,
                                  ),
                                  labelText: "Port",
                                  hintText: "Ex: 8080",
                                  contentPadding:
                                      EdgeInsets.only(top: 30, bottom: 20.0),
                                  hintStyle: TextStyle(
                                      fontFamily: "WorkSansSemiBold",
                                      fontSize: 16.0),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: _cancel ? false : _dConfig ? false : true,
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(
                    width: 140,
                    margin: EdgeInsets.only(top: height - (height - _height)),
                    decoration: new BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Colors.blueAccent,
                          offset: Offset(1.0, 3.0),
                          blurRadius: 15.0,
                        ),
                      ],
                      color: Colors.white,
                    ),
                    child: MaterialButton(
                        highlightColor: Colors.transparent,
                        splashColor: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.only(),
                          child: Text(
                            "Configure Drone",
                            textScaleFactor: 1.0,
                            style: TextStyle(
                                color: Colors.blueAccent,
                                fontSize: 12.3,
                                fontFamily: "WorkSansBold"),
                          ),
                        ),
                        onPressed: () async {
                          if (!(_connection == 0 ||
                              _connection == 1 ||
                              _connection == 2))
                            showInSnackBarModel("Connection not picked",
                                Icons.error, Colors.red);
                          else if (!(_model == 0 ||
                              _model == 1 ||
                              _model == 2 ||
                              _model == 3))
                            showInSnackBarModel(
                                "Model not picked", Icons.error, Colors.red);
                          else if (connectionHostname.text.trim().isEmpty)
                            showInSnackBarModel(
                                "Host is empty", Icons.error, Colors.red);
                          else if (connectionHostname.text.trim().length <= 11)
                            showInSnackBarModel(
                                "Host invalid", Icons.error, Colors.red);
                          else if (!(connectionHostname.text
                                      .trim()
                                      .substring(3, 4) ==
                                  "." &&
                              connectionHostname.text.trim().substring(7, 8) ==
                                  "." &&
                              (connectionHostname.text
                                          .trim()
                                          .substring(9, 10) ==
                                      "." ||
                                  connectionHostname.text
                                          .trim()
                                          .substring(10, 11) ==
                                      "." ||
                                  connectionHostname.text
                                          .trim()
                                          .substring(11, 12) ==
                                      ".")))
                            showInSnackBarModel(
                                "Host invalid", Icons.error, Colors.red);
                          else if (connectionPort.text.trim().isEmpty)
                            showInSnackBarModel(
                                "Port is empty", Icons.error, Colors.red);
                          else {
                            ConnectionModel connectionModel =
                                new ConnectionModel(
                                    userId,
                                    _modelList.elementAt(_model),
                                    _connectionList.elementAt(_connection),
                                    connectionHostname.text.trim(),
                                    int.parse(connectionPort.text.trim()));
                            connectionModelCrud.updateConnection(
                                userId, connectionModel);
                            showInSnackBarModel("Updated Succesfully",
                                Icons.check_circle, Colors.green);
                            setState(() {
                              _height = 0;
                              _dConfig = true;
                              _keysOn = false;
                              _page = 1;
                            });
                            await Future.delayed(const Duration(seconds: 1),
                                () {
                              setState(() {
                                _configured = false;
                                _gridVisible = true;
                              });
                            });
                            setState(() {
                              connectedToServers = 0;
                            });

                            await connectToSockets();
                          }
                        }),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Container(
                    width: 140,
                    margin: EdgeInsets.only(top: height - (height - _height)),
                    decoration: new BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Colors.blueAccent,
                          offset: Offset(1.0, 6.0),
                          blurRadius: 15.0,
                        ),
                      ],
                      color: Colors.white,
                    ),
                    child: MaterialButton(
                        highlightColor: Colors.transparent,
                        splashColor: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.only(),
                          child: Text(
                            "Cancel",
                            textScaleFactor: 1.0,
                            style: TextStyle(
                                color: Colors.blueAccent,
                                fontSize: 12.3,
                                fontFamily: "WorkSansBold"),
                          ),
                        ),
                        onPressed: () async {
                          setState(() {
                            _height = 0;
                            _cancel = true;
                            _keysOn = false;
                            Future.delayed(const Duration(seconds: 1), () {
                              print(_configured);
                              setState(() {
                                _gridVisible = true;
                                _page = 1;
                                if (_configured == false)
                                  _unConf = false;
                                else
                                  _unConf = true;
                              });
                            });
                          });
                        }),
                  ),
                ]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget dashGrid(BuildContext context) {
    Items item1 = new Items(
      title: "Voice Control",
      img: "assets/images-png/mic.png",
    );

    Items item2 = new Items(
      title: "Camera",
      img: "assets/images-png/camera.png",
    );
    Items item3 = new Items(
      title: "Location",
      img: "assets/images-png/gps.png",
    );
    Items item4 = new Items(
      title: "Gallery",
      img: "assets/images-png/gallery.png",
    );
    List<Items> myList = [item1, item2, item3, item4];

    return Stack(
      children: <Widget>[
        Container(
          child: ScrollConfiguration(
            behavior: MyBehavior(),
            child: GridView.count(
                childAspectRatio: 1.0,
                padding: EdgeInsets.only(left: 16, right: 16),
                crossAxisCount: 2,
                crossAxisSpacing: 18,
                mainAxisSpacing: 18,
                children: myList.map((data) {
                  return InkWell(
                    child: Container(
                      alignment: Alignment.bottomCenter,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(190),
                        border: Border.all(
                          width: 3,
                          color: Colors.blueAccent.withAlpha(50),
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            height: 8,
                          ),
                          Image.asset(
                            data.img,
                            width: 42,
                          ),
                          Text(
                            data.title,
                            textScaleFactor: 0.7,
                            style: GoogleFonts.openSans(
                                textStyle: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600)),
                          ),
                          SizedBox(
                            height: 14,
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      if (_configured == true)
                        showInSnackBarModel(
                            'Drone not configured\n(Go to settings to configure)',
                            Icons.error,
                            Colors.red);
                      else if(_connected == false)
                        showInSnackBarModel(
                            "Not connected to the drone", Icons.error, Colors.redAccent);
                      else if (data.title == 'Gallery') {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => GalleryView()));
                      } else if (data.title == 'Location') {
                        Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => GpsView()));
                      } else if (data.title == 'Camera') {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => MyVideoView()));
                      } else if (data.title == 'Voice Control') {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => VoiceControl()));
                      }
                    },
                  );
                }).toList()),
          ),
        ),
      ],
    );
  }

  Widget _connectionLoader() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Container(
      width: width / 1.5,
      height: height / 3,
      decoration: new BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.blue,
            offset: Offset(0.0, 10.0),
            blurRadius: 12.0,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(top: 20),
        child: Align(
          alignment: Alignment.center,
          child: Card(
            elevation: 10,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SpinKitFadingCube(
                  color: Colors.blueAccent,
                  size: 60.0,
                  controller: AnimationController(
                    vsync: this,
                    duration: const Duration(milliseconds: 1200),
                  ),
                ),
                SizedBox(
                  height: 40.0,
                ),
                LoadingText(
                    textStyle: TextStyle(
                        fontFamily: 'WorkSansSemiBold',
                        fontSize: 20,
                        color: Colors.black)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> connectToDrone() async {
    var take = await ConnectionCrud().getConnectionModel(userId);
    if (take != null) {
      connectionFromHost = take.connectionHost;
      connectionFromPort = take.connectionPort;
    }
  }

  Widget _pageView(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    if (_page == 1) {
      return GestureDetector(
        onTap: () {
          setState(() {
            _keysOn = false;
          });
          FocusScopeNode currentFocus = FocusScope.of(context);

          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(color: Colors.blueAccent, width: 5)),
                image: DecorationImage(
                  image: AssetImage("assets/gif/intro_logo.gif"),
                  fit: BoxFit.fitWidth,
                ),
              ),
              child: new BackdropFilter(
                filter: new ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: Center(
                  child: new Container(
                    decoration: new BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        Align(
                          alignment: Alignment.topCenter,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.only(top: 10),
                                width: 250,
                                height: 250,
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                  image: AssetImage(
                                      "assets/images-png/drone_title.png"),
                                )),
                              )
                            ],
                          ),
                        ),
                        AnimatedPositioned(
                          width: width,
                          height: height,
                          duration: Duration(milliseconds: 500),
                          top: _keysOn
                              ? height - (height - 150)
                              : height - (height - 260),
                          child: ConstrainedBox(
                              constraints: const BoxConstraints.expand(),
                              child: _unConf
                                  ? _gridVisible
                                      ? dashGrid(context)
                                      : _droneConfig()
                                  : dashGrid(context)),
                        ),
                        !_gridVisible
                            ? Container()
                            : Visibility(
                                visible: loaderVisibility,
                                child: AnimatedPositioned(
                                    duration: Duration(milliseconds: 500),
                                    top: loaderVisibility ? height - (height - 300) : 20,
                                    child: _connectionLoader())),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      if (_page == 2)
        return SettingsList(
          sections: [
            SettingsSection(
              title: 'Settings',
              tiles: [
                SettingsTile(
                  title: 'Account',
                  leading: Icon(Icons.account_circle),
                  onTap: () async {
                    await animated_dialog_box.showInOutDailog(
                      title: Center(
                          child: Text(
                        "Account",
                        style: TextStyle(
                            color: Colors.black,
                            fontFamily: "WorkSansSemiBold"),
                        textScaleFactor: 1.0,
                      )),
                      context: context,
                      firstButton: MaterialButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                        color: Colors.black,
                        child: Text(
                          'Log Out',
                          textScaleFactor: 0.7,
                        ),
                        onPressed: () async {
                          setState(() {
                            _page = 1;
                          });
                          final CurvedNavigationBarState navBarState =
                              _bottomNavigationKey.currentState;
                          navBarState.setPage(1);
                          logoutUser();
                          setState(() {
                            SocketClient.socket.write("!DISCONNECT");
                            SocketClient.socketParameters.write("!DISCONNECT");
                            if(_connected == true) {
                              SocketClient.socket.destroy();
                              SocketClient.socketParameters.destroy();
                            }
                            connectedToServers = 0;
                          });
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => LoginPage()));
                        },
                      ),
                      secondButton: MaterialButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                        color: Colors.black,
                        child: Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      icon: Icon(
                        Icons.account_circle,
                        color: Colors.transparent,
                        size: 1,
                      ),
                      yourWidget: Container(
                        child: Column(
                          children: [
                            Image(
                              image: AssetImage(
                                  "assets/images-png/settings_account.png"),
                              width: 150.0,
                              height: 150.0,
                            ),
                            SizedBox(
                              width: 150.0,
                              height: 2.0,
                            ),
                            Container(
                              width: 250.0,
                              height: 1.0,
                              color: Colors.blueGrey[400],
                            ),
                            SizedBox(
                              width: 250.0,
                              height: 8.0,
                            ),
                            Container(
                              color: Colors.blue.withAlpha(30),
                              child: Text(
                                "Email: " + userEmail,
                                textScaleFactor: 1.0,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: "WorkSansSemiBold"),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                SettingsTile(
                  title: 'Change Passwword',
                  leading: Icon(Icons.lock_outline),
                  onTap: () async {
                    await animated_dialog_box.showInOutDailog(
                      title: Center(
                          child: Text(
                        "Reset Password",
                        textScaleFactor: 0.7,
                      )),
                      context: context,
                      firstButton: MaterialButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                        color: Colors.black,
                        child: Text(
                          'Ok',
                          textScaleFactor: 0.7,
                        ),
                        onPressed: () {},
                      ),
                      secondButton: MaterialButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                        color: Colors.black,
                        child: Text(
                          'Cancel',
                          textScaleFactor: 0.7,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      icon: Icon(
                        Icons.lock_outline,
                        color: Colors.transparent,
                      ),
                      yourWidget: Container(
                        child: Column(
                          children: [
                            TextFormField(
                              obscureText: _obscurePassword,
                              style: TextStyle(
                                  fontFamily: "WorkSansSemiBold",
                                  fontSize: 16.0,
                                  color: Colors.black),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                icon: Icon(
                                  Icons.lock_open,
                                  color: Colors.black,
                                ),
                                labelText: "Old Password",
                                hintText: "******",
                                suffixIcon: GestureDetector(
                                  onTap: _toggleSignup,
                                  child: Icon(
                                    _obscurePassword
                                        ? FontAwesomeIcons.eye
                                        : FontAwesomeIcons.eyeSlash,
                                    size: 15.0,
                                    color: Colors.black,
                                  ),
                                ),
                                hintStyle: TextStyle(
                                    fontFamily: "WorkSansSemiBold",
                                    fontSize: 17.0),
                              ),
                            ),
                            Container(
                              width: 250.0,
                              height: 1.0,
                              color: Colors.blueGrey[400],
                            ),
                            TextFormField(
                              obscureText: _obscurePassword,
                              style: TextStyle(
                                  fontFamily: "WorkSansSemiBold",
                                  fontSize: 16.0,
                                  color: Colors.black),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                icon: Icon(
                                  Icons.lock_outline,
                                  color: Colors.black,
                                ),
                                labelText: "New Password",
                                hintText: "******",
                                suffixIcon: GestureDetector(
                                  onTap: _toggleSignup,
                                  child: Icon(
                                    _obscurePassword
                                        ? FontAwesomeIcons.eye
                                        : FontAwesomeIcons.eyeSlash,
                                    size: 15.0,
                                    color: Colors.black,
                                  ),
                                ),
                                hintStyle: TextStyle(
                                    fontFamily: "WorkSansSemiBold",
                                    fontSize: 17.0),
                              ),
                            ),
                            Container(
                              width: 250.0,
                              height: 1.0,
                              color: Colors.blueGrey[400],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                SettingsTile(
                    title: 'Configure Drone',
                    leading: Icon(Icons.vpn_key),
                    onTap: () async {
                      if (_configured == false) {
                        var take =
                            await ConnectionCrud().getConnectionModel(userId);
                        connectionPort.text = (take.connectionPort.toString());
                        connectionHostname.text = take.connectionHost;

                        if (take.connectionType == "SSH")
                          _connection = 0;
                        else if (take.connectionType == "SERIAL")
                          _connection = 1;
                        else if (take.connectionType == "TELEMETRY")
                          _connection = 2;

                        if (take.connectionModel == "BeagleBone Blue")
                          _model = 0;
                        else if (take.connectionModel == "Navio2")
                          _model = 1;
                        else if (take.connectionModel == "Pixhawk Cube")
                          _model = 2;
                        else if (take.connectionModel == "Pixhawk") _model = 3;
                      }
                      final CurvedNavigationBarState navBarState =
                          _bottomNavigationKey.currentState;
                      navBarState.setPage(1);
                      setState(() {
                        _gridVisible = false;
                        _unConf = true;
                        _page = 1;
                        index = 1;
                        dashboardContent(1);
                      });
                      Future.delayed(const Duration(milliseconds: 1600), () {
                        setState(() {
                          _cancel = false;
                          _dConfig = false;
                        });
                      });
                      Future.delayed(const Duration(milliseconds: 500), () {
                        setState(() {
                          _height = 400;
                        });
                      });
                    }),
                SettingsTile(
                  title: 'Language',
                  subtitle: 'Only English available now.\nWait for Update!',
                  leading: Icon(Icons.language),
                  onTap: () async {
                    await animated_dialog_box.showInOutDailog(
                      title: Center(
                          child: Text(
                        "Update coming soon",
                        textScaleFactor: 0.7,
                      )),
                      context: context,
                      firstButton: MaterialButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                        color: Colors.black,
                        child: Text(
                          'Ok',
                          textScaleFactor: 0.7,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      icon: Icon(
                        Icons.language,
                        color: Colors.black,
                      ),
                      yourWidget: Container(
                        width: 250.0,
                        height: 1.0,
                        color: Colors.blueGrey[400],
                      ),
                    );
                  },
                ),
              ],
            ),
            SettingsSection(
              title: "Notification",
              tiles: [
                SettingsTile.switchTile(
                  title: "Receive Notifications",
                  switchValue: notifications,
                  onToggle: (bool notifications) {
                    print(notifications);
                    setState(() {
                      notifications = true;
                    });
                  },
                ),
                SettingsTile.switchTile(
                  title: "Receive Newsletter",
                  onToggle: (bool newsletter) {
                    newsletter = !newsletter;
                  },
                  switchValue: newsletter,
                  enabled: false,
                ),
              ],
            ),
          ],
        );
      else {
        return new Container(
          height: height - 60,
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images-jpg/flysafe_bg.jpg"),
              fit: BoxFit.fill,
            ),
          ),
          child: new BackdropFilter(
            filter: new ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            child: Stack(
              children: [
                ScrollConfiguration(
                  behavior: MyBehavior(),
                  child: ListView(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                            top: _dTap ? 80.0 : 0,
                            left: _dTap ? 25.0 : 0,
                            right: _dTap ? 25.0 : 0),
                        child: Column(
                          children: [
                            Visibility(
                              visible: _safe
                                  ? false
                                  : _func ? false : _tech ? false : true,
                              child: SizedBox(
                                width: width,
                                height: 80,
                                child: GestureDetector(
                                  onTap: () {
                                    print("DropDown");
                                    if (_hDown == 0) {
                                      Future.delayed(const Duration(seconds: 0),
                                          () {
                                        setState(() {
                                          _hDown = height - 250;
                                          _area = true;
                                          _tap = true;
                                        });
                                      });
                                    } else {
                                      setState(() {
                                        Future.delayed(
                                            const Duration(seconds: 1), () {
                                          setState(() {
                                            _area = false;
                                            _safe = false;
                                            _func = false;
                                            _tech = false;
                                            _tap = false;
                                            _dTap = true;
                                          });
                                        });
                                        _hDown = 0;
                                      });
                                    }
                                  },
                                  child: Card(
                                    color: _tap
                                        ? Colors.white
                                        : Colors.white.withAlpha(180),
                                    shadowColor: Colors.blueAccent,
                                    elevation: 50,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(20.0),
                                      child: Row(children: [
                                        Expanded(
                                          child: Text(
                                            "What is a Drone?",
                                            textScaleFactor: 0.7,
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontFamily: 'WorkSansBold'),
                                          ),
                                        ),
                                        Icon(
                                          Icons.info_outline,
                                          color: Colors.black,
                                          size: 30,
                                        ),
                                      ]),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Visibility(
                              visible: _area
                                  ? false
                                  : _func ? false : _tech ? false : true,
                              child: SizedBox(
                                width: width,
                                height: 80,
                                child: GestureDetector(
                                  onTap: () {
                                    print("DropDown");
                                    if (_hDown == 0) {
                                      Future.delayed(const Duration(seconds: 0),
                                          () {
                                        setState(() {
                                          _hDown = height - 250;
                                          _tap = true;
                                          _safe = true;
                                          print(_safe);
                                        });
                                      });
                                    } else {
                                      Future.delayed(const Duration(seconds: 1),
                                          () {
                                        setState(() {
                                          _safe = false;
                                          _area = false;
                                          _func = false;
                                          _tech = false;
                                          _tap = false;
                                          _dTap = true;
                                        });
                                      });
                                      setState(() {
                                        _hDown = 0;
                                      });
                                    }
                                  },
                                  child: Card(
                                    color: _tap
                                        ? Colors.white
                                        : Colors.white.withAlpha(180),
                                    shadowColor: Colors.blueAccent,
                                    elevation: 50,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(20.0),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              "Fly Safe",
                                              textScaleFactor: 0.7,
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontFamily: 'WorkSansBold'),
                                            ),
                                          ),
                                          Icon(
                                            Icons.flight,
                                            color: Colors.black,
                                            size: 30,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Visibility(
                              visible: _area
                                  ? false
                                  : _safe ? false : _tech ? false : true,
                              child: SizedBox(
                                width: width,
                                height: 80,
                                child: GestureDetector(
                                  onTap: () {
                                    print("DropDown");
                                    if (_hDown == 0) {
                                      Future.delayed(const Duration(seconds: 0),
                                          () {
                                        setState(() {
                                          _hDown = height - 250;
                                          _tap = true;
                                          _func = true;
                                        });
                                      });
                                    } else {
                                      Future.delayed(const Duration(seconds: 1),
                                          () {
                                        setState(() {
                                          _func = false;
                                          _area = false;
                                          _safe = false;
                                          _tech = false;
                                          _tap = false;
                                          _dTap = true;
                                        });
                                      });
                                      setState(() {
                                        _hDown = 0;
                                      });
                                    }
                                  },
                                  child: Card(
                                    color: _tap
                                        ? Colors.white
                                        : Colors.white.withAlpha(180),
                                    shadowColor: Colors.blueAccent,
                                    elevation: 50,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(20.0),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              "Drone Functionality",
                                              textScaleFactor: 0.7,
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontFamily: 'WorkSansBold'),
                                            ),
                                          ),
                                          Icon(
                                            Icons.settings_input_antenna,
                                            color: Colors.black,
                                            size: 30,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Visibility(
                              visible: _area
                                  ? false
                                  : _safe ? false : _func ? false : true,
                              child: SizedBox(
                                width: width,
                                height: 80,
                                child: GestureDetector(
                                  onTap: () {
                                    print("DropDown");
                                    if (_hDown == 0) {
                                      Future.delayed(const Duration(seconds: 0),
                                          () {
                                        setState(() {
                                          _hDown = height - 250;
                                          _tap = true;
                                          _tech = true;
                                        });
                                      });
                                    } else {
                                      Future.delayed(const Duration(seconds: 1),
                                          () {
                                        setState(() {
                                          _func = false;
                                          _area = false;
                                          _tech = false;
                                          _safe = false;
                                          _tap = false;
                                          _dTap = true;
                                        });
                                      });
                                      setState(() {
                                        _hDown = 0;
                                      });
                                    }
                                  },
                                  child: Card(
                                    color: _tap
                                        ? Colors.white
                                        : Colors.white.withAlpha(180),
                                    shadowColor: Colors.blueAccent,
                                    elevation: 50,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(20.0),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              "Technology and features",
                                              textScaleFactor: 0.7,
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontFamily: 'WorkSansBold'),
                                            ),
                                          ),
                                          Icon(
                                            Icons.all_inclusive,
                                            color: Colors.black,
                                            size: 30,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment(0, 0.2),
                        child: AnimatedContainer(
                          duration: Duration(seconds: 1),
                          width: width,
                          height: _hDown,
                          child: GestureDetector(
                            onDoubleTap: () {
                              if (_dTap == false)
                                Future.delayed(const Duration(seconds: 1), () {
                                  setState(() {
                                    _dTap = true;
                                  });
                                });
                              else {
                                setState(() {
                                  _dTap = false;
                                });
                              }
                              setState(() {
                                if (_hDown == height - 170)
                                  _hDown = height - 250;
                                else
                                  _hDown = height - 170;
                              });
                            },
                            child: Card(
                              elevation: 50,
                              color: Colors.white.withAlpha(200),
                              shadowColor: Colors.blueAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              margin: EdgeInsets.all(_dTap ? 25.0 : 0),
                              child: _safe
                                  ? _flySafe()
                                  : Container(
                                      child: _area
                                          ? _stuffAbout()
                                          : Container(
                                              child: _func
                                                  ? _droneFuncionality()
                                                  : Container(
                                                      child: _tech
                                                          ? _droneTech()
                                                          : Container(),
                                                    ),
                                            ),
                                    ),
                            ),
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
    }
  }

  Widget _flySafe() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Stack(
        children: <Widget>[
          ScrollConfiguration(
            behavior: MyBehavior(),
            child: ListView(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                      left: 10, right: 15, top: 10, bottom: 10.0),
                  child: Column(
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.navigate_next,
                                color: Colors.red,
                                size: 18,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Text(
                                  "During flight always maintain visual contact with your drone.",
                                  overflow: TextOverflow.clip,
                                  textScaleFactor: 0.7,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontFamily: 'WorkSansMedium',
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.navigate_next,
                                color: Colors.black,
                                size: 18,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Text(
                                  "Flying closer than 1km from an airport runway is not allowed without permission from the air traffic control tower.",
                                  overflow: TextOverflow.clip,
                                  textScaleFactor: 0.7,
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontFamily: 'WorkSansMedium'),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.navigate_next,
                                color: Colors.black,
                                size: 18,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Text(
                                  "Flying at distances between 1 km to 3 km from an airport runway is allowed up to the height of surrounding obstacles. In close vicinity to an obstacle, you may fly 15 m over the obstacle height with permission from the obstacle owner.",
                                  overflow: TextOverflow.clip,
                                  textScaleFactor: 0.7,
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontFamily: 'WorkSansMedium'),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.navigate_next,
                                color: Colors.black,
                                size: 18,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Text(
                                  "The maximum allowed flight altitude is 150m. Flying in the control zone of an airport but still further away than 3 km from the airport runways, the maximum allowed flight altitude is 50m.",
                                  overflow: TextOverflow.clip,
                                  textScaleFactor: 0.7,
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontFamily: 'WorkSansMedium'),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.navigate_next,
                                color: Colors.blueAccent,
                                size: 18,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Text(
                                  "Flying a drone above a crowd of people is not allowed. The minimum safe distance is 50 m.",
                                  overflow: TextOverflow.clip,
                                  textScaleFactor: 0.7,
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontFamily: 'WorkSansMedium',
                                      color: Colors.blueAccent),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.navigate_next,
                                color: Colors.red,
                                size: 18,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Text(
                                  "The flight must not endanger or disturb the operations of an emergency services helicopter. ",
                                  overflow: TextOverflow.clip,
                                  textScaleFactor: 0.7,
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontFamily: 'WorkSansMedium',
                                      color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.navigate_next,
                                color: Colors.red,
                                size: 18,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Text(
                                  "When flying close to small aerodromes you need the aerodrome operator’s permit to fly closer than 1 km, or if the aerodrome has published local regulations for flying a drone you must follow them. ",
                                  overflow: TextOverflow.clip,
                                  textScaleFactor: 0.7,
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontFamily: 'WorkSansMedium',
                                      color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.navigate_next,
                                color: Colors.red,
                                size: 18,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Text(
                                  "For flying closer than 600 m to helipads you need to have the helipad operator’s permission. ",
                                  overflow: TextOverflow.clip,
                                  textScaleFactor: 0.7,
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontFamily: 'WorkSansMedium',
                                      color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.navigate_next,
                                color: Colors.black,
                                size: 18,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Text(
                                  "Flying above cities is allowed if the pilot knows the flying area, has made sure that it is possible to fly there safely, and the drone weighs less than 3kg.",
                                  overflow: TextOverflow.clip,
                                  textScaleFactor: 0.7,
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontFamily: 'WorkSansMedium'),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.navigate_next,
                                color: Colors.red,
                                size: 18,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Text(
                                  "Flights must not cause danger to or disturb other people. ",
                                  overflow: TextOverflow.clip,
                                  textScaleFactor: 0.7,
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontFamily: 'WorkSansMedium',
                                      color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.navigate_next,
                                color: Colors.blueAccent,
                                size: 18,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Text(
                                  "Mark your drone with your name and contact information.",
                                  overflow: TextOverflow.clip,
                                  textScaleFactor: 0.7,
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontFamily: 'WorkSansMedium',
                                      color: Colors.blueAccent),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.navigate_next,
                                color: Colors.blueAccent,
                                size: 18,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Text(
                                  "Taking an insurance against third party damages is recommended.",
                                  overflow: TextOverflow.clip,
                                  textScaleFactor: 0.7,
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontFamily: 'WorkSansMedium',
                                      color: Colors.blueAccent),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: IconButton(
              onPressed: () {
                setState(() {
                  _hDown = 0;
                  Future.delayed(const Duration(seconds: 1), () {
                    setState(() {
                      print(_safe);
                      _area = false;
                      _safe = false;
                      _tech = false;
                      _func = false;
                      _dTap = true;
                    });
                  });
                  _tap = false;
                });
              },
              icon: new Icon(Icons.keyboard_arrow_up,
                  size: 40, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stuffAbout() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Padding(
      padding: EdgeInsets.only(left: 10, right: 15, top: 10, bottom: 10),
      child: Stack(
        children: [
          ScrollConfiguration(
            behavior: MyBehavior(),
            child: ListView(
              children: [
                Text(
                  "   What is a Drone?",
                  textScaleFactor: 0.7,
                  style: TextStyle(
                    fontFamily: 'WorkSansSemiBold',
                    fontSize: 19,
                  ),
                ),
                Text(
                  "\nA drone, in technological terms, is an unmanned aircraft. Drones are more formally known as unmanned aerial vehicles (UAVs) or unmanned aircraft systems (UASes). Essentially, a drone is a flying robot that can be remotely controlled or fly autonomously through software-controlled flight plans in their embedded systems, working in conjunction with onboard sensors and GPS."
                  "\n\nIn the recent past, UAVs were most often associated with the military, where they were used initially for anti-aircraft target practice, intelligence gathering and then, more controversially, as weapons platforms. Drones are now also used in a wide range of civilian roles ranging from search and rescue, surveillance, traffic monitoring, weather monitoring and firefighting, to personal drones and business drone-based photography, as well as videography, agriculture and even delivery services.",
                  overflow: TextOverflow.clip,
                  textScaleFactor: 0.7,
                  style: TextStyle(fontSize: 18, fontFamily: 'WorkSansMedium'),
                ),
                Text(
                  "\n\n   The history of drones",
                  textScaleFactor: 0.7,
                  style: TextStyle(
                    fontFamily: 'WorkSansSemiBold',
                    fontSize: 19,
                  ),
                ),
                Text(
                  "\nMany trace the history of drones to 1849 Italy, when Venice was fighting for its independence from Austria. Austrian soldiers attacked Venice with hot-air, hydrogen- or helium-filled balloons equipped with bombs.\n\nThe first pilotless radio-controlled aircraft were used in World War I. In 1918, the U.S. Army developed the experimental Kettering Bug, an unmanned 'flying bomb' aircraft, which was never used in combat.\n\nThe first generally used drone appeared in 1935 as a full-size retooling of the de Havilland DH82B 'Queen Bee' biplane, which was fitted with a radio and servo-operated controls in the back seat. The plane could be conventionally piloted from the front seat, but generally it flew unmanned and was shot at by artillery gunners in training. The term drone dates to this initial use, a play on the 'Queen Bee' nomenclature.\n\nUAV technology continued to be of interest to the military, but it was often too unreliable and costly to put into use. After concerns about the shooting down of spy planes arose, the military revisited the topic of unmanned aerial vehicles. Military use of drones soon expanded to play roles in dropping leaflets and acting as spying decoys.\n",
                  overflow: TextOverflow.clip,
                  textScaleFactor: 0.7,
                  style: TextStyle(fontSize: 18, fontFamily: 'WorkSansMedium'),
                ),
                Container(
                  width: width,
                  height: height / 3,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images-jpg/history.jpg"),
                      fit: BoxFit.fill,
                    ),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
                Text(
                  "\nMilitary drone use solidified in 1982 when the Israeli Air Force used UAVs to wipe out the Syrian fleet with minimal loss of Israeli forces. The Israeli UAVs acted as decoys, jammed communication and offered real-time video reconnaissance.\n\nDrones have continued to be a mainstay in the military, playing critical roles in intelligence, surveillance and force protection, artillery spotting, target following and acquisition, battle damage assessment and reconnaissance, as well as for weaponry.",
                  overflow: TextOverflow.clip,
                  textScaleFactor: 0.7,
                  style: TextStyle(fontSize: 18, fontFamily: 'WorkSansMedium'),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: IconButton(
              onPressed: () {
                setState(() {
                  _hDown = 0;
                  Future.delayed(const Duration(seconds: 1), () {
                    setState(() {
                      _safe = false;
                      _area = false;
                      _tech = false;
                      _func = false;
                      _dTap = true;
                    });
                  });
                  _tap = false;
                });
              },
              icon: new Icon(Icons.keyboard_arrow_up,
                  size: 40, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _droneFuncionality() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Padding(
      padding: EdgeInsets.only(left: 10, right: 15, top: 0, bottom: 5),
      child: Stack(
        children: <Widget>[
          ScrollConfiguration(
            behavior: MyBehavior(),
            child: ListView(
              children: [
                Text(
                  "   How does a drone work?\n",
                  textScaleFactor: 0.7,
                  style: TextStyle(
                    fontFamily: 'WorkSansSemiBold',
                    fontSize: 19,
                  ),
                ),
                Text(
                  "While drones serve a variety of purposes, such as recreational, photography, commercial and military, their two basic functions are flight and navigation.\n\nTo achieve flight, drones consist of a power source, such as battery or fuel, rotors, propellers and a frame. The frame of a drone is typically made of lightweight, composite materials, to reduce weight and increase maneuverability during flight.\n\nDrones require a controller, which is used remotely by an operator to launch, navigate and land it. Controllers communicate with the drone using radio waves, including Wi-Fi.",
                  overflow: TextOverflow.clip,
                  textScaleFactor: 0.7,
                  style: TextStyle(fontSize: 18, fontFamily: 'WorkSansMedium'),
                ),
                Container(
                  width: width,
                  height: height / 3.5,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/gif/functionality.gif"),
                      fit: BoxFit.fill,
                    ),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: IconButton(
              onPressed: () {
                setState(() {
                  _hDown = 0;
                  Future.delayed(const Duration(seconds: 1), () {
                    setState(() {
                      _func = false;
                      _area = false;
                      _tech = false;
                      _safe = false;
                      _dTap = true;
                    });
                  });
                  _tap = false;
                });
              },
              icon: new Icon(Icons.keyboard_arrow_up,
                  size: 40, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _droneTech() {
    return Padding(
        padding: EdgeInsets.only(left: 10, right: 15, top: 0, bottom: 5),
        child: Stack(children: [
          ScrollConfiguration(
            behavior: MyBehavior(),
            child: ListView(
              children: [
                Column(
                  children: <Widget>[
                    Text(
                      "Drones contain a large number of technological components, including:\n",
                      textScaleFactor: 0.7,
                      style: TextStyle(
                        fontSize: 19,
                        fontFamily: 'WorkSansMedium',
                        color: Colors.black,
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.blur_circular,
                          color: Colors.black,
                          size: 18,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Text(
                            "Electronic Speed Controllers (ESC), an electronic circuit that controls a motor’s speed and direction.",
                            overflow: TextOverflow.clip,
                            textScaleFactor: 0.7,
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: 'WorkSansMedium',
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.blur_circular,
                          color: Colors.black,
                          size: 18,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Text(
                            "Flight controller.",
                            textScaleFactor: 0.7,
                            overflow: TextOverflow.clip,
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: 'WorkSansMedium',
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.blur_circular,
                          color: Colors.black,
                          size: 18,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Text(
                            "GPS module",
                            textScaleFactor: 0.7,
                            overflow: TextOverflow.clip,
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: 'WorkSansMedium',
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.blur_circular,
                          color: Colors.black,
                          size: 18,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Text(
                            "Battery",
                            textScaleFactor: 0.7,
                            overflow: TextOverflow.clip,
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: 'WorkSansMedium',
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.blur_circular,
                          color: Colors.black,
                          size: 18,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Text(
                            "Antenna",
                            textScaleFactor: 0.7,
                            overflow: TextOverflow.clip,
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: 'WorkSansMedium',
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.blur_circular,
                          color: Colors.black,
                          size: 18,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Text(
                            "Receiver",
                            textScaleFactor: 0.7,
                            overflow: TextOverflow.clip,
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: 'WorkSansMedium',
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.blur_circular,
                          color: Colors.black,
                          size: 18,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Text(
                            "Cameras",
                            textScaleFactor: 0.7,
                            overflow: TextOverflow.clip,
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: 'WorkSansMedium',
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.blur_circular,
                          color: Colors.black,
                          size: 18,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Text(
                            "Sensors, including ultrasonic sensors and collision avoidance sensors",
                            overflow: TextOverflow.clip,
                            textScaleFactor: 0.7,
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: 'WorkSansMedium',
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.blur_circular,
                          color: Colors.black,
                          size: 18,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Text(
                            "Accelerometer, which measures speed",
                            textScaleFactor: 0.7,
                            overflow: TextOverflow.clip,
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: 'WorkSansMedium',
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.blur_circular,
                          color: Colors.black,
                          size: 18,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Text(
                            "Altimeter, which measures altitude",
                            textScaleFactor: 0.7,
                            overflow: TextOverflow.clip,
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: 'WorkSansMedium',
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                  ],
                ),
                AvatarGlow(
                  startDelay: Duration(milliseconds: 1000),
                  glowColor: Colors.blueAccent,
                  endRadius: 100.0,
                  duration: Duration(milliseconds: 2000),
                  repeat: true,
                  showTwoGlows: true,
                  repeatPauseDuration: Duration(milliseconds: 100),
                  child: MaterialButton(
                    onPressed: _launchURL,
                    elevation: 20.0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0)),
                    child: Container(
                      width: 100.0,
                      height: 100.0,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(50.0)),
                      child: Text(
                        "12 Best Drones",
                        textScaleFactor: 0.7,
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Colors.blueAccent),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Align(alignment: Alignment.bottomCenter, child: Container()),
          Align(
            alignment: Alignment.bottomRight,
            child: IconButton(
              onPressed: () {
                setState(() {
                  _hDown = 0;
                  Future.delayed(const Duration(seconds: 1), () {
                    setState(() {
                      print(_safe);
                      _area = false;
                      _safe = false;
                      _tech = false;
                      _func = false;
                      _dTap = true;
                    });
                  });
                  _tap = false;
                });
              },
              icon: new Icon(Icons.keyboard_arrow_up,
                  size: 40, color: Colors.black),
            ),
          ),
        ]));
  }

  void _toggleSignup() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  Future<void> logoutUser() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<void> getCurrentUserInfo() async {
    user = await _auth.currentUser();
    userEmail = user.email;
    userId = user.uid;
    getConnectionContext(user.uid);
  }

  Future<void> getConnectionContext(String userId) async {
    bool res = await connectionModelCrud.getConnectionById(userId);
    if (!res) {
      setState(() {
        _configured = false;
        _gridVisible = true;
        _unConf = false;
      });
    } else
      setState(() {
        _configured = true;
        _unConf = true;
      });
  }

  _launchURL() async {
    const url = 'https://uavcoach.com/professional-drones/';
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: true,
        forceWebView: true,
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  void configureConnectionDrone(String connectionType, String modelType,
      String connectionHostname, int port) {
    connectionModel = new ConnectionModel(
        user.uid, modelType, connectionType, connectionHostname, port);
    connectionModelCrud.addConnection(connectionModel);
    setState(() {
      _height = 0;
      _keysOn = false;
      _dConfig = true;
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _configured = true;
          _unConf = false;
        });
      });
    });
  }

  Future<void> connectToSockets() async {
    connectToDrone();
    if (connectedToServers == 0) {
      setState(() {
        loaderVisibility = true;
      });
      await Future.delayed(const Duration(seconds: 5), () {
        setState(() {
          if (connectionFromHost != null && connectionFromPort != null)
            socketClient =
                new SocketClient(connectionFromHost, connectionFromPort);
        });
      });

      setState(() {
        loaderVisibility = false;
        connectedToServers = 1;
      });

      await Future.delayed(const Duration(seconds: 1));
      try {
        SocketClient.socket.listen((data) {
          String value = new String.fromCharCodes(data).trim();
          if (value == "connected") {
            _connected = true;
          }
          else _connected = false;
        });

      } catch (e) {
        showInSnackBarModel(
            "Not connected to the drone", Icons.error, Colors.redAccent);
        _connected = false;
      }
    }
  }
}

class Items {
  String title;
  String subtitle;
  String event;
  String img;
  Items({this.title, this.subtitle, this.event, this.img});
}
