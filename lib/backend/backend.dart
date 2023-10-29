import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:myevents/backend/auth_error.dart';
import 'package:myevents/pojos/user_basic.dart';
import 'package:shared_preferences/shared_preferences.dart';

String uuidFromObject(Object object) {
  if (object is Map<String, Object>) {
    final String typeName = object['__typename'] as String;
    final String id = object['id'].toString();
    if (typeName != null && id != null) {
      return <String>[typeName, id].join('/');
    }
  }
  return null;
}

class BackendService {
  StreamController<UserBasic> userController =
      StreamController<UserBasic>.broadcast();

  final NormalizedInMemoryCache normalizedInMemoryCache =
      NormalizedInMemoryCache(
    dataIdFromObject: uuidFromObject,
  );

  var httpClient = new Client();
  String receivedJWT = "";
  final httpEndpoint = 'https://admin.munasaba.co';
  static final String qlEndpoint = 'https://admin.munasaba.co/graphql';

  HttpLink _httpLink = HttpLink(uri: qlEndpoint);
  AuthLink _authLink;

  GraphQLClient _httpClient;
  GraphQLClient _authClient;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  DatabaseReference _firebaseDB;
  final FirebaseMessaging _fcm = FirebaseMessaging();

  Future<int> getMe() async {
    String jwt = await getPreferences("token");
    Map<String, String> headers = {"Authorization": "Bearer $jwt"};
    var getMeResponse =
        await httpClient.get("$httpEndpoint/users/me", headers: headers);
    if (getMeResponse.statusCode == 200) {
      UserBasic fetchedUser =
          UserBasic.fromJson(json.decode(getMeResponse.body));
      userController.add(fetchedUser);
      receivedJWT = jwt;
      _authLink = AuthLink(getToken: () async {
        return 'Bearer $receivedJWT';
      });
      print("[GetMe] $receivedJWT");
    }
    return getMeResponse.statusCode;
  }

  Future<String> loginAccount(String username, String password) async {
    AuthError authError;
    var response = await httpClient.post("$httpEndpoint/auth/local", body: {
      "identifier": username,
      "password": password,
    });

    if (response.statusCode == 200) {
      // await firebaseEmailLogin(username, password);
      UserBasic basicUser =
          UserBasic.fromJson(json.decode(response.body)["user"]);
      saveDeviceToken(basicUser.id, basicUser.firebaseID);
      userController.add(basicUser);
      receivedJWT = jsonDecode(response.body)['jwt'];
      savePrefrences("token", receivedJWT);
      _authLink = AuthLink(getToken: () async {
        return 'Bearer $receivedJWT';
      });
      print("[JWT]: " + receivedJWT);
      return "success";
    } else {
      authError = AuthError.fromJson(json.decode(response.body));
      return authError.message.first.messages.first.message;
    }
  }

  Future<String> getFCM() => _fcm.getToken();

  // Future<String> createFirebaseUserEmail(String email, String password) async {
  //   String errorMessage;

  //   try {
  //     final FirebaseUser user = (await _auth.createUserWithEmailAndPassword(
  //       email: email,
  //       password: password,
  //     ))
  //         .user;
  //     if (user != null) {
  //       print("FirebaseAuthWithEmail : " + user.uid);

  //       return user.uid;
  //     } else {
  //       print("FirebaseAuthWithEmail error occured");
  //       return null;
  //     }
  //   } catch (error) {
  //     switch (error.code) {
  //       case "ERROR_INVALID_EMAIL":
  //         errorMessage = "Your email address appears to be malformed.";
  //         break;
  //       case "ERROR_WRONG_PASSWORD":
  //         errorMessage = "Your password is wrong.";
  //         break;
  //       case "ERROR_USER_NOT_FOUND":
  //         errorMessage = "User with this email doesn't exist.";
  //         break;
  //       case "ERROR_USER_DISABLED":
  //         errorMessage = "User with this email has been disabled.";
  //         break;
  //       case "ERROR_TOO_MANY_REQUESTS":
  //         errorMessage = "Too many requests. Try again later.";
  //         break;
  //       case "ERROR_OPERATION_NOT_ALLOWED":
  //         errorMessage = "Signing in with Email and Password is not enabled.";
  //         break;
  //       case "ERROR_EMAIL_ALREADY_IN_USE":
  //         errorMessage = "Email is already in use on different account";
  //         break;
  //       default:
  //         errorMessage = "An undefined Error happened.";
  //     }
  //   }

  //   if (errorMessage != null) {
  //     return null;
  //   }
  // }

  // Future<String> firebaseEmailLogin(String email, String password) async {
  //   final AuthResult result = (await _auth.signInWithEmailAndPassword(
  //     email: email,
  //     password: password,
  //   ));
  //   if (result.user != null) {
  //     return result.user.uid;
  //   } else {
  //     print("FirebaseSignInWithEmail error occured");
  //     return null;
  //   }
  // }

  Future<void> saveDeviceToken(String strapiID, String firebaseUID) async {
    String fcmToken = await _fcm.getToken();
    if (fcmToken != null && fcmToken.isNotEmpty) {
      _firebaseDB =
          FirebaseDatabase.instance.reference().child("tokens").child(strapiID);
      _firebaseDB.set(<String, dynamic>{
        "token": fcmToken,
        "firebaseUID": firebaseUID,
        "createdAt": ServerValue.timestamp,
        "platform": Platform.operatingSystem,
      });
    }
  }

  Future<String> multipleFileUploads(List<Asset> imageSelections) async {
    Map<String, String> headers = {"Authorization": "Bearer $receivedJWT"};
    var request = MultipartRequest("POST", Uri.parse("$httpEndpoint/upload"));
    request.headers.addAll(headers);
    List<MultipartFile> multiPartFiles = [];
    for (Asset path in imageSelections) {
      ByteData imageByteData = await path.getByteData(quality: 30);
      List<int> imageData = imageByteData.buffer.asUint8List();
      multiPartFiles.add(MultipartFile.fromBytes("files", imageData,
          filename: '${DateTime.now().second}.jpg'));
    }
    request.files.addAll(multiPartFiles);
    var response = await Response.fromStream(await request.send());
    print("MultiFileUpload: " + response.body);
    if (response.statusCode == 200) {
      print("MFU: " + response.body);
      return response.body;
    } else {
      return null;
    }
  }

  Future<String> createAccount(String email, String username, String password,
      String phone, String firebaseID) async {
    // String firebaseUID = await createFirebaseUserEmail(email, password);
    AuthError authError;
    var response =
        await httpClient.post("$httpEndpoint/auth/local/register", body: {
      "email": email,
      "fullName": "Munasaba User",
      "password": password,
      "username": username,
      "phone": phone,
      "confirmed": "true",
      "blocked": "false",
      "firebaseID": firebaseID
    });
    print("[RegisterResponse]" + response.body);
    if (response.statusCode == 200) {
      UserBasic basicUser =
          UserBasic.fromJson(json.decode(response.body)["user"]);
      // saveDeviceToken(basicUser.id, firebaseUID);
      userController.add(basicUser);
      saveDeviceToken(basicUser.id, basicUser.firebaseID);
      receivedJWT = jsonDecode(response.body)['jwt'];
      savePrefrences("token", receivedJWT);
      print("[JWT]: " + receivedJWT);
      _authLink = AuthLink(getToken: () async {
        return 'Bearer $receivedJWT';
      });
      print("RESPONSE:" + response.body);
      return "success";
    } else {
      authError = AuthError.fromJson(json.decode(response.body));
      return authError.message.first.messages.first.message;
    }
  }

  Future savePrefrences(String key, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<String> getPreferences(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key) ?? null;
  }

  Future loadToken(String key) async {
    String token = await getPreferences(key);
    if (token != null) receivedJWT = token;
  }

  ValueNotifier<GraphQLClient> clientFor() {
    return ValueNotifier<GraphQLClient>(
      GraphQLClient(
        cache: normalizedInMemoryCache,
        link: _getConcatLink(),
      ),
    );
  }

  Link _getConcatLink() {
    if (_authLink != null) {
      return _authLink.concat(_httpLink);
    } else {
      return _httpLink;
    }
  }

  GraphQLClient getGraphClient() {
    if (_authLink != null) {
      _authClient ??=
          GraphQLClient(link: _getConcatLink(), cache: normalizedInMemoryCache);
      return _authClient;
    } else {
      _httpClient ??=
          GraphQLClient(link: _getConcatLink(), cache: normalizedInMemoryCache);
      return _httpClient;
    }
  }
}
