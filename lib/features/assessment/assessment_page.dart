import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_state.dart';
import '../../core/models.dart';
import '../../data/seed_data.dart';
import '../../widgets/brand_components.dart';
import '../../widgets/responsive.dart';

class AssessmentPage extends StatefulWidget {
  const AssessmentPage({super.key});

  @override
  State<AssessmentPage> createState() => _AssessmentPageState();
}

class _AssessmentPageState extends State<AssessmentPage> {
  var index = 0;
  var saving = false;

  AssessmentQuestion get question => assessmentQuestions[index];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final answered = appState.responses.length;
        final complete = answered == assessmentQuestions.length;
        final response = appState.responses[question.id];
        return SingleChildScrollView(
          child: PageBand(
            maxWidth: 820,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const BrandEyebrow('One question at a time'),
                const SizedBox(height: 10),
                Text('Spiritual Gifts Assessment',
                    style: Theme.of(context).textTheme.displayMedium),
                const SizedBox(height: 8),
                const Text(
                    'Respond honestly and without overthinking. GiftPath is a reflective tool, not a verdict about your calling or spiritual maturity.'),
                const SizedBox(height: 22),
                _ProgressHeader(
                    index: index, answered: answered, complete: complete),
                const SizedBox(height: 18),
                _QuestionPanel(
                  question: question,
                  response: response,
                  onAnswer: (value) {
                    appState.answer(question.id, value);
                    if (index < assessmentQuestions.length - 1) {
                      Future<void>.delayed(const Duration(milliseconds: 180),
                          () {
                        if (mounted) setState(() => index += 1);
                      });
                    }
                  },
                ),
                const SizedBox(height: 18),
                _AssessmentControls(
                  index: index,
                  complete: complete,
                  response: response,
                  onBack: index == 0 ? null : () => setState(() => index -= 1),
                  onNext: index == assessmentQuestions.length - 1
                      ? null
                      : () => setState(() => index += 1),
                  onReviewMissing: () {
                    final missing = assessmentQuestions.indexWhere(
                        (item) => !appState.responses.containsKey(item.id));
                    if (missing >= 0) setState(() => index = missing);
                  },
                  onFinish: complete
                      ? () async {
                          setState(() => saving = true);
                          await appState.completeAssessment();
                          if (!mounted) return;
                          setState(() => saving = false);
                          GoRouter.of(this.context).go('/results');
                        }
                      : null,
                  saving: saving,
                ),
                const SizedBox(height: 22),
                _QuestionMap(
                    currentIndex: index,
                    onSelect: (next) => setState(() => index = next)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader(
      {required this.index, required this.answered, required this.complete});

  final int index;
  final int answered;
  final bool complete;

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                  child: Text(
                      'Question ${index + 1} of ${assessmentQuestions.length}',
                      style: const TextStyle(fontWeight: FontWeight.w900))),
              Text(
                complete ? 'Ready for results' : '$answered answered',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DashedPathProgress(
            total: assessmentQuestions.length,
            currentIndex: index,
            answered: answered,
          ),
        ],
      ),
    );
  }
}

class _QuestionPanel extends StatelessWidget {
  const _QuestionPanel(
      {required this.question, required this.response, required this.onAnswer});

  final AssessmentQuestion question;
  final int? response;
  final ValueChanged<int> onAnswer;

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question.text,
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontSize: 30)),
          const SizedBox(height: 20),
          for (final option in const [
            (1, 'Not like me'),
            (2, 'Rarely like me'),
            (3, 'Sometimes like me'),
            (4, 'Often like me'),
            (5, 'Very much like me'),
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _AnswerOption(
                  number: option.$1,
                  label: option.$2,
                  selected: response == option.$1,
                  onTap: () => onAnswer(option.$1)),
            ),
        ],
      ),
    );
  }
}

class _AnswerOption extends StatelessWidget {
  const _AnswerOption(
      {required this.number,
      required this.label,
      required this.selected,
      required this.onTap});

  final int number;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color:
              selected ? scheme.primary.withValues(alpha: .10) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: selected
                  ? scheme.primary
                  : scheme.primary.withValues(alpha: .14),
              width: selected ? 2 : 1),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? scheme.primary : scheme.surface,
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: scheme.primary.withValues(alpha: .18)),
              ),
              child: Text('$number',
                  style: TextStyle(
                      color: selected ? Colors.white : scheme.primary,
                      fontWeight: FontWeight.w900)),
            ),
            const SizedBox(width: 12),
            Expanded(
                child: Text(label,
                    style: const TextStyle(fontWeight: FontWeight.w800))),
            if (selected) Icon(Icons.check_circle, color: scheme.primary),
          ],
        ),
      ),
    );
  }
}

class _AssessmentControls extends StatelessWidget {
  const _AssessmentControls({
    required this.index,
    required this.complete,
    required this.response,
    required this.onBack,
    required this.onNext,
    required this.onReviewMissing,
    required this.onFinish,
    required this.saving,
  });

  final int index;
  final bool complete;
  final int? response;
  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final VoidCallback onReviewMissing;
  final Future<void> Function()? onFinish;
  final bool saving;

  @override
  Widget build(BuildContext context) {
    final isLast = index == assessmentQuestions.length - 1;
    return Row(
      children: [
        OutlinedButton.icon(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back')),
        const Spacer(),
        if (complete)
          FilledButton.icon(
              onPressed: saving ? null : onFinish,
              icon: saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(saving ? 'Saving Results' : 'Reveal My Gifts'))
        else if (isLast)
          OutlinedButton.icon(
              onPressed: onReviewMissing,
              icon: const Icon(Icons.rate_review_outlined),
              label: const Text('Review Missing'))
        else
          FilledButton.icon(
              onPressed: onNext,
              icon: const Icon(Icons.arrow_forward),
              label: Text(response == null ? 'Skip for Now' : 'Next')),
      ],
    );
  }
}

class _QuestionMap extends StatelessWidget {
  const _QuestionMap({required this.currentIndex, required this.onSelect});

  final int currentIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        const BrandEyebrow('Question trail'),
        for (var i = 0; i < assessmentQuestions.length; i++)
          Tooltip(
            message: 'Question ${i + 1}',
            child: InkWell(
              onTap: () => onSelect(i),
              borderRadius: BorderRadius.circular(6),
              child: Container(
                width: 30,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: i == currentIndex
                      ? scheme.primary
                      : appState.responses
                              .containsKey(assessmentQuestions[i].id)
                          ? scheme.primary.withValues(alpha: .10)
                          : Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  border:
                      Border.all(color: scheme.primary.withValues(alpha: .16)),
                ),
                child: Text(
                  '${i + 1}',
                  style: TextStyle(
                      fontSize: 11,
                      color:
                          i == currentIndex ? Colors.white : scheme.onSurface,
                      fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
