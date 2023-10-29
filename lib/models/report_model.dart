
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:myevents/backend/backend.dart';
import 'package:myevents/locator.dart';
import 'package:myevents/viewstate.dart';

import 'base_model.dart';

class ReportModel extends BaseModel {
  BackendService _backendService = locator<BackendService>();

  Future<String> submitReport(Map<String, dynamic> fields) async {
    setState(ViewState.Busy);
    QueryResult reportingMutation =
        await _backendService.getGraphClient().mutate(
              MutationOptions(
                documentNode: gql(createReportsMutation),
                variables: <String, dynamic>{
                  "field": <String, dynamic>{"data": fields}
                },
              ),
            );
    if (reportingMutation.exception == null) {
      setState(ViewState.Busy);
      return reportingMutation?.data["createReports"]["report"]["id"];
    }
    setState(ViewState.Busy);
    return null;
  }
}

const String createReportsMutation =
    r'''mutation createreport($field: createReportsInput!)
{
  createReports(input: $field){
    report{
      id
      description
    }
  }
}''';
