import 'dart:async';
import 'package:camcode/camcode_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'extensions.dart';

/// Camera barcode scanner widget
/// Asks for camera access permission
/// Shows camera images stream
/// Captures pictures every 'refreshDelayMillis'
/// Ask your favorite javascript library
/// to identify a barcode in the current picture
class CamCodeScanner extends StatefulWidget {
  // shows the current analysing picture
  final bool showDebugFrames;

  // shows the current part of the video feed being analysed for barcodes
  final bool showDebugOverlayAnalysisArea;

  // call back to trigger on barcode result
  final Function onBarcodeResult;

  // width dimension
  final double width;

  // height dimension
  final double height;

  // delay between to picture analysis
  final int refreshDelayMillis;

  // Flag to indicates if camcode should show an overlay on top of the cam view
  final bool showOverlay;

  // Flag to indicates if we want to look for Barcodes/QrCodes in the entire
  // camera video feed, or only inside the piece of image below the overlay
  // Meaning, it reduces the dimensions if the image used for barcode analysis
  final bool scanInsideOverlayOnly;

  // Color of the cam overlay
  final Color overlayColor;

  // Overrides the default width of the overlay
  final double overlayWidth;

  // Overrides the default height of the overlay
  final double overlayHeight;

  /// Camera barcode scanner widget
  /// Params:
  /// * showDebugFrames [true|false] - shows the current analysing picture
  /// * onBarcodeResult - call back to trigger on barcode result
  /// * width, height - dimensions
  /// * refreshDelayMillis - delay between to picture analysis
  CamCodeScanner({
    this.showDebugFrames = false,
    this.showDebugOverlayAnalysisArea = false,
    required this.onBarcodeResult,
    required this.width,
    required this.height,
    this.showOverlay = false,
    this.overlayColor = Colors.black,
    this.scanInsideOverlayOnly = false,
    this.overlayWidth = 400,
    this.overlayHeight = 240, // 240 is 400 * 0.6
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
  Widget? debugOverlayAnalysisArea;

  final _overlayKey = GlobalKey();
  final _overlayContainerKey = GlobalKey();

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

    if (SchedulerBinding.instance != null) {
      SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
        final bounds = _overlayKey.globalPaintBounds;

        if (bounds != null) {
          // Send the overlay size informations to the platform channel
          // for image analysis
          channel.invokeMethod('defineScanzone', [
            bounds.left,
            bounds.top,
            bounds.width,
            bounds.height,
          ]);

          if (widget.showDebugOverlayAnalysisArea) {
            setState(() {
              debugOverlayAnalysisArea = Positioned.fromRect(
                rect: bounds,
                child: Opacity(
                  opacity: 0.2,
                  child: Container(
                    width: bounds.width,
                    height: bounds.height,
                    color: Colors.black,
                  ),
                ),
              );
            });
          }
        }
      });
    }

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
            key: _overlayContainerKey,
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
                        height: 100,
                        width: 100,
                        child: _imageWidget,
                      ),
                if (widget.showOverlay)
                  Align(
                    alignment: Alignment.center,
                    child: CamcodeOverlayPaint(
                      key: _overlayKey,
                      overlayColor: widget.overlayColor,
                      width: widget.overlayWidth,
                      height: widget.overlayHeight,
                    ),
                  ),
                if (widget.showOverlay &&
                    widget.showDebugOverlayAnalysisArea &&
                    debugOverlayAnalysisArea != null)
                  debugOverlayAnalysisArea!,
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
