import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String kGoogleApiKey = "AIzaSyD5yELbuSPDlo4PFmSW_qlkkawcGAEWHxo";

const Color primaryColor = Color(0xFF7F0A3D);
const Color generalTextColor = Color(0x99000000);
const Color exoticPurple = Color(0xFF7F0A78);
const TextStyle raisedTextStyle =
    TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500);
const TextStyle flatTextStyle =
    TextStyle(color: primaryColor, fontSize: 16, fontWeight: FontWeight.w500);
final DateFormat displayFormater = DateFormat('hh:mm:ss.SSS');
final DateFormat serverFormater = DateFormat('hh:mm aaa');

final String fallbackImage = "https://picsum.photos/id/182/300/300";

// Property Cards Specs
double iconSize = 16;

enum BookingStats { CONFIRM, CANCEL, SEE_DATES }

enum NActions {
  BookingSubmitted,
  BookingConfirmed,
  BookingCancelled,
  PaymentSubmitted
}

final TextStyle backdropListStyle = TextStyle(
  color: Colors.white,
  fontSize: 24,
);
String restrictFractionalSeconds(String dateTime) =>
    dateTime.replaceFirstMapped(RegExp("(\\.\\d{6})\\d+"), (m) => m[1]);

String formattedDateTime(String isoDate) {
  if (isoDate == null) return null;
  DateTime dateTime =
      DateTime.parse(restrictFractionalSeconds(isoDate)).toLocal();
  return DateFormat("EEE, MMM d, yyyy", "en").format(dateTime).toString();
}

// String formattedDateTime(String isoDate, String locale) {
//   if (isoDate == null) return null;
//   DateTime dateTime =
//       DateTime.parse(restrictFractionalSeconds(isoDate)).toLocal();
//   return DateFormat("MMM dd, yyyy | hh:mm aaa", locale)
//       .format(dateTime)
//       .toString();
// }

String formattedTimeOnly(String isoDate) {
  if (isoDate == null) return null;
  DateTime dateTime =
      DateTime.parse(restrictFractionalSeconds(isoDate)).toLocal();
  return DateFormat("hh:mm aaa").format(dateTime).toString();
}

// String getTimeString(String isoTimeString) {
//   DateTime temp = displayFormater.parse(isoTimeString);
//   return serverFormater.format(temp).toString();
// }

Widget sectionHeader(String text) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text(
        text,
        style: TextStyle(fontSize: 20),
      ),
      Container(
        width: 54,
        height: 2,
        color: primaryColor,
      )
    ],
  );
}

void onLoading(BuildContext context, String message) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        child: new Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            new CircularProgressIndicator(),
            new Text("$message"),
          ],
        ),
      );
    },
  );
  new Future.delayed(new Duration(seconds: 3), () {
    Navigator.pop(context); //pop dialog
  });
}

String uniqueChatroomID(String currentId, String peerId) {
  int compare = currentId.compareTo(peerId);
  if (compare > 0)
    return "$currentId-$peerId";
  else
    return "$peerId-$currentId";
}

String phoneNumberFormatter(String rawNumber) {
  // if (rawNumber.startsWith("03")) {
  //   return rawNumber.replaceFirst("0", "+92");
  // } else if (rawNumber.startsWith("3")) {
  //   return "+92" + rawNumber;
  // } else if (rawNumber.startsWith("+92")) {
  //   return rawNumber;
  // } else
  //   return null;
  return "+966$rawNumber";
}

String changeDigit(String number, bool toEnglish) {
  var persianNumbers = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
  var arabicNumbers = ['٩', '٨', '٧', '٦', '٥', '٤', '٣', '٢', '١', '٠'];
  var enNumbers = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "."];

  if (toEnglish) {
    for (var i = 0; i < 10; i++) {
      number = number
          .replaceAll(new RegExp(persianNumbers[i]), enNumbers[i])
          .replaceAll(new RegExp(arabicNumbers[i]), enNumbers[i]);
    }
  } else {
    for (var i = 0; i < 10; i++) {
      number = number
          .replaceAll(new RegExp(enNumbers[i]), persianNumbers[i])
          .replaceAll(new RegExp(enNumbers[i]), arabicNumbers[i]);
    }
  }
  return number;
}
