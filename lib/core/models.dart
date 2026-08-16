enum GiftKey { prophecy, serving, teaching, encouragement, giving, leadership, mercy }

class SpiritualGift {
  const SpiritualGift({
    required this.key,
    required this.name,
    required this.shortDescription,
    required this.biblicalContext,
    required this.scripture,
    required this.characteristics,
    required this.strengths,
    required this.blindSpots,
    required this.workExpression,
    required this.churchExpression,
    required this.lifeExpression,
  });

  final GiftKey key;
  final String name;
  final String shortDescription;
  final String biblicalContext;
  final String scripture;
  final List<String> characteristics;
  final List<String> strengths;
  final List<String> blindSpots;
  final String workExpression;
  final String churchExpression;
  final String lifeExpression;
}

class QuestionGiftWeight {
  const QuestionGiftWeight({
    required this.gift,
    required this.weight,
    this.reverseScored = false,
  });

  final GiftKey gift;
  final double weight;
  final bool reverseScored;
}

class AssessmentQuestion {
  const AssessmentQuestion({
    required this.id,
    required this.text,
    required this.weights,
  });

  final String id;
  final String text;
  final List<QuestionGiftWeight> weights;
}

class GiftScore {
  const GiftScore({
    required this.gift,
    required this.rawScore,
    required this.normalizedScore,
  });

  final GiftKey gift;
  final double rawScore;
  final int normalizedScore;
}

class Career {
  const Career({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.salaryLow,
    required this.salaryHigh,
    required this.educationRequirement,
    required this.responsibilities,
    required this.environment,
    required this.interests,
    required this.values,
    required this.giftWeights,
  });

  final String id;
  final String title;
  final String category;
  final String description;
  final int salaryLow;
  final int salaryHigh;
  final String educationRequirement;
  final List<String> responsibilities;
  final String environment;
  final List<String> interests;
  final List<String> values;
  final Map<GiftKey, int> giftWeights;
}

class CareerMatch {
  const CareerMatch({
    required this.career,
    required this.score,
    required this.strongestGifts,
    required this.reason,
  });

  final Career career;
  final int score;
  final List<GiftKey> strongestGifts;
  final String reason;
}

class UserPreference {
  const UserPreference({
    this.interests = const {},
    this.values = const {},
    this.location = '',
    this.remoteOnly = false,
    this.salaryMin,
    this.employmentType,
  });

  final Set<String> interests;
  final Set<String> values;
  final String location;
  final bool remoteOnly;
  final int? salaryMin;
  final String? employmentType;
}

class JobListing {
  const JobListing({
    required this.id,
    required this.provider,
    required this.title,
    required this.company,
    required this.location,
    required this.description,
    required this.salaryMin,
    required this.salaryMax,
    required this.employmentType,
    required this.remote,
    required this.postedDate,
    required this.applicationUrl,
    required this.matchScore,
  });

  final String id;
  final String provider;
  final String title;
  final String company;
  final String location;
  final String description;
  final int? salaryMin;
  final int? salaryMax;
  final String employmentType;
  final bool remote;
  final DateTime postedDate;
  final String applicationUrl;
  final int matchScore;
}
