import 'dart:convert';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:myevents/backend/backend.dart';
import 'package:myevents/locator.dart';
import 'package:http/http.dart';
import 'package:myevents/pojos/upload.dart';

class VideoService {
  BackendService _backendService = locator<BackendService>();
  File _video;
  final picker = ImagePicker();

  File getPickedVideo() => _video;

  Future<bool> launchVideoPicker() async {
    PickedFile pickedFile = await picker.getVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      _video = File(pickedFile.path);
      return true;
    } else
      return false;
  }

  bool isVideoPicked() => _video != null;

  void clearPickedVideo() => _video = null;

  Future<String> httpVideoUpload() async {
    Map<String, String> headers = {
      "Authorization": "Bearer ${_backendService.receivedJWT}"
    };
    var request = MultipartRequest(
        "POST", Uri.parse("${_backendService.httpEndpoint}/upload"));
    request.headers.addAll(headers);
    var uploadFile = await MultipartFile.fromPath("files", _video.path);
    request.files.add(uploadFile);
    var response = await Response.fromStream(await request.send());

    if (response.statusCode == 200) {
      List<UploadResponse> uploadResponses = <UploadResponse>[];
      List<dynamic> decoded = json.decode(response.body);
      if (decoded != null && decoded.isNotEmpty) {
        for (var uploadEntry in decoded) {
          uploadResponses.add(UploadResponse.fromJson(uploadEntry));
        }
        return uploadResponses.elementAt(0).sId;
      } else {
        return null;
      }
    } else {
      print(response.body);
      print(response.statusCode);
      return null;
    }
  }

  // Possible breaking on Android
  // https://pub.dev/packages/image_picker#handling-mainactivity-destruction-on-android
}
