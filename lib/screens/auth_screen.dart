import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/http_exception.dart';
import 'package:real_shop/providers/auth.dart';

class AuthScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [
                      Color.fromRGBO(255, 200, 255, 1).withOpacity(0.9),
                      Color.fromRGBO(100, 240, 255, 1).withOpacity(0.5)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: [0, 1])),
          ),
          SingleChildScrollView(
            child: Container(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 50),
                        margin: EdgeInsets.only(bottom: 20),
                        transform: Matrix4.rotationZ(-8 * pi / 180),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.deepPurpleAccent[200],
                            boxShadow: [
                              BoxShadow(
                                  blurRadius: 8,
                                  color: Colors.black26,
                                  offset: Offset(0, 8))
                            ]),
                        child: Text("My Shop",
                            style: TextStyle(
                                fontFamily: 'Anton',
                                fontSize: 50,
                                color: Theme.of(context)
                                    .accentTextTheme
                                    .headline6
                                    .color))),
                  ),
                  Flexible(
                    child: AuthCard(),
                    flex: deviceSize.width > 600 ? 2 : 1,
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  @override
  _AuthCardState createState() => _AuthCardState();
}

enum AuthMode { Login, SignUp }

class _AuthCardState extends State<AuthCard> with TickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;
  Map<String, String> _userData = {'email': '', 'password': ''};
  TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  AnimationController _animationController;
  Animation<double> _animatuinOpacity;
  Animation<Offset> _animatuinOffset;
  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.SignUp;
      });
      _animationController.forward();
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
      _animationController.reverse();
    }
  }

  @override
  void initState() {
    super.initState();

    _animationController =
        AnimationController(vsync: this, duration: Duration(microseconds: 300));
    _animatuinOpacity = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.linear));
    _animatuinOffset = Tween<Offset>(begin: Offset(0, -0.15), end: Offset(0, 0))
        .animate(CurvedAnimation(
            parent: _animationController, curve: Curves.linear));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState.validate()) {
      return;
    }

    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });
    try {
      if (_authMode == AuthMode.SignUp) {
        await Provider.of<Auth>(context, listen: false)
            .signUp(_userData['email'], _userData['password']);
      } else {
        await Provider.of<Auth>(context, listen: false)
            .logIn(_userData['email'], _userData['password']);
      }
    } on HttpExceptionApp catch (error) {
      print("http exception");
      var errorMessage = "Authentication failed";
      if (error.toString().contains("EMAIL_EXISTS")) {
        errorMessage = "This email address is already in use.";
      } else if (error.toString().contains("INVALID_EMAIL")) {
        errorMessage = "This is not a valid email address.";
      } else if (error.toString().contains("WEAK_PASSWORD")) {
        errorMessage = "This password is too weak.";
      } else if (error.toString().contains("EMAIL_NOT_FOUND")) {
        errorMessage = "Could not find a user with that email";
      } else if (error.toString().contains("INVALID_PASSWORD")) {
        errorMessage = "Invalid password";
      }
      _showErrorDialog(errorMessage);
    } catch (error) {
      const errorMessage =
          'Could not authenticate you. Please try again later.';
      _showErrorDialog(errorMessage);
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _showErrorDialog(String errorMessage) {
    showDialog(
        context: context,
        builder: (innerCtx) => AlertDialog(
              title: Text("An Error Occurred:"),
              content: Text(errorMessage),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(innerCtx).pop(),
                    child: Text("Ok"))
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    var deviceSize = MediaQuery.of(context).size;

    return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 10,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          curve: Curves.linear,
          width: deviceSize.width * 0.75,
          height: _authMode == AuthMode.SignUp ? 320 : 260,
          constraints: BoxConstraints(
              minHeight: _authMode == AuthMode.SignUp ? 320 : 260),
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                        labelText: "E-Mail", hintText: "example@gmail.com"),
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) {
                      if (val.isEmpty || !val.contains('@')) {
                        return "Invalid email";
                      }
                      return null;
                    },
                    onSaved: (val) {
                      _userData['email'] = val.trim();
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                        labelText: "Password",
                        hintText: "Minimum Length 6 Character"),
                    obscureText: true,
                    controller: _controller,
                    validator: (val) {
                      if (val.isEmpty || val.length < 6) {
                        return "Password is too short! minimum 6 character";
                      }
                      return null;
                    },
                    onSaved: (val) {
                      _userData['password'] = val.trim();
                    },
                  ),
                  AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.linear,
                      constraints: BoxConstraints(
                          maxHeight: _authMode == AuthMode.SignUp ? 120 : 0,
                          minHeight: _authMode == AuthMode.SignUp ? 60 : 0),
                      child: FadeTransition(
                        opacity: _animatuinOpacity,
                        child: SlideTransition(
                          position: _animatuinOffset,
                          child: TextFormField(
                            enabled: _authMode == AuthMode.SignUp,
                            decoration: InputDecoration(
                              labelText: "Confirm Password",
                            ),
                            obscureText: true,
                            validator: _authMode == AuthMode.SignUp
                                ? (val) {
                                    if (val != _controller.text) {
                                      return "Password does not match";
                                    }
                                    return null;
                                  }
                                : null,
                          ),
                        ),
                      )),
                  SizedBox(
                    height: 20,
                  ),
                  if (_isLoading) CircularProgressIndicator(),
                  ElevatedButton(
                      style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20))),
                          textStyle: MaterialStateProperty.all<TextStyle>(
                              TextStyle(
                                  color:
                                      Theme.of(context)
                                          .accentTextTheme
                                          .headline6
                                          .color)),
                          padding:
                              MaterialStateProperty.all<EdgeInsetsGeometry>(
                                  EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 30))),
                      onPressed: _submit,
                      child: _authMode == AuthMode.Login
                          ? Text("LOGIN")
                          : Text("SIGNUP")),
                  SizedBox(
                    height: 10,
                  ),
                  TextButton(
                      style: ButtonStyle(
                          padding:
                              MaterialStateProperty.all<EdgeInsetsGeometry>(
                                  EdgeInsets.symmetric(
                                      vertical: 4, horizontal: 30))),
                      onPressed: _switchAuthMode,
                      child: Text(
                          "${_authMode == AuthMode.Login ? "SIGNUP" : "LOGIN"} INSTEAD"))
                ],
              ),
            ),
          ),
        ));
  }
}
