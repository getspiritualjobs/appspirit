import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/env.dart';
import '../features/blog/blog_posts.dart';

class BlogRepository {
  const BlogRepository();

  SupabaseClient? get _client {
    if (!Env.hasSupabase) return null;
    return Supabase.instance.client;
  }

  Future<bool> isAdmin() async {
    final client = _client;
    final email = client?.auth.currentUser?.email;
    if (client == null || email == null || email.isEmpty) return false;

    try {
      final row = await client
          .from('blog_admins')
          .select('email')
          .eq('email', email)
          .maybeSingle();
      return row != null;
    } catch (_) {
      return false;
    }
  }

  Future<List<BlogPost>> fetchPosts({bool includeDrafts = false}) async {
    final client = _client;
    if (client == null) return blogPosts;

    try {
      var query = client.from('blog_posts').select();
      if (!includeDrafts) {
        query = query.eq('status', 'published');
      }
      final rows = await query.order('published_at',
          ascending: false, nullsFirst: false);
      final posts = rows
          .map<BlogPost>((row) => _postFromRow(Map<String, dynamic>.from(row)))
          .toList();
      return posts.isEmpty && !includeDrafts ? blogPosts : posts;
    } catch (_) {
      return blogPosts;
    }
  }

  Future<BlogPost?> fetchPost(String slug) async {
    final client = _client;
    if (client == null) return blogPostBySlug(slug);

    try {
      final row = await client
          .from('blog_posts')
          .select()
          .eq('slug', slug)
          .maybeSingle();
      if (row == null) return blogPostBySlug(slug);
      return _postFromRow(Map<String, dynamic>.from(row));
    } catch (_) {
      return blogPostBySlug(slug);
    }
  }

  Future<void> savePost(BlogPostDraft draft) async {
    final client = _client;
    if (client == null) {
      throw StateError('Supabase is not configured for blog publishing.');
    }

    final user = client.auth.currentUser;
    if (user == null) {
      throw StateError('Sign in before saving a blog post.');
    }

    final status = draft.published ? 'published' : 'draft';
    final payload = {
      if (draft.id != null) 'id': draft.id,
      'slug': draft.slug,
      'title': draft.title,
      'excerpt': draft.excerpt,
      'eyebrow': draft.eyebrow,
      'read_time': draft.readTime,
      'content_markdown': draft.contentMarkdown,
      'status': status,
      'author_id': user.id,
      if (draft.published)
        'published_at': DateTime.now().toUtc().toIso8601String(),
    };

    await client.from('blog_posts').upsert(payload, onConflict: 'id');
  }

  BlogPost _postFromRow(Map<String, dynamic> row) {
    final markdown = (row['content_markdown'] as String?)?.trim() ?? '';
    final publishedAt =
        DateTime.tryParse(row['published_at']?.toString() ?? '');
    return BlogPost(
      id: row['id']?.toString(),
      slug: row['slug']?.toString() ?? '',
      title: row['title']?.toString() ?? 'Untitled',
      excerpt: row['excerpt']?.toString() ?? '',
      eyebrow: row['eyebrow']?.toString() ?? 'Journal',
      publishedLabel:
          publishedAt == null ? 'Draft' : _publishedLabel(publishedAt),
      readTime: row['read_time']?.toString() ?? '3 min read',
      sections: blogSectionsFromMarkdown(markdown),
      contentMarkdown: markdown,
      isDraft: row['status'] == 'draft',
    );
  }

  String _publishedLabel(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class BlogPostDraft {
  const BlogPostDraft({
    this.id,
    required this.slug,
    required this.title,
    required this.excerpt,
    required this.eyebrow,
    required this.readTime,
    required this.contentMarkdown,
    required this.published,
  });

  final String? id;
  final String slug;
  final String title;
  final String excerpt;
  final String eyebrow;
  final String readTime;
  final String contentMarkdown;
  final bool published;
}
