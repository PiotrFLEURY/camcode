import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CamCodeScanner extends StatefulWidget {
  final bool showDebugFrames;
  final Function onBarcodeResult;
  final double width;
  final double height;
  final int refreshDelayMillis;

  CamCodeScanner({
    this.showDebugFrames = false,
    @required this.onBarcodeResult,
    @required this.width,
    @required this.height,
    this.refreshDelayMillis = 400,
  });

  @override
  _CamCodeScannerState createState() => _CamCodeScannerState();
}

class _CamCodeScannerState extends State<CamCodeScanner> {
  final MethodChannel channel = MethodChannel('camcode');
  // Webcam widget to insert into the tree
  Widget _webcamWidget;
  Widget _imageWidget;

  String barcode;

  bool initialized = false;

  @override
  void initState() {
    super.initState();

    initialize();
  }

  Future<void> initialize() async {
    int time = await channel.invokeMethod(
      "initialize",
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

  Future<void> _waitForResult() async {
    channel
        .invokeMethod("fetchResult")
        .then((barcode) => onBarcodeResult(barcode));
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
          channel.invokeMethod('releaseResources');
          return true;
        },
        child: Builder(
          builder: (context) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                initialized
                    ? SizedBox(
                        width: widget.width,
                        height: widget.height,
                        child: _webcamWidget,
                      )
                    : Text("loading camera..."),
                !widget.showDebugFrames
                    ? Container()
                    : SizedBox(
                        width: 100,
                        height: 100,
                        child: _imageWidget,
                      ),
                barcode == null ? Text("Scanning barcode...") : Text(barcode),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
