// stub dart_ui for ui.platformViewRegistry exposition on compile time
export 'dart_ui_fake.dart' if (dart.library.html) 'dart_ui_real.dart';
