import 'dart:async';

import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:myevents/backend/backend.dart';
import 'package:myevents/backend/filters_service.dart';
import 'package:myevents/graphql/query.dart';
import 'package:myevents/locator.dart';
import 'package:myevents/models/base_model.dart';
import 'package:myevents/pojos/filter.dart';
import 'package:myevents/pojos/venue_options.dart';

import '../viewstate.dart';

class DirPageModel extends BaseModel {
  FilterService _filterService = locator<FilterService>();
  Filter appliedFilters;
  StreamSubscription<Filter> subscription;

  BackendService _backendService = locator<BackendService>();

  VenueOptions venueOptions;

  DirPageModel() {
    subscription =
        _filterService.filterController.stream.listen((Filter filter) {
      appliedFilters = filter;
    });
  }

  void setSortingPreference(bool decending) {
    if (appliedFilters != null) {
      appliedFilters.priceSortDecending = decending;
    } else {
      appliedFilters =
          Filter(filterValues: {"field": {}}, priceSortDecending: decending);
    }
    _filterService.filterController.add(appliedFilters);
  }

  Future loadVenueTypes() async {
    setState(ViewState.Busy);
    QueryResult queryResult = await _backendService.getGraphClient().query(
          QueryOptions(documentNode: gql(getVenueTypes)),
        );
    if (queryResult.hasException) {
      print(queryResult.exception.toString());
    } else {
      venueOptions = VenueOptions.fromJson(queryResult.data);
      setState(ViewState.Idle);
    }
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }
}
