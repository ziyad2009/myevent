import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:myevents/backend/backend.dart';
import 'package:myevents/locator.dart';
import 'package:myevents/models/base_model.dart';
import 'package:myevents/viewstate.dart';

// This model is initiated at the very beginning can be used to take care of auth, internet connectivity issues etc.
class GlobalModel extends BaseModel {
  BackendService _backendService = locator<BackendService>();
  int result;

  Future<void> attemptLogin() async {
    setState(ViewState.Busy);
    result = await _backendService.getMe();
    setState(ViewState.Idle);
  }

  GraphQLClient afterAuthClient() => _backendService.getGraphClient();
}
