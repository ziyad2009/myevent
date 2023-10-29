import 'dart:async';

import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:myevents/backend/backend.dart';
import 'package:myevents/backend/filters_service.dart';
import 'package:myevents/graphql/query.dart';
import 'package:myevents/locator.dart';
import 'package:myevents/models/base_model.dart';
import 'package:myevents/pojos/ad_items.dart';
import 'package:myevents/pojos/filter.dart';
import 'package:myevents/viewstate.dart';

class ResortModel extends BaseModel {
  BackendService _backendService = locator<BackendService>();
  FilterService _filterService = locator<FilterService>();
  AdItems adItems;
  StreamSubscription<Filter> filterSubscription;

  ResortModel() {
    filterSubscription =
        _filterService.filterController.stream.listen((Filter filter) async {
      await fetchAds(filter);
    });
  }

  @override
  void dispose() {
    filterSubscription.cancel();
    super.dispose();
  }

  Future fetchAds(Filter appliedFilter) async {
    appliedFilter.filterValues["field"]["category"] = "Resort";
    print(appliedFilter.filterValues.toString());
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
    if (appliedFilter.priceSortDecending)
      appliedFilter.filterValues["sort"] = "price:asc";
    else
      appliedFilter.filterValues["sort"] = "price:desc";
    appliedFilter.filterValues["field"]["category"] = "Resort";

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
