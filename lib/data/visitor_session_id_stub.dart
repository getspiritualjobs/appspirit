import 'package:uuid/uuid.dart';

class VisitorSessionId {
  static String? _id;

  Future<String> load() async {
    _id ??= 'visitor_${const Uuid().v4()}';
    return _id!;
  }
}
