# camcode

A camera barcode scan library for Flutter Web

## Getting Started

# Add to pubspec.yaml

```
dependencies:
    camcode: ^1.0.0
```

# Run flutter pub get

```
$ flutter pub get
```

# Add a javascript file for barcode scan

```
function detectBarcode(dataUrl, callback) {

    // call here your favorite javascript barcode scan library
    // input must be an image dataUrl
    // output must be a single String

    // don't forget to trigger the call back in order to get the result
    callback(barcode);
}
```

# Import javascript files into your index.html

```
<script src="LINK_TO_MY_AWESOME_JAVASCRIPT_BARCODE_SCAN_LIB"></script>
<script src="js/barcode.js"></script> // the javascript file with the detectBarcode function
```

# Use it

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
    ),
);
```
