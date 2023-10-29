import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:myevents/backend/backend.dart';
import 'package:myevents/graphql/query.dart';
import 'package:myevents/locator.dart';
import 'package:myevents/models/base_model.dart';
import 'package:myevents/pojos/filter.dart';
import 'package:myevents/pojos/service_items.dart';
import 'package:myevents/viewstate.dart';

class ServiceListModel extends BaseModel {
  BackendService _backendService = locator<BackendService>();
  String lastError;
  ServiceItems serviceItems;

  Future fetchAllServices({Filter filter}) async {
    if (filter.priceSortDecending)
      filter.filterValues["sort"] = "pricePerDay:desc";
    else
      filter.filterValues["sort"] = "pricePerDay:asc";
    print(filter.filterValues);
    setState(ViewState.Busy);
    QueryResult queryResult = await _backendService.getGraphClient().query(
          QueryOptions(
            documentNode: gql(getServiceItems),
            variables: filter.filterValues,
          ),
        );
    if (queryResult.hasException) {
      lastError = queryResult.exception.toString();
      setState(ViewState.Error);
    } else {
      serviceItems = ServiceItems.fromJson(queryResult.data);
      print(serviceItems.services.length);
      setState(ViewState.Idle);
    }
  }
}
