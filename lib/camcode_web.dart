import 'dart:async';
// In order to *not* need this ignore, consider extracting the "web" version
// of your plugin as a separate package, instead of inlining it in the same
// package as the core of your plugin.
// ignore: avoid_web_libraries_in_flutter
import 'dart:html';
import 'dart:js';
import 'dart:ui' as ui;

import 'package:camcode/quagga.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

/// A web implementation of the Camcode plugin.
class CamcodeWeb {
  // VideoElement
  VideoElement _webcamVideoElement;
  // ImageElement
  ImageElement imageElement;

  ImageData image;

  Timer _timer;

  bool gotResult = false;

  Completer completer;

  static void registerWith(Registrar registrar) {
    MethodChannel channel = MethodChannel(
      'camcode',
      const StandardMethodCodec(),
      registrar,
    );

    final pluginInstance = CamcodeWeb();
    channel.setMethodCallHandler(pluginInstance.handleMethodCall);
  }

  Future<dynamic> handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'initialize':
        final List arguments = call.arguments;
        return initialize(
          arguments[0],
          arguments[1],
          arguments[2],
        );
        break;
      case 'releaseResources':
        return releaseResources();
        break;
      case 'fetchResult':
        return fetchResult();
        break;
      default:
        throw PlatformException(
          code: 'Unimplemented',
          details: 'camcode for web doesn\'t implement \'${call.method}\'',
        );
    }
  }

  Future<String> fetchResult() {
    return completer.future;
  }

  int initialize(double width, double height, int refreshDelayMillis) {
    completer = Completer();
    gotResult = false;
    // Create a video element which will be provided with stream source
    _webcamVideoElement = VideoElement()
      ..width = width.toInt()
      ..height = height.toInt()
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
      _timer = Timer.periodic(Duration(milliseconds: refreshDelayMillis),
          (timer) async {
        _takePicture();
      });
    });

    return time;
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

      detectBarcode(dataUrl, allowInterop((result) => onBarcodeResult(result)));
    }
  }

  Future<void> onBarcodeResult(String _barcode) async {
    if (!gotResult) {
      gotResult = true;
      releaseResources();
      print("onBarcodeResult $_barcode");
      completer.complete(_barcode);
    }
  }

  Future<void> releaseResources() async {
    _timer.cancel();
    _webcamVideoElement.pause();
  }
}
