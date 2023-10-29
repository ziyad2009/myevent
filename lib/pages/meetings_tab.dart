import 'package:flutter/material.dart';
import 'package:myevents/models/resort_model.dart';
import 'package:myevents/pages/base_view.dart';
import 'package:myevents/pages/single_page.dart';
import 'package:myevents/pojos/filter.dart';
import 'package:myevents/viewstate.dart';
import 'package:myevents/widgets/property_card.dart';
import 'package:myevents/widgets/shimmer_effect.dart';
import 'package:provider/provider.dart';

class MeetingsTab extends StatelessWidget {
  final Filter filter = Filter(filterValues: {"field": {}});
  @override
  Widget build(BuildContext context) {
    return BaseView<ResortModel>(
      onModelReady: (model) async {
        if (Provider.of<Filter>(context) != null)
          filter.filterValues = Provider.of<Filter>(context).filterValues;
        await model.fetchAds(filter);
      },
      builder: (context, model, child) => model.state == ViewState.Busy
          ? ShimmerPlaceholder()
          : Scaffold(
              body: RefreshIndicator(
              onRefresh: () async {
                model.refetchAds(filter);
              },
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Flexible(
                      child: GridView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        padding: EdgeInsets.only(top: 12),
                        itemCount: model.adItems.userAds.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: MediaQuery.of(context).size.width /
                              (MediaQuery.of(context).size.height / 0.9),
                        ),
                        itemBuilder: (context, index) => GestureDetector(
                          onLongPress: () {},
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SingleAdPage(
                                        classfiedAdID: model.adItems.userAds
                                            .elementAt(index)
                                            .id)));
                          },
                          child: PropertyCard(
                              userAd: model.adItems.userAds.elementAt(index)),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )),
    );
  }
}
