import 'package:flutter/material.dart';
import 'package:myevents/common/app_colors.dart';
import 'package:myevents/models/trending_model.dart';
import 'package:myevents/pages/base_view.dart';
import 'package:myevents/pages/single_page.dart';
import 'package:myevents/pojos/filter.dart';
import 'package:myevents/pojos/venue_options.dart';
import 'package:myevents/viewstate.dart';
import 'package:myevents/widgets/property_card.dart';
import 'package:myevents/widgets/shimmer_effect.dart';
import 'package:myevents/widgets/slide_in.dart';

class TrendingPage extends StatefulWidget {
  @override
  _TrendingPageState createState() => _TrendingPageState();
}

class _TrendingPageState extends State<TrendingPage> {
  final int delay = 200;
  final TextEditingController textEditingController = TextEditingController();
  VenueTypes selectedVenueType;

  @override
  Widget build(BuildContext context) {
    return BaseView<TrendingModel>(
      onModelReady: (model) async {
        await model.fetchVenueTypes();
        await model.fetchAds(
          Filter(filterValues: {
            "field": {"adStatus": "Active"}
          }, priceSortDecending: false),
        );
      },
      builder: (context, model, child) => model.state == ViewState.Busy
          ? ShimmerPlaceholder()
          : Scaffold(
              body: RefreshIndicator(
                onRefresh: () async {
                  await model.refetchAds(Filter(filterValues: {
                    "field": {"adStatus": "Active"}
                  }, priceSortDecending: false));
                  selectedVenueType = null;
                  textEditingController.clear();
                },
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(left: 16, top: 8, bottom: 4),
                        color: primaryColor,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            ShowUp(
                              delay: delay,
                              child: Text(
                                "Find Your\nEvent Space",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 48),
                              ),
                            ),
                            ShowUp(
                              delay: delay + 100,
                              child: Text(
                                "Let us find you the space of your dream!",
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18),
                              ),
                            ),
                            SizedBox(height: 20),
                            Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4)),
                              padding: EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 4),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Flexible(
                                    flex: 2,
                                    child: TextField(
                                      controller: textEditingController,
                                      decoration: InputDecoration(
                                        prefixIcon: Icon(Icons.location_on,
                                            color: exoticPurple),
                                        hintText: "Location",
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.grey),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: exoticPurple),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    flex: 1,
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<VenueTypes>(
                                        hint: Text("Category",
                                            style:
                                                TextStyle(color: Colors.grey)),
                                        value: selectedVenueType,
                                        items: model.venueOptions.venueTypes
                                            .map((VenueTypes value) {
                                          return new DropdownMenuItem<
                                                  VenueTypes>(
                                              value: value,
                                              child: new Text(value.typeName
                                                  .toUpperCase()));
                                        }).toList(),
                                        onChanged: (_) async {
                                          setState(() {
                                            selectedVenueType = _;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(right: 24),
                              alignment: Alignment.bottomRight,
                              child: RaisedButton.icon(
                                color: Colors.white,
                                onPressed: () async {
                                  Map<String, String> filterValues = {};
                                  if (selectedVenueType != null) {
                                    filterValues["venueTypes_in"] =
                                        selectedVenueType.id;
                                  }
                                  if (textEditingController.text.isNotEmpty) {
                                    filterValues["venueAddress_contains"] =
                                        textEditingController.text;
                                  }
                                  filterValues["adStatus"] = "Active";
                                  await model.fetchAds(
                                    Filter(filterValues: {
                                      "field": filterValues,
                                    }, priceSortDecending: false),
                                  );
                                },
                                icon: Icon(Icons.search, color: exoticPurple),
                                label: Text(
                                  "FIND",
                                  style: TextStyle(color: exoticPurple),
                                ),
                              ),
                            ),
                            SizedBox(height: 12),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            ShowUp(
                                delay: delay + 100,
                                child: sectionHeader("Featured Properties")),
                            SizedBox(height: 12),
                            ShowUp(
                              delay: delay + 100,
                              child: Text(
                                "Featured properties are our handpicked venues. They are sure make your events more memorable.",
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 16),
                              ),
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text("Swipe for more"),
                                Icon(Icons.arrow_forward_ios,
                                    color: primaryColor, size: 14)
                              ],
                            ),
                            SizedBox(
                              height: 350,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: model.adItems.userAds.length,
                                itemBuilder: (context, index) =>
                                    GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SingleAdPage(
                                            classfiedAdID: model.adItems.userAds
                                                .elementAt(index)
                                                .id),
                                      ),
                                    );
                                  },
                                  child: SizedBox(
                                    width: 177,
                                    child: PropertyCard(
                                        userAd: model.adItems.userAds
                                            .elementAt(index)),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            sectionHeader("Recently Posted"),
                            SizedBox(height: 12),
                            Text(
                              "Check out all the events spaces we have to offer. They are sure make your events more memorable.",
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 16),
                            ),
                            Flexible(
                              child: GridView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                padding: EdgeInsets.only(top: 12),
                                itemCount: model.adItems.userAds.length,
                                // gridDelegate:
                                //     SliverGridDelegateWithFixedCrossAxisCount(
                                //   crossAxisCount: _crossAxisCount,
                                //   crossAxisSpacing: _crossAxisSpacing,
                                //   mainAxisSpacing: _mainAxisSpacing,
                                //   childAspectRatio: _aspectRatio,
                                // ),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.45,
                                ),
                                itemBuilder: (context, index) =>
                                    GestureDetector(
                                  onLongPress: () {
                                    // model.adItems.userAds
                                    //         .elementAt(index)
                                    //         .isSelected =
                                    //     !model.adItems.userAds
                                    //         .elementAt(index)
                                    //         .isSelected;
                                    // if (model.adItems.userAds
                                    //     .elementAt(index)
                                    //     .isSelected)
                                    //   selectedAds.add(model.adItems.userAds
                                    //       .elementAt(index)
                                    //       .id);
                                    // else
                                    //   selectedAds.remove(model.adItems.userAds
                                    //       .elementAt(index)
                                    //       .id);
                                    // model.updateState();
                                  },
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => SingleAdPage(
                                                classfiedAdID: model
                                                    .adItems.userAds
                                                    .elementAt(index)
                                                    .id)));
                                  },
                                  child: PropertyCard(
                                      userAd: model.adItems.userAds
                                          .elementAt(index)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
