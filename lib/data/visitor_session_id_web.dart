import 'dart:js_interop';

@JS('giftPathGetVisitorId')
external JSString _getVisitorId();

class VisitorSessionId {
  Future<String> load() async {
    try {
      return _getVisitorId().toDart;
    } catch (_) {
      return '';
    }
  }
}
