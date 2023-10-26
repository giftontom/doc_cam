// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:popup_menu_2/popup_menu_2.dart';

// This is the main application widget.
class DocCam extends StatefulWidget {
  // Default Constructor
  const DocCam({super.key});

  @override
  State<DocCam> createState() => _DocCamState();
}

class _DocCamState extends State<DocCam> {
  String _cameraInfo = 'Unknown'; // Stores camera information
  List<CameraDescription> _cameras = <CameraDescription>[];
  int _cameraIndex = 0;
  int _cameraId = -1;
  bool _initialized = false; // Indicates if the camera is initialized
  bool _recording = false; // Indicates if video recording is in progress
  bool _recordingTimed = false;
  bool _recordAudio = true; // Indicates if audio recording is enabled
  bool _previewPaused = false; // Indicates if the camera preview is paused
  Size? _previewSize; // Stores the size of the camera preview
  ResolutionPreset _resolutionPreset =
      ResolutionPreset.veryHigh; // Camera resolution preset
  StreamSubscription<CameraErrorEvent>?
      _errorStreamSubscription; // Subscription to camera error events
  StreamSubscription<CameraClosingEvent>?
      _cameraClosingStreamSubscription; // Subscription to camera closing events
  double brightnessLevel =
      50; // Initialize the brightness level to 50 (or your preferred initial value).
  bool _isMirrored = false; // Initial state: not mirrored
  bool _screenSize = false; // Initial state: not mirrored

double _brightnessLevel = 100.0; // Initial brightness level (0%)
double _maxBrightness = 100.0;  // Maximum brightness level (100%)
double _minBrightness = 0.0;   // Minimum brightness level (0%)

double _zoomLevel = 100.0; // Initial zoom level (100%)
double _maxZoom = 200.0;   // Maximum zoom level (200%)
double _minZoom = 100.0;   // Minimum zoom level (100%)
double _zoomStep = 10.0;   // Zoom step (10%)



void _zoomIn() {
  setState(() {
    if (_zoomLevel < _maxZoom) {
      _zoomLevel += _zoomStep; // Increase zoom by the zoom step
    }
  });
}

void _zoomOut() {
  setState(() {
    if (_zoomLevel > _minZoom) {
      _zoomLevel -= _zoomStep; // Decrease zoom by the zoom step
    }
  });
}



void _increaseBrightness() {
  setState(() {
    if (_brightnessLevel < _maxBrightness) {
      _brightnessLevel += 10.0; // Increase brightness by 10%
    }
  });
}

void _decreaseBrightness() {
  setState(() {
    if (_brightnessLevel > _minBrightness) {
      _brightnessLevel -= 10.0; // Decrease brightness by 10%
    }
  });
}


  void _toggleMirror() {
    setState(() {
      _isMirrored = !_isMirrored;
    });
  }

  void _toggleScreenSize() {
    setState(() {
      _screenSize = !_screenSize;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    _fetchCameras();
    _initializeCamera();
  }

  @override
  void dispose() {
    _disposeCurrentCamera();
    _errorStreamSubscription?.cancel();
    _errorStreamSubscription = null;
    _cameraClosingStreamSubscription?.cancel();
    _cameraClosingStreamSubscription = null;

    _initializeCamera();
    super.dispose();
  }

  double _cameraRotation = 0.0;

  double _counter = 0; // Counter used in the ContextualMenu
  GlobalKey key = GlobalKey(); // Key for the ContextualMenu
  void _rotateCameraVisuals() {
    setState(() {
      _cameraRotation += 90.0;
      // Ensure the rotation stays within 0 to 360 degrees
      _cameraRotation = _cameraRotation % 360;
    });
  }

  // Increment the counter
  void _incrementCounter() async {
    await Future.delayed(const Duration(milliseconds: 500));
    debugPrint('awaited successfully');

    setState(() {
      _counter++;
    });
  }

  // Decrement the counter
  void _decrementCounter() async {
    await Future.delayed(const Duration(milliseconds: 500));
    debugPrint('awaited successfully');
    setState(() {
      _counter--;
    });
  }

  // Fetches list of available cameras
  Future<void> _fetchCameras() async {
    String cameraInfo;
    List<CameraDescription> cameras = <CameraDescription>[];

    int cameraIndex = 0;
    try {
      cameras = await CameraPlatform.instance.availableCameras();
      if (cameras.isEmpty) {
        cameraInfo = 'No available cameras';
      } else {
        cameraIndex = _cameraIndex % cameras.length;
        cameraInfo = cameras[cameraIndex].name;
      }
    } on PlatformException catch (e) {
      cameraInfo = 'Failed to get cameras: ${e.code}: ${e.message}';
    }

    if (mounted) {
      setState(() {
        _cameraIndex = cameraIndex;
        _cameras = cameras;
        _cameraInfo = cameraInfo;
      });
    }
  }

  // Initializes the camera on the device
  Future<void> _initializeCamera() async {
    assert(!_initialized);

    if (_cameras.isEmpty) {
      return;
    }

    int cameraId = -1;
    try {
      final int cameraIndex = _cameraIndex % _cameras.length;
      final CameraDescription camera = _cameras[cameraIndex];

      cameraId = await CameraPlatform.instance.createCamera(
        camera,
        _resolutionPreset,
        enableAudio: _recordAudio,
      );

      unawaited(_errorStreamSubscription?.cancel());
      _errorStreamSubscription = CameraPlatform.instance
          .onCameraError(cameraId)
          .listen(_onCameraError);

      unawaited(_cameraClosingStreamSubscription?.cancel());
      _cameraClosingStreamSubscription = CameraPlatform.instance
          .onCameraClosing(cameraId)
          .listen(_onCameraClosing);

      final Future<CameraInitializedEvent> initialized =
          CameraPlatform.instance.onCameraInitialized(cameraId).first;

      await CameraPlatform.instance.initializeCamera(
        cameraId,
      );

      final CameraInitializedEvent event = await initialized;
      _previewSize = Size(
        event.previewWidth,
        event.previewHeight,
      );

      if (mounted) {
        setState(() {
          _initialized = true;
          _cameraId = cameraId;
          _cameraIndex = cameraIndex;
          _cameraInfo = ' ${camera.name}';
        });
      }
    } on CameraException catch (e) {
      try {
        if (cameraId >= 0) {
          await CameraPlatform.instance.dispose(cameraId);
        }
      } on CameraException catch (e) {
        debugPrint('Failed to dispose camera: ${e.code}: ${e.description}');
      }

      // Reset state.
      if (mounted) {
        setState(() {
          _initialized = false;
          _cameraId = -1;
          _cameraIndex = 0;
          _previewSize = null;
          _recording = false;
          _recordingTimed = false;
        });
      }
    }
  }

  // Dispose the currently active camera
  Future<void> _disposeCurrentCamera() async {
    if (_cameraId >= 0 && _initialized) {
      try {
        await CameraPlatform.instance.dispose(_cameraId);

        if (mounted) {
          setState(() {
            _initialized = false;
            _cameraId = -1;
            _previewSize = null;
            _recording = false;
            _recordingTimed = false;
            _previewPaused = false;
          });
        }
      } on CameraException catch (e) {
        if (mounted) {
          setState(() {
            _cameraInfo = ' ${e.code}: ${e.description}';
          });
        }
      }
    }
  }
  // Build the camera preview widget
  Widget _buildPreview() {
  final brightness = (_brightnessLevel / _maxBrightness).clamp(0.0, 1.0);
final zoomFactor = (_zoomLevel / 100.0).clamp(1.0, _maxZoom / 100.0);

  return ColorFiltered(
    colorFilter: ColorFilter.mode(
      Colors.white.withOpacity(brightness), // Adjust brightness here
      BlendMode.modulate, // Modify the blend mode as needed
    ),
    child: Transform.scale(
      scale:zoomFactor ,
      child: CameraPlatform.instance.buildPreview(_cameraId)),
  );
}
  
  // Take a picture using the camera
  Future<void> _takePicture() async {
    final XFile file = await CameraPlatform.instance.takePicture(_cameraId);
    _showInSnackBar('Picture captured to: ${file.path}');
  }

  // Toggle the camera preview pause
  Future<void> _togglePreview() async {
    if (_initialized && _cameraId >= 0) {
      if (!_previewPaused) {
        await CameraPlatform.instance.pausePreview(_cameraId);
      } else {
        await CameraPlatform.instance.resumePreview(_cameraId);
      }
      if (mounted) {
        setState(() {
          _previewPaused = !_previewPaused;
        });
      }
    }
  }

  // Switch between available cameras
  Future<void> _switchCamera() async {
    if (_cameras.isNotEmpty) {
      _cameraIndex = (_cameraIndex + 1) % _cameras.length;
      if (_initialized && _cameraId >= 0) {
        await _disposeCurrentCamera();
        await _fetchCameras();
        if (_cameras.isNotEmpty) {
          await _initializeCamera();
        }
      } else {
        await _fetchCameras();
      }
    }
  }

  // Handle changes in camera resolution
  Future<void> _onResolutionChange(ResolutionPreset newValue) async {
    setState(() {
      _resolutionPreset = newValue;
    });
    if (_initialized && _cameraId >= 0) {
      await _disposeCurrentCamera();
      await _initializeCamera();
    }
  }

  // Toggle audio recording
  Future<void> _onAudioChange(bool recordAudio) async {
    setState(() {
      _recordAudio = recordAudio;
    });
    if (_initialized && _cameraId >= 0) {
      await _disposeCurrentCamera();
      await _initializeCamera();
    }
  }

  // Handle camera error events
  void _onCameraError(CameraErrorEvent event) {
    if (mounted) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(content: Text('Error: ${event.description}')));

      // Dispose camera on camera error as it can not be used anymore.
      _disposeCurrentCamera();
      _fetchCameras();
    }
  }

  // Handle camera closing events
  void _onCameraClosing(CameraClosingEvent event) {
    if (mounted) {
      _showInSnackBar('Camera is closing');
    }
  }

  // Show a message in a snack bar
  void _showInSnackBar(String message) {
    _scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 1),
    ));
  }

  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    // Create a list of dropdown items for camera resolution presets
    final List<DropdownMenuItem<ResolutionPreset>> resolutionItems =
        ResolutionPreset.values
            .map<DropdownMenuItem<ResolutionPreset>>((ResolutionPreset value) {
      return DropdownMenuItem<ResolutionPreset>(
        value: value,
        child: Text(value.toString()),
      );
    }).toList();

    return MaterialApp(
      scaffoldMessengerKey: _scaffoldMessengerKey,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Stack(
          children: [
            ListView(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 10,
                  ),
                  child: Text(_cameraInfo),
                ),
                if (_cameras.isEmpty)
                  ElevatedButton(
                    onPressed: _fetchCameras,
                    child: const Text('Re-check available cameras'),
                  ),
                if (_cameras.isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      DropdownButton<ResolutionPreset>(
                        value: _resolutionPreset,
                        onChanged: (ResolutionPreset? value) {
                          if (value != null) {
                            _onResolutionChange(value);
                          }
                        },
                        items: resolutionItems,
                      ),
                      const SizedBox(width: 20),
                      const Text('Audio:'),
                      Switch(
                          value: _recordAudio,
                          onChanged: (bool state) => _onAudioChange(state)),
                      const SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: _initialized
                            ? _disposeCurrentCamera
                            : _initializeCamera,
                        child: Text(
                            _initialized ? 'Dispose camera' : 'Create camera'),
                      ),
                      const SizedBox(width: 5),
                      ElevatedButton(
                        onPressed: _initialized ? _takePicture : null,
                        child: const Text('Take picture'),
                      ),
                      const SizedBox(width: 5),
                      ElevatedButton(
                        onPressed: _initialized ? _togglePreview : null,
                        child: Text(
                          _previewPaused ? 'Resume preview' : 'Pause preview',
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: ContextualMenu(
                          targetWidgetKey: key,
                          ctx: context,
                          maxColumns: 1,
                          backgroundColor: Colors.red,
                          highlightColor: Colors.white,
                          onDismiss: () {
                            setState(() {
                              _counter = _counter * 1.2;
                            });
                          },
                          items: [
                            CustomPopupMenuItem(
                              press: _incrementCounter,
                              title: 'increment',
                              textAlign: TextAlign.justify,
                              textStyle: const TextStyle(color: Colors.black),
                              image: const Icon(Icons.add, color: Colors.black),
                            ),
                            CustomPopupMenuItem(
                              press: _decrementCounter,
                              title: 'decrement',
                              textAlign: TextAlign.justify,
                              textStyle: const TextStyle(color: Colors.black),
                              image:
                                  const Icon(Icons.remove, color: Colors.black),
                            ),
                          ],
                          child: Icon(
                            Icons.add,
                            key: key,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      // ElevatedButton(
                      //   onPressed: _initialized ? _toggleRecord : null,
                      //   child: Text(
                      //     (_recording || _recordingTimed)
                      //         ? 'Stop recording'
                      //         : 'Record Video',
                      //   ),
                      // ),
                      // const SizedBox(width: 5),
                      // ElevatedButton(
                      //   onPressed: (_initialized && !_recording && !_recordingTimed)
                      //       ? () => _recordTimed(5)
                      //       : null,
                      //   child: const Text(
                      //     'Record 5 seconds',
                      //   ),
                      // ),
                      ElevatedButton(
                        onPressed: () {
                          _showBrightnessPopup();
                        },
                        child: const Text("Brightness"),
                      ),
                      if (_cameras.length > 1) ...<Widget>[
                        const SizedBox(width: 5),
                        ElevatedButton(
                          onPressed: _switchCamera,
                          child: const Text(
                            'Switch camera',
                          ),
                        ),
                      ]
                    ],
                  ),
                const SizedBox(height: 5),
                if (_initialized && _cameraId > 0 && _previewSize != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                    ),
                    child: Align(
                      child: Container(
                        constraints: const BoxConstraints(
                          maxHeight: 500,
                        ),
                        child: AspectRatio(
                          aspectRatio:
                              _previewSize!.width / _previewSize!.height,
                          // child: _buildPreview(),
                        ),
                      ),
                    ),
                  ),
                if (_previewSize != null)
                  Center(
                    child: Text(
                      'Preview size: ${_previewSize!.width.toStringAsFixed(0)}x${_previewSize!.height.toStringAsFixed(0)}',
                    ),
                  ),
              ],
            ),

//Klass-Education Widget<--------------------------------------------------------------->
            Positioned(
                left: 100,
                top: 100,
                child: Container(
                  width: _screenSize ? 600 : 400,
                  // (_cameraRotation== 90||_cameraRotation == 270)?
                  height: _screenSize ? 450 : 337,
                  decoration: ShapeDecoration(
                    color: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                    shadows: [
                      const BoxShadow(
                        color: Color(0x2B000000),
                        blurRadius: 8,
                        offset: Offset(15, 15),
                        spreadRadius: -5,
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      //<------------------------------------------------<Row 1>---------------------->
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              onTap: () {
                                _initializeCamera();
                                _switchCamera();
                              },
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 150,
                                    child: Text(
                                      _cameraInfo,
                                      maxLines: 1,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.w500,
                                        height: 0,
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_drop_down,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            Container(
                              width: 18,
                              height: 18,
                              decoration: const ShapeDecoration(
                                color: Color(0xFF656565),
                                shape: OvalBorder(),
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.black,
                                size: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                      //<------------------------------------------------<Row 2>---------------------->
                      Expanded(
  child: Stack(
    children: [
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        constraints: const BoxConstraints(
          // maxHeight: 500,
        ),
        // decoration: ShapeDecoration(
        //   color: const Color(0xFFD9D9D9),
        //   shape: RoundedRectangleBorder(
        //     borderRadius: BorderRadius.circular(7),
        //   ),
        // ),
        child: Center(
          child: ClipRect(
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()..scale(_isMirrored ? -1.0 : 1.0, 1.0),
              child: Transform.rotate(
                angle: _cameraRotation * (3.14159265359 / 180),
                child: _buildPreview(),
              ),
            ),
          ),
        ),
      ),
      Positioned(
        right: 25,
        bottom: 5,
        child: Container(
          width: 35,
          height: 35,
          decoration: const ShapeDecoration(
            color: Color(0xFF656565),
            shape: OvalBorder(),
          ),
          child: Center(
            child: IconButton(
              onPressed: _toggleScreenSize,
              icon: const Icon(
                Icons.fullscreen_sharp,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ),
      )
    ],
  ),
),

                      //<------------------------------------------------<Row 3>---------------------->
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              onPressed: _toggleMirror,
                              icon: const Icon(
                                Icons.flip,
                                color: Colors.white,
                              ),
                            ),
                            IconButton(
                              onPressed: _rotateCameraVisuals,
                              icon: const Icon(
                                Icons.rotate_left,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(
                              height: 40,
                              child: VerticalDivider(
                                color: Colors.white,
                                width: 5,
                                thickness: 1,
                                indent: 10,
                                endIndent: 10,
                              ),
                            ),
                            IconButton(
                              onPressed: _initialized ? _togglePreview : null,
                              icon: const Icon(
                                Icons.severe_cold,
                                color: Colors.white,
                              ),
                            ),
                            IconButton(
                              onPressed: _initialized ? _takePicture : null,
                              icon: const Icon(
                                Icons.camera_outlined,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(
                              height: 40,
                              child: VerticalDivider(
                                color: Colors.white,
                                width: 5,
                                thickness: 1,
                                indent: 10,
                                endIndent: 10,
                              ),
                            ),
                            Row(
                              children: [
                                SpeedDial(
                                  icon: Icons.brightness_6_outlined,
                                  iconTheme:
                                      const IconThemeData(color: Colors.white),
                                  backgroundColor: Colors.black,
                                  visible: true,
                                  overlayOpacity: 0,
                                  // renderOverlay: false,
                                  closeManually: true,
                                  curve: Curves.bounceInOut,
                                  buttonSize: Size(50.00, 50.00),
                                  childrenButtonSize: const Size(50, 100),
                                  spaceBetweenChildren: 0,
                                  spacing: 0,
                                  childPadding: EdgeInsets.all(0),
                                  childMargin: EdgeInsets.all(0),
                                  closeDialOnPop: false,
                                  elevation: 0,
                                  children: [
                                    SpeedDialChild(
                                      backgroundColor: Colors.white,
                                      child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            IconButton(
                                              onPressed: _increaseBrightness,
                                              icon: const Icon(
                                                Icons.add_circle_outline,
                                                color: Colors.black,
                                              ),
                                            ),
                                            Text(" ${_brightnessLevel.toInt()}%"),
                                            IconButton(
                                              onPressed: _decreaseBrightness,
                                              icon: const Icon(
                                                Icons.remove_circle_outline,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ]),
                                      onTap: null,
                                      shape: const StadiumBorder(),
                                    ),
                                  ],
                                ),
                                  SpeedDial(
                                  child: Icon(Icons.zoom_in,color: Colors.white,),
                                  iconTheme:
                                      const IconThemeData(color: Colors.white),
                                  backgroundColor: Colors.black,
                                  visible: true,
                                  overlayOpacity: 0,
                                  // renderOverlay: false,
                                  closeManually: true,
                                  curve: Curves.bounceInOut,
                                  buttonSize: Size(50.00, 50.00),
                                  childrenButtonSize: const Size(50, 100),
                                  
                                  spaceBetweenChildren: 0,
                                  spacing: 0,
                                  childPadding: EdgeInsets.all(0),
                                  childMargin: EdgeInsets.all(0),
                                  elevation: 0,
                                  children: [
                                    SpeedDialChild(
                                      backgroundColor: Colors.white,
                                      child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            IconButton(
                                              onPressed: _zoomIn,
                                              icon: const Icon(
                                                Icons.zoom_in,
                                                color: Colors.black,
                                              ),
                                            ),
                                            Text("${_zoomLevel.toInt()}%"),
                                            IconButton(
                                              onPressed: _zoomOut,
                                              icon: const Icon(
                                                Icons.zoom_out,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ]),
                                      onTap: null,
                                      shape: const StadiumBorder(),
                                    ),
                                  ],
                                                            ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ))

//Klass-Education Widget<--------------------------------------------------->
          ],
        ),
      ),
    );
  }

  void _showBrightnessPopup() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Adjust Brightness'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      setState(() {
                        brightnessLevel -= 10;
                      });
                    },
                  ),
                  Text('Brightness: $brightnessLevel'),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      setState(() {
                        brightnessLevel += 10;
                      });
                    },
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }
}
