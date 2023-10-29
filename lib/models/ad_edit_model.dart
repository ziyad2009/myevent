import 'dart:convert';

import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:myevents/backend/backend.dart';
import 'package:myevents/backend/dates_handler.dart';
import 'package:myevents/graphql/mutations.dart';
import 'package:myevents/graphql/query.dart';
import 'package:myevents/locator.dart';
import 'package:myevents/models/base_model.dart';
import 'package:myevents/pojos/ad_detail.dart';
import 'package:myevents/pojos/upload.dart';
import 'package:myevents/viewstate.dart';

enum EditVenueStates {
  INITIAL,
  FETCHING,
  FETCH_FAILED,
  SAVING,
  SAVED,
  SAVE_FAILED
}

class AdEditModel extends BaseModel {
  BackendService _backendService = locator<BackendService>();
  AdDetail adDetail;
  String lastError;
  DatesHandler datesHandler = DatesHandler();

  EditVenueStates editState = EditVenueStates.INITIAL;

  Future uploadEditedAd(Map<String, dynamic> editedVenue) async {
    setState(ViewState.Idle);
    editState = EditVenueStates.SAVING;
    editedVenue = await _processImagesAndCover(editedVenue);
    QueryResult queryResult = await _backendService.getGraphClient().mutate(
          MutationOptions(
            documentNode: gql(updateUserAd),
            variables: {
              "field": {
                "where": {"id": adDetail.userAd.id},
                "data": editedVenue
              },
            },
          ),
        );
    if (queryResult.hasException) {
      lastError = queryResult.exception.toString();
      print(lastError);
      editState = EditVenueStates.SAVE_FAILED;
      setState(ViewState.Idle);
    } else {
      editState = EditVenueStates.SAVED;
      setState(ViewState.Idle);
    }
  }

  Future fetchAdToEdit(String adID) async {
    setState(ViewState.Busy);
    editState = EditVenueStates.FETCHING;
    QueryResult queryResult = await _backendService.getGraphClient().query(
          QueryOptions(
            fetchPolicy: FetchPolicy.networkOnly,
            documentNode: gql(loadSingleAd),
            variables: <String, dynamic>{"field": adID},
          ),
        );
    if (queryResult.hasException) {
      lastError = queryResult.exception.toString();
      editState = EditVenueStates.FETCH_FAILED;
      setState(ViewState.Idle);
    } else {
      editState = EditVenueStates.INITIAL;
      adDetail = AdDetail.fromJson(queryResult.data);
      setState(ViewState.Idle);
    }
  }

  Future uploadUnAvailableDates(Set<DateTime> dateTimeSet) async {
    // await inserts(dateTimeSet);
    // await removals(dateTimeSet);
    datesHandler.uploadUnAvailableDates(dateTimeSet,
        adDetail.userAd.offlineDates, adDetail.userAd.id, "userAd", true);
  }

  // Future<void> inserts(Set<DateTime> updated) async {
  //   List<OfflineDates> inserted = List<OfflineDates>();
  //   if (adDetail.userAd.offlineDates == null)
  //     inserted = updated.map<OfflineDates>((DateTime dt) {
  //       return OfflineDates(date: dt);
  //     }).toList();
  //   else {
  //     List<OfflineDates> newInsertions =
  //         updated.map<OfflineDates>((DateTime dt) {
  //       return OfflineDates(date: dt);
  //     }).toList();
  //     inserted = listDiff(adDetail.userAd.offlineDates, newInsertions);
  //   }

  //   if (inserted.isNotEmpty) {
  //     inserted.forEach(
  //       (OfflineDates offDate) async {
  //         QueryResult queryResult =
  //             await _backendService.getGraphClient().mutate(
  //                   MutationOptions(
  //                     documentNode: gql(createOfflineDate),
  //                     variables: {
  //                       "field": {
  //                         "data": {
  //                           "unavailable":
  //                               DateFormat("yyyy-MM-dd").format(offDate.date),
  //                           "userAd": adDetail.userAd.id
  //                         }
  //                       }
  //                     },
  //                   ),
  //                 );
  //         if (queryResult.hasException) {
  //           print(queryResult.exception.toString());
  //         }
  //       },
  //     );
  //   }
  // }

  // Future<void> removals(Set<DateTime> updated) async {
  //   List<OfflineDates> removed = List<OfflineDates>();
  //   if (adDetail.userAd.offlineDates != null) {
  //     List<OfflineDates> newInsertions =
  //         updated.map<OfflineDates>((DateTime dt) {
  //       return OfflineDates(date: dt);
  //     }).toList();
  //     removed = listDiff(newInsertions, adDetail.userAd.offlineDates);
  //     if (removed.isNotEmpty) {
  //       removed.forEach(
  //         (OfflineDates offDate) async {
  //           QueryResult queryResult =
  //               await _backendService.getGraphClient().mutate(
  //                     MutationOptions(
  //                       documentNode: gql(deleteOfflineDate),
  //                       variables: {
  //                         "field": {
  //                           "where": {"id": offDate.id}
  //                         }
  //                       },
  //                     ),
  //                   );
  //           if (queryResult.hasException) {
  //             print(queryResult.exception.toString());
  //           }
  //         },
  //       );
  //     }
  //   }
  // }

  // List<OfflineDates> listDiff<T>(
  //         List<OfflineDates> l1, List<OfflineDates> l2) =>
  //     (l1.toSet()..addAll(l2)).where((i) => !l1.contains(i)).toList();

  Future<List<String>> _processImageUploads(List<dynamic> imageList) async {
    // First SEPERATE if there are some new images to upload
    List<UploadResponse> existingImages = List<UploadResponse>();
    List<Asset> newPicks = List<Asset>();
    imageList.forEach((img) {
      if (img is Asset) newPicks.add(img);
      if (img is UploadResponse) existingImages.add(img);
    });

    // UPLOAD new images
    if (newPicks.isNotEmpty) {
      List<UploadResponse> uploadResponses = List<UploadResponse>();
      String uploadResponse =
          await _backendService.multipleFileUploads(newPicks);

      List<dynamic> decoded = json.decode(uploadResponse);
      for (var uploadEntry in decoded) {
        uploadResponses.add(UploadResponse.fromJson(uploadEntry));
      }
      // merge new upload ids with exiting ones
      existingImages.addAll(uploadResponses);
      return existingImages.map((e) => e.sId).toList();
    }
    // NO new images to upload just return the exiting ones
    return existingImages.map((e) => e.sId).toList();
  }

  Future<Map<String, dynamic>> _processImagesAndCover(
      Map<String, dynamic> data) async {
    int serviceFeatureImageIndex = data['featuredImage'];
    List<String> processedImages = await _processImageUploads(data['adImages']);
    data['adImages'] = processedImages;
    data['featuredImage'] = processedImages.elementAt(serviceFeatureImageIndex);
    return data;
  }
}
