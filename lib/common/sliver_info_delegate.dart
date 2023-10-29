import 'package:flutter/material.dart';

class SliverUserProfileInfoDelegate extends SliverPersistentHeaderDelegate {
  final Widget userInfoHeader;
  final double minHeight;
  final double maxHeight;
  SliverUserProfileInfoDelegate(
      {this.userInfoHeader, this.minHeight, this.maxHeight});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(
      child: userInfoHeader,
    );
  }

  @override
  double get maxExtent => maxHeight;

  @override
  double get minExtent => minHeight;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}

class SliverColorTabBarDelegate extends SliverPersistentHeaderDelegate {
  SliverColorTabBarDelegate(this._coloredTabBar);
  final ColoredTabBar _coloredTabBar;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return new Container(child: _coloredTabBar);
  }

  @override
  double get minExtent => _coloredTabBar.preferredSize.height;
  @override
  double get maxExtent => _coloredTabBar.preferredSize.height;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}

class ColoredTabBar extends Container implements PreferredSizeWidget {
  ColoredTabBar(this.color, this.tabBar);

  final Color color;
  final TabBar tabBar;

  @override
  Size get preferredSize => tabBar.preferredSize;

  @override
  Widget build(BuildContext context) => Container(
        color: color,
        child: tabBar,
      );
}