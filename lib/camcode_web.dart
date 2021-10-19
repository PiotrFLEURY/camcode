import 'dart:async';

/// In order to *not* need this ignore, consider extracting the "web" version
/// of your plugin as a separate package, instead of inlining it in the same
/// package as the core of your plugin.
/// ignore: avoid_web_libraries_in_flutter
import 'dart:html';
import 'dart:js';
import 'package:camcode/barcode_results.dart';
import 'package:camcode/dart_ui_stub/dart_ui.dart' as ui;

import 'package:camcode/barcode.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

/// A web implementation of the Camcode plugin.
class CamcodeWeb {
  /// VideoElement used to display the camera image
  late VideoElement _webcamVideoElement;

  /// ImageElement used to display taken pictures
  late ImageElement imageElement;

  /// timer shceduling the pictures treatment process
  late Timer _timer;

  /// used to transmit result to the Widget via MethodChannel
  late Completer<String> completer;

  /// bacode results container
  final BarcodeResults _barcodeResults = BarcodeResults();

  /// Canvas element used to draw the barcode result
  late CanvasElement _canvasElement;

  /// list of every cameras
  final Map<String, String> _cameraDevices = {};

  /// ID of the selected device
  String? _selectedDeviceId;

  /// Completer to get enumerateDevices result
  late Completer<List<String>> _enumerateDevicesCompleter;

  int frameSize = 1;
  int counter = 0;
  int maxAttempt = 4;

  /// Registering method
  static void registerWith(Registrar registrar) {
    final channel = MethodChannel(
      'camcode',
      const StandardMethodCodec(),
      // ignore: unnecessary_cast
      registrar as BinaryMessenger,
    );

    final pluginInstance = CamcodeWeb();
    channel.setMethodCallHandler(pluginInstance.handleMethodCall);
  }

  /// handle channel calls
  Future<dynamic> handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'initialize':
        final List arguments = call.arguments;
        return initialize(
          arguments[0],
          arguments[1],
          arguments[2],
        );
      case 'releaseResources':
        return releaseResources();
      case 'fetchResult':
        return fetchResult();
      case 'fetchDeviceList':
        return fetchDevices();
      case 'selectDevice':
        return _selectDevice(call.arguments);
      default:
        throw PlatformException(
          code: 'Unimplemented',
          details: 'camcode for web doesn\'t implement \'${call.method}\'',
        );
    }
  }

  /// wait for the result to be completed
  Future<String> fetchResult() {
    return completer.future;
  }

  /// wait for the list of devices to be completed
  Future<List<String>> fetchDevices() {
    _enumerateVideoDevices();
    return _enumerateDevicesCompleter.future;
  }

  /// Initialize the scanner :
  /// - request user permission
  /// - request camera stream
  /// - initialize video
  /// - start video streaming
  /// - start picture snapshot timer scheduling
  int initialize(
    double width,
    double height,
    int refreshDelayMillis,
  ) {
    completer = Completer<String>();
    _enumerateDevicesCompleter = Completer<List<String>>();
    _barcodeResults.clear();

    // Create a video element which will be provided with stream source
    _webcamVideoElement = VideoElement()
      ..width = 1920
      ..height = 1080
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.objectFit = 'contain'
      ..autoplay = true
      ..muted = true;
    _webcamVideoElement.setAttribute('playsinline', 'true');

    imageElement = ImageElement()
      ..width = 1920
      ..height = 1080
      ..style.width = '100%'
      ..style.height = '100%';

    _canvasElement = CanvasElement(
      width: 1920,
      height: 1080,
    );

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
    _setupMediaStream(width, height);

    Future.delayed(Duration(seconds: 1), () {
      _scan(refreshDelayMillis);
    });

    return time;
  }

  /// Fetch media device stream and affect it to the video element
  void _setupMediaStream(double width, double height) {
    if (window.location.protocol.contains('https')) {
      var options = _configureOptions(width, height);
      window.navigator.mediaDevices
          ?.getUserMedia(options)
          .then((MediaStream stream) {
        _webcamVideoElement.srcObject = stream;
      });
    } else {
      window.navigator.getUserMedia(video: true).then((MediaStream stream) {
        _webcamVideoElement.srcObject = stream;
      });
    }
  }

  /// configure constraint options to fetch media device stream
  dynamic _configureOptions(double width, double height) {
    var options;
    if (window.navigator.userAgent.contains('Mobi')) {
      options = {
        'audio': false,
        'video': {
          'deviceId':
              _selectedDeviceId != null ? {'exact': _selectedDeviceId} : null,
          'facingMode': {'exact': 'environment'},
        }
      };
    } else {
      options = {
        'audio': false,
        'video': {
          'deviceId':
              _selectedDeviceId != null ? {'exact': _selectedDeviceId} : null,
        }
      };
    }
    return options;
  }

  /// Selects a device with the given label
  void _selectDevice(String? deviceLabel) {
    _selectedDeviceId = _cameraDevices[deviceLabel];
    _setupMediaStream(
      _webcamVideoElement.width.toDouble(),
      _webcamVideoElement.height.toDouble(),
    );
  }

  /// Enumerate all video devices
  void _enumerateVideoDevices() {
    window.navigator.mediaDevices?.enumerateDevices().then((devices) {
      for (final device in devices) {
        if (device.kind == 'videoinput') {
          _cameraDevices[device.label] = device.deviceId;
        }
      }
      _enumerateDevicesCompleter.complete(_cameraDevices.keys.toList());
    });
  }

  /// Scan loop
  Future<void> _scan(int refreshDelayMillis) async {
    counter = 0;
    _timer = Timer.periodic(
      Duration(
        milliseconds: refreshDelayMillis,
      ),
      (timer) {
        _takePicture();
      },
    );
  }

  /// Takes a picture of the current camera image
  /// and process it for barcode identification
  Future<void> _takePicture() async {
    final context = _canvasElement.context2D;
    // context.filter = 'grayscale(1)';

    switch (frameSize) {
      case 1:
        context.drawImageScaledFromSource(
          _webcamVideoElement,
          _webcamVideoElement.videoWidth * .2,
          _webcamVideoElement.videoHeight * .4,
          _webcamVideoElement.videoWidth * .6,
          _webcamVideoElement.videoHeight * .2,
          0,
          0,
          _webcamVideoElement.width,
          _webcamVideoElement.height,
        );
        break;
      default:
        context.drawImageScaledFromSource(
          _webcamVideoElement,
          0,
          _webcamVideoElement.videoHeight * .4,
          _webcamVideoElement.videoWidth,
          _webcamVideoElement.videoHeight * .2,
          0,
          0,
          _webcamVideoElement.width,
          _webcamVideoElement.height,
        );
        break;
    }

    debugPrint(
        'Webcam taille : ${_webcamVideoElement.height} & ${_webcamVideoElement.width}');
    debugPrint(
        'Webcam video taille : ${_webcamVideoElement.videoHeight} & ${_webcamVideoElement.videoWidth}');

    final dataUrl = _canvasElement.toDataUrl('image/jpeg', 1.0);
    imageElement.src = dataUrl;
    detectBarcode(dataUrl, allowInterop((result) => onBarcodeResult(result)));

    counter++;

    if (counter >= maxAttempt) {
      counter = 0;
      frameSize = frameSize == 0 ? 1 : 0;
    }
  }

  /// Method called on barcode result to finish the process and send result
  Future<void> onBarcodeResult(String _barcode) async {
    _barcodeResults.add(_barcode);
    if (_barcodeResults.gotResult) {
      releaseResources();
      if (!completer.isCompleted) {
        completer.complete(_barcodeResults.mostFrequentBarcode);
        _barcodeResults.clear();
      }
    }
  }

  /// Release resources to avoid leaks
  void releaseResources() {
    _timer.cancel();
    _webcamVideoElement.pause();
    _webcamVideoElement.srcObject?.getTracks().forEach((track) {
      track.stop();
      track.enabled = false;
    });
    _webcamVideoElement.srcObject = null;
    _canvasElement.remove();
    _webcamVideoElement.remove();
    imageElement.remove();
  }
}
