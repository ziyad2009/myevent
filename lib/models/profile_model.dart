import 'dart:convert';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:myevents/backend/backend.dart';
import 'package:myevents/graphql/mutations.dart';
import 'package:myevents/graphql/query.dart';
import 'package:myevents/locator.dart';
import 'package:myevents/models/base_model.dart';
import 'package:myevents/pojos/upload.dart';
import 'package:myevents/pojos/user_basic.dart';
import 'package:myevents/pojos/user_detail.dart';
import 'package:myevents/viewstate.dart';

class ProfileModel extends BaseModel {
  BackendService _backendService = locator<BackendService>();
  UserDetail userDetail;
  bool externalUser;

  Future loadProfile(String userID) async {
    setState(ViewState.Busy);
    QueryResult queryResult = await _backendService.getGraphClient().query(
        QueryOptions(
            documentNode: gql(anyProfileInfo),
            fetchPolicy: FetchPolicy.networkOnly,
            variables: <String, dynamic>{"field": userID}));
    if (!queryResult.hasException) {
      userDetail = UserDetail.fromJson(queryResult.data);
    }
    else{
      print("loadProfile: " + queryResult.exception.toString());
    }
    setState(ViewState.Idle);
  }

  Future<UserSearchList> searchUsers(String nameQuery) async {
    QueryResult queryResult = await _backendService.getGraphClient().query(
            QueryOptions(
                fetchPolicy: FetchPolicy.noCache,
                documentNode: gql(searchUsersQuery),
                variables: <String, dynamic>{
              "fields": <String, dynamic>{"fullName_contains": nameQuery}
            }));
    if (queryResult.exception == null)
      return UserSearchList.fromJson(queryResult.data);
    else
      UserSearchList();
  }

  Future<List<UploadResponse>> uploadAboutImages(
      List<UploadResponse> old, List<Asset> images) async {
    List<UploadResponse> updatedList = [];

    setState(ViewState.Busy);
    String uploadJson = await _backendService.multipleFileUploads(images);
    List<UploadResponse> uploadResponseList = [];
    List<dynamic> decoded = json.decode(uploadJson);
    if (decoded != null && decoded.isNotEmpty) {
      for (var uploadEntry in decoded) {
        uploadResponseList.add(UploadResponse.fromJson(uploadEntry));
      }
      for (UploadResponse image in old) {
        UploadResponse uploadResponse =
            UploadResponse(sId: image.sId, url: image.url);
        uploadResponseList.add(uploadResponse);
      }
      QueryResult mutationResult =
          await _backendService.getGraphClient().mutate(
                MutationOptions(
                  documentNode: gql(updateUser),
                  variables: <String, dynamic>{
                    "fields": <String, dynamic>{
                      "where": <String, dynamic>{"id": userDetail.user.id},
                      "data": <String, dynamic>{
                        "aboutImages": uploadResponseList
                            .map((UploadResponse resp) => resp.sId)
                            .toList()
                      }
                    }
                  },
                ),
              );

      if (mutationResult.data["updateUser"]["user"]["aboutImages"] != null) {
        mutationResult.data["updateUser"]["user"]["aboutImages"]
            .forEach((v) => updatedList.add(UploadResponse.fromJson(v)));
      }
      setState(ViewState.Idle);
      return updatedList;
    }
    setState(ViewState.Idle);
    return old;
  }

  Future uploadImage(List<Asset> selections, String changeImageField) async {
    String uploadJson = await _backendService.multipleFileUploads(selections);
    print(uploadJson);
    List<UploadResponse> uploadResponseList = [];
    List<dynamic> decoded = json.decode(uploadJson);
    if (decoded != null && decoded.isNotEmpty) {
      for (var uploadEntry in decoded) {
        uploadResponseList.add(UploadResponse.fromJson(uploadEntry));
      }
      if (uploadResponseList != null && uploadResponseList.isNotEmpty) {
        QueryResult queryResult = await _backendService.getGraphClient().mutate(
                MutationOptions(
                    documentNode: gql(updateUser),
                    variables: <String, dynamic>{
                  "fields": <String, dynamic>{
                    "where": <String, dynamic>{"id": userDetail.user.id},
                    "data": <String, dynamic>{
                      changeImageField: uploadResponseList.first.sId
                    }
                  }
                }));
        UserDetail editedProfile =
            UserDetail.fromJson(queryResult.data["updateUser"]);
        if (changeImageField == "profilePicuture") {
          userDetail.user.profilePicture = editedProfile.user.profilePicture;
        } else {
          userDetail.user.coverImage = editedProfile.user.coverImage;
        }
      }
    }
    setState(ViewState.Idle);
  }

  Future<void> updateAboutImages(int imageToRemove) async {
    userDetail.user.aboutImages.removeAt(imageToRemove);
    setState(ViewState.Busy);
    await _backendService.getGraphClient().mutate(
          MutationOptions(
            documentNode: gql(updateUser),
            variables: <String, dynamic>{
              "fields": <String, dynamic>{
                "where": <String, dynamic>{"id": userDetail.user.id},
                "data": <String, dynamic>{
                  "aboutImages": userDetail.user.aboutImages
                      .map((UploadResponse resp) => resp.sId)
                      .toList()
                }
              }
            },
          ),
        );
    setState(ViewState.Idle);
  }
}
