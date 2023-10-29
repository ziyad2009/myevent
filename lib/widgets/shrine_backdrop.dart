// Copyright 2018-present the Flutter authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:myevents/pages/chat_list_page.dart';
import 'package:myevents/pages/front_page_one_naive.dart';
import 'package:myevents/pages/profile_page.dart';
import 'package:myevents/pages/support_page.dart';
import 'package:myevents/pojos/user_basic.dart';
import 'package:myevents/refactored_pages/menu_backpage.dart';
import 'package:myevents/refactored_pages/search_backpage.dart';
import 'package:provider/provider.dart';

const double _kFlingVelocity = 2.0;

enum BackdropModes { Menu, Search }
enum FrontPages { HomeSimple, Chats, HelpSupport, Logout }
FrontPages _currentFrontPage = FrontPages.HomeSimple;

class _FrontLayer extends StatelessWidget {
  const _FrontLayer({
    Key key,
    this.onTap,
    this.child,
  }) : super(key: key);

  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 16.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: Container(
              alignment: AlignmentDirectional.centerStart,
            ),
          ),
          Expanded(
            child: child,
          ),
        ],
      ),
    );
  }
}

class _BackdropTitle extends AnimatedWidget {
  final Function onPress;
  final Widget frontTitle;
  final Widget backTitle;

  const _BackdropTitle({
    Key key,
    Listenable listenable,
    this.onPress,
    @required this.frontTitle,
    @required this.backTitle,
  })  : assert(frontTitle != null),
        assert(backTitle != null),
        super(key: key, listenable: listenable);

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation = this.listenable;

    return DefaultTextStyle(
      style: Theme.of(context).primaryTextTheme.title,
      softWrap: false,
      overflow: TextOverflow.ellipsis,
      child: Row(children: <Widget>[
        Stack(
          children: <Widget>[
            Opacity(
              opacity: CurvedAnimation(
                parent: ReverseAnimation(animation),
                curve: Interval(0.5, 1.0),
              ).value,
              child: FractionalTranslation(
                translation: Tween<Offset>(
                  begin: Offset.zero,
                  end: Offset(0.5, 0.0),
                ).evaluate(animation),
                child: Semantics(
                    label: 'hide categories menu',
                    child: ExcludeSemantics(child: backTitle)),
              ),
            ),
            Opacity(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Interval(0.5, 1.0),
              ).value,
              child: FractionalTranslation(
                translation: Tween<Offset>(
                  begin: Offset(-0.25, 0.0),
                  end: Offset.zero,
                ).evaluate(animation),
                child: Semantics(
                    label: 'show categories menu',
                    child: ExcludeSemantics(child: frontTitle)),
              ),
            ),
          ],
        )
      ]),
    );
  }
}

/// Builds a Backdrop.
///
/// A Backdrop widget has two layers, front and back. The front layer is shown
/// by default, and slides down to show the back layer, from which a user
/// can make a selection. The user can also configure the titles for when the
/// front or back layer is showing.
class ShrineBackdrop extends StatefulWidget {
  final String currentCategory;

  final Widget backTitle;
  final VoidCallback updateFrontPageCallback;
  // final List<Widget> appBarActions;

  const ShrineBackdrop({
    @required this.currentCategory,
    @required this.backTitle,
    @required this.updateFrontPageCallback,
  })  : assert(currentCategory != null),
        assert(backTitle != null);

  @override
  _BackdropState createState() => _BackdropState();
}

class _BackdropState extends State<ShrineBackdrop>
    with SingleTickerProviderStateMixin {
  final GlobalKey _backdropKey = GlobalKey(debugLabel: 'Backdrop');
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 300),
      value: 1.0,
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(ShrineBackdrop old) {
    super.didUpdateWidget(old);

    if (widget.currentCategory != old.currentCategory) {
      _toggleBackdropLayerVisibility();
    } else if (!_frontLayerVisible) {
      _controller.fling(velocity: _kFlingVelocity);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _frontLayerVisible {
    final AnimationStatus status = _controller.status;
    return status == AnimationStatus.completed ||
        status == AnimationStatus.forward;
  }

  void _toggleBackdropLayerVisibility() {
    _controller.fling(
        velocity: _frontLayerVisible ? -_kFlingVelocity : _kFlingVelocity);
  }

  Widget _buildStack(BuildContext context, BoxConstraints constraints) {
    double layerTitleHeight =
        _backdropMode == BackdropModes.Search ? 60.0 : 280;
    final Size layerSize = constraints.biggest;
    final double layerTop = layerSize.height - layerTitleHeight;

    Animation<RelativeRect> layerAnimation = RelativeRectTween(
      begin: RelativeRect.fromLTRB(
          0.0, layerTop, 0.0, layerTop - layerSize.height),
      end: RelativeRect.fromLTRB(0.0, 0.0, 0.0, 0.0),
    ).animate(_controller.view);

    return Stack(
      key: _backdropKey,
      children: <Widget>[
        ExcludeSemantics(
          child: _backdropMode == BackdropModes.Menu
              ? MenuListPage(
                  backdropCallback: ([FrontPages frontPage]) {
                    print("FrontPage Updated To:  " + frontPage.toString());
                    _currentFrontPage = frontPage;
                    _toggleBackdropLayerVisibility();
                  },
                )
              : SearcListPage(backDropCallback: null),
          excluding: _frontLayerVisible,
        ),
        PositionedTransition(
          rect: layerAnimation,
          child: _FrontLayer(
            onTap: _toggleBackdropLayerVisibility,
            child: currentFrontPage(),
          ),
        ),
      ],
    );
  }

  Widget currentFrontPage() {
    if ((_currentFrontPage == FrontPages.HomeSimple))
      return FrontHome();
    else if (_currentFrontPage == FrontPages.Chats)
      return ChatList();
    else if (_currentFrontPage == FrontPages.HelpSupport)
      return SupportPage();
    else
      return Container();
  }

  BackdropModes _backdropMode = BackdropModes.Menu;

  @override
  Widget build(BuildContext context) {
    var appBar = AppBar(
        brightness: Brightness.light,
        elevation: 0.0,
        titleSpacing: 0.0,
        leading: IconButton(
            icon: AnimatedIcon(
              icon: AnimatedIcons.close_menu,
              progress: _controller,
            ),
            onPressed: () {
              _backdropMode = BackdropModes.Menu;
              _toggleBackdropLayerVisibility();
            }),
        title: _BackdropTitle(
          listenable: _controller.view,
          onPress: _toggleBackdropLayerVisibility,
          frontTitle: Container(width: 0, height: 0),
          backTitle: Container(width: 0, height: 0),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.account_circle, color: Colors.white),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfilePage(
                  userID: Provider.of<UserBasic>(context, listen: false).id,
                ),
              ),
            ),
          ),
          IconButton(
              icon: Icon(Icons.search, color: Colors.white),
              onPressed: () {
                _backdropMode = BackdropModes.Search;
                _toggleBackdropLayerVisibility();
              })
        ]);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: appBar,
      body: LayoutBuilder(
        builder: _buildStack,
      ),
    );
  }
}
