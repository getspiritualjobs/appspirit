import 'package:flutter/material.dart';

import '../core/theme.dart';
import 'brand_components.dart';

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
    // Ambient, wide-radius shadow rather than Material's tight default —
    // per BRAND.md this is what makes a resting card read as "lifted off
    // the cream" instead of "outlined box".
    return DecoratedBox(
      decoration: BoxDecoration(
        color: BrandTokens.surface,
        borderRadius: BorderRadius.circular(BrandTokens.radiusMd),
        border: Border.all(color: BrandTokens.forest.withValues(alpha: .08)),
        boxShadow: [
          BoxShadow(
            color: BrandTokens.forestDeep.withValues(alpha: .08),
            blurRadius: 42,
            spreadRadius: -26,
            offset: const Offset(0, 24),
          ),
        ],
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.icon,
    required this.title,
    required this.body,
    required this.action,
    this.eyebrow = 'Start here',
    super.key,
  });

  final IconData icon;
  final String title;
  final String body;
  final Widget action;

  /// Per-context label so the three empty states in the app don't all
  /// read as the same template (BRAND.md).
  final String eyebrow;

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 34),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Same forest-gradient badge the landing page's feature cards
          // use, so an empty state still feels like the brand.
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [BrandTokens.forest, BrandTokens.forestDeep],
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: BrandTokens.goldBright, size: 24),
          ),
          const SizedBox(height: 16),
          BrandEyebrow(eyebrow),
          const SizedBox(height: 10),
          Text(title,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(body, textAlign: TextAlign.center),
          const SizedBox(height: 22),
          action,
        ],
      ),
    );
  }
}
