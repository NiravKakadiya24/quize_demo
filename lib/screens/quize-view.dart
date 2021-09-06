import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:demo_projects/main.dart';
import 'package:demo_projects/utils/comman-screen.dart';
import 'package:demo_projects/utils/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:im_stepper/stepper.dart';
import 'package:sizer/sizer.dart';
import 'package:video_player/video_player.dart';

class QuizViewScreen extends StatefulWidget {
  const QuizViewScreen({Key? key}) : super(key: key);

  @override
  _QuizViewScreenState createState() => _QuizViewScreenState();
}

class _QuizViewScreenState extends State<QuizViewScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  int activeStep = 0; // Initial step set to 5.

  int upperBound = 4;

  List<String> questionsList = [
    'What is Flutter?',
    'Should I learn Dart for Flutter?',
    'Is Flutter Free?',
    'What are the Flutter widgets?',
    'What do you understand by the Stateful and Stateless widgets?',
  ];

  String nextButtonName = 'Next';

  CameraController? controller;
  XFile? imageFile;
  XFile? videoFile;
  VoidCallback? videoPlayerListener;
  bool enableAudio = true;
  double _minAvailableExposureOffset = 0.0;
  double _maxAvailableExposureOffset = 0.0;
  double _currentExposureOffset = 0.0;
  late AnimationController _flashModeControlRowAnimationController;
  late Animation<double> _flashModeControlRowAnimation;
  late AnimationController _exposureModeControlRowAnimationController;
  late Animation<double> _exposureModeControlRowAnimation;
  late AnimationController _focusModeControlRowAnimationController;
  late Animation<double> _focusModeControlRowAnimation;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _currentScale = 1.0;
  double _baseScale = 1.0;

  // Counting pointers (number of user fingers on screen)
  int _pointers = 0;

  int delayTime = 3;

  bool isOnceRecorded = false;
  late VideoPlayerController _controller;

  @override
  void initState() {
    _controller = VideoPlayerController.network(
        'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4')
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
    super.initState();
    _ambiguate(WidgetsBinding.instance)?.addObserver(this);

    _flashModeControlRowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _flashModeControlRowAnimation = CurvedAnimation(
      parent: _flashModeControlRowAnimationController,
      curve: Curves.easeInCubic,
    );
    _exposureModeControlRowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _exposureModeControlRowAnimation = CurvedAnimation(
      parent: _exposureModeControlRowAnimationController,
      curve: Curves.easeInCubic,
    );
    _focusModeControlRowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _focusModeControlRowAnimation = CurvedAnimation(
      parent: _focusModeControlRowAnimationController,
      curve: Curves.easeInCubic,
    );
    if (cameras.isNotEmpty) {
      onNewCameraSelected(cameras[1]);
    }
  }

  @override
  void dispose() {
    _ambiguate(WidgetsBinding.instance)?.removeObserver(this);
    _flashModeControlRowAnimationController.dispose();
    _exposureModeControlRowAnimationController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      onNewCameraSelected(cameraController.description);
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return commanScreen(
      screenTitle: '',
      context: context,
      body: Container(
        child: Column(
          children: [
            SingleChildScrollView(
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      alignment: Alignment.center,
                      child: Text(
                        questionsList[activeStep],
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Stack(
                      children: [
                        Container(
                          color: Colors.black,
                          child: Center(
                            child: Container(
                              height: 300,
                              child: _cameraPreviewWidget(),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: delayTime != -1,
                          child: Container(
                            alignment: Alignment.center,
                            height: 300,
                            child: delayTime == 0
                                ? Container(
                                    child: Icon(
                                      Icons.cancel,
                                      size: 20.h,
                                    ),
                                  )
                                : Text(
                                    delayTime.toString(),
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 80.sp),
                                  ),
                          ),
                        ),
                        Visibility(
                          visible: _controller.value.isPlaying,
                          child: Container(
                              alignment: Alignment.center,
                              height: 300,
                              child: AspectRatio(
                                aspectRatio: _controller.value.aspectRatio,
                                child: VideoPlayer(_controller),
                              )),
                        )
                      ],
                    ),
                    Container(
                      alignment: Alignment.center,
                      child: textButton(
                        context: context,
                        buttonName: controller?.value.isRecordingVideo ?? false
                            ? 'Stop Recording'
                            : 'Start Recording',
                        onTapFunction: () {
                          if (!controller!.value.isRecordingVideo) {
                            isOnceRecorded = false;

                            delayTime = 3;
                          }
                          new Timer.periodic(
                            Duration(seconds: 1),
                            (Timer timer) {
                              if (delayTime == -1) {
                                setState(() {
                                  timer.cancel();
                                });
                                if (!controller!.value.isRecordingVideo) {
                                  onVideoRecordButtonPressed();
                                } else {
                                  onStopButtonPressed();
                                }
                              } else {
                                setState(() {
                                  delayTime--;
                                });
                              }
                            },
                          );
                        },
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      child: textButton(
                          context: context,
                          buttonName: nextButtonName,
                          onTapFunction: () {
                            if (activeStep < 4) {
                              buildDialog(
                                context: context,
                                okTapFunction: () {
                                  isOnceRecorded = false;
                                  delayTime = 3;

                                  Navigator.pop(context);
                                  activeStep++;
                                  if (activeStep == 4) {
                                    nextButtonName = 'Submit';
                                  }
                                  setState(() {});
                                },
                                content:
                                    'Are You Sure? \n You won\'t be able to go back',
                                title: '',
                              );
                            }
                          }),
                    ),
                    Visibility(
                      visible: isOnceRecorded,
                      child: Container(
                        alignment: Alignment.center,
                        child: textButton(
                            context: context,
                            buttonName:
                                _controller.value.isPlaying ? 'Stop' : 'Play',
                            onTapFunction: () {
                              if (_controller.value.isPlaying) {
                                _controller.pause();
                              } else {
                                _controller = VideoPlayerController.file(
                                    File(videoFile!.path))
                                  ..initialize().then((_) {
                                    _controller.play();
                                    _controller.setLooping(true);

                                    // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
                                    setState(() {});
                                  }).catchError((onError) {
                                    print('oasdjojd' + onError.toString());
                                  });
                              }

                              setState(() {});
                            }),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconStepper(
                            enableNextPreviousButtons: false,
                            steppingEnabled: false,
                            enableStepTapping: false,

                            icons: [
                              Icon(
                                Icons.add_circle,
                                color: Colors.white,
                              ),
                              Icon(Icons.flag),
                              Icon(Icons.access_alarm),
                              Icon(Icons.supervised_user_circle),
                              Icon(Icons.flag),
                            ],

                            // activeStep property set to activeStep variable defined above.
                            activeStep: activeStep,

                            // This ensures step-tapping updates the activeStep.
                            onStepReached: (index) {
                              setState(() {
                                activeStep = index;
                              });
                            },
                          ),
                          header(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData getCameraLensIcon(CameraLensDirection direction) {
    switch (direction) {
      case CameraLensDirection.back:
        return Icons.camera_rear;
      case CameraLensDirection.front:
        return Icons.camera_front;
      case CameraLensDirection.external:
        return Icons.camera;
      default:
        throw ArgumentError('Unknown lens direction');
    }
  }

  Widget _cameraPreviewWidget() {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return const Text(
        'Tap a camera',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24.0,
          fontWeight: FontWeight.w900,
        ),
      );
    } else {
      return Listener(
        onPointerDown: (_) => _pointers++,
        onPointerUp: (_) => _pointers--,
        child: CameraPreview(
          controller!,
          child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onScaleStart: _handleScaleStart,
              onScaleUpdate: _handleScaleUpdate,
              onTapDown: (details) => onViewFinderTap(details, constraints),
            );
          }),
        ),
      );
    }
  }

  void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    if (controller == null) {
      return;
    }

    final CameraController cameraController = controller!;

    final offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    cameraController.setExposurePoint(offset);
    cameraController.setFocusPoint(offset);
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _baseScale = _currentScale;
  }

  Future<void> _handleScaleUpdate(ScaleUpdateDetails details) async {
    // When there are not exactly two fingers on screen don't scale
    if (controller == null || _pointers != 2) {
      return;
    }

    _currentScale = (_baseScale * details.scale)
        .clamp(_minAvailableZoom, _maxAvailableZoom);

    await controller!.setZoomLevel(_currentScale);
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller!.dispose();
    }

    final CameraController cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.medium,
      enableAudio: enableAudio,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    controller = cameraController;

    // If the controller is updated then update the UI.
    cameraController.addListener(() {
      if (mounted) setState(() {});
      if (cameraController.value.hasError) {
        showInSnackBar(
            'Camera error ${cameraController.value.errorDescription}');
      }
    });

    try {
      await cameraController.initialize();
      await Future.wait([
        cameraController
            .getMinExposureOffset()
            .then((value) => _minAvailableExposureOffset = value),
        cameraController
            .getMaxExposureOffset()
            .then((value) => _maxAvailableExposureOffset = value),
        cameraController
            .getMaxZoomLevel()
            .then((value) => _maxAvailableZoom = value),
        cameraController
            .getMinZoomLevel()
            .then((value) => _minAvailableZoom = value),
      ]);
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  void onVideoRecordButtonPressed() {
    startVideoRecording().then((_) {
      print('started');
      if (mounted) setState(() {});
    });
  }

  void onStopButtonPressed() {
    stopVideoRecording().then((file) {
      if (file != null) {
        print('Video recorded to ${file.path}');
        videoFile = file;
        isOnceRecorded = true;
      }
    }).catchError((onError) {
      print('Error' + onError.toString());
    });
  }

  Future<void> startVideoRecording() async {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return;
    }

    if (cameraController.value.isRecordingVideo) {
      // A recording is already started, do nothing.
      return;
    }

    try {
      await cameraController.startVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      return;
    }
  }

  Future<XFile?> stopVideoRecording() async {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isRecordingVideo) {
      return null;
    }

    try {
      return cameraController.stopVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
  }

  void _showCameraException(CameraException e) {
    logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  void showInSnackBar(String message) {
    // ignore: deprecated_member_use
    _scaffoldKey.currentState?.showSnackBar(SnackBar(content: Text(message)));
  }

  Widget header() {
    return Container(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Question ${activeStep + 1}',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '3min',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void logError(String code, String? message) {
    if (message != null) {
      print('Error: $code\nError Message: $message');
    } else {
      print('Error: $code');
    }
  }
}

T? _ambiguate<T>(T? value) => value;
