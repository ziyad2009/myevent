import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPreviewWidget extends StatefulWidget {
  final DataSourceType dataSourceType;
  final File localFile;
  final String networkFileUrl;
  final Function removeVideoCallback;

  const VideoPreviewWidget(
      {Key key,
      this.localFile,
      this.dataSourceType,
      this.networkFileUrl,
      this.removeVideoCallback})
      : super(key: key);
  @override
  _VideoPreviewWidgetState createState() => _VideoPreviewWidgetState();
}

class _VideoPreviewWidgetState extends State<VideoPreviewWidget> {
  VideoPlayerController _controller;
  @override
  void initState() {
    super.initState();
    if (widget.dataSourceType == DataSourceType.file) {
      _controller = VideoPlayerController.file(widget.localFile);
      _controller.setLooping(false);
      _controller.initialize().then((_) => setState(() {}));
    } else {
      _controller = VideoPlayerController.network(widget.networkFileUrl);
      _controller.setLooping(false);
      _controller.initialize().then((_) => setState(() {}));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      child: AspectRatio(
        aspectRatio: _controller.value.aspectRatio,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            VideoPlayer(_controller),
            _PlayPauseOverlay(controller: _controller),
            VideoProgressIndicator(_controller, allowScrubbing: true),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: GestureDetector(
                onTap: () => widget.removeVideoCallback(),
                child: Align(
                  alignment: Alignment.topRight,
                  child: Icon(Icons.remove_circle, color: Colors.red, size: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayPauseOverlay extends StatelessWidget {
  const _PlayPauseOverlay({Key key, this.controller}) : super(key: key);

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: Duration(milliseconds: 50),
          reverseDuration: Duration(milliseconds: 200),
          child: Visibility(
            visible: !controller.value.isPlaying,
            child: Container(
              color: Colors.black26,
              child: Center(
                child: Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 24.0,
                ),
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            controller.value.isPlaying ? controller.pause() : controller.play();
          },
        ),
      ],
    );
  }
}
