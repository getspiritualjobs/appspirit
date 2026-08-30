import 'package:flutter/material.dart';

import '../core/theme.dart';
import 'brand_components.dart';
import 'brand_mark.dart';

class PageBand extends StatelessWidget {
  const PageBand(
      {required this.child, this.maxWidth = 1120, this.padding, super.key});

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding ??
              const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
          child: child,
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  const InfoCard(
      {required this.child,
      this.padding = const EdgeInsets.all(22),
      super.key});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: BrandTokens.surface,
          borderRadius: BorderRadius.circular(BrandTokens.radiusMd),
        ),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.icon,
    required this.title,
    required this.body,
    required this.action,
    super.key,
  });

  final IconData icon;
  final String title;
  final String body;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconBadge(icon, size: 48),
          const SizedBox(height: 12),
          const BrandEyebrow('Start here'),
          const SizedBox(height: 8),
          Text(title,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(body, textAlign: TextAlign.center),
          const SizedBox(height: 18),
          action,
        ],
      ),
    );
  }
}
