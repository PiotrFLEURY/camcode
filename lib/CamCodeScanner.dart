import 'dart:async';
import 'dart:html';
import 'dart:js';
// ignore: avoid_web_libraries_in_flutter
import 'dart:ui' as ui;
import 'package:camcode/quagga.dart';
import 'package:flutter/material.dart';

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
  // Webcam widget to insert into the tree
  Widget _webcamWidget;
  Widget _imageWidget;
  // VideoElement
  VideoElement _webcamVideoElement;
  // ImageElement
  ImageElement imageElement;

  ImageData image;

  Timer _timer;

  String barcode;

  bool gotResult = false;

  @override
  void initState() {
    super.initState();
    // Create a video element which will be provided with stream source
    _webcamVideoElement = VideoElement()
      ..width = widget.width.toInt()
      ..height = widget.height.toInt()
      ..autoplay = true;

    imageElement = ImageElement()
      ..width = 320
      ..height = 320;

    // Register an webcam

    final time = DateTime.now().microsecondsSinceEpoch;

    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      'webcamVideoElement$time',
      (int viewId) => _webcamVideoElement,
    );
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      'imageElement',
      (int viewId) => imageElement,
    );
    // Create video widget
    _webcamWidget =
        HtmlElementView(key: UniqueKey(), viewType: 'webcamVideoElement$time');

    _imageWidget = HtmlElementView(viewType: 'imageElement');
    // Access the webcam stream
    if (window.location.protocol.contains("https")) {
      var options;
      if (window.navigator.userAgent.contains("Mobi")) {
        options = {
          'video': {
            'facingMode': {'exact': "environment"}
          }
        };
      } else {
        options = {'video': true};
      }
      window.navigator.mediaDevices
          .getUserMedia(options)
          .then((MediaStream stream) {
        _webcamVideoElement.srcObject = stream;
      });
    } else {
      window.navigator.getUserMedia(video: true).then((MediaStream stream) {
        _webcamVideoElement.srcObject = stream;
      });
    }

    Future.delayed(Duration(seconds: 1), () {
      _timer = Timer.periodic(Duration(milliseconds: widget.refreshDelayMillis),
          (timer) async {
        _takePicture();
      });
    });
  }

  void _takePicture() async {
    CanvasElement _canvasElement = CanvasElement(
        width: _webcamVideoElement.width, height: _webcamVideoElement.height);
    final context = _canvasElement.context2D;
    context.drawImageScaled(
      _webcamVideoElement,
      0,
      0,
      _webcamVideoElement.width,
      _webcamVideoElement.height,
    );
    image =
        context.getImageData(0, 0, _canvasElement.width, _canvasElement.height);
    if (image != null) {
      final dataUrl = _canvasElement.toDataUrl('image/png');
      imageElement.src = dataUrl;

      setState(() {});

      detectBarcode(dataUrl, allowInterop((result) => onBarcodeResult(result)));
    }
  }

  Future<void> onBarcodeResult(String _barcode) async {
    if (!gotResult) {
      gotResult = true;
      releaseResources();
      print("onBarcodeResult $_barcode");
      setState(() {
        barcode = _barcode;
      });
      widget.onBarcodeResult(barcode);
    }
  }

  Future<void> releaseResources() async {
    _timer.cancel();
    _webcamVideoElement.pause();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: () async {
          releaseResources();
          return true;
        },
        child: Builder(
          builder: (context) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  width: widget.width,
                  height: widget.height,
                  child: _webcamWidget,
                ),
                image == null || !widget.showDebugFrames
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
