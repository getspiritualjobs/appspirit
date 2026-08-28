class BlogPost {
  const BlogPost({
    required this.slug,
    required this.title,
    required this.excerpt,
    required this.eyebrow,
    required this.publishedLabel,
    required this.readTime,
    required this.sections,
  });

  final String slug;
  final String title;
  final String excerpt;
  final String eyebrow;
  final String publishedLabel;
  final String readTime;
  final List<BlogSection> sections;
}

class BlogSection {
  const BlogSection({
    required this.heading,
    required this.paragraphs,
  });

  final String heading;
  final List<String> paragraphs;
}

const blogPosts = [
  BlogPost(
    slug: 'spiritual-gifts-and-career-discernment',
    eyebrow: 'Discernment',
    publishedLabel: 'Launch guide',
    readTime: '4 min read',
    title: 'How spiritual gifts can shape career discernment',
    excerpt:
        'A practical way to treat gifts as clues for work, service, and next steps without turning an assessment into a verdict.',
    sections: [
      BlogSection(
        heading: 'Start with patterns, not pressure',
        paragraphs: [
          'A spiritual gifts assessment should not tell you what you must do with your life. A healthier use is quieter: notice the patterns that keep showing up, then compare them with real opportunities.',
          'GiftPath scores gifts as alignment. That means a result can give language to what you already sense, but it still belongs in conversation with Scripture, prayer, wise counsel, and lived experience.',
        ],
      ),
      BlogSection(
        heading: 'Ask where the gift becomes useful',
        paragraphs: [
          'Teaching may point toward classrooms, training, curriculum, coaching, or product education. Mercy may point toward care work, counseling-adjacent roles, patient support, or nonprofit service. Leadership may show up in operations, team building, ministry administration, or project ownership.',
          'The point is not to force a direct one-to-one match. The point is to ask where a gift can become concrete enough to serve someone.',
        ],
      ),
      BlogSection(
        heading: 'Test one next step',
        paragraphs: [
          'A good next step is small enough to try and specific enough to teach you something. Save a career lane, open a few jobs, talk with someone in the field, or volunteer in a related setting.',
          'Discernment gets clearer when reflection meets evidence.',
        ],
      ),
    ],
  ),
  BlogPost(
    slug: 'romans-12-gifts-explained',
    eyebrow: 'Romans 12',
    publishedLabel: 'Gift guide',
    readTime: '5 min read',
    title: 'The seven Romans 12 gifts, explained plainly',
    excerpt:
        'A simple overview of prophecy, serving, teaching, encouragement, giving, leadership, and mercy.',
    sections: [
      BlogSection(
        heading: 'Why these seven gifts',
        paragraphs: [
          'Romans 12:6-8 gives a concise list of gifts that translate well into reflection prompts. GiftPath begins here because the list is specific enough to score thoughtfully and broad enough to connect with modern work.',
          'The New Testament includes other gift passages too. This is not an exhaustive inventory. It is a focused starting point.',
        ],
      ),
      BlogSection(
        heading: 'What the gifts can reveal',
        paragraphs: [
          'Serving often notices practical needs. Teaching clarifies ideas. Encouragement helps people keep going. Giving sees resources as tools for care. Leadership brings order and movement. Mercy moves toward pain with compassion. Prophecy cares about truth, conviction, and alignment.',
          'In real life, these gifts overlap. A person may teach with mercy, lead through encouragement, or serve with unusual discernment.',
        ],
      ),
      BlogSection(
        heading: 'How to read your result',
        paragraphs: [
          'Your top gifts are best treated as your strongest signals, not your only gifts. Lower scores are not failures. They may simply mean those patterns were less prominent in your answers right now.',
          'Use the language to pay attention: where do you bring life, clarity, courage, generosity, order, care, or conviction?',
        ],
      ),
    ],
  ),
  BlogPost(
    slug: 'one-question-at-a-time',
    eyebrow: 'Assessment',
    publishedLabel: 'Product note',
    readTime: '3 min read',
    title: 'Why GiftPath asks one question at a time',
    excerpt:
        'The quiz is designed to slow the process down so each answer is more honest and less performative.',
    sections: [
      BlogSection(
        heading: 'A quieter pace helps',
        paragraphs: [
          'Most assessments try to move quickly. GiftPath intentionally asks one question at a time because reflection benefits from a little space.',
          'The goal is not to make the quiz feel dramatic. The goal is to reduce noise so your answers can be honest.',
        ],
      ),
      BlogSection(
        heading: 'Less comparison, better answers',
        paragraphs: [
          'When too many questions sit on the screen at once, it is easy to manage an image of yourself instead of answering what is true. A single prompt keeps attention on the next honest response.',
          'That is also why results use language like alignment and signal. GiftPath is meant to help you notice, not perform.',
        ],
      ),
      BlogSection(
        heading: 'From answer to action',
        paragraphs: [
          'After the assessment, the path continues into gifts, career lanes, and open jobs. The question flow is only the beginning. The real value is turning reflection into a next step you can actually compare and test.',
        ],
      ),
    ],
  ),
];

BlogPost? blogPostBySlug(String slug) {
  for (final post in blogPosts) {
    if (post.slug == slug) return post;
  }
  return null;
}
