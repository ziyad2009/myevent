import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_database/firebase_database.dart' as firebase;
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:myevents/common/app_colors.dart';
import 'package:myevents/graphql/mutations.dart';
import 'package:myevents/graphql/query.dart';
import 'package:myevents/models/share_button_model.dart';
import 'package:myevents/pages/base_view.dart';
import 'package:myevents/pages/booking_pages/book_now_page.dart';
import 'package:myevents/pages/chat_page.dart';
import 'package:myevents/pages/image_view.dart';
import 'package:myevents/pages/profile_page.dart';
import 'package:myevents/pages/write_review.dart';
import 'package:myevents/pojos/perk_list.dart';
import 'package:myevents/pojos/review_average.dart';
import 'package:myevents/pojos/review_list.dart';
import 'package:myevents/pojos/service_detail.dart';
import 'package:myevents/pojos/upload.dart';
import 'package:myevents/pojos/user_basic.dart';
import 'package:myevents/pojos/user_detail.dart';
import 'package:myevents/service_addons/service_edit_page.dart';
import 'package:myevents/widgets/check_video_cta.dart';
import 'package:myevents/widgets/dost_indicator.dart';
import 'package:myevents/widgets/review_card.dart';
import 'package:provider/provider.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:url_launcher/url_launcher.dart';

import '../viewstate.dart';

enum ServiceActions { Status, Edit }

class ServiceDetailPage extends StatefulWidget {
  final String serviceID;

  ServiceDetailPage({this.serviceID});
  static const _kDuration = const Duration(milliseconds: 300);
  static const _kCurve = Curves.ease;

  @override
  _ServiceDetailPageState createState() => _ServiceDetailPageState();
}

class _ServiceDetailPageState extends State<ServiceDetailPage> {
  final _controller = new PageController();

  var top = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Query(
        options: QueryOptions(
            documentNode: gql(fetchSingleService),
            variables: <String, dynamic>{"field": widget.serviceID}),
        builder: (QueryResult result,
            {VoidCallback refetch, FetchMore fetchMore}) {
          if (result.hasException) {
            return Text(result.exception.toString());
          }

          if (result.loading) {
            return Scaffold(
              appBar: AppBar(
                title: Text(
                  "Service Ad",
                  style: TextStyle(color: Colors.white),
                ),
                leading: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context)),
              ),
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          ServiceDetail serviceDetail = ServiceDetail.fromJson(result.data);

          return NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) => <Widget>[
              SliverAppBar(
                backgroundColor: primaryColor,
                titleSpacing: 0.0,
                expandedHeight: 200.0,
                floating: false,
                pinned: true,
                actions: <Widget>[
                  Mutation(
                      options: MutationOptions(
                        documentNode: gql(updateService),
                        update: (Cache cache, QueryResult result) {
                          return result;
                        },
                      ),
                      builder: (
                        RunMutation runMutation,
                        QueryResult result,
                      ) {
                        return PopupMenuButton<ServiceActions>(
                          icon: Icon(Icons.more_vert),
                          color: Colors.white,
                          onSelected: (ServiceActions action) {
                            if (action == ServiceActions.Status) {
                              String newStatus =
                                  serviceDetail.service.adStatus == "Active"
                                      ? "Disabled"
                                      : "Active";
                              runMutation({
                                "field": <String, dynamic>{
                                  "where": <String, dynamic>{
                                    "id": serviceDetail.service.id
                                  },
                                  "data": {"adStatus": newStatus}
                                }
                              });
                            } else if (action == ServiceActions.Edit) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditServiceForm(
                                      serviceID: serviceDetail.service.id),
                                ),
                              );
                            }
                          },
                          itemBuilder: (context) =>
                              <PopupMenuEntry<ServiceActions>>[
                            PopupMenuItem(
                              enabled: serviceDetail.service.provider.id ==
                                  Provider.of<UserBasic>(context).id,
                              value: ServiceActions.Status,
                              child: serviceDetail.service.adStatus == "Active"
                                  ? Text("Mark Rented")
                                  : Text("Mark Active"),
                            ),
                            PopupMenuItem(
                              enabled: serviceDetail.service.provider.id ==
                                  Provider.of<UserBasic>(context).id,
                              value: ServiceActions.Edit,
                              child: Text("Edit"),
                            ),
                          ],
                        );
                      })
                ],
                flexibleSpace: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    top = constraints.biggest.height;
                    return FlexibleSpaceBar(
                      centerTitle: false,
                      background: imageViewerPages(
                          serviceDetail.service.servicePhotos,
                          serviceDetail.service.isPremium,
                          serviceDetail.service.serviceVideo,
                          context),
                      title: AnimatedOpacity(
                        duration: Duration(milliseconds: 300),
                        opacity: top == 80.0 ? 1.0 : 0.0,
                        //opacity: 1.0,
                        child: Text(
                          "${serviceDetail.service.name}",
                          maxLines: 1,
                          style: TextStyle(fontSize: 16.0, color: Colors.white),
                        ),
                      ),
                    );
                  },
                ),
              )
            ],
            body: SingleChildScrollView(
              child: Container(
                margin:
                    EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            serviceDetail.service.name ?? "Title",
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF442B2D)),
                          ),
                        ),
                        BaseView<SaveServiceButtonModel>(
                          onModelReady: (model) async {
                            await model.fetchSavedServices(
                                Provider.of<UserBasic>(context).id);
                          },
                          builder: (context, model, child) {
                            if (model.state == ViewState.Busy) {
                              return SizedBox(
                                height: 23,
                                width: 23,
                                child: Center(
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2.5)),
                              );
                            } else {
                              return IconButton(
                                onPressed: () async {
                                  await model.updateSavedServices(
                                      serviceDetail.service.id,
                                      Provider.of<UserBasic>(context).id);
                                },
                                icon: model.isServiceSaved(
                                        serviceDetail.service.id)
                                    ? Icon(Icons.bookmark, color: exoticPurple)
                                    : Icon(Icons.bookmark_border,
                                        color: exoticPurple),
                              );
                            }
                          },
                        )
                      ],
                    ),
                    Query(
                      options: QueryOptions(
                          documentNode: gql(ratingAverage),
                          variables: {
                            "field": {"service": serviceDetail.service.id}
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

                        return SmoothStarRating(
                          starCount: 5,
                          borderColor: Color(0xFFDAA000),
                          color: Color(0xFFDAA000),
                          allowHalfRating: false,
                          rating: reviewAverage
                              .reviewsConnection.aggregate.avg.stars,
                          size: 20,
                        );
                      },
                    ),
                    SizedBox(height: 8),
                    Text(
                      "SAR ${serviceDetail.service.pricePerDay}/day",
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: primaryColor,
                          fontSize: 23),
                    ),
                    Text(
                      serviceDetail.service.description ??
                          "No description provided",
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w500),
                    ),
                    serviceDetail.service.isPremium
                        ? CheckVideoCTA(
                            videoURL: serviceDetail.service.serviceVideo.url)
                        : Container(),
                    SizedBox(
                      height: 12,
                    ),
                    _infoIconTile(serviceDetail.service.serviceAddress,
                        "Location", Icons.location_on),
                    SizedBox(height: 16),
                    Visibility(
                      visible: serviceDetail.service.provider.id !=
                          Provider.of<UserBasic>(context).id,
                      child: SizedBox(
                          width: double.maxFinite,
                          child: RaisedButton(
                            color: primaryColor,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BookNowPage(
                                    targetType: "service",
                                    targetID: serviceDetail.service.id,
                                    perDayPrice:
                                        serviceDetail.service.pricePerDay,
                                    targetName: serviceDetail.service.name,
                                    isEditingMode: false,
                                    editBookingID: null,
                                  ),
                                ),
                              );
                            },
                            child: Text(
                              "BOOK NOW",
                              style: TextStyle(
                                  color: Colors.white,
                                  letterSpacing: 1.25,
                                  fontWeight: FontWeight.w600),
                            ),
                          )),
                    ),
                    SizedBox(height: 25),
                    _additionalDetailsList(serviceDetail.service.perkList),
                    SizedBox(
                      height: 12,
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.help,
                        color: primaryColor,
                      ),
                      onTap: () {
                        BotToast.showText(
                            text: "Information guide coming soon!");
                      },
                      title: Text(
                        "Information Guide",
                        style: TextStyle(fontSize: 18, color: primaryColor),
                      ),
                      subtitle: Text("Check features and offers"),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: 20,
                      ),
                    ),
                    _sellerDescription(
                      serviceDetail.service.provider,
                    ),
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
                                      targetName: serviceDetail.service.name,
                                      targetID: serviceDetail.service.id,
                                      targetType: "service",
                                    )));
                      },
                    )
                  ],
                ),
              ),
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
                  title ?? subtitle,
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
    if (perkList == null || perkList.perks.isEmpty) {
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
          Text("Perks",
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
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProfilePage(userID: seller.id)));
            },
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
                    BotToast.showText(text: "You posted this service");
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
                  if (seller.id ==
                      Provider.of<UserBasic>(context, listen: false).id) {
                    BotToast.showText(text: "You posted this service");
                    return;
                  }
                  String url = "tel:" + seller.phone;
                  if (await canLaunch(url)) {
                    await launch(url);
                  } else {
                    // throw 'Could not launch $url';
                    BotToast.showText(
                        text:
                            "Sorry! The seller did not provide a contact number");
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
              "field": <String, dynamic>{"service": widget.serviceID}
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

  Widget imageViewerPages(List<UploadResponse> productImages, bool isFeatured,
      UploadResponse propertyVideo, BuildContext context) {
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
                    duration: ServiceDetailPage._kDuration,
                    curve: ServiceDetailPage._kCurve,
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
