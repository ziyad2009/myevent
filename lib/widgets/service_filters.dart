import 'package:flutter/material.dart';
import 'package:myevents/common/app_colors.dart';
import 'package:myevents/pojos/filter.dart';

class ServiceFilters extends StatefulWidget {
  @override
  _ServiceFiltersState createState() => _ServiceFiltersState();
}

class _ServiceFiltersState extends State<ServiceFilters> {
  final TextEditingController locationController = TextEditingController();
  bool priceDecending = true;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          sectionHeader("Filter by Location"),
          SizedBox(height: 20),
          TextField(
            controller: locationController,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.location_on, color: exoticPurple),
              hintText: "Enter location",
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: exoticPurple),
              ),
            ),
          ),
          SizedBox(height: 20),
          sectionHeader("Filter by price"),
          SizedBox(height: 20),
          Row(
            children: <Widget>[
              new Radio<bool>(
                value: true,
                groupValue: priceDecending,
                onChanged: (bool val) {
                  setState(() {
                    priceDecending = val;
                  });
                },
              ),
              new Text(
                'High to Low',
                style: new TextStyle(fontSize: 16.0),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              new Radio<bool>(
                value: false,
                groupValue: priceDecending,
                onChanged: (bool val) {
                  setState(() {
                    priceDecending = val;
                  });
                },
              ),
              new Text(
                'Low to High',
                style: new TextStyle(fontSize: 16.0),
              ),
            ],
          ),
          ButtonBar(
            alignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                color: exoticPurple,
                onPressed: () {
                  Map<String, String> vals = {};
                  if (locationController.text.isNotEmpty) {
                    vals["serviceAddress_contains"] = locationController.text;
                  }
                  Filter filter = Filter(filterValues: {"field": vals});
                  filter.priceSortDecending = priceDecending;
                  print(filter.filterValues);
                  Navigator.pop(context, filter);
                },
                child: Text("APPLY FILTERS",
                    style: TextStyle(color: Colors.white)),
              ),
              OutlineButton(
                onPressed: () {
                  Navigator.pop(context, null);
                },
                child: Text("CLEAR FILTERS",
                    style: TextStyle(color: exoticPurple)),
              ),
            ],
          )
        ],
      ),
    );
  }
}
