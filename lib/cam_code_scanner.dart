import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Camera barcode scanner widget
/// Asks for camera access permission
/// Shows camera images stream
/// Captures pictures every 'refreshDelayMillis'
/// Ask your favorite javascript library
/// to identify a barcode in the current picture
class CamCodeScanner extends StatefulWidget {
  /// shows the current analysing picture
  final bool showDebugFrames;

  /// call back to trigger on barcode result
  final Function onBarcodeResult;

  /// width dimension
  final double width;

  /// height dimension
  final double height;

  /// delay between to picture analysis
  final int refreshDelayMillis;

  /// controller to control the camera from outside
  final CamCodeScannerController? controller;

  /// Camera barcode scanner widget
  /// Params:
  /// * showDebugFrames [true|false] - shows the current analysing picture
  /// * onBarcodeResult - call back to trigger on barcode result
  /// * width, height - dimensions
  /// * refreshDelayMillis - delay between to picture analysis
  CamCodeScanner({
    this.showDebugFrames = false,
    required this.onBarcodeResult,
    required this.width,
    required this.height,
    this.refreshDelayMillis = 400,
    this.controller,
  });

  @override
  _CamCodeScannerState createState() => _CamCodeScannerState();
}

class _CamCodeScannerState extends State<CamCodeScanner> {
  /// communication channel between widget and platform code
  final MethodChannel channel = MethodChannel('camcode');

  /// Webcam widget to insert into the tree
  late Widget _webcamWidget;

  /// Debug frame Image widget to insert into the tree
  //late Widget _imageWidget;

  /// The barcode result
  String barcode = '';

  /// Used to know if camera is loading or initialized
  bool initialized = false;

  @override
  void initState() {
    super.initState();

    initialize();
  }

  @override
  void dispose() {
    channel.invokeMethod(
      'releaseResources',
    );
    super.dispose();
  }

  /// Calls the platform initialization and wait for result
  Future<void> initialize() async {
    final time = await channel.invokeMethod(
      'initialize',
      [
        widget.width,
        widget.height,
        widget.refreshDelayMillis,
      ],
    );

    // Create video widget
    _webcamWidget = HtmlElementView(
      key: UniqueKey(),
      viewType: 'webcamVideoElement$time',
    );

    //_imageWidget = HtmlElementView(
    //  viewType: 'imageElement',
    //);

    // Set the initialized flag
    setState(() {
      initialized = true;
    });

    _waitForResult();
    widget.controller?._channelCompleter.complete(channel);
  }

  /// Waits for the platform completer result
  void _waitForResult() {
    channel.invokeMethod<String>('fetchResult').then((barcode) {
      if (barcode != null) {
        onBarcodeResult(barcode);
      }
    });
  }

  /// Method called when a barcode is detected
  Future<void> onBarcodeResult(String _barcode) async {
    setState(() {
      barcode = _barcode;
    });
    widget.onBarcodeResult(barcode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: () async {
          await channel.invokeMethod('releaseResources');
          return true;
        },
        child: Builder(
          builder: (context) => Center(
            child: initialized
                ? Stack(
                    children: <Widget>[
                      SizedBox(
                        width: widget.width,
                        height: widget.height,
                        child: _webcamWidget,
                      ),
                      // if (widget.showDebugFrames)
                      //   Container(
                      //     width: widget.width,
                      //     height: widget.height,
                      //     color: Colors.black.withOpacity(0.8),
                      //     child: Text(''),
                      //   ),
                      // Positioned(
                      //   top: (widget.height / 2) - (widget.height * .1),
                      //   left: (widget.width * .1),
                      //   child: Container(
                      //     decoration: BoxDecoration(
                      //       border: Border.all(
                      //         color: Colors.green,
                      //         width: 1,
                      //       ),
                      //     ),
                      //     child: SizedBox(
                      //       width: widget.width * .8,
                      //       height: widget.height * .2,
                      //       child: widget.showDebugFrames
                      //           ? _imageWidget
                      //           : Container(),
                      //     ),
                      //   ),
                      // ),
                      //Center(
                      //  child: CustomPaint(
                      //    size: Size(
                      //      widget.width * .5,
                      //      widget.height * .2,
                      //    ),
                      //    painter: _ScannerLine(
                      //      color: Colors.red,
                      //    ),
                      //  ),
                      //),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(barcode),
                        ),
                      ),
                    ],
                  )
                : CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}

/// Custom painter to draw the scanner line
class ScannerLine extends CustomPainter {
  /// Color of the line
  final Color color;

  ScannerLine({
    this.color = Colors.white,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

/// Controller to control the camera from outside
class CamCodeScannerController {
  /// Channel to communicate with the platform code
  final Completer<MethodChannel> _channelCompleter = Completer();

  /// Invoke this method to close the camera and release all resources
  Future<void> releaseResources() async {
    final _channel = await _channelCompleter.future;
    return _channel.invokeMethod(
      'releaseResources',
    );
  }

  /// Waits for the device list completer result
  Future<List<String>> fetchDeviceList() async {
    final _channel = await _channelCompleter.future;
    final devices =
        await _channel.invokeMethod<List<dynamic>?>('fetchDeviceList');
    return devices?.map((e) => e.toString()).toList() ?? [];
  }

  /// Selects the device with the given device name
  Future<void> selectDevice(String device) async {
    final _channel = await _channelCompleter.future;
    return _channel.invokeMethod(
      'selectDevice',
      device,
    );
  }
}
