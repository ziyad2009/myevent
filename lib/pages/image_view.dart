import 'package:flutter/material.dart';
import 'package:myevents/pojos/upload.dart';
import 'package:myevents/widgets/dost_indicator.dart';

class ImageView extends StatefulWidget {
  final List<UploadResponse> imagesList;
  final int startPosition;
  static const _kDuration = const Duration(milliseconds: 300);
  static const _kCurve = Curves.ease;

  ImageView({this.imagesList, this.startPosition});

  @override
  _ImageViewState createState() => _ImageViewState();
}

class _ImageViewState extends State<ImageView> {
  PageController _controller;

  Widget imageViewerPages() {
    return Stack(
      children: <Widget>[
        new PageView.builder(
          onPageChanged: (int page) {
            // if (page == widget.imagesList.length) {
            //   _controller.animateToPage(
            //     0,
            //     duration: ImageView._kDuration,
            //     curve: ImageView._kCurve,
            //   );
            // }
          },
          physics: new AlwaysScrollableScrollPhysics(),
          controller: _controller,
          itemCount: widget.imagesList.length,
          itemBuilder: (BuildContext context, int index) {
            // return _pages[index % _pages.length];
            return Image.network(
              widget.imagesList.elementAt(index).url,
              fit: BoxFit.contain,
              height: double.infinity,
              width: double.infinity,
              alignment: Alignment.center,
            );
          },
        ),
        new Positioned(
          bottom: 0.0,
          left: 0.0,
          right: 0.0,
          child: new Container(
            color: Colors.grey[800].withOpacity(0.0),
            padding: const EdgeInsets.all(20.0),
            child: new Center(
              child: new DotsIndicator(
                controller: _controller,
                itemCount: widget.imagesList.length,
                onPageSelected: (int page) {
                  _controller.animateToPage(
                    page,
                    duration: ImageView._kDuration,
                    curve: ImageView._kCurve,
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    _controller = PageController(initialPage: widget.startPosition);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      // body: new Image.network(
      //   "https://cdn.pixabay.com/photo/2017/02/21/21/13/unicorn-2087450_1280.png",
      //   fit: BoxFit.cover,
      //   height: double.infinity,
      //   width: double.infinity,
      //   alignment: Alignment.center,
      // ),
      body: widget.imagesList.isEmpty
          ? Center(
              child: Text("No images found"),
            )
          : imageViewerPages(),
    );
  }
}
