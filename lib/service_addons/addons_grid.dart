import 'package:flutter/material.dart';
import 'package:myevents/common/app_colors.dart';
import 'package:myevents/models/service_models/service_list_model.dart';
import 'package:myevents/pages/base_view.dart';
import 'package:myevents/pojos/filter.dart';
import 'package:myevents/service_addons/addon_detail_page.dart';
import 'package:myevents/viewstate.dart';
import 'package:myevents/widgets/modal_bottom_sheet.dart';
import 'package:myevents/widgets/service_card.dart';
import 'package:myevents/widgets/service_filters.dart';
import 'package:myevents/widgets/shimmer_effect.dart';

class AddonsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BaseView<ServiceListModel>(
      onModelReady: (model) async {
        await model.fetchAllServices(
            filter:
                Filter(filterValues: {"field": {}}, priceSortDecending: true));
      },
      builder: (context, model, child) => model.state == ViewState.Busy
          ? ShimmerPlaceholder()
          : Scaffold(
              body: RefreshIndicator(
                onRefresh: () async {
                  await model.fetchAllServices(
                      filter: Filter(
                          filterValues: {"field": {}},
                          priceSortDecending: true));
                },
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 8.0, right: 8.0, top: 8.0),
                        child: GestureDetector(
                          onTap: () async {
                            showModalBottomSheetApp<Filter>(
                                    context: context,
                                    builder: (context) => ServiceFilters())
                                .then((value) async {
                              if (value != null) {
                                await model.fetchAllServices(filter: value);
                              }
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.grey[300]),
                              color: Colors.grey[200],
                            ),
                            child: Text(
                              "Filters",
                              style: TextStyle(
                                  color: primaryColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        child: GridView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          padding: EdgeInsets.only(top: 12),
                          itemCount: model.serviceItems.services.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio:
                                MediaQuery.of(context).size.width /
                                    (MediaQuery.of(context).size.height / 0.97),
                          ),
                          itemBuilder: (context, index) => GestureDetector(
                            onLongPress: () {},
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ServiceDetailPage(
                                      serviceID: model.serviceItems.services
                                          .elementAt(index)
                                          .id),
                                ),
                              );
                            },
                            child: ServiceCard(
                                service: model.serviceItems.services
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
