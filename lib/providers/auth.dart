import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/http_exception.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier {
  String _token;
  String _userId;
  DateTime _expiryDate;
  Timer _authTimer;

  //return if user is auth or not auth
  bool get isAuth {
    return token != null;
  }

  //return token after check is user data right
  String get token {
    if (_token != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _expiryDate != null) {
      return _token;
    } else
      return null;
  }

  //return userId
  String get userId {
    return _userId;
  }

  //function for authenticate user (signin/signup) in API firebase
  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    final url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyBh_WIFAA1-RBAfobllU2xBJkCffEkIJ_0');
    try {
      //post user data in API
      http.Response response = await http.post(url,
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true
          }));

      //response after post user data
      var responseData = json.decode(response.body);
      //if response return error
      if (responseData['error'] != null) {
        //if response return error
        throw HttpExceptionApp(responseData['error']['message']);
      }
      //if response not has any error
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      //add time of signIn to time now
      _expiryDate = DateTime.now()
          .add(Duration(seconds: int.parse(responseData['expiresIn'])));
      _autologOut(); //auto logOut user after end time to logIn
      notifyListeners();
      //for save user account in sharedPreferances as json file
      var pref = await SharedPreferences.getInstance();
      String userData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiryDate': _expiryDate.toIso8601String() //convert DateTime to string
      });

      pref.setString('userData', userData);
      print("set key");
    } catch (e) {
      //print(e);
      throw e;
    }
  }

  //function for signUp user
  Future signUp(String email, String password) async {
    return _authenticate(email, password, "signUp");
  }

  //function for LogIn user
  Future logIn(String email, String password) async {
    return _authenticate(email, password, "signInWithPassword");
  }

  //function to try auto login user by get user data from SharedPreferences
  Future<bool> tryAutoLogIn() async {
    var pref = await SharedPreferences.getInstance();
    //if don't any user data in SharedPreferences as key
    if (!pref.containsKey('userData')) return false;
    //extracted user data from json file in SharedPreferences as map
    Map<String, Object> extractDataUser =
        json.decode(pref.getString('userData')) as Map<String, Object>;
    //return convert expiryDate from string to DateTime
    final expiryDate = DateTime.parse(extractDataUser['expiryDate']);
    //if end session user logIn
    if (DateTime.now().isAfter(expiryDate)) return false;

    _token = extractDataUser['token'];
    _userId = extractDataUser['userId'];
    _expiryDate = expiryDate;

    notifyListeners();

    _autologOut();
    return true;
  }

//function to logOut user when you want
  Future<void> logOut() async {
    _token = null;
    _userId = null;
    _expiryDate = null;
    if (_authTimer != null) {
      //if is timer run previously
      _authTimer.cancel();
      _authTimer = null;
    }
    //clear user date in SharedPreferences
    final pref = await SharedPreferences.getInstance();
    pref.clear();
    notifyListeners();
  }

  //function to auto logOut user after end session logIn
  void _autologOut() {
    if (_authTimer != null) {
      //if is timer run previously
      _authTimer.cancel();
    }
    //calculate time to logIn (session)
    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    //started timer to logOut
    _authTimer = Timer(Duration(seconds: timeToExpiry), logOut);
  }
}
