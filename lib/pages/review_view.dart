import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:myevents/graphql/mutations.dart';
import 'package:myevents/graphql/query.dart';
import 'package:myevents/pojos/ad_detail.dart';
import 'package:myevents/pojos/user_me.dart';
import 'package:provider/provider.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

class ReviewPage extends StatefulWidget {
  final String reviewID;
  ReviewPage({this.reviewID});
  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  TextEditingController _reviewContentController = TextEditingController();
  double _selectedRating = 1.0;

  Map<String, dynamic> uploadFields = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Review"),
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
        actions: <Widget>[],
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(11.0),
          child: Column(
            children: <Widget>[
              Query(
                options: QueryOptions(
                    documentNode: gql(loadSingleAd),
                    variables: <String, dynamic>{
                      "field": widget.reviewID
                    }),
                builder: (QueryResult result,
                    {VoidCallback refetch, FetchMore fetchMore}) {
                  if (result.exception != null) {
                    return Text(result.exception.toString());
                  }

                  if (result.loading) {
                    return Text('Loading');
                  }

                  AdDetail adDetail = AdDetail.fromJson(result.data);

                  return Text(
                    "Review for \'${adDetail.userAd.title}\'",
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF442B2D)),
                  );
                },
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
