import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
        title: InkWell(
          onTap: () => context.go('/'),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.auto_awesome, color: Colors.white, size: 19),
              ),
              const SizedBox(width: 10),
              const Text('GiftPath', style: TextStyle(fontWeight: FontWeight.w800)),
            ],
          ),
        ),
        actions: isWide
            ? [
                for (final item in nav.skip(1))
                  _NavButton(label: item.$1, path: item.$2, selected: location == item.$2),
                Padding(
                  padding: const EdgeInsets.only(right: 16),
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
                    const ListTile(title: Text('GiftPath', style: TextStyle(fontWeight: FontWeight.w800))),
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
  const _NavButton({required this.label, required this.path, required this.selected});

  final String label;
  final String path;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => context.go(path),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
          color: selected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}
