import 'dart:ui';
import 'package:drone_s500/src/app/views/dashboard_page.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:drone_s500/src/app/utils/bubble_indication_painter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:drone_s500/src/app/utils/firebase_auth.dart';
import 'package:animated_dialog_box/animated_dialog_box.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKeySignUp = GlobalKey<FormState>();
  final _formKeySignIn = GlobalKey<FormState>();

  final GlobalKey<ScaffoldState> _scaffoldKeyError =
      new GlobalKey<ScaffoldState>();
  final FocusNode myFocusNodeEmailLogin = FocusNode();
  final FocusNode myFocusNodePasswordLogin = FocusNode();

  final FocusNode myFocusNodePassword = FocusNode();
  final FocusNode myFocusNodeEmail = FocusNode();
  final FocusNode myFocusNodeName = FocusNode();

  TextEditingController loginEmailController = new TextEditingController();
  TextEditingController loginPasswordController = new TextEditingController();

  bool _obscureTextLogin = true;
  bool _obscureTextSignup = true;

  TextEditingController loginPasswordRecoverController =
      new TextEditingController();
  TextEditingController signupEmailController = new TextEditingController();
  TextEditingController signupNameController = new TextEditingController();
  TextEditingController signupPasswordController = new TextEditingController();

  PageController _pageController;

  Color left = Colors.black;
  Color right = Colors.white;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return WillPopScope(
        onWillPop: () {
      return new Future(() => false);
    },
    child: new Scaffold(
      key: _scaffoldKeyError,
      body: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (overscroll) {
          overscroll.disallowGlow();
          return;
        },
        child: SingleChildScrollView(
          child: Container(
            width: width,
            height: height >= 775.0 ? height : 775.0,
            decoration: new BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/images-jpg/login_background.jpg"),
                  fit: BoxFit.cover),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top:100.0),
                  child: new Image(
                    width: 250.0,
                    height: 191.0,
                    fit: BoxFit.fill,
                    filterQuality: FilterQuality.high,
                    image: new AssetImage('assets/images-png/drone_title_white.png'),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 20.0),
                  child: _buildMenuBar(context),
                ),
                Expanded(
                  flex: 2,
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (i) {
                      if (i == 0) {
                        setState(() {
                          right = Colors.white;
                          left = Colors.black;
                        });
                      } else if (i == 1) {
                        setState(() {
                          right = Colors.black;
                          left = Colors.white;
                        });
                      }
                    },
                    children: <Widget>[
                      new ConstrainedBox(
                        constraints: const BoxConstraints.expand(),
                        child: _buildSignIn(context),
                      ),
                      new ConstrainedBox(
                        constraints: const BoxConstraints.expand(),
                        child: _buildSignUp(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),);
  }

  Widget _buildSignUp(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Form(
      key: _formKeySignUp,
      child: Column(
        children: <Widget>[
          Stack(
            alignment: Alignment.topCenter,
            overflow: Overflow.visible,
            children: <Widget>[
              Card(
                margin: new EdgeInsets.symmetric(vertical: 23.0),
                elevation: 2.0,
                color: Colors.white.withAlpha(150),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Container(
                  width: 300.0,
                  height: 280,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                            left: 25.0,
                            right: 25.0),
                        child: TextFormField(
                          focusNode: myFocusNodeName,
                          controller: signupNameController,
                          keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.words,
                          style: TextStyle(
                              fontFamily: "WorkSansSemiBold",
                              fontSize: 16.0,
                              color: Colors.black),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(
                              FontAwesomeIcons.user,
                              color: Colors.black,
                            ),
                            contentPadding: EdgeInsets.only(top: 30, bottom: 20.0),
                            labelText: "Name",
                            hintText: "name",
                            hintStyle: TextStyle(
                                fontFamily: "WorkSansSemiBold", fontSize: 16.0),
                          ),
                        ),
                      ),
                      Container(
                        width: 250.0,
                        height: 1.0,
                        color: Colors.blueGrey[400],
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: 25.0,
                            right: 25.0),
                        child: TextFormField(
                          focusNode: myFocusNodeEmail,
                          controller: signupEmailController,
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(
                              fontFamily: "WorkSansSemiBold",
                              fontSize: 16.0,
                              color: Colors.black),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(
                              FontAwesomeIcons.envelope,
                              color: Colors.black,
                            ),
                            contentPadding: EdgeInsets.only(top: 30, bottom: 20.0),
                            labelText: "Email Address",
                            hintText: "you@example.com",
                            hintStyle: TextStyle(
                                fontFamily: "WorkSansSemiBold", fontSize: 16.0),
                          ),
                        ),
                      ),
                      Container(
                        width: 250.0,
                        height: 1.0,
                        color: Colors.blueGrey[400],
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: 25.0,
                            right: 25.0),
                        child: TextFormField(
                          focusNode: myFocusNodePassword,
                          controller: signupPasswordController,
                          obscureText: _obscureTextSignup,
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
                            contentPadding: EdgeInsets.only(top: 30, bottom: 20.0),
                            labelText: "Password",
                            hintText: "password",
                            hintStyle: TextStyle(
                                fontFamily: "WorkSansSemiBold", fontSize: 16.0),
                            suffixIcon: GestureDetector(
                              onTap: _toggleSignup,
                              child: Icon(
                                _obscureTextSignup
                                    ? FontAwesomeIcons.eye
                                    : FontAwesomeIcons.eyeSlash,
                                size: 15.0,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: height-(height-280)),
                decoration: new BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black,
                      offset: Offset(0.5, 6.0),
                      blurRadius: 20.0,
                    ),
                  ],
                  gradient: new LinearGradient(
                      colors: [Color(0xff1F47A6), Color(0xff5792D6)],
                      begin: const FractionalOffset(0.2, 0.2),
                      end: const FractionalOffset(1.0, 1.0),
                      stops: [0.0, 1.0],
                      tileMode: TileMode.clamp),
                ),
                child: MaterialButton(
                    highlightColor: Colors.transparent,
                    splashColor: Colors.black,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 42.0),
                      child: Text(
                        "SIGN UP",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 25.0,
                            fontFamily: "WorkSansBold"),
                        textScaleFactor: 1.0,
                      ),
                    ),
                    onPressed: () async {
                      if (signupNameController.text.isEmpty)
                        showInSnackBarModel("Name is empty",
                            Icons.error, Colors.red);
                      else if (signupEmailController.text.isEmpty)
                        showInSnackBarModel("Email is empty",
                            Icons.error, Colors.red);
                      else if (signupPasswordController.text.isEmpty)
                        showInSnackBarModel("Password is empty",
                            Icons.error, Colors.red);
                      else if (signupNameController.text.length < 3)
                        showInSnackBarModel("Name is to short",
                            Icons.error, Colors.red);
                      else if (!signupEmailController.text.contains("@") ||
                          signupEmailController.text.length < 5)
                        showInSnackBarModel("Invalid email format",
                            Icons.error, Colors.red);
                      else if (signupPasswordController.text.length < 6)
                        showInSnackBarModel("Password is to short",
                            Icons.error, Colors.red);
                      else {
                        bool res = await FirebaseAuthProvider().signUpWithEmail(
                            signupEmailController.text.trim(),
                            signupPasswordController.text.trim());
                        if (!res)
                          showInSnackBarModel("SignUp failed",
                              Icons.error, Colors.red);
                        else {
                          await animated_dialog_box.showInOutDailog(
                              title: Center(child: Text("Verify your Email",
                                textScaleFactor: 1.0,)),
                              context: context,
                              firstButton: MaterialButton(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(40),
                                ),
                                color: Colors.black,
                                child: Text('Ok',
                                  textScaleFactor: 1.0,),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  _onSignInButtonPress();
                                },
                              ),
                              icon: Icon(
                                Icons.info_outline,
                                color: Colors.black,
                              ),
                              // IF YOU WANT TO ADD ICON
                              yourWidget: Container(
                                child:
                                    Text('An email confirmation has been sent',
                                      textScaleFactor: 1.0,),
                              ));
                        }
                      }
                    }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    _pageController = PageController();
  }

  Widget showInSnackBarModel(String value, IconData icon, Color colorType) {
    FocusScope.of(context).requestFocus(new FocusNode());
    return new Flushbar(
      borderRadius: 7,
      padding: EdgeInsets.only(left: 10),
      dismissDirection: FlushbarDismissDirection.HORIZONTAL,
      margin: EdgeInsets.only(left: 7, right: 7, bottom: 7),
      duration: Duration(milliseconds: 3000),
      shouldIconPulse: true,
      backgroundColor: Colors.black54,
      icon: Icon(icon, size: 40, color: colorType),
      messageText: Text(
        value,
        textScaleFactor: 1.0,
        style: TextStyle(
            color: Colors.white,
            fontSize: 18.0,
            fontFamily: "WorkSans-ExtraLight"),
      ),
    )..show(context);
  }

  Widget _buildMenuBar(BuildContext context) {
    return Container(
      width: 300.0,
      height: 50,
      decoration: BoxDecoration(
        color: Color(0x552B2B2B),
        borderRadius: BorderRadius.all(Radius.circular(25.0)),
      ),
      child: CustomPaint(
        painter: TabIndicationPainter(pageController: _pageController),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Expanded(
              child: FlatButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onPressed: _onSignInButtonPress,
                child: Text(
                  "Existing",
                  style: TextStyle(
                      color: left,
                      fontSize: 16.0,
                      fontFamily: "WorkSansSemiBold"),
                  textScaleFactor: 1.0,
                ),
              ),
            ),
            Expanded(
              child: FlatButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onPressed: _onSignUpButtonPress,
                child: Text(
                  "New",
                  style: TextStyle(
                      color: right,
                      fontSize: 16.0,
                      fontFamily: "WorkSansSemiBold"),
                  textScaleFactor: 1.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignIn(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Form(
      key: _formKeySignIn,
      child: Column(
        children: <Widget>[
          Stack(
            alignment: Alignment.topCenter,
            overflow: Overflow.visible,
            children: <Widget>[
              Card(
                margin: new EdgeInsets.symmetric(vertical: 23.0),
                elevation: 2.0,
                color: Colors.white.withAlpha(150),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Container(
                  width: 300.0,
                  height: 200,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                            left: 25.0,
                            right: 25.0),
                        child: TextFormField(
                          focusNode: myFocusNodeEmailLogin,
                          controller: loginEmailController,
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(
                              fontFamily: "WorkSansSemiBold",
                              fontSize: 16.0,
                              color: Colors.black),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(
                              FontAwesomeIcons.envelope,
                              color: Colors.black,
                              size: 22.0,
                            ),
                            contentPadding: EdgeInsets.only(top: 30, bottom: 20.0),
                            labelText: "Email Address",
                            hintText: "you@example.com",
                            hintStyle: TextStyle(
                                fontFamily: "WorkSansSemiBold", fontSize: 17.0),
                          ),
                        ),
                      ),
                      Container(
                        width: 250.0,
                        height: 1.0,
                        color: Colors.blueGrey[400],
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: 25.0,
                            right: 25.0),
                        child: TextFormField(
                          focusNode: myFocusNodePasswordLogin,
                          controller: loginPasswordController,
                          obscureText: _obscureTextLogin,
                          style: TextStyle(
                              fontFamily: "WorkSansSemiBold",
                              fontSize: 16.0,
                              color: Colors.black),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(
                              FontAwesomeIcons.lock,
                              size: 22.0,
                              color: Colors.black,
                            ),
                            labelText: "Password",
                            hintText: "password",
                            contentPadding: EdgeInsets.only(top: 30, bottom: 20.0),
                            hintStyle: TextStyle(
                                fontFamily: "WorkSansSemiBold", fontSize: 17.0),
                            suffixIcon: GestureDetector(
                              onTap: _toggleLogin,
                              child: Icon(
                                _obscureTextLogin
                                    ? FontAwesomeIcons.eye
                                    : FontAwesomeIcons.eyeSlash,
                                size: 15.0,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: height-(height-190)),
                decoration: new BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black,
                      offset: Offset(0.5, 6.0),
                      blurRadius: 20.0,
                    ),
                  ],
                  gradient: new LinearGradient(
                      colors: [Color(0xff1F47A6), Color(0xff5792D6)],
                      begin: const FractionalOffset(0.2, 0.2),
                      end: const FractionalOffset(1.0, 1.0),
                      stops: [0.0, 1.0],
                      tileMode: TileMode.clamp),
                ),
                child: MaterialButton(
                    highlightColor: Colors.transparent,
                    splashColor: Colors.black,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 42.0),
                      child: Text(
                        "LOGIN",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 25.0,
                            fontFamily: "WorkSansBold"),
                        textScaleFactor: 1.0,
                      ),
                    ),
                    onPressed: () async {
                      if (loginEmailController.text.isEmpty)
                        showInSnackBarModel("Email is empty",
                            Icons.error, Colors.red);
                      else if (loginPasswordController.text.isEmpty)
                        showInSnackBarModel("Password is empty",
                            Icons.error, Colors.red);
                      else if (!loginEmailController.text.contains("@") ||
                          loginEmailController.text.length < 5)
                        showInSnackBarModel("Invalid email format",
                            Icons.error, Colors.red);
                      else if (loginPasswordController.text.length < 6)
                        showInSnackBarModel("Password is short",
                            Icons.error, Colors.red);
                      else {
                        bool res = await FirebaseAuthProvider().signInWithEmail(
                            signupNameController.text.trim(),
                            loginEmailController.text.trim(),
                            loginPasswordController.text.trim());
                        if (!res)
                          showInSnackBarModel("LogIn failed",
                              Icons.error, Colors.red);
                        else
                          {
                            showInSnackBarModel("Sign In Successfuly",
                                Icons.check_circle, Colors.green);
                            Future.delayed(const Duration(seconds: 1), () {
                              setState(() {
                                Navigator.push(
                                    context,
                                    PageTransition(
                                        type: PageTransitionType.fade,
                                        child: DashboardPage()));
                              });
                            });
                          }
                      }
                    }),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: 10.0),
            child: FlatButton(
                onPressed: () async {
                  await animated_dialog_box.showRotatedAlert(
                    title: Center(child: Text("Email recovery",
                      textScaleFactor: 1.0,)),
                    context: context,
                    firstButton: MaterialButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                      color: Colors.black,
                      child: Text('Ok',
                        textScaleFactor: 1.0,),
                      onPressed: () {
                        if (loginPasswordRecoverController.text.isNotEmpty) {
                          FirebaseAuthProvider().resetPassword(
                              loginPasswordRecoverController.text.trim());
                          Navigator.of(context).pop();
                        } else {
                          showInSnackBarModel("Field is empty",
                              Icons.error, Colors.red);
                        }
                      },
                    ),
                    secondButton: MaterialButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                      color: Colors.black,
                      child: Text('Cancel',
                        textScaleFactor: 1.0,),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    icon: Icon(
                      Icons.email,
                      color: Colors.transparent,
                    ),
                    yourWidget: Container(
                      child: Column(
                        children: [
                          TextFormField(
                            focusNode: myFocusNodePasswordLogin,
                            controller: loginPasswordRecoverController,
                            obscureText: _obscureTextLogin,
                            style: TextStyle(
                                fontFamily: "WorkSansSemiBold",
                                fontSize: 16.0,
                                color: Colors.black),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              icon: Icon(
                                Icons.email,
                                color: Colors.black,
                              ),
                              labelText: "Email",
                              hintText: "email@example.com",
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
                child: Text(
                  "Forgot Password?",
                  style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: Colors.white70,
                      fontSize: 16.0,
                      fontFamily: "WorkSansMedium"),
                  textScaleFactor: 1.0,
                )),
          ),
          Padding(
            padding: EdgeInsets.only(top: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    gradient: new LinearGradient(
                        colors: [
                          Colors.white10,
                          Colors.white,
                        ],
                        begin: const FractionalOffset(0.0, 0.0),
                        end: const FractionalOffset(1.0, 1.0),
                        stops: [0.0, 1.0],
                        tileMode: TileMode.clamp),
                  ),
                  width: 100.0,
                  height: 1.0,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 15.0, right: 15.0),
                  child: Text(
                    "Or",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontFamily: "WorkSansMedium"),
                    textScaleFactor: 1.0,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: new LinearGradient(
                        colors: [
                          Colors.white,
                          Colors.white10,
                        ],
                        begin: const FractionalOffset(0.0, 0.0),
                        end: const FractionalOffset(1.0, 1.0),
                        stops: [0.0, 1.0],
                        tileMode: TileMode.clamp),
                  ),
                  width: 100.0,
                  height: 1.0,
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 10.0, right: 40.0),
                child: GestureDetector(
                  onTap: () async {
                    bool res = await FirebaseAuthProvider().loginWithFacebook();
                    if (!res)

                      showInSnackBarModel("Facebook LogIn failed",
                          Icons.error, Colors.red);
                    else
                    {
                      showInSnackBarModel("Sign In Successfuly",
                          Icons.check_circle, Colors.green);
                      Future.delayed(const Duration(seconds: 1), () {
                        setState(() {
                          Navigator.push(
                              context,
                              PageTransition(
                                  type: PageTransitionType.fade,
                                  child: DashboardPage()));
                        });
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(15.0),
                    decoration: new BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: new Icon(
                      FontAwesomeIcons.facebookF,
                      color: Color(0xFF0084ff),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 10.0),
                child: GestureDetector(
                  onTap: () async {
                    bool res = await FirebaseAuthProvider().loginWithGoogle();
                    if (!res)

                      showInSnackBarModel("Google LogIn failed",
                          Icons.error, Colors.red);
                    else
                    {
                      showInSnackBarModel("Sign In Successfuly",
                          Icons.check_circle, Colors.green);
                      Future.delayed(const Duration(seconds: 1), () {
                        setState(() {
                          Navigator.push(
                              context,
                              PageTransition(
                                  type: PageTransitionType.fade,
                                  child: DashboardPage()));
                        });
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(15.0),
                    decoration: new BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: new Icon(
                      FontAwesomeIcons.google,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _onSignInButtonPress() {
    _pageController.animateToPage(0,
        duration: Duration(milliseconds: 500), curve: Curves.decelerate);
  }

  void _onSignUpButtonPress() async {
    _pageController?.animateToPage(1,
        duration: Duration(milliseconds: 500), curve: Curves.decelerate);
  }

  void _toggleLogin() {
    setState(() {
      _obscureTextLogin = !_obscureTextLogin;
    });
  }

  void _toggleSignup() {
    setState(() {
      _obscureTextSignup = !_obscureTextSignup;
    });
  }
}
