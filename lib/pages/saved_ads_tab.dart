import 'package:flutter/material.dart';
import 'package:myevents/common/app_colors.dart';
import 'package:myevents/models/ad_dir_model.dart';
import 'package:myevents/pages/base_view.dart';
import 'package:myevents/pages/comparision_page.dart';
import 'package:myevents/pages/single_page.dart';
import 'package:myevents/pojos/user_basic.dart';
import 'package:myevents/widgets/property_card.dart';
import 'package:provider/provider.dart';

import '../viewstate.dart';

class SavedAdsTab extends StatelessWidget {
  List<String> selectedAds = [];
  @override
  Widget build(BuildContext context) {
    return BaseView<AdDirModel>(
      onModelReady: (model) async {
        model.fetchSavedAds(Provider.of<UserBasic>(context).id);
      },
      builder: (context, model, child) => model.state == ViewState.Busy
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Scaffold(
              floatingActionButton: Visibility(
                visible: selectedAds.length > 1,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FloatingActionButton(
                    backgroundColor: primaryColor,
                    child: Icon(
                      Icons.compare_arrows,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ComparisionPage(selectedAds: selectedAds),
                        ),
                      ).then((_) {
                        selectedAds.clear();
                        model.savedList.user.savedAds.forEach((element) {
                          element.isSelected = false;
                        });
                        model.updateState();
                      });
                    },
                  ),
                ),
              ),
              body: RefreshIndicator(
                onRefresh: () async {
                  await model.fetchSavedAds(Provider.of<UserBasic>(context).id);
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
                          itemCount: model.savedList.user.savedAds.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio:
                                MediaQuery.of(context).size.width /
                                    (MediaQuery.of(context).size.height / 0.9),
                          ),
                          itemBuilder: (context, index) => GestureDetector(
                            onLongPress: () {
                              if (selectedAds.length < 5)
                                model.savedList.user.savedAds
                                        .elementAt(index)
                                        .isSelected =
                                    !model.savedList.user.savedAds
                                        .elementAt(index)
                                        .isSelected;
                              if (model.savedList.user.savedAds
                                      .elementAt(index)
                                      .isSelected &&
                                  selectedAds.length < 5)
                                selectedAds.add(model.savedList.user.savedAds
                                    .elementAt(index)
                                    .id);
                              else
                                selectedAds.remove(model.savedList.user.savedAds
                                    .elementAt(index)
                                    .id);
                              model.updateState();
                            },
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SingleAdPage(
                                          classfiedAdID: model
                                              .savedList.user.savedAds
                                              .elementAt(index)
                                              .id)));
                            },
                            child: PropertyCard(
                                userAd: model.savedList.user.savedAds
                                    .elementAt(index)),
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
