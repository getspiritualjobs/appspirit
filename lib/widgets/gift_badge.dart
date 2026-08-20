import 'package:flutter/material.dart';

import '../core/models.dart';
import '../core/scoring.dart';
import '../core/theme.dart';

class GiftBadge extends StatelessWidget {
  const GiftBadge(this.gift, {this.dense = false, super.key});

  final GiftKey gift;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(_icon(gift), size: dense ? 15 : 17),
      label: Text(giftLabel(gift)),
      visualDensity: dense ? VisualDensity.compact : VisualDensity.standard,
      backgroundColor: BrandTokens.forest.withValues(alpha: .08),
      side: BorderSide(color: BrandTokens.forest.withValues(alpha: .18)),
      labelStyle: const TextStyle(
        fontWeight: FontWeight.w800,
        color: BrandTokens.forest,
      ),
    );
  }
}

IconData _icon(GiftKey gift) {
  return switch (gift) {
    GiftKey.prophecy => Icons.campaign_outlined,
    GiftKey.serving => Icons.handyman_outlined,
    GiftKey.teaching => Icons.menu_book_outlined,
    GiftKey.encouragement => Icons.favorite_border,
    GiftKey.giving => Icons.volunteer_activism_outlined,
    GiftKey.leadership => Icons.flag_outlined,
    GiftKey.mercy => Icons.healing_outlined,
  };
}
