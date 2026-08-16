import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_state.dart';
import '../../core/models.dart';
import '../../data/seed_data.dart';
import '../../widgets/responsive.dart';

class AssessmentPage extends StatelessWidget {
  const AssessmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final answered = appState.responses.length;
        final complete = answered == assessmentQuestions.length;
        return SingleChildScrollView(
          child: PageBand(
            maxWidth: 860,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Spiritual Gifts Assessment', style: Theme.of(context).textTheme.displayMedium),
                const SizedBox(height: 8),
                const Text('Respond honestly. This is a tool for reflection, not a verdict about your calling or spiritual maturity.'),
                const SizedBox(height: 18),
                LinearProgressIndicator(value: answered / assessmentQuestions.length, minHeight: 8),
                const SizedBox(height: 8),
                Text('Question $answered of ${assessmentQuestions.length} answered'),
                const SizedBox(height: 18),
                for (var i = 0; i < assessmentQuestions.length; i++)
                  _QuestionCard(index: i, question: assessmentQuestions[i]),
                const SizedBox(height: 18),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    onPressed: complete
                        ? () {
                            appState.completeAssessment();
                            context.go('/results');
                          }
                        : null,
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('Reveal My Gifts'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({required this.index, required this.question});

  final int index;
  final AssessmentQuestion question;

  @override
  Widget build(BuildContext context) {
    final value = appState.responses[question.id];
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InfoCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${index + 1}. ${question.text}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final option in const [
                  (1, 'Not like me'),
                  (2, 'Rarely'),
                  (3, 'Sometimes'),
                  (4, 'Often'),
                  (5, 'Very much'),
                ])
                  ChoiceChip(
                    label: Text('${option.$1} - ${option.$2}'),
                    selected: value == option.$1,
                    onSelected: (_) => appState.answer(question.id, option.$1),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
