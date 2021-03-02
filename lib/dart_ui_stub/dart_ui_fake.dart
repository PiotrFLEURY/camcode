import 'dart:html' as html;

// stub dart_ui for ui.platformViewRegistry exposition on compile time
class platformViewRegistry {
  static void registerViewFactory(
      String viewTypeId, html.Element Function(int viewId) viewFactory) {}
}
