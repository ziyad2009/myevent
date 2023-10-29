import 'dart:async';

import 'package:myevents/pojos/filter.dart';

class FilterService {
  StreamController<Filter> filterController =
      StreamController<Filter>.broadcast();
  /* Price is being sorted from [High to Low] by default */
  bool priceSortDecending = false;
}
