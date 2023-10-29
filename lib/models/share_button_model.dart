import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:myevents/backend/backend.dart';
import 'package:myevents/graphql/mutations.dart';
import 'package:myevents/graphql/query.dart';
import 'package:myevents/locator.dart';
import 'package:myevents/models/base_model.dart';
import 'package:myevents/pojos/saved_list.dart';
import 'package:myevents/pojos/saved_service_list.dart';

import '../viewstate.dart';

class SaveAdButtonModel extends BaseModel {
  SavedList savedList;
  BackendService _backendService = locator<BackendService>();
  String lastError;

  Future fetchSavedAds(String userID) async {
    setState(ViewState.Busy);
    QueryResult queryResult = await _backendService.getGraphClient().query(
          QueryOptions(
              documentNode: gql(loadSavedAds), variables: {"field": userID}),
        );
    if (queryResult.hasException) {
      lastError = queryResult.exception.toString();
      setState(ViewState.Error);
    } else {
      savedList = SavedList.fromJson(queryResult.data);
      setState(ViewState.Idle);
    }
  }

  Future updateSavedAds(String serviceID, String userID) async {
    if (savedList.user.savedAds.contains(SavedServicesIDs(id: serviceID)))
      savedList.user.savedAds.removeWhere((SavedAds s) => s.id == serviceID);
    else
      savedList.user.savedAds.add(SavedAds(id: serviceID));
    setState(ViewState.Busy);
    QueryResult queryResult = await _backendService
        .getGraphClient()
        .mutate(MutationOptions(documentNode: gql(updateUser), variables: {
          "fields": <String, dynamic>{
            "where": <String, dynamic>{"id": userID},
            "data": <String, dynamic>{
              "savedAds":
                  savedList.user.savedAds.map((SavedAds s) => s.id).toList()
            }
          }
        }));
    if (queryResult.hasException) {
      setState(ViewState.Error);
    } else {
      setState(ViewState.Idle);
    }
  }

  bool isAdSaved(String serviceID) =>
      savedList.user.savedAds.contains(SavedServicesIDs(id: serviceID));
}

class SaveServiceButtonModel extends BaseModel {
  SavedServicesList savedServicesList;
  BackendService _backendService = locator<BackendService>();
  String lastError;

  Future fetchSavedServices(String userID) async {
    setState(ViewState.Busy);
    QueryResult queryResult = await _backendService.getGraphClient().query(
          QueryOptions(
              documentNode: gql(savedServicesListQuery),
              variables: {"field": userID}),
        );
    if (queryResult.hasException) {
      lastError = queryResult.exception.toString();
      setState(ViewState.Error);
    } else {
      savedServicesList = SavedServicesList.fromJson(queryResult.data);
      setState(ViewState.Idle);
    }
  }

  Future updateSavedServices(String serviceID, String userID) async {
    if (savedServicesList.user.savedServices
        .contains(SavedServicesIDs(id: serviceID)))
      savedServicesList.user.savedServices
          .removeWhere((SavedServicesIDs s) => s.id == serviceID);
    else
      savedServicesList.user.savedServices.add(SavedServicesIDs(id: serviceID));
    setState(ViewState.Busy);
    QueryResult queryResult = await _backendService.getGraphClient().mutate(
          MutationOptions(
            documentNode: gql(updateUser),
            variables: {
              "fields": {
                "where": {"id": userID},
                "data": {
                  "savedServices": savedServicesList.user.savedServices
                      .map((SavedServicesIDs s) => s.id)
                      .toList()
                }
              }
            },
          ),
        );
    if (queryResult.hasException) {
      setState(ViewState.Error);
    } else {
      setState(ViewState.Idle);
    }
  }

  bool isServiceSaved(String serviceID) => savedServicesList.user.savedServices
      .contains(SavedServicesIDs(id: serviceID));
}
