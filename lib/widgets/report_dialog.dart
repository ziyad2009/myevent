import 'package:flutter/material.dart';
import 'package:myevents/models/report_model.dart';
import 'package:myevents/pages/base_view.dart';
import 'package:myevents/pojos/user_basic.dart';
import 'package:provider/provider.dart';

import '../viewstate.dart';

TextEditingController messageContentController = TextEditingController();

class ReportDialog extends StatelessWidget {
  final Map<String, dynamic> fields;
  ReportDialog({this.fields});

  @override
  Widget build(BuildContext context) {
    Widget cancelButton = FlatButton(
      child: Text(
        "Cancel",
        style: TextStyle(color: Colors.grey),
      ),
      onPressed: () {
        Navigator.of(context).pop(false);
      },
    );

    return BaseView<ReportModel>(
      onModelReady: (model) {
        messageContentController.clear();
      },
      builder: (context, model, child) => model.state == ViewState.Busy
          ? Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : AlertDialog(
              title: Text(
                "Report",
                style: TextStyle(color: Colors.red),
              ),
              content: TextField(
                maxLines: null,
                maxLength: 100,
                controller: messageContentController,
                decoration: InputDecoration.collapsed(
                    hintText: "Tell us your concerns about this content?"),
                textCapitalization: TextCapitalization.sentences,
                style: TextStyle(fontSize: 14),
              ),
              actions: [
                cancelButton,
                FlatButton(
                  child: Text(
                    "Submit",
                    style: TextStyle(color: Colors.red),
                  ),
                  onPressed: () async {
                    if (messageContentController.text.isNotEmpty) {
                      fields["description"] = messageContentController.text;
                      fields["reporter"] = Provider.of<UserBasic>(context).id;
                      String reportID = await model.submitReport(fields);
                      if (reportID != null)
                        Navigator.pop(context, true);
                      else
                        Navigator.pop(context, false);
                    }
                  },
                )
              ],
            ),
    );
  }
}
