@JS()
library barcode;

import 'package:js/js.dart';

/// Call the barcode the Javascript detection method
/// Parameters:
/// - dataUrl: a valid HTML image data url
/// - callback: the function called on barcode result
/// Requires a Javascript file containing a method called "detectBarcode" with the 2 arguments
/// function detectBarcode(dataUrl, callback) {
///
///   call here your favorite javascript barcode scan library
///   input must be an image dataUrl
///   output must be a single String
///
///   callback(barcode);
///
/// }
@JS('detectBarcode')
external void detectBarcode(String dataUrl, BarcodeDetectionCallback callback);

/// The method called on barcode result
typedef BarcodeDetectionCallback = void Function(String result);
