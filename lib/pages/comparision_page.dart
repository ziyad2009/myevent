import 'package:flutter/material.dart';
import 'package:myevents/pages/single_page.dart';
import 'package:myevents/pages/single_page_comparison.dart';

class ComparisionPage extends StatefulWidget {
  final List<String> selectedAds;
  ComparisionPage({this.selectedAds});
  @override
  _ComparisionPageState createState() => _ComparisionPageState();
}

class _ComparisionPageState extends State<ComparisionPage> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: DefaultTabController(
        length: widget.selectedAds.length,
        child: Scaffold(
          appBar: AppBar(
            title: Text("Comparision"),
            leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(context);
                }),
            bottom: TabBar(
              isScrollable: true,
              tabs:
                  List<Widget>.generate(widget.selectedAds.length, (int index) {
                return new Tab(text: "Property ${index + 1}");
              }),
            ),
          ),
          body: TabBarView(
            children: List<Widget>.generate(
                widget.selectedAds.length,
                (int index) => SingleComparison(
                      classfiedAdID: widget.selectedAds.elementAt(index),
                      scrollController:
                          new ScrollController(keepScrollOffset: true),
                    )),
          ),
        ),
      ),
    );
  }
}
