class Filter {
  Map<String, dynamic> filterValues;
  /* Price is being sorted from [High to Low] by default */
  bool priceSortDecending = true;
  Filter({this.filterValues, this.priceSortDecending});
}
