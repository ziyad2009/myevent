import 'dart:async';

import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:myevents/backend/backend.dart';
import 'package:myevents/graphql/mutations.dart';
import 'package:myevents/graphql/query.dart';
import 'package:myevents/locator.dart';
import 'package:myevents/models/base_model.dart';
import 'package:myevents/pojos/ad_items.dart';
import 'package:myevents/pojos/filter.dart';
import 'package:myevents/pojos/saved_detail.dart';
import 'package:myevents/pojos/saved_services.dart';
import 'package:myevents/pojos/service_items.dart';
import 'package:myevents/viewstate.dart';

class AdDirModel extends BaseModel {
  BackendService _backendService = locator<BackendService>();

  AdItems adItems;
  AdItems featuredAds;
  SavedDetail savedList;

  ServiceItems serviceItems;

  SavedServices savedServicesList;

  Future fetchAds(Filter appliedFilter) async {
    setState(ViewState.Busy);
    QueryResult queryResult = await _backendService.getGraphClient().query(
        QueryOptions(
            documentNode: gql(loadAds), variables: appliedFilter.filterValues));
    if (!queryResult.hasException) {
      adItems = AdItems.fromJson(queryResult.data);
    }
    setState(ViewState.Idle);
  }

  Future refetchAds(Filter appliedFilter) async {
    setState(ViewState.Busy);
    QueryResult queryResult = await _backendService.getGraphClient().query(
          QueryOptions(
              documentNode: gql(loadAds),
              variables: appliedFilter.filterValues,
              fetchPolicy: FetchPolicy.networkOnly),
        );
    if (!queryResult.hasException) {
      adItems = AdItems.fromJson(queryResult.data);
    }
    setState(ViewState.Idle);
  }

  Future fetchFeaturedAds() async {
    setState(ViewState.Busy);
    QueryResult queryResult = await _backendService.getGraphClient().query(
          QueryOptions(
            documentNode: gql(loadAds),
            variables: <String, dynamic>{
              "field": <String, dynamic>{"isFeatured": true},
              "sort": "createdAt:desc"
            },
          ),
        );
    if (!queryResult.hasException) {
      featuredAds = AdItems.fromJson(queryResult.data);
    }
    setState(ViewState.Idle);
  }

  Future fetchSavedAds(String userID) async {
    setState(ViewState.Busy);
    QueryResult queryResult = await _backendService.getGraphClient().query(
          QueryOptions(
            documentNode: gql(loadTrackedAds),
            fetchPolicy: FetchPolicy.networkOnly,
            variables: <String, dynamic>{"field": userID},
          ),
        );
    if (!queryResult.hasException) {
      savedList = SavedDetail.fromJson(queryResult.data);
    }
    setState(ViewState.Idle);
  }

  Future fectchSavedServices(String userID) async {
    setState(ViewState.Busy);
    QueryResult queryResult = await _backendService.getGraphClient().query(
          QueryOptions(
            documentNode: gql(loadTrackedServices),
            fetchPolicy: FetchPolicy.networkOnly,
            variables: {"field": userID},
          ),
        );

    if (!queryResult.hasException) {
      savedServicesList = SavedServices.fromJson(queryResult.data);
    }
    setState(ViewState.Idle);
  }

  Future fecthServiceAds(Filter filter) async {
    setState(ViewState.Busy);
    QueryResult queryResult = await _backendService.getGraphClient().query(
          QueryOptions(
            documentNode: gql(getServiceItems),
            variables: filter.filterValues,
          ),
        );
    if (queryResult.hasException) {
      print(queryResult.exception.toString());
    } else {
      serviceItems = ServiceItems.fromJson(queryResult.data);
    }
    setState(ViewState.Idle);
  }

  Future deleteUserAd(String adID, int index) async {
    QueryResult queryResult = await _backendService.getGraphClient().mutate(
          MutationOptions(
            documentNode: gql(deleteAd),
            variables: <String, dynamic>{
              "field": <String, dynamic>{
                "where": <String, dynamic>{"id": adID}
              }
            },
          ),
        );
    if (!queryResult.hasException) {
      adItems.userAds.removeAt(index);
    }
    setState(ViewState.Idle);
  }

  Future deleteServiceAd(String adID, int index) async {
    QueryResult queryResult = await _backendService.getGraphClient().mutate(
          MutationOptions(
            documentNode: gql(deleteService),
            variables: <String, dynamic>{
              "field": <String, dynamic>{
                "where": <String, dynamic>{"id": adID}
              }
            },
          ),
        );
    if (!queryResult.hasException) {
      serviceItems.services.removeAt(index);
    }
    setState(ViewState.Idle);
  }

  void updateState() => setState(ViewState.Idle);
}
