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
import 'package:myevents/pojos/venue_options.dart';
import 'package:myevents/viewstate.dart';

class TrendingModel extends BaseModel {
  BackendService _backendService = locator<BackendService>();

  AdItems adItems;
  AdItems featuredAds;
  SavedDetail savedList;

  VenueOptions venueOptions;

  Future fetchAds(Filter appliedFilter) async {
    setState(ViewState.Busy);
    QueryResult queryResult = await _backendService.getGraphClient().query(
        QueryOptions(
            documentNode: gql(loadAds), variables: appliedFilter.filterValues));
    if (queryResult.hasException) {
      print(queryResult.exception.toString());
      setState(ViewState.Idle);
    } else {
      adItems = AdItems.fromJson(queryResult.data);
      setState(ViewState.Idle);
    }
  }

  Future fetchVenueTypes() async {
    setState(ViewState.Busy);
    QueryResult queryResult = await _backendService.getGraphClient().query(
          QueryOptions(
            documentNode: gql(getVenueTypes),
          ),
        );
    if (queryResult.hasException) {
      print(queryResult.exception.toString());
    } else {
      venueOptions = VenueOptions.fromJson(queryResult.data);
    }
  }

  Future refetchAds(Filter appliedFilter) async {
    setState(ViewState.Busy);
    QueryResult queryResult = await _backendService.getGraphClient().query(
          QueryOptions(
            documentNode: gql(loadAds),
            variables: appliedFilter.filterValues,
            fetchPolicy: FetchPolicy.networkOnly,
          ),
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
            variables: <String, dynamic>{"field": userID}));
    if (!queryResult.hasException) {
      savedList = SavedDetail.fromJson(queryResult.data);
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

  void updateState() => setState(ViewState.Idle);
}
