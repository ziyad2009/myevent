import 'package:flutter/material.dart';
import 'package:myevents/common/app_colors.dart';
import 'package:myevents/models/dynamic_tabs/dynamic_tab_model.dart';
import 'package:myevents/pages/base_view.dart';
import 'package:myevents/pages/single_page.dart';
import 'package:myevents/pojos/filter.dart';
import 'package:myevents/pojos/venue_options.dart';
import 'package:myevents/viewstate.dart';
import 'package:myevents/widgets/property_card.dart';
import 'package:myevents/widgets/shimmer_effect.dart';

class DynamicTabPage extends StatelessWidget {
  final VenueTypes venueType;
  const DynamicTabPage({Key key, this.venueType}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return BaseView<DynamicTabModel>(
      onModelReady: (model) async {
        model.venueType = venueType;
        await model.fetchAds(
          Filter(filterValues: {
            "field": {
              "venueTypes_in": [venueType.id]
            }
          }, priceSortDecending: false),
        );
      },
      builder: (context, model, child) => model.state == ViewState.Busy
          ? ShimmerPlaceholder()
          : Scaffold(
              body: RefreshIndicator(
                onRefresh: () async {
                  await model.refetchAds(Filter(filterValues: {
                    "venueType_in": [venueType.id]
                  }, priceSortDecending: false));
                },
                child: model.adItems.userAds.isEmpty
                    ? Center(
                        child: Text(
                          "Oops! No spaces were found. Try other search filters or category from the tabs above",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: exoticPurple, fontSize: 18),
                        ),
                      )
                    : SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Flexible(
                              child: GridView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                padding: EdgeInsets.only(top: 12),
                                itemCount: model.adItems.userAds.length,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.45,
                                ),
                                itemBuilder: (context, index) =>
                                    GestureDetector(
                                  onLongPress: () {},
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
                                  child: PropertyCard(
                                      userAd: model.adItems.userAds
                                          .elementAt(index)),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
              ),
            ),
    );
  }
}
