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
    ('Careers', '/careers'),
    ('Opportunities', '/opportunities'),
    ('Saved', '/saved'),
    ('About', '/about'),
  ];

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 900;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: isWide ? 72 : 62,
        titleSpacing: isWide ? 28 : 16,
        backgroundColor: BrandTokens.cream,
        foregroundColor: BrandTokens.forest,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: BrandTokens.gold.withValues(alpha: .22),
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
                      selected: location == item.$2),
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
                        selected: location == item.$2,
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
    final scheme = Theme.of(context).colorScheme;
    return TextButton(
      onPressed: () => context.go(path),
      style: TextButton.styleFrom(
        backgroundColor:
            selected ? BrandTokens.forest.withValues(alpha: .10) : null,
        foregroundColor: selected ? scheme.primary : scheme.onSurface,
        minimumSize: const Size(40, 38),
        padding: const EdgeInsets.symmetric(horizontal: 9),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 15,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600)),
    );
  }
}
