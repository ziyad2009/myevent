import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:myevents/common/app_colors.dart';
import 'package:myevents/graphql/query.dart';
import 'package:myevents/pages/chat_page.dart';
import 'package:myevents/pages/image_view.dart';
import 'package:myevents/pages/write_review.dart';
import 'package:myevents/pojos/ad_detail.dart';
import 'package:myevents/pojos/perk_list.dart';
import 'package:myevents/pojos/review_average.dart';
import 'package:myevents/pojos/review_list.dart';
import 'package:myevents/pojos/upload.dart';
import 'package:firebase_database/firebase_database.dart' as firebase;
import 'package:myevents/pojos/user_basic.dart';
import 'package:myevents/pojos/user_detail.dart';
import 'package:myevents/widgets/dost_indicator.dart';
import 'package:myevents/widgets/review_card.dart';
import 'package:provider/provider.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:url_launcher/url_launcher.dart';

class SingleComparison extends StatefulWidget {
  final String classfiedAdID;

  final ScrollController scrollController;
  SingleComparison({this.classfiedAdID, this.scrollController});
  static const _kDuration = const Duration(milliseconds: 300);
  static const _kCurve = Curves.ease;

  @override
  _SingleComparisionState createState() => _SingleComparisionState();
}

class _SingleComparisionState extends State<SingleComparison> {
  final _controller = new PageController();
  var top = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Query(
        options: QueryOptions(
            documentNode: gql(loadSingleAd),
            variables: <String, dynamic>{"field": widget.classfiedAdID}),
        builder: (QueryResult result,
            {VoidCallback refetch, FetchMore fetchMore}) {
          if (result.hasException) {
            return Text(result.exception.toString());
          }

          if (result.loading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          AdDetail adDetail = AdDetail.fromJson(result.data);

          return SingleChildScrollView(
            controller: widget.scrollController,
            child: Column(
              children: <Widget>[
                Container(
                  height: 200,
                  child: imageViewerPages(adDetail.userAd.adImages, context),
                ),
                Container(
                  margin:
                      EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              adDetail.userAd.title ?? "Title",
                              style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF442B2D)),
                            ),
                          ),
                        ],
                      ),
                      Query(
                        options: QueryOptions(
                            documentNode: gql(ratingAverage),
                            variables: {
                              "field": {"user_ad": adDetail.userAd.id}
                            }),
                        builder: (QueryResult result,
                            {VoidCallback refetch, FetchMore fetchMore}) {
                          if (result.hasException) {
                            return Text('Rating not available',
                                style: TextStyle(
                                    color: Colors.grey[400], fontSize: 12));
                          }

                          if (result.loading) {
                            return Text('Loading...',
                                style: TextStyle(
                                    color: Colors.grey[400], fontSize: 12));
                          }

                          ReviewAverage reviewAverage =
                              ReviewAverage.fromJson(result.data);

                          return Row(
                            children: <Widget>[
                              SmoothStarRating(
                                starCount: 5,
                                borderColor: Color(0xFFDAA000),
                                color: Color(0xFFDAA000),
                                allowHalfRating: false,
                                rating: reviewAverage
                                    .reviewsConnection.aggregate.avg.stars,
                                size: 20,
                              ),
                              FlatButton.icon(
                                icon: Icon(
                                  Icons.mode_comment,
                                  color: Colors.grey,
                                  size: 23,
                                ),
                                onPressed: null,
                                label: Text(
                                    "${reviewAverage.reviewsConnection.aggregate.count} Reviews"),
                              )
                            ],
                          );
                        },
                      ),
                      Text(
                        "SAR ${adDetail.userAd.price}/day",
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: primaryColor,
                            fontSize: 23),
                      ),
                      Text(
                        adDetail.userAd.description ??
                            "No description provided",
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.w500),
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      _infoIconTile(adDetail.userAd.venueAddress, "Location",
                          Icons.location_on),
                      _infoIconTile(adDetail.userAd.accommodation.toString(),
                          "Accomodation", Icons.people),
                      _infoIconTile(adDetail.userAd.area.toString(), "Area(m²)",
                          Icons.business),
                      _infoIconTile(
                          "${formattedTimeOnly(adDetail.userAd.timeStart)} - ${formattedTimeOnly(adDetail.userAd.timeEnd)}",
                          "Time Limit",
                          Icons.access_time),
                      SizedBox(height: 25),
                      _additionalDetailsList(adDetail.userAd.perkList),
                      SizedBox(
                        height: 12,
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.help,
                          color: primaryColor,
                        ),
                        title: Text(
                          "Tourist Guide",
                          style: TextStyle(fontSize: 18, color: primaryColor),
                        ),
                        subtitle: Text("Check Surroundings and Tips"),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          size: 20,
                        ),
                      ),
                      _sellerDescription(adDetail.userAd.seller),
                      SizedBox(
                        height: 12,
                      ),
                      SizedBox(
                        child: _reviewsList(),
                        height: 200,
                      ),
                      OutlineButton.icon(
                        label: Text(
                          "Write Review",
                          style: TextStyle(color: primaryColor),
                        ),
                        icon: Icon(
                          Icons.rate_review,
                          color: primaryColor,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WriteReviewPage(
                                targetName: adDetail.userAd.title,
                                targetID: adDetail.userAd.id,
                                targetType: "user_ad",
                              ),
                            ),
                          );
                        },
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _infoIconTile(String title, String subtitle, IconData icon) {
    return Container(
      padding: const EdgeInsets.only(top: 8.0, bottom: 4),
      child: Row(
        children: <Widget>[
          Icon(
            icon,
            size: 40,
            color: Color(0x8A000000),
          ),
          SizedBox(
            width: 4,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(subtitle),
                Text(
                  title,
                  style: TextStyle(fontSize: 22, color: Color(0x8A000000)),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _additionalDetailsList(PerkList perkList) {
    if (perkList == null) {
      return Container(
        height: 0,
        width: 0,
      );
    }
    return Container(
      padding: EdgeInsets.only(left: 19, right: 19, top: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey),
        color: Color(0xFFFAFAFA),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("Details",
              style: TextStyle(fontSize: 19, color: Color(0x99000000))),
          ListView.separated(
            separatorBuilder: (context, index) => Divider(
              thickness: 1,
            ),
            shrinkWrap: true,
            physics: BouncingScrollPhysics(),
            itemCount: perkList.perks.length,
            itemBuilder: (context, index) => ListTile(
              title: Text(perkList.perks.elementAt(index).perkName),
              trailing: Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sellerDescription(User seller) {
    return Container(
      padding: EdgeInsets.only(left: 19, right: 19, top: 12),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(6),
          color: Color(0xFFFAFAFA)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("Seller Details",
              style: TextStyle(fontSize: 19, color: Color(0x99000000))),
          ListTile(
            leading: CircleAvatar(
              radius: 20,
              backgroundImage: seller.profilePicture != null
                  ? NetworkImage(
                      seller.profilePicture.url,
                    )
                  : AssetImage("lib/assets/crying.png"),
            ),
            title: Text(
              seller.fullName ?? "Seller Name",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 20,
            ),
          ),
          Divider(),
          Text(
            seller.shortBio ?? "Seller Bio",
            style: TextStyle(color: Colors.grey),
          ),
          SizedBox(
            height: 9,
          ),
          ButtonBar(
            alignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(4.0),
                ),
                color: primaryColor,
                child: Text(
                  "CHAT WITH SELLER",
                  style: raisedTextStyle,
                ),
                onPressed: () {
                  if (seller.id ==
                      Provider.of<UserBasic>(context, listen: false).id) {
                    BotToast.showText(text: "You posted this ad");
                    return;
                  }
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ChatView(
                                peerName: seller.fullName,
                                peerStarpiID: seller.id,
                                peerFirebaseUID: seller.firebaseID,
                                myFirebaseID: Provider.of<UserBasic>(context,
                                        listen: false)
                                    .firebaseID,
                                peerImage: seller?.profilePicture?.url ?? null,
                              ))).then((_) {
                    firebase.FirebaseDatabase.instance
                        .reference()
                        .child("chatrooms")
                        .child(Provider.of<UserBasic>(context).firebaseID)
                        .child(uniqueChatroomID(
                            Provider.of<UserBasic>(context).firebaseID,
                            seller.firebaseID))
                        .child(Provider.of<UserBasic>(context).firebaseID)
                        .set(firebase.ServerValue.timestamp);
                  });
                },
              ),
              RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(4.0),
                ),
                color: primaryColor,
                child: Icon(Icons.phone, color: Colors.white),
                onPressed: () async {
                  String url = "tel:" + seller.phone;
                  if (await canLaunch(url)) {
                    await launch(url);
                  } else {
                    throw 'Could not launch $url';
                  }
                },
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _reviewsList() {
    return Query(
        options: QueryOptions(
            documentNode: gql(loadReviews),
            variables: <String, dynamic>{
              "field": <String, dynamic>{"user_ad": widget.classfiedAdID}
            }),
        builder: (QueryResult result,
            {VoidCallback refetch, FetchMore fetchMore}) {
          if (result.hasException) {
            return Text(result.exception.toString());
          }

          if (result.loading) {
            return Text('Loading');
          }

          ReviewList reviewList = ReviewList.fromJson(result.data);
          return reviewList.reviews.isEmpty
              ? Center(
                  child: Text("No reviews yet!",
                      style: TextStyle(color: primaryColor, fontSize: 24)))
              : PageView.builder(
                  pageSnapping: false,
                  itemCount: reviewList.reviews.length,
                  itemBuilder: (context, index) =>
                      ReviewCard(review: reviewList.reviews.elementAt(index)),
                );
        });
  }

  Widget imageViewerPages(
      List<UploadResponse> productImages, BuildContext context) {
    return Stack(
      children: <Widget>[
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ImageView(
                  imagesList: productImages,
                  startPosition: 0,
                ),
              ),
            );
          },
          child: new PageView.builder(
            physics: new AlwaysScrollableScrollPhysics(),
            controller: _controller,
            itemCount: productImages.length,
            itemBuilder: (BuildContext context, int index) {
              // return _pages[index % _pages.length];
              return Image.network(
                productImages.elementAt(index).url,
                fit: BoxFit.cover,
              );
            },
          ),
        ),
        new Positioned(
          bottom: 0.0,
          left: 0.0,
          right: 0.0,
          child: new Container(
            color: Colors.grey[800].withOpacity(0.0),
            padding: const EdgeInsets.all(20.0),
            child: new Center(
              child: new DotsIndicator(
                controller: _controller,
                itemCount: productImages.length,
                onPageSelected: (int page) {
                  _controller.animateToPage(
                    page,
                    duration: SingleComparison._kDuration,
                    curve: SingleComparison._kCurve,
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
