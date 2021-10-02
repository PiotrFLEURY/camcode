import 'package:camcode/barcode_results.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(
    'result count',
    () {
      test(
        'should get result if got 3 times the same',
        () {
          // GIVEN
          final barcodeResults = BarcodeResults();
          barcodeResults.add('123456789');
          barcodeResults.add('123456789');
          barcodeResults.add('123456789');

          // WHEN
          final gotResult = barcodeResults.gotResult;

          // THEN
          expect(gotResult, true);
        },
      );

      test(
        'should get result if got 3 same results in a list of random results',
        () {
          // GIVEN
          final barcodeResults = BarcodeResults();
          barcodeResults.add('123456789');
          barcodeResults.add('987654321');
          barcodeResults.add('123456789');
          barcodeResults.add('987654321');
          barcodeResults.add('123456789');

          // WHEN
          final gotResult = barcodeResults.gotResult;

          // THEN
          expect(gotResult, true);
        },
      );
      test(
        'should not get result if got 3 different barcodes',
        () {
          // GIVEN
          final barcodeResults = BarcodeResults();
          barcodeResults.add('123');
          barcodeResults.add('456');
          barcodeResults.add('789');

          // WHEN
          final gotResult = barcodeResults.gotResult;

          // THEN
          expect(gotResult, false);
        },
      );
    },
  );
  group('mostFequent', () {
    test('most frequent barcode', () {
      // GIVEN
      final barcodeResults = BarcodeResults();
      barcodeResults.add('123456789');
      barcodeResults.add('987654321');
      barcodeResults.add('123456789');
      barcodeResults.add('987654321');
      barcodeResults.add('123456789');

      // WHEN
      final mostFrequent = barcodeResults.mostFrequentBarcode;

      // THEN
      expect(mostFrequent, '123456789');
    });
  });
}
