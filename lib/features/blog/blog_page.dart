import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../data/blog_repository.dart';
import '../../widgets/brand_components.dart';
import '../../widgets/responsive.dart';
import 'blog_posts.dart';

class BlogPage extends StatefulWidget {
  const BlogPage({super.key});

  @override
  State<BlogPage> createState() => _BlogPageState();
}

class _BlogPageState extends State<BlogPage> {
  final repository = const BlogRepository();
  var posts = blogPosts;
  var isAdmin = false;
  var loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final admin = await repository.isAdmin();
    final loadedPosts = await repository.fetchPosts(includeDrafts: admin);
    if (!mounted) return;
    setState(() {
      isAdmin = admin;
      posts = loadedPosts;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final publishedPosts = posts.where((post) => !post.isDraft).toList();
    final featured = publishedPosts.isNotEmpty
        ? publishedPosts.first
        : posts.isNotEmpty
            ? posts.first
            : null;
    final remaining = featured == null
        ? const <BlogPost>[]
        : posts.where((post) => post.slug != featured.slug).toList();

    return SingleChildScrollView(
      child: PageBand(
        maxWidth: 1080,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 18,
              runSpacing: 14,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const BrandEyebrow('GiftPath journal'),
                    const SizedBox(height: 10),
                    Text(
                      'Notes on gifts, work, and next steps',
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                  ],
                ),
                if (isAdmin)
                  FilledButton.icon(
                    onPressed: () => context.go('/blog/new'),
                    icon: const Icon(Icons.edit_note),
                    label: const Text('New post'),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Plainspoken guides for reading your results, comparing career lanes, and turning reflection into a next step.',
            ),
            if (loading) ...[
              const SizedBox(height: 18),
              const LinearProgressIndicator(minHeight: 3),
            ],
            const SizedBox(height: 24),
            if (featured == null)
              EmptyState(
                icon: Icons.article_outlined,
                title: 'No posts yet',
                body: 'The GiftPath journal is ready for its first article.',
                action: isAdmin
                    ? FilledButton(
                        onPressed: () => context.go('/blog/new'),
                        child: const Text('Write first post'),
                      )
                    : FilledButton(
                        onPressed: () => context.go('/assessment'),
                        child: const Text('Take the assessment'),
                      ),
              )
            else ...[
              _FeaturedPost(post: featured, isAdmin: isAdmin),
              const SizedBox(height: 24),
              const BrandDivider(),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 820;
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: remaining.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: wide ? 2 : 1,
                      mainAxisExtent: 258,
                      crossAxisSpacing: 18,
                      mainAxisSpacing: 18,
                    ),
                    itemBuilder: (context, index) {
                      return _PostCard(
                        post: remaining[index],
                        isAdmin: isAdmin,
                      );
                    },
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class BlogPostPage extends StatefulWidget {
  const BlogPostPage({required this.slug, super.key});

  final String slug;

  @override
  State<BlogPostPage> createState() => _BlogPostPageState();
}

class _BlogPostPageState extends State<BlogPostPage> {
  final repository = const BlogRepository();
  BlogPost? post;
  var isAdmin = false;
  var loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final admin = await repository.isAdmin();
    final loadedPost = await repository.fetchPost(widget.slug);
    if (!mounted) return;
    setState(() {
      isAdmin = admin;
      post = loadedPost;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final loadedPost = post;
    if (!loading && loadedPost == null) {
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

    if (loadedPost == null) {
      return const PageBand(
        maxWidth: 820,
        child: LinearProgressIndicator(minHeight: 3),
      );
    }

    return SingleChildScrollView(
      child: PageBand(
        maxWidth: 820,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: () => context.go('/blog'),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back to blog'),
                ),
                if (isAdmin)
                  OutlinedButton.icon(
                    onPressed: () =>
                        context.go('/blog/${loadedPost.slug}/edit'),
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Edit post'),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            BrandEyebrow(loadedPost.eyebrow),
            const SizedBox(height: 10),
            Text(loadedPost.title,
                style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: 12),
            Text(
              loadedPost.excerpt,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),
            Text(
              '${loadedPost.publishedLabel} - ${loadedPost.readTime}',
              style: const TextStyle(
                color: BrandTokens.moss,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 26),
            const BrandDivider(),
            const SizedBox(height: 26),
            for (final section in loadedPost.sections) ...[
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

class BlogEditorPage extends StatefulWidget {
  const BlogEditorPage({this.slug, super.key});

  final String? slug;

  @override
  State<BlogEditorPage> createState() => _BlogEditorPageState();
}

class _BlogEditorPageState extends State<BlogEditorPage> {
  final repository = const BlogRepository();
  final title = TextEditingController();
  final slug = TextEditingController();
  final eyebrow = TextEditingController(text: 'Journal');
  final excerpt = TextEditingController();
  final readTime = TextEditingController(text: '3 min read');
  final markdown = TextEditingController();
  String? postId;
  bool published = false;
  bool isAdmin = false;
  bool loading = true;
  bool saving = false;
  String message = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    title.dispose();
    slug.dispose();
    eyebrow.dispose();
    excerpt.dispose();
    readTime.dispose();
    markdown.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final admin = await repository.isAdmin();
    final loadedPost =
        widget.slug == null ? null : await repository.fetchPost(widget.slug!);
    if (!mounted) return;

    if (loadedPost != null) {
      postId = loadedPost.id;
      title.text = loadedPost.title;
      slug.text = loadedPost.slug;
      eyebrow.text = loadedPost.eyebrow;
      excerpt.text = loadedPost.excerpt;
      readTime.text = loadedPost.readTime;
      markdown.text =
          loadedPost.contentMarkdown ?? blogPostToMarkdown(loadedPost);
      published = !loadedPost.isDraft;
    }

    setState(() {
      isAdmin = admin;
      loading = false;
    });
  }

  Future<void> _save() async {
    final cleanTitle = title.text.trim();
    final cleanSlug = slug.text.trim();
    final cleanExcerpt = excerpt.text.trim();
    final cleanMarkdown = markdown.text.trim();
    if (cleanTitle.isEmpty ||
        cleanSlug.isEmpty ||
        cleanExcerpt.isEmpty ||
        cleanMarkdown.isEmpty) {
      setState(() => message = 'Title, slug, excerpt, and body are required.');
      return;
    }

    setState(() {
      saving = true;
      message = '';
    });

    try {
      await repository.savePost(BlogPostDraft(
        id: postId,
        slug: cleanSlug,
        title: cleanTitle,
        excerpt: cleanExcerpt,
        eyebrow: eyebrow.text.trim().isEmpty ? 'Journal' : eyebrow.text.trim(),
        readTime:
            readTime.text.trim().isEmpty ? '3 min read' : readTime.text.trim(),
        contentMarkdown: cleanMarkdown,
        published: published,
      ));
      if (mounted) context.go('/blog/$cleanSlug');
    } catch (error) {
      setState(() => message = error.toString());
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const PageBand(
        maxWidth: 760,
        child: LinearProgressIndicator(minHeight: 3),
      );
    }

    if (!isAdmin) {
      return SingleChildScrollView(
        child: PageBand(
          maxWidth: 720,
          child: EmptyState(
            icon: Icons.lock_outline,
            title: 'Admin access needed',
            body:
                'Sign in with the GiftPath editor account to write or edit blog posts.',
            action: FilledButton(
              onPressed: () => context.go('/auth?returnTo=/blog'),
              child: const Text('Sign in'),
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: PageBand(
        maxWidth: 880,
        child: InfoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton.icon(
                onPressed: () => context.go('/blog'),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back to blog'),
              ),
              const SizedBox(height: 12),
              const BrandEyebrow('Editor'),
              const SizedBox(height: 10),
              Text(
                widget.slug == null ? 'Write a blog post' : 'Edit blog post',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 18),
              TextField(
                controller: title,
                decoration: const InputDecoration(labelText: 'Title'),
                textInputAction: TextInputAction.next,
                onChanged: (value) {
                  if (widget.slug == null) slug.text = _slugify(value);
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: slug,
                decoration: const InputDecoration(labelText: 'Slug'),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: 260,
                    child: TextField(
                      controller: eyebrow,
                      decoration:
                          const InputDecoration(labelText: 'Eyebrow label'),
                    ),
                  ),
                  SizedBox(
                    width: 220,
                    child: TextField(
                      controller: readTime,
                      decoration: const InputDecoration(labelText: 'Read time'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: excerpt,
                decoration: const InputDecoration(labelText: 'Excerpt'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: markdown,
                decoration: const InputDecoration(
                  labelText: 'Body',
                  helperText:
                      'Use ## for section headings. Separate paragraphs with blank lines.',
                ),
                keyboardType: TextInputType.multiline,
                minLines: 12,
                maxLines: 18,
              ),
              const SizedBox(height: 14),
              SwitchListTile.adaptive(
                value: published,
                onChanged: saving
                    ? null
                    : (value) => setState(() => published = value),
                title: const Text('Publish this post'),
                subtitle: const Text('Drafts are visible only to blog admins.'),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  FilledButton.icon(
                    onPressed: saving ? null : _save,
                    icon: const Icon(Icons.save_outlined),
                    label: Text(saving ? 'Saving...' : 'Save post'),
                  ),
                  OutlinedButton(
                    onPressed: saving ? null : () => context.go('/blog'),
                    child: const Text('Cancel'),
                  ),
                  if (message.isNotEmpty)
                    Text(
                      message,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _slugify(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
  }
}

class _FeaturedPost extends StatelessWidget {
  const _FeaturedPost({required this.post, required this.isAdmin});

  final BlogPost post;
  final bool isAdmin;

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
                Row(
                  children: [
                    BrandEyebrow(post.isDraft ? 'Draft' : post.eyebrow),
                    if (post.isDraft) ...[
                      const SizedBox(width: 10),
                      const Icon(Icons.visibility_off_outlined,
                          color: BrandTokens.gold, size: 18),
                    ],
                  ],
                ),
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
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    FilledButton.icon(
                      onPressed: () => context.go('/blog/${post.slug}'),
                      style: FilledButton.styleFrom(
                        backgroundColor: BrandTokens.gold,
                        foregroundColor: BrandTokens.forest,
                      ),
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Read the guide'),
                    ),
                    if (isAdmin)
                      OutlinedButton.icon(
                        onPressed: () => context.go('/blog/${post.slug}/edit'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: BrandTokens.cream,
                          side: BorderSide(
                            color: BrandTokens.cream.withValues(alpha: .58),
                          ),
                        ),
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: const Text('Edit'),
                      ),
                  ],
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
  const _PostCard({required this.post, required this.isAdmin});

  final BlogPost post;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              BrandEyebrow(post.isDraft ? 'Draft' : post.eyebrow),
              if (post.isDraft) ...[
                const SizedBox(width: 8),
                const Icon(Icons.visibility_off_outlined,
                    color: BrandTokens.gold, size: 17),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Text(post.title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          Expanded(child: Text(post.excerpt)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${post.publishedLabel} - ${post.readTime}',
                  style: const TextStyle(
                    color: BrandTokens.moss,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
              if (isAdmin)
                IconButton(
                  tooltip: 'Edit post',
                  onPressed: () => context.go('/blog/${post.slug}/edit'),
                  icon: const Icon(Icons.edit_outlined, size: 18),
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
