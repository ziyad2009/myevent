import 'package:flutter/material.dart';
import 'package:myevents/common/app_colors.dart';

class UploadChoiceDialog extends StatelessWidget {
  /// Dialog which gives the option to upload photos or video.
  /// If photos is selected returned value is [false]
  /// If video is selected returned value is [true]
  /// In case of no selection returned value will be [null]
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      title: Text("What would you like to upload?"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            onTap: () {
              Navigator.pop(context, false);
            },
            leading: Icon(Icons.add_a_photo, color: exoticPurple, size: 28),
            title: Text("Upload Photos"),
          ),
          ListTile(
            leading: Icon(
              Icons.video_call,
              color: exoticPurple,
              size: 28,
            ),
            onTap: () {
              Navigator.pop(context, true);
            },
            title: Text("Upload Video"),
            subtitle: Text(
              "Payment Required",
              style: TextStyle(color: Colors.grey, fontSize: 10, height: 1),
            ),
            trailing: Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(4)),
                child: Text("SAR",
                    style: TextStyle(color: Colors.white, fontSize: 16))),
          ),
        ],
      ),
    );
  }
}
