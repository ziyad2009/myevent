import 'package:myevents/common/app_colors.dart';

class PushNotify {
  final String receiver;
  final NActions action;
  final String senderFullname;
  final String adTitle;
  final String bookingID;
  final String bookingType; // This type can be Shipper/Driver/Company

  PushNotify({
    this.bookingID,
    this.bookingType,
    this.adTitle,
    this.receiver,
    this.action,
    this.senderFullname,
  });
}
