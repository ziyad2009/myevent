import 'package:firebase_database/firebase_database.dart';
import 'package:myevents/backend/backend.dart';
import 'package:myevents/common/app_colors.dart';
import 'package:myevents/pojos/push_notify.dart';

import '../locator.dart';

class NotificationAPI {
  /* This Singleton Class is Responsible to Generate and Submit Notifications */
  DatabaseReference _firebaseDB;

  Future<void> commitNotification(PushNotify notification) async {
    _firebaseDB = FirebaseDatabase.instance
        .reference()
        .child("notifications")
        .child(notification.receiver);
    _firebaseDB.push().set(<String, dynamic>{
      "receiver": notification.receiver,
      "createdAt": ServerValue.timestamp,
      "senderFullname": notification.senderFullname,
      "bookingType": notification.bookingType,
      "bookingID": notification.bookingID,
      "adTitle": notification.adTitle,
      "action": _notificationAction(notification.action),
      "seen": false,
    });
  }

  String _notificationAction(NActions nActions) {
    if (nActions == NActions.BookingConfirmed)
      return "booking_confirmed";
    else if (nActions == NActions.BookingSubmitted)
      return "booking_submitted";
    else if (nActions == NActions.BookingCancelled)
      return "booking_cancelled";
    else if (nActions == NActions.PaymentSubmitted)
      return "payment_submitted";
    else
      return "undefined";
  }
}
