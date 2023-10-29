import 'package:flutter/material.dart';
import 'package:myevents/common/app_colors.dart';
import 'package:myevents/widgets/video_viewer.dart';

class CheckVideoCTA extends StatelessWidget {
  final String videoURL;

  const CheckVideoCTA({Key key, this.videoURL}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(height: 12),
        Divider(),
        ListTile(
          leading: Icon(
            Icons.video_library,
            color: Color(0x8A000000),
          ),
          title: Text("See in action"),
          trailing: Icon(Icons.arrow_forward_ios, color: primaryColor),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ChewieDemo(videoURL: videoURL),
                  fullscreenDialog: true),
            );
          },
        ),
        Divider(),
      ],
    );
  }
}
