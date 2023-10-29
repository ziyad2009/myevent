import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:myevents/graphql/mutations.dart';
import 'package:myevents/graphql/query.dart';
import 'package:myevents/pojos/ad_detail.dart';
import 'package:myevents/pojos/user_basic.dart';
import 'package:provider/provider.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

class WriteReviewPage extends StatefulWidget {
  final String targetType;
  final String targetID;
  final String targetName;
  WriteReviewPage({this.targetType, this.targetID, this.targetName});
  @override
  _WriteReviewPageState createState() => _WriteReviewPageState();
}

class _WriteReviewPageState extends State<WriteReviewPage> {
  TextEditingController _reviewContentController = TextEditingController();
  double _selectedRating = 1.0;
  Map<String, dynamic> uploadFields = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Write review"),
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: <Widget>[
          Mutation(
            options: MutationOptions(
              documentNode: gql(createReview),
              onError: (OperationException exp) {
                print(exp);
                Fluttertoast.showToast(
                    msg: "We had some trouble posting your review",
                    backgroundColor: Colors.yellow[800],
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.BOTTOM);
              },
              update: (Cache cache, QueryResult result) {
                return result;
              },
              onCompleted: (dynamic data) {
                Fluttertoast.showToast(
                    msg: "Review Posted",
                    backgroundColor: Colors.green[700],
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.BOTTOM);
                Navigator.pop(context);
              },
            ),
            builder: (RunMutation runMutation, QueryResult result) {
              if (result.exception != null) {
                return Text(result.exception.toString());
              }

              if (result.loading) {
                return SizedBox(
                  width: 40,
                  height: 40,
                  child: Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.white,
                      strokeWidth: 4,
                    ),
                  ),
                );
              }

              return FlatButton(
                child: Text(
                  "POST",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  if (_reviewContentController.text.isEmpty) {
                    BotToast.showText(text: "Review is empty!");
                    return;
                  }
                  uploadFields[widget.targetType] = widget.targetID;
                  uploadFields["reviewer"] = Provider.of<UserBasic>(context).id;
                  uploadFields["content"] = _reviewContentController.text;
                  uploadFields["stars"] = _selectedRating;
                  runMutation({
                    "fields": <String, dynamic>{"data": uploadFields}
                  });
                },
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(11.0),
          child: Column(
            children: <Widget>[
              Text(
                "Review for \'${widget.targetName}\'",
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF442B2D)),
              ),
              SizedBox(height: 18),
              SmoothStarRating(
                allowHalfRating: false,
                onRatingChanged: (double v) {
                  setState(() {
                    _selectedRating = v;
                  });
                },
                starCount: 5,
                rating: _selectedRating,
                size: 28.0,
                color: Color(0xFFE2A500),
                borderColor: Color(0xFFE2A500),
                spacing: 0.0,
              ),
              SizedBox(height: 18),
              TextField(
                textInputAction: TextInputAction.newline,
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.sentences,
                controller: _reviewContentController,
                style: TextStyle(fontSize: 18),
                maxLines: null,
                maxLength: 300,
                decoration: new InputDecoration(
                  border: new OutlineInputBorder(
                      borderSide: new BorderSide(color: Colors.teal)),
                  hintText: 'Type review here...',
                  helperText: 'Keep it short and precise.',
                  labelText: 'Review',
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
