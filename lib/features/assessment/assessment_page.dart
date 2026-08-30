import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_state.dart';
import '../../core/models.dart';
import '../../core/scoring.dart';
import '../../core/theme.dart';
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
  var retaking = false;

  AssessmentQuestion get question => assessmentQuestions[index];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        if (appState.hasCompletedAssessment && !retaking) {
          return SingleChildScrollView(
            child: PageBand(
              maxWidth: 820,
              child: _CompletedAssessmentPanel(
                onRetake: () {
                  appState.startRetake();
                  setState(() {
                    index = 0;
                    retaking = true;
                  });
                },
              ),
            ),
          );
        }

        final answered = appState.responses.length;
        final complete = answered == assessmentQuestions.length;
        final response = appState.responses[question.id];
        final canStartAssessment =
            appState.assessmentConsentAccepted || answered > 0;
        return SingleChildScrollView(
          child: PageBand(
            maxWidth: 820,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const BrandEyebrow('One question at a time'),
                const SizedBox(height: 10),
                Text(
                  'Spiritual Gifts Assessment',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: 8),
                const Text(
                    '56 prompts, one at a time. Answer from your actual life, not from the person you think you should be.'),
                const SizedBox(height: 22),
                if (!canStartAssessment)
                  _AssessmentConsentPanel(
                    onAccepted: appState.acceptAssessmentConsent,
                  )
                else ...[
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
                    onBack:
                        index == 0 ? null : () => setState(() => index -= 1),
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
                            setState(() {
                              saving = false;
                              retaking = false;
                            });
                            GoRouter.of(this.context)
                                .go('/auth?returnTo=/results');
                          }
                        : null,
                    saving: saving,
                  ),
                  const SizedBox(height: 22),
                  _QuestionMap(
                      currentIndex: index,
                      onSelect: (next) => setState(() => index = next)),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AssessmentConsentPanel extends StatefulWidget {
  const _AssessmentConsentPanel({required this.onAccepted});

  final VoidCallback onAccepted;

  @override
  State<_AssessmentConsentPanel> createState() =>
      _AssessmentConsentPanelState();
}

class _AssessmentConsentPanelState extends State<_AssessmentConsentPanel> {
  var accepted = false;

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BrandEyebrow('Before you begin'),
          const SizedBox(height: 10),
          Text(
            'Confirm this is for you.',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 10),
          const Text(
            'GiftPath asks reflective spiritual-gifts questions and uses your answers to generate gift scores, career lanes, and job matches. It is for adults and is not a measure of spiritual worth, maturity, calling, or God\'s will.',
          ),
          const SizedBox(height: 16),
          BrandNotice(
            icon: Icons.privacy_tip_outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Assessment data notice',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                const Text(
                  'When you submit the assessment, GiftPath stores your answers and generated scores so your results can be saved and used for career and opportunity matching.',
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    TextButton(
                      onPressed: () => context.go('/terms'),
                      child: const Text('Terms'),
                    ),
                    TextButton(
                      onPressed: () => context.go('/privacy'),
                      child: const Text('Privacy'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () => setState(() => accepted = !accepted),
            borderRadius: BorderRadius.circular(BrandTokens.radiusSm),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: accepted,
                    activeColor: BrandTokens.forest,
                    checkColor: BrandTokens.cream,
                    onChanged: (value) =>
                        setState(() => accepted = value ?? false),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Text(
                        'I confirm I am 18 or older, accept the Terms and Privacy Policy, and understand GiftPath will process my assessment responses to generate results.',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: accepted ? widget.onAccepted : null,
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Start assessment'),
          ),
        ],
      ),
    );
  }
}

class _CompletedAssessmentPanel extends StatelessWidget {
  const _CompletedAssessmentPanel({required this.onRetake});

  final VoidCallback onRetake;

  @override
  Widget build(BuildContext context) {
    final topGift = appState.topThree.isEmpty
        ? null
        : giftLabel(appState.topThree.first.gift);
    final topCareer = appState.careerMatches.isEmpty
        ? null
        : appState.careerMatches.first.career.title;

    return InfoCard(
      padding: const EdgeInsets.all(26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BrandEyebrow('Assessment complete'),
          const SizedBox(height: 10),
          Text(
            'You have already taken the quiz.',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 10),
          Text(
            topGift == null
                ? 'Your saved GiftPath result is ready to review.'
                : 'Your latest result starts with $topGift. You can review it, explore aligned opportunities, or retake the assessment if your season has changed.',
          ),
          const SizedBox(height: 18),
          BrandNotice(
            icon: Icons.route_outlined,
            accent: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Current path',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                Text([
                  if (topGift != null) 'Top gift: $topGift',
                  if (topCareer != null) 'Top career lane: $topCareer',
                  if (topGift == null && topCareer == null)
                    'Saved result available',
                ].join('  |  ')),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton.icon(
                onPressed: () => context.go('/results'),
                icon: const Icon(Icons.auto_awesome),
                label: const Text('View results'),
              ),
              OutlinedButton.icon(
                onPressed: () => context.go('/opportunities'),
                icon: const Icon(Icons.work_outline),
                label: const Text('See opportunities'),
              ),
              TextButton.icon(
                onPressed: onRetake,
                icon: const Icon(Icons.refresh),
                label: const Text('Retake assessment'),
              ),
            ],
          ),
        ],
      ),
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
          Text(
            question.text,
            style: const TextStyle(
              fontFamily: 'Fraunces',
              color: BrandTokens.ink,
              fontSize: 26,
              fontWeight: FontWeight.w600,
              height: 1.25,
            ),
          ),
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
      {required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(BrandTokens.radiusSm),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color:
              selected ? scheme.primary.withValues(alpha: .10) : Colors.white,
          borderRadius: BorderRadius.circular(BrandTokens.radiusSm),
          border: Border.all(
              color: selected
                  ? scheme.primary
                  : scheme.primary.withValues(alpha: .14),
              width: selected ? 2 : 1),
        ),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? scheme.primary : scheme.surface,
                shape: BoxShape.circle,
                border:
                    Border.all(color: scheme.primary.withValues(alpha: .42)),
              ),
              child: selected
                  ? const Icon(Icons.check, size: 13, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 14),
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
    final firstMissing = assessmentQuestions
        .indexWhere((question) => !appState.responses.containsKey(question.id));
    return InfoCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BrandEyebrow('Question trail'),
          const SizedBox(height: 8),
          Text(
            'You are on question ${currentIndex + 1}. Answered prompts stay on the path, and you can jump back to anything unfinished before revealing results.',
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              OutlinedButton.icon(
                onPressed: currentIndex == 0 ? null : () => onSelect(0),
                icon: const Icon(Icons.first_page),
                label: const Text('First Question'),
              ),
              if (firstMissing >= 0)
                FilledButton.icon(
                  onPressed: () => onSelect(firstMissing),
                  icon: const Icon(Icons.route_outlined),
                  label: Text('Next Open: ${firstMissing + 1}'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
