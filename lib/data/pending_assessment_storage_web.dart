import 'dart:convert';
import 'dart:js_interop';

@JS('giftPathSavePendingAssessment')
external void _savePendingAssessment(JSString payload);

@JS('giftPathLoadPendingAssessment')
external JSString _loadPendingAssessment();

@JS('giftPathClearPendingAssessment')
external void _clearPendingAssessment();

class PendingAssessmentSnapshot {
  const PendingAssessmentSnapshot({
    required this.responses,
    required this.consentAccepted,
  });

  final Map<String, int> responses;
  final bool consentAccepted;

  String toJson() => jsonEncode({
        'responses': responses,
        'consent_accepted': consentAccepted,
      });

  static PendingAssessmentSnapshot? fromJson(String value) {
    if (value.isEmpty) return null;
    final decoded = jsonDecode(value);
    if (decoded is! Map<String, Object?>) return null;
    final rawResponses = decoded['responses'];
    if (rawResponses is! Map) return null;
    return PendingAssessmentSnapshot(
      responses: {
        for (final entry in rawResponses.entries)
          if (entry.key is String && entry.value is num)
            entry.key as String: (entry.value as num).round(),
      },
      consentAccepted: decoded['consent_accepted'] == true,
    );
  }
}

class PendingAssessmentStorage {
  Future<void> save(PendingAssessmentSnapshot snapshot) async {
    try {
      _savePendingAssessment(snapshot.toJson().toJS);
    } catch (_) {}
  }

  Future<PendingAssessmentSnapshot?> load() async {
    try {
      return PendingAssessmentSnapshot.fromJson(
          _loadPendingAssessment().toDart);
    } catch (_) {
      return null;
    }
  }

  Future<void> clear() async {
    try {
      _clearPendingAssessment();
    } catch (_) {}
  }
}
