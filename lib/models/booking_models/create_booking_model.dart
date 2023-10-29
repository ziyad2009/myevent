import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:myevents/backend/backend.dart';
import 'package:myevents/backend/dates_handler.dart';
import 'package:myevents/graphql/mutations.dart';
import 'package:myevents/graphql/query.dart';
import 'package:myevents/locator.dart';
import 'package:myevents/models/base_model.dart';
import 'package:myevents/pojos/service_booking_dates.dart';
import 'package:myevents/pojos/venue_booking_dates.dart';
import 'package:myevents/pojos/offline_dates.dart';

import '../../viewstate.dart';

class CreateBookingModel extends BaseModel {
  BackendService _backendService = locator<BackendService>();
  DatesHandler datesHandler = DatesHandler();
  String lastError;
  List<OfflineDates> unavailableDates;
  List<OfflineDates> vendorReservedDates;
  VenueBookingDates venueBookingDates;
  ServiceBookingDates serviceBookingDates;

  Future fetchOfflineDates(String targetType, String targetID) async {
    setState(ViewState.Busy);
    QueryResult queryResult = await _backendService.getGraphClient().query(
          QueryOptions(
            documentNode: gql(getOfflineDates),
            fetchPolicy: FetchPolicy.networkOnly,
            variables: {
              "field": {
                targetType: targetID,
                targetType == "userAd" ? "venueBooking" : "serviceBooking": {
                  "status_in": ["waiting", "confirmed"],
                  
                }
              }
            },
          ),
        );
    if (queryResult.data['offlineDates'] != null) {
      unavailableDates = new List<OfflineDates>();
      queryResult.data['offlineDates'].forEach((v) {
        unavailableDates.add(new OfflineDates.fromJson(v));
      });
    }
    setState(ViewState.Idle);
  }

  Future fetchVendorReservedDates(String targetType, String targetID) async {
    setState(ViewState.Busy);
    QueryResult queryResult = await _backendService.getGraphClient().query(
          QueryOptions(
            documentNode: gql(getOfflineDates),
            fetchPolicy: FetchPolicy.networkOnly,
            variables: {
              "field": {targetType: targetID, "offlineByVendor": true}
            },
          ),
        );
    if (queryResult.data['offlineDates'] != null) {
      vendorReservedDates = new List<OfflineDates>();
      queryResult.data['offlineDates'].forEach((v) {
        vendorReservedDates.add(new OfflineDates.fromJson(v));
      });
    }
    setState(ViewState.Idle);
  }

  void mergeCustomerAndVendorReservedDates() =>
      unavailableDates.addAll(vendorReservedDates);

  Future editableOfflineDates(
      String targetType, String targetID, String bookingID) async {
    String targetSymbolInOfflineDate =
        targetType == "userAd" ? "venueBooking" : "serviceBooking";
    setState(ViewState.Busy);
    QueryResult queryResult = await _backendService.getGraphClient().query(
          QueryOptions(
            documentNode: gql(getOfflineDates),
            fetchPolicy: FetchPolicy.networkOnly,
            variables: {
              "field": {
                targetType: targetID,
                "${targetSymbolInOfflineDate}_ne": bookingID,
                targetType == "userAd" ? "venueBooking" : "serviceBooking": {
                  "status_in": ["waiting", "confirmed"],
                },
              }
            },
          ),
        );
    if (queryResult.data['offlineDates'] != null) {
      unavailableDates = new List<OfflineDates>();
      queryResult.data['offlineDates'].forEach((v) {
        unavailableDates.add(new OfflineDates.fromJson(v));
      });
    }
    setState(ViewState.Idle);
  }

  Future fetchVenueBookingDates(String bookingID) async {
    setState(ViewState.Busy);
    QueryResult queryResult = await _backendService.getGraphClient().query(
          QueryOptions(
            documentNode: gql(getVenueBookingDates),
            fetchPolicy: FetchPolicy.networkOnly,
            variables: {"field": bookingID},
          ),
        );
    if (queryResult.hasException) {
      lastError = queryResult.exception.toString();
    } else {
      venueBookingDates = VenueBookingDates.fromJson(queryResult.data);
    }
    setState(ViewState.Idle);
  }

  Future fetchServiceBookingDates(String bookingID) async {
    setState(ViewState.Busy);
    QueryResult queryResult = await _backendService.getGraphClient().query(
          QueryOptions(
            documentNode: gql(getServiceBookingDates),
            fetchPolicy: FetchPolicy.networkOnly,
            variables: {"field": bookingID},
          ),
        );
    if (queryResult.hasException) {
      lastError = queryResult.exception.toString();
    } else {
      serviceBookingDates = ServiceBookingDates.fromJson(queryResult.data);
    }
    setState(ViewState.Idle);
  }

  List<DateTime> getUnavailableDates() =>
      unavailableDates.map((e) => e.date).toList();

  Future submitVenueBooking(String targetID, String targetType,
      Map<String, dynamic> data, Set<DateTime> bookingDates) async {
    setState(ViewState.Busy);
    List<String> createdOfflineDates = await datesHandler.inserts(
        bookingDates, null, targetID, targetType, false);
    data["bookedDates"] = createdOfflineDates;
    data["reservedDates"] = createdOfflineDates;
    data['property'] = targetID;
    QueryResult queryResult = await _backendService.getGraphClient().mutate(
          MutationOptions(documentNode: gql(createVenueBooking), variables: {
            "field": {"data": data}
          }),
        );
    if (queryResult.hasException) {
      lastError = queryResult.exception.toString();
      print(lastError);
      setState(ViewState.Error);
    } else {
      setState(ViewState.Success);
    }
  }

  Future submitServiceBooking(String targetID, String targetType,
      Map<String, dynamic> data, Set<DateTime> bookingDates) async {
    setState(ViewState.Busy);
    List<String> createdOfflineDates = await datesHandler.inserts(
        bookingDates, null, targetID, targetType, false);
    data["reservedDates"] = createdOfflineDates;
    data["bookedDates"] = createdOfflineDates;
    data["service"] = targetID;
    QueryResult queryResult = await _backendService.getGraphClient().mutate(
          MutationOptions(documentNode: gql(createServiceBooking), variables: {
            "field": {"data": data}
          }),
        );
    if (queryResult.hasException) {
      lastError = queryResult.exception.toString();
      setState(ViewState.Error);
    } else {
      setState(ViewState.Success);
    }
  }

  Future modifyVenueBooking(
      String targetID,
      String targetType,
      Map<String, dynamic> data,
      Set<DateTime> bookingDates,
      String bookingID) async {
    setState(ViewState.Busy);
    await datesHandler.removals(
        bookingDates, venueBookingDates.booking.bookedDates);
    List<String> updatedOfflineDates = await datesHandler.inserts(bookingDates,
        venueBookingDates.booking.bookedDates, targetID, targetType, false);
    updatedOfflineDates.addAll(
        venueBookingDates.booking.bookedDates.map((e) => e.id).toList());
    data["bookedDates"] = updatedOfflineDates;
    data["reservedDates"] = updatedOfflineDates;

    QueryResult queryResult = await _backendService.getGraphClient().mutate(
          MutationOptions(documentNode: gql(updateVenueBooking), variables: {
            "field": {
              "where": {"id": bookingID},
              "data": data
            }
          }),
        );
    if (queryResult.hasException) {
      lastError = queryResult.exception.toString();
      print(lastError);
      setState(ViewState.Error);
    } else {
      setState(ViewState.Success);
    }
  }

  Future modifyServiceBooking(
      String targetID,
      String targetType,
      Map<String, dynamic> data,
      Set<DateTime> bookingDates,
      String bookingID) async {
    setState(ViewState.Busy);
    await datesHandler.removals(
        bookingDates, serviceBookingDates.serviceBooking.bookedDates);
    List<String> updatedOfflineDates = await datesHandler.inserts(
        bookingDates,
        serviceBookingDates.serviceBooking.bookedDates,
        targetID,
        targetType,
        false);
    updatedOfflineDates.addAll(serviceBookingDates.serviceBooking.bookedDates
        .map((e) => e.id)
        .toList());
    data["bookedDates"] = updatedOfflineDates;
    data["reservedDates"] = updatedOfflineDates;
    QueryResult queryResult = await _backendService.getGraphClient().mutate(
          MutationOptions(documentNode: gql(updateServiceBooking), variables: {
            "field": {
              "where": {"id": bookingID},
              "data": data
            }
          }),
        );
    if (queryResult.hasException) {
      lastError = queryResult.exception.toString();
      print(lastError);
      setState(ViewState.Error);
    } else {
      setState(ViewState.Success);
    }
  }
}
