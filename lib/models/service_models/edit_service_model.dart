import 'dart:convert';

import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:myevents/backend/backend.dart';
import 'package:myevents/backend/dates_handler.dart';
import 'package:myevents/graphql/mutations.dart';
import 'package:myevents/graphql/query.dart';
import 'package:myevents/locator.dart';
import 'package:myevents/models/base_model.dart';
import 'package:myevents/pojos/service_detail.dart';
import 'package:myevents/pojos/upload.dart';
import 'package:myevents/viewstate.dart';

enum EditServiceStates {
  INITIAL,
  FETCHING,
  FETCH_FAILED,
  SAVING,
  SAVED,
  SAVE_FAILED
}

class EditServiceModel extends BaseModel {
  BackendService _backendService = locator<BackendService>();
  String lastError;
  EditServiceStates editServiceState = EditServiceStates.INITIAL;

  ServiceDetail serviceDetail;

  DatesHandler datesHandler = DatesHandler();
  Future getServiceToEdit(String serviceID) async {
    setState(ViewState.Idle);
    editServiceState = EditServiceStates.FETCHING;
    QueryResult queryResult = await _backendService.getGraphClient().query(
          QueryOptions(
              fetchPolicy: FetchPolicy.networkOnly,
              documentNode: gql(fetchSingleService),
              variables: {"field": serviceID}),
        );
    if (queryResult.hasException) {
      lastError = queryResult.exception.toString();
      editServiceState = EditServiceStates.FETCH_FAILED;
      setState(ViewState.Idle);
    } else {
      editServiceState = EditServiceStates.INITIAL;
      serviceDetail = ServiceDetail.fromJson(queryResult.data);
      setState(ViewState.Idle);
    }
  }

  Future uploadUnAvailableDates(Set<DateTime> dateTimeSet) async {
    // await inserts(dateTimeSet);
    // await removals(dateTimeSet);
    datesHandler.uploadUnAvailableDates(
        dateTimeSet,
        serviceDetail.service.offlineDates,
        serviceDetail.service.id,
        "service", true);
  }

  Future uploadEditedAd(Map<String, dynamic> editedService) async {
    editServiceState = EditServiceStates.SAVING;
    setState(ViewState.Idle);
    editedService = await _processImagesAndCover(editedService);
    QueryResult queryResult = await _backendService.getGraphClient().mutate(
          MutationOptions(
            documentNode: gql(updateService),
            variables: {
              "input": {
                "where": {"id": serviceDetail.service.id},
                "data": editedService
              },
            },
          ),
        );
    if (queryResult.hasException) {
      lastError = queryResult.exception.toString();
      editServiceState = EditServiceStates.SAVE_FAILED;
      setState(ViewState.Idle);
    } else {
      editServiceState = EditServiceStates.SAVED;
      setState(ViewState.Idle);
    }
  }

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
    int serviceFeatureImageIndex = data['serviceFeatureImage'];
    List<String> processedImages =
        await _processImageUploads(data['servicePhotos']);
    data['servicePhotos'] = processedImages;
    data['serviceFeatureImage'] =
        processedImages.elementAt(serviceFeatureImageIndex);
    return data;
  }
}
