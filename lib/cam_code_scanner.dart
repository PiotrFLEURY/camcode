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
  // shows the current analysing picture
  final bool showDebugFrames;

  // call back to trigger on barcode result
  final Function onBarcodeResult;

  // width dimension
  final double width;

  // height dimension
  final double height;

  // delay between to picture analysis
  final int refreshDelayMillis;

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
  });

  @override
  _CamCodeScannerState createState() => _CamCodeScannerState();
}

class _CamCodeScannerState extends State<CamCodeScanner> {
  // communication channel between widget and platform code
  final MethodChannel channel = MethodChannel('camcode');
  // Webcam widget to insert into the tree
  late Widget _webcamWidget;
  // Debug frame Image widget to insert into the tree
  late Widget _imageWidget;
  // The barcode result
  String barcode = '';
  // Used to know if camera is loading or initialized
  bool initialized = false;

  @override
  void initState() {
    super.initState();

    initialize();
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
    _webcamWidget =
        HtmlElementView(key: UniqueKey(), viewType: 'webcamVideoElement$time');

    _imageWidget = HtmlElementView(viewType: 'imageElement');

    setState(() {
      initialized = true;
    });

    _waitForResult();
  }

  /// Waits for the platform completer result
  void _waitForResult() {
    channel.invokeMethod<String>('fetchResult').then((barcode) {
      if (barcode != null) {
        onBarcodeResult(barcode);
      }
    });
  }

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
            child: Stack(
              children: <Widget>[
                initialized
                    ? SizedBox(
                        width: widget.width,
                        height: widget.height,
                        child: _webcamWidget,
                      )
                    : CircularProgressIndicator(),
                !widget.showDebugFrames
                    ? Container()
                    : SizedBox(
                        width: 100,
                        height: 100,
                        child: _imageWidget,
                      ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(barcode),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
