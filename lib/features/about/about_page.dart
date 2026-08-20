import 'package:flutter/material.dart';

import '../../widgets/responsive.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: PageBand(
        maxWidth: 900,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('About the Assessment',
                style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: 12),
            const Text(
                "This tool helps Christians reflect on spiritual gifts and explore possible vocational connections. It is educational and reflective, not a claim to determine God's will."),
            const SizedBox(height: 18),
            const _Section(
              title: 'Biblical foundation',
              body:
                  'V1 focuses on the seven gifts named in Romans 12:6-8: Prophecy, Serving, Teaching, Encouragement, Giving, Leadership, and Mercy. The app also teaches that the New Testament includes multiple descriptions of gifts, including 1 Corinthians 12, Ephesians 4:11-13, and 1 Peter 4:10-11.',
            ),
            const _Section(
              title: 'Why Romans 12?',
              body:
                  'Romans 12 offers a concise set of gifts that can be translated into reflective statements without implying that Scripture gives a modern personality assessment or an exhaustive gift inventory.',
            ),
            const _Section(
              title: 'How scoring works',
              body:
                  'Each response contributes to one or more gifts using structured weights. Scores are normalized from 0 to 100 and described as alignment, not as proof that someone has or lacks a gift.',
            ),
            const _Section(
              title: 'Limitations',
              body:
                  'Spiritual gifts are not identical to careers, and higher scores do not mean greater spiritual maturity. Your results are one lens for prayer, conversation, service, and vocational discernment.',
            ),
            const _Section(
              title: 'Purpose',
              body:
                  'Use this app to consider how your gifts may show up in work, church, relationships, volunteering, family, and community. It should never replace Scripture, wise counsel, prayer, or real-world experience.',
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: InfoCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(body),
          ],
        ),
      ),
    );
  }
}
