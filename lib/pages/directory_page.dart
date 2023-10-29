import 'package:flutter/material.dart';
import 'package:myevents/common/app_colors.dart';
import 'package:myevents/models/dir_page_model.dart';
import 'package:myevents/pages/base_view.dart';
import 'package:myevents/pages/dynamic_tabs/dynamic_tab_page.dart';
import 'package:myevents/viewstate.dart';
import 'package:myevents/widgets/decorated_tabs.dart';

class DirectoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BaseView<DirPageModel>(onModelReady: (model) async {
      await model.loadVenueTypes();
    }, builder: (context, model, child) {
      if (model.state == ViewState.Busy)
        return Center(child: CircularProgressIndicator());
      else {
        return DefaultTabController(
          length: model.venueOptions.venueTypes.length,
          child: Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(100.0),
              child: AppBar(
                flexibleSpace: Container(
                  color: Colors.white,
                  child: new Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding:
                            EdgeInsets.only(left: 16, right: 16, bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            sectionHeader("All Properties"),
                            SizedBox(
                              height: 20,
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  hint: Text("Sort By Price"),
                                  icon: Icon(Icons.swap_vert,
                                      color: primaryColor, size: 24),
                                  items: <String>["High to Low", "Low to High"]
                                      .map((String value) {
                                    return new DropdownMenuItem<String>(
                                      value: value,
                                      child: new Text(value),
                                    );
                                  }).toList(),
                                  onChanged: (String sortChoice) async {
                                    model.setSortingPreference(
                                        sortChoice == "Low to High");
                                  },
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      new DecoratedTabBar(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Color(0x2A7F0A3D),
                              width: 2.0,
                            ),
                          ),
                        ),
                        tabBar: TabBar(
                          indicatorColor: Color(0xFF720936),
                          tabs: model.venueOptions.venueTypes
                              .map<Widget>(
                                (e) => new Tab(
                                  child: Text(
                                    e.typeName.toUpperCase(),
                                    style: TextStyle(
                                        color: exoticPurple,
                                        letterSpacing: 1.25,
                                        fontSize: 16.29),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Expanded(
                  child: TabBarView(
                    children: model.venueOptions.venueTypes
                        .map<Widget>(
                          (e) => new DynamicTabPage(
                            venueType: e,
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    });
  }
}
