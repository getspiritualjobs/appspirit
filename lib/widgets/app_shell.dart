import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme.dart';
import 'brand_mark.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.child, super.key});

  final Widget child;

  static const nav = [
    ('Home', '/'),
    ('Assessment', '/assessment'),
    ('My Gifts', '/results'),
    ('Opportunities', '/opportunities'),
    ('Blog', '/blog'),
    ('Saved', '/saved'),
    ('About', '/about'),
  ];

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 1080;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: isWide ? 72 : 62,
        titleSpacing: isWide ? 28 : 16,
        backgroundColor: Colors.transparent,
        foregroundColor: BrandTokens.forest,
        elevation: 0,
        // Frosted-glass nav, matching the brand mockup's blur-on-scroll
        // treatment — a flat translucent fill reads dead on Flutter web,
        // the blur is what makes it feel like it's floating over content.
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    BrandTokens.surface.withValues(alpha: .94),
                    BrandTokens.cream.withValues(alpha: .88),
                    BrandTokens.creamDim.withValues(alpha: .82),
                  ],
                ),
              ),
            ),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: BrandTokens.gold.withValues(alpha: .28),
          ),
        ),
        title: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => context.go('/'),
          child: GiftPathLogo(markSize: isWide ? 30 : 26, compact: true),
        ),
        actions: isWide
            ? [
                for (final item in nav.skip(1))
                  _NavButton(
                      label: item.$1,
                      path: item.$2,
                      selected: location == item.$2 ||
                          (item.$2 == '/blog' &&
                              location.startsWith('/blog/'))),
                Padding(
                  padding: const EdgeInsets.only(right: 28, left: 8),
                  child: OutlinedButton.icon(
                    onPressed: () => context.go('/auth'),
                    icon: const Icon(Icons.person_outline, size: 18),
                    label: const Text('Account'),
                  ),
                ),
              ]
            : null,
      ),
      drawer: isWide
          ? null
          : Drawer(
              child: SafeArea(
                child: ListView(
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(18, 18, 18, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GiftPathLogo(markSize: 32),
                          SizedBox(height: 10),
                          Text(
                            'DISCOVER YOUR GIFTS. FIND YOUR PATH.',
                            style: TextStyle(
                              color: BrandTokens.gold,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    for (final item in nav)
                      ListTile(
                        title: Text(item.$1),
                        selected: location == item.$2 ||
                            (item.$2 == '/blog' &&
                                location.startsWith('/blog/')),
                        onTap: () {
                          Navigator.of(context).pop();
                          context.go(item.$2);
                        },
                      ),
                    ListTile(
                      leading: const Icon(Icons.person_outline),
                      title: const Text('Account'),
                      onTap: () {
                        Navigator.of(context).pop();
                        context.go('/auth');
                      },
                    ),
                  ],
                ),
              ),
            ),
      body: child,
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton(
      {required this.label, required this.path, required this.selected});

  final String label;
  final String path;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => context.go(path),
      style: TextButton.styleFrom(
        backgroundColor:
            selected ? BrandTokens.forest.withValues(alpha: .10) : null,
        foregroundColor: selected ? BrandTokens.forest : BrandTokens.ink,
        minimumSize: const Size(40, 38),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        shape: const StadiumBorder(),
      ).copyWith(
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered)) {
            return BrandTokens.forest.withValues(alpha: .07);
          }
          return null;
        }),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 15,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600)),
    );
  }
}
