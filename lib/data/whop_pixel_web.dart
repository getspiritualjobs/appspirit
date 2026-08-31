import 'dart:convert';
import 'dart:js_interop';

@JS('giftPathTrackWhop')
external void _trackWhopEvent(JSString eventName, JSString propertiesJson);

void trackWhopEvent(
  String eventName, {
  Map<String, Object?> properties = const {},
}) {
  try {
    _trackWhopEvent(eventName.toJS, jsonEncode(properties).toJS);
  } catch (_) {
    // Whop attribution should never block the product flow.
  }
}
