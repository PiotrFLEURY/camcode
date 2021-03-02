import 'dart:async';
// In order to *not* need this ignore, consider extracting the "web" version
// of your plugin as a separate package, instead of inlining it in the same
// package as the core of your plugin.
// ignore: avoid_web_libraries_in_flutter
import 'dart:html';
import 'dart:js';
import 'dart:ui' as ui;

import 'package:camcode/barcode.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

/// A web implementation of the Camcode plugin.
class CamcodeWeb {
  // VideoElement used to display the camera image
  VideoElement _webcamVideoElement;
  // ImageElement used to display taken pictures
  ImageElement imageElement;
  // The current processing image
  ImageData image;
  // timer shceduling the pictures treatment process
  Timer _timer;
  // indicates if the the scan got result or not
  bool gotResult = false;
  // used to transmit result to the Widget via MethodChannel
  Completer completer;

  // Registering method
  static void registerWith(Registrar registrar) {
    MethodChannel channel = MethodChannel(
      'camcode',
      const StandardMethodCodec(),
      registrar,
    );

    final pluginInstance = CamcodeWeb();
    channel.setMethodCallHandler(pluginInstance.handleMethodCall);
  }

  // handle channel calls
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

  // wait for the result to be completed
  Future<String> fetchResult() {
    return completer.future;
  }

  /// Initialize the scanner :
  /// - request user permission
  /// - request camera stream
  /// - initialize video
  /// - start video streaming
  /// - start picture snapshot timer scheduling
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
    if (window.location.protocol.contains('https')) {
      var options;
      if (window.navigator.userAgent.contains('Mobi')) {
        options = {
          'video': {
            'facingMode': {'exact': 'environment'}
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

  /// Takes a picture of the current camera image
  /// and process it for barcode identification
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

  // Method called on barcode result to finish the process and send result
  Future<void> onBarcodeResult(String _barcode) async {
    if (!gotResult) {
      gotResult = true;
      releaseResources();
      completer.complete(_barcode);
    }
  }

  // Release resources to avoid leaks
  Future<void> releaseResources() async {
    _timer.cancel();
    _webcamVideoElement.pause();
    _webcamVideoElement.srcObject.getTracks().forEach((track) {
      track.stop();
      track.enabled = false;
    });
    _webcamVideoElement.srcObject = null;
  }
}
