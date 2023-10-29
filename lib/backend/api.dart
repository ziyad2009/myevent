import 'dart:convert';
import 'dart:core';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:myevents/backend/auth_error.dart';
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

final NormalizedInMemoryCache cache = NormalizedInMemoryCache(
  dataIdFromObject: uuidFromObject,
);

var httpClient = new Client();
String receivedJWT = "";
const httpEndpoint = 'http://192.168.8.101:1337';

Future<String> loginAccount(String username, String password) async {
  AuthError authError;
  var response = await httpClient.post("$httpEndpoint/auth/local", body: {
    "identifier": username,
    "password": password,
  });
  print("[LoginResponse]" + response.statusCode.toString());
  print(response.body);
  if (response.statusCode == 200) {
    receivedJWT = jsonDecode(response.body)['jwt'];
    savePrefrences("token", receivedJWT);
    print("[JWT]: " + receivedJWT);
    return "success";
  } else {
    authError = AuthError.fromJson(json.decode(response.body));
    return authError.message.first.messages.first.id;
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

Future<String> createAccount(
    String email, String username, String password) async {
  AuthError authError;
  var response =
      await httpClient.post("$httpEndpoint/auth/local/register", body: {
    "email": email,
    "password": password,
    "username": username,
    "confirmed": "true",
    "blocked": "false",
  });
  print("[RegisterResponse]" + response.statusCode.toString());
  if (response.statusCode == 200) {
    receivedJWT = jsonDecode(response.body)['jwt'];
    savePrefrences("token", receivedJWT);
    print("[JWT]: " + receivedJWT);
    return "success";
  } else {
    authError = AuthError.fromJson(json.decode(response.body));
    return authError.message.first.messages.first.id;
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

ValueNotifier<GraphQLClient> clientFor({
  @required String uri,
}) {
  Link link = HttpLink(uri: uri);
  AuthLink authLink = AuthLink(getToken: () async {
    if (receivedJWT.isEmpty) await loadToken("token");
    return 'Bearer $receivedJWT';
  });

  return ValueNotifier<GraphQLClient>(
    GraphQLClient(
      cache: cache,
      link: authLink.concat(link),
    ),
  );
}

class ClientProvider extends StatelessWidget {
  ClientProvider({
    @required this.child,
    @required String uri,
  }) : client = clientFor(
          uri: uri,
        );

  final Widget child;
  final ValueNotifier<GraphQLClient> client;

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: client,
      child: child,
    );
  }
}
