import 'package:flutter/material.dart';
import 'package:myevents/pages/front_page_one_naive.dart';
import 'package:myevents/refactored_pages/menu_backpage.dart';
import 'package:myevents/refactored_pages/search_backpage.dart';
import 'package:myevents/widgets/shrine_backdrop.dart';

class ImprovedHomepage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ShrineBackdrop(
      updateFrontPageCallback: () {},
      currentCategory: "shrine-backdrop",
      backTitle: Container(),
    );
  }
}
