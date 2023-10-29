import 'package:flutter/material.dart';
import 'package:myevents/models/banquet_model.dart';
import 'package:myevents/pages/base_view.dart';
import 'package:myevents/pages/single_page.dart';
import 'package:myevents/pojos/filter.dart';
import 'package:myevents/viewstate.dart';
import 'package:myevents/widgets/property_card.dart';
import 'package:myevents/widgets/shimmer_effect.dart';

class PartyTab extends StatelessWidget {
  final Filter filter =
      Filter(filterValues: {"field": {}}, priceSortDecending: false);
  @override
  Widget build(BuildContext context) {
    return BaseView<BanquetModel>(
      onModelReady: (model) async {
        await model.fetchAds(filter);
      },
      builder: (context, model, child) => model.state == ViewState.Busy
          ? ShimmerPlaceholder()
          : Scaffold(
              body: RefreshIndicator(
              onRefresh: () async {
                await model.refetchAds(filter);
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
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio:
                              MediaQuery.of(context).size.width /
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
