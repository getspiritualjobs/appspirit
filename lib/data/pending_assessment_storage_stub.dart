class PendingAssessmentSnapshot {
  const PendingAssessmentSnapshot({
    required this.responses,
    required this.consentAccepted,
  });

  final Map<String, int> responses;
  final bool consentAccepted;
}

class PendingAssessmentStorage {
  Future<void> save(PendingAssessmentSnapshot snapshot) async {}

  Future<PendingAssessmentSnapshot?> load() async => null;

  Future<void> clear() async {}
}
