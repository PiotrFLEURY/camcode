import 'package:camcode/barcode_results.dart';
import 'package:every_test/every_test.dart';
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

  group('singleShot', () {
    test('singleShot enabled', () {
      // GIVEN
      final barcodeResults = BarcodeResults(singleShot: true);
      barcodeResults.add('42424242');

      // WHEN
      final gotResult = barcodeResults.gotResult;

      // THEN
      expect(gotResult, true);
    });

    test('singleShot disabled', () {
      // GIVEN
      final barcodeResults = BarcodeResults(singleShot: false);
      barcodeResults.add('42424242');

      // WHEN
      final gotResult = barcodeResults.gotResult;

      // THEN
      expect(gotResult, false);
    });

    test('singleShot default', () {
      // GIVEN
      final barcodeResults = BarcodeResults();
      barcodeResults.add('42424242');

      // WHEN
      final gotResult = barcodeResults.gotResult;

      // THEN
      expect(gotResult, false);
    });
  });

  everyTest(
    'minimalResultCount',
    of: (params) {
      // GIVEN
      final _minimalResulCount = params['minimalResultCount'] as int;
      final List barcodes = params['barcodes'];
      final barcodeResults =
          BarcodeResults(minimalResultCount: _minimalResulCount);
      barcodes.forEach((it) {
        barcodeResults.add(it);
      });

      // WHEN
      return barcodeResults.gotResult;
    },
    expects: [
      // THEN
      param({
        'minimalResultCount': 1,
        'barcodes': ['123456']
      }).gives(false),
      param({
        'minimalResultCount': 2,
        'barcodes': ['123456', '123456']
      }).gives(true),
      param({
        'minimalResultCount': 2,
        'barcodes': ['123456', '123456', '123456']
      }).gives(true),
      param({
        'minimalResultCount': 2,
        'barcodes': ['123456']
      }).gives(false),
      param({
        'minimalResultCount': 4,
        'barcodes': ['123456', '123456', '123456']
      }).gives(false),
    ],
  );
}
