import 'dart:async';

import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:myevents/backend/backend.dart';
import 'package:myevents/backend/filters_service.dart';
import 'package:myevents/graphql/query.dart';
import 'package:myevents/locator.dart';
import 'package:myevents/models/base_model.dart';
import 'package:myevents/pojos/ad_items.dart';
import 'package:myevents/pojos/filter.dart';
import 'package:myevents/pojos/venue_options.dart';
import 'package:myevents/viewstate.dart';

class DynamicTabModel extends BaseModel {
  BackendService _backendService = locator<BackendService>();
  FilterService _filterService = locator<FilterService>();
  StreamSubscription<Filter> filterSubscription;
  AdItems adItems;
  VenueTypes venueType;

  DynamicTabModel() {
    filterSubscription =
        _filterService.filterController.stream.listen((Filter filter) async {
      filter.filterValues["field"]["venueTypes_in"] = [venueType.id];
      await fetchAds(filter);
    });
  }

  @override
  void dispose() {
    filterSubscription.cancel();
    super.dispose();
  }

  Future fetchAds(Filter appliedFilter) async {
    if (appliedFilter.priceSortDecending)
      appliedFilter.filterValues["sort"] = "price:asc";
    else
      appliedFilter.filterValues["sort"] = "price:desc";
    print(appliedFilter.filterValues);
    setState(ViewState.Busy);
    QueryResult queryResult = await _backendService.getGraphClient().query(
        QueryOptions(
            documentNode: gql(loadAds), variables: appliedFilter.filterValues));
    if (!queryResult.hasException) {
      adItems = AdItems.fromJson(queryResult.data);
    } else {
      print(queryResult.exception.toString());
    }
    setState(ViewState.Idle);
  }

  Future refetchAds(Filter appliedFilter) async {
    if (appliedFilter.priceSortDecending)
      appliedFilter.filterValues["sort"] = "price:asc";
    else
      appliedFilter.filterValues["sort"] = "price:desc";
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
    } else {
      print("Exception while fetching filtered results: " +
          queryResult.exception.toString());
    }
    setState(ViewState.Idle);
  }

  void updateState() => setState(ViewState.Idle);
}
