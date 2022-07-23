# camcode

A camera barcode scan library for Flutter Web

![Web build status](https://github.com/PiotrFLEURY/camcode/actions/workflows/web.yml/badge.svg)

# Getting Started

## Add a javascript file for barcode scan

```
function detectBarcode(dataUrl, callback) {

    // call here your favorite javascript barcode scan library
    // input must be an image dataUrl
    // output must be a single String

    // don't forget to trigger the call back in order to get the result
    callback(barcode);
}
```

## Import javascript files into your index.html

```
<script src="LINK_TO_MY_AWESOME_JAVASCRIPT_BARCODE_SCAN_LIB"></script>
<script src="js/barcode.js"></script> // the javascript file with the detectBarcode function
```

## Use it

```
import 'package:camcode/cam_code_scanner.dart';

showDialog(
    context: context,
    builder: (context) => CamCodeScanner(
    width: MediaQuery.of(context).size.width,
    height: MediaQuery.of(context).size.height,
    refreshDelayMillis: 200,
    onBarcodeResult: (barcode) {
        // do whatever you want
    },
    minimalResultCount: 2,
    ),
);
```

# More options

## Manually release resources

Sometimes, depending on your camcode usage, you may need to release resources manually.

1- To do so, create first a controller for the scanner

```dart
// Create a controller to send instructions to scanner
  final CamCodeScannerController _controller = CamCodeScannerController();
```

2- Then, add it to the `CamCodeScanner`

```dart
CamCodeScanner(
    width: ...,
    height: ...,
    refreshDelayMillis: ...,
    onBarcodeResult: (barcode) {
        ...
    },
    controller: _controller,
),
```

3- And finally, just call `releaseResources()` method when required

```dart
ElevatedButton(
    onPressed: () {
        _controller.releaseResources();
    },
    child: Text('Release resources'),
),
```

> Calling this method will close the camera and stop the scanner process
