import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';
import 'package:myevents/backend/backend.dart';
import 'package:myevents/graphql/mutations.dart';
import 'package:myevents/locator.dart';
import 'package:myevents/pojos/offline_dates.dart';

class DatesHandler {
  BackendService _backendService = locator<BackendService>();

  Future uploadUnAvailableDates(
      Set<DateTime> dateTimeSet,
      List<OfflineDates> originalDates,
      String targetID,
      String targetType,
      bool offlineByVendor) async {
    await inserts(
        dateTimeSet, originalDates, targetID, targetType, offlineByVendor);
    await removals(dateTimeSet, originalDates);
  }

  Future<List<String>> inserts(
      Set<DateTime> updated,
      List<OfflineDates> originalDates,
      String targetID,
      String targetType,
      bool offlineByVendor) async {
    List<OfflineDates> inserted = List<OfflineDates>();
    List<String> insertedDates = List<String>();
    if (originalDates == null)
      inserted = updated.map<OfflineDates>((DateTime dt) {
        return OfflineDates(date: dt);
      }).toList();
    else {
      List<OfflineDates> newInsertions =
          updated.map<OfflineDates>((DateTime dt) {
        return OfflineDates(date: dt);
      }).toList();
      inserted = listDiff(originalDates, newInsertions);
    }

    if (inserted.isNotEmpty) {
      for (int i = 0; i < inserted.length; i++) {
        OfflineDates offDate = inserted.elementAt(i);
        QueryResult queryResult = await _backendService.getGraphClient().mutate(
              MutationOptions(
                documentNode: gql(createOfflineDate),
                variables: {
                  "field": {
                    "data": {
                      "unavailable":
                          DateFormat("yyyy-MM-dd").format(offDate.date),
                      "$targetType": targetID,
                      "offlineByVendor": offlineByVendor
                    }
                  }
                },
              ),
            );
        if (queryResult.hasException) {
          print(queryResult.exception.toString());
        } else {
          print(queryResult.data["createOfflineDate"]["offlineDate"]["id"]);
          insertedDates
              .add(queryResult.data["createOfflineDate"]["offlineDate"]["id"]);
        }
      }
    }
    return insertedDates;
  }

  Future<void> removals(
      Set<DateTime> updated, List<OfflineDates> originalDates) async {
    List<OfflineDates> removed = List<OfflineDates>();
    if (originalDates != null) {
      List<OfflineDates> newInsertions =
          updated.map<OfflineDates>((DateTime dt) {
        return OfflineDates(date: dt);
      }).toList();
      removed = listDiff(newInsertions, originalDates);
      if (removed.isNotEmpty) {
        for (int i = 0; i < removed.length; i++) {
          OfflineDates offDate = removed.elementAt(i);
          QueryResult queryResult =
              await _backendService.getGraphClient().mutate(
                    MutationOptions(
                      documentNode: gql(deleteOfflineDate),
                      variables: {
                        "field": {
                          "where": {"id": offDate.id}
                        }
                      },
                    ),
                  );
          if (queryResult.hasException) {
            print(queryResult.exception.toString());
          }
        }
      }
    }
  }

  List<OfflineDates> listDiff<T>(
          List<OfflineDates> l1, List<OfflineDates> l2) =>
      (l1.toSet()..addAll(l2)).where((i) => !l1.contains(i)).toList();
}
