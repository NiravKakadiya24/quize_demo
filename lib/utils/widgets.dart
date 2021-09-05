import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:video_player/video_player.dart';

Widget textButton({onTapFunction, buttonName, context}) {
  return TextButton(
    style: ButtonStyle(
      backgroundColor: MaterialStateProperty.all(
        Theme.of(context).primaryColor,
      ),
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(1.5.h),
        ),
      ),
    ),
    onPressed: () => onTapFunction(),
    child: Text(
      buttonName,
      style: TextStyle(
        color: Colors.black,
      ),
    ),
  );
}

buildDialog(
    {required BuildContext context,
    required String title,
    required String content,
    required VoidCallback okTapFunction}) {
  Widget okButton = TextButton(
    child: Text("OK",
        style: TextStyle(
          color: Colors.black,
          decorationColor: Colors.black,
        )),
    onPressed: () => okTapFunction(),
  );
  Widget cancelButton = TextButton(
    child: Text("Cancel",
        style: TextStyle(
          color: Colors.black,
          decorationColor: Colors.black,
        )),
    onPressed: () => Navigator.pop(context),
  );

  // set up the AlertDialog

  if (Platform.isAndroid) {
    AlertDialog alert = AlertDialog(
      title: Text(title,
          style: TextStyle(
            color: Colors.black,
            decorationColor: Colors.black,
          )),
      content: Text(content,
          style: TextStyle(
            color: Colors.black,
            decorationColor: Colors.black,
          )),
      actions: [
        okButton,
        cancelButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
  if (Platform.isIOS) {
    CupertinoAlertDialog cupertinoAlertDialog = CupertinoAlertDialog(
      title: Text(title,
          style: TextStyle(
            color: Colors.black,
            decorationColor: Colors.black,
          )),
      content: Text(content,
          style: TextStyle(
            color: Colors.black,
            decorationColor: Colors.black,
          )),
      actions: [
        okButton,
        cancelButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return cupertinoAlertDialog;
      },
    );
  }
  // show the dialog
}

class CameraPreview1 extends StatefulWidget {
  final String videoPath;

  CameraPreview1({
    Key? key,
    required this.videoPath,
  }) : super(key: key);

  @override
  _CameraPreview1State createState() => _CameraPreview1State();
}

class _CameraPreview1State extends State<CameraPreview1> {
  late VideoPlayerController _videoPlayerController;

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) {
        setState(() {});
        _videoPlayerController.play();
      });
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video preview'),
      ),
      body: Center(
        child: _videoPlayerController.value.isInitialized
            ? AspectRatio(
                aspectRatio: _videoPlayerController.value.aspectRatio,
                child: VideoPlayer(_videoPlayerController),
              )
            : Container(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _videoPlayerController.value.isPlaying
                ? _videoPlayerController.pause()
                : _videoPlayerController.play();
          });
        },
        child: Icon(
          _videoPlayerController.value.isPlaying
              ? Icons.pause
              : Icons.play_arrow,
        ),
      ),
    );
  }
}
