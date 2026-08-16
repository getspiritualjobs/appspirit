import 'package:flutter/material.dart';

import '../core/models.dart';
import '../core/scoring.dart';

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
      backgroundColor: _color(gift).withOpacity(.12),
      side: BorderSide(color: _color(gift).withOpacity(.20)),
      labelStyle: TextStyle(fontWeight: FontWeight.w700, color: _color(gift)),
    );
  }
}

Color _color(GiftKey gift) {
  return switch (gift) {
    GiftKey.prophecy => const Color(0xFF7B3F61),
    GiftKey.serving => const Color(0xFF2D6A6A),
    GiftKey.teaching => const Color(0xFF315D9F),
    GiftKey.encouragement => const Color(0xFFB75E3E),
    GiftKey.giving => const Color(0xFF7A6A2A),
    GiftKey.leadership => const Color(0xFF2D5A4A),
    GiftKey.mercy => const Color(0xFF8B5278),
  };
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
