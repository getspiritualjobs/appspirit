import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../widgets/brand_components.dart';
import '../../widgets/responsive.dart';
import 'blog_posts.dart';

class BlogPage extends StatelessWidget {
  const BlogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: PageBand(
        maxWidth: 1080,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BrandEyebrow('GiftPath journal'),
            const SizedBox(height: 10),
            Text(
              'Notes on gifts, work, and next steps',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 12),
            const Text(
              'Plainspoken guides for reading your results, comparing career lanes, and turning reflection into a next step.',
            ),
            const SizedBox(height: 24),
            _FeaturedPost(post: blogPosts.first),
            const SizedBox(height: 24),
            const BrandDivider(),
            const SizedBox(height: 24),
            LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 820;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: blogPosts.length - 1,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: wide ? 2 : 1,
                    mainAxisExtent: 250,
                    crossAxisSpacing: 18,
                    mainAxisSpacing: 18,
                  ),
                  itemBuilder: (context, index) {
                    return _PostCard(post: blogPosts[index + 1]);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class BlogPostPage extends StatelessWidget {
  const BlogPostPage({required this.slug, super.key});

  final String slug;

  @override
  Widget build(BuildContext context) {
    final post = blogPostBySlug(slug);
    if (post == null) {
      return SingleChildScrollView(
        child: PageBand(
          maxWidth: 760,
          child: EmptyState(
            icon: Icons.article_outlined,
            title: 'Post not found',
            body: 'This GiftPath journal note may have moved.',
            action: FilledButton(
              onPressed: () => context.go('/blog'),
              child: const Text('Back to blog'),
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: PageBand(
        maxWidth: 820,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton.icon(
              onPressed: () => context.go('/blog'),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back to blog'),
            ),
            const SizedBox(height: 12),
            BrandEyebrow(post.eyebrow),
            const SizedBox(height: 10),
            Text(post.title, style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: 12),
            Text(
              post.excerpt,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),
            Text(
              '${post.publishedLabel} · ${post.readTime}',
              style: const TextStyle(
                color: BrandTokens.moss,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 26),
            const BrandDivider(),
            const SizedBox(height: 26),
            for (final section in post.sections) ...[
              Text(section.heading,
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 10),
              for (final paragraph in section.paragraphs) ...[
                Text(paragraph, style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 14),
              ],
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 12),
            BrandNotice(
              icon: Icons.route_outlined,
              accent: true,
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                runSpacing: 12,
                spacing: 16,
                children: [
                  const Text(
                    'Ready to turn reflection into a result?',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  FilledButton.icon(
                    onPressed: () => context.go('/assessment'),
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Take the assessment'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeaturedPost extends StatelessWidget {
  const _FeaturedPost({required this.post});

  final BlogPost post;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: BrandTokens.forest,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: BrandTokens.ink.withValues(alpha: .12),
            blurRadius: 30,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 760;
            final title = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BrandEyebrow(post.eyebrow),
                const SizedBox(height: 10),
                Text(
                  post.title,
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: BrandTokens.cream,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  post.excerpt,
                  style: const TextStyle(
                    color: BrandTokens.cream,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: () => context.go('/blog/${post.slug}'),
                  style: FilledButton.styleFrom(
                    backgroundColor: BrandTokens.gold,
                    foregroundColor: BrandTokens.forest,
                  ),
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Read the guide'),
                ),
              ],
            );
            const path = SizedBox(
              height: 150,
              child: DashedPathConnector(),
            );
            return wide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(flex: 6, child: title),
                      const SizedBox(width: 28),
                      const Expanded(flex: 4, child: path),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      title,
                      const SizedBox(height: 18),
                      path,
                    ],
                  );
          },
        ),
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  const _PostCard({required this.post});

  final BlogPost post;

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BrandEyebrow(post.eyebrow),
          const SizedBox(height: 12),
          Text(post.title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          Expanded(child: Text(post.excerpt)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${post.publishedLabel} · ${post.readTime}',
                  style: const TextStyle(
                    color: BrandTokens.moss,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () => context.go('/blog/${post.slug}'),
                icon: const Icon(Icons.arrow_forward, size: 18),
                label: const Text('Read'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
