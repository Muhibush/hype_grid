import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hype_grid/utils/app_colors.dart';

class HypeBadge extends StatelessWidget {
  final int hypeScore;

  const HypeBadge({super.key, required this.hypeScore});

  bool get isHighHype => hypeScore >= 95;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isHighHype
            ? AppColors.hypeBadgeBackground
            : AppColors.normalBadgeBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: isHighHype
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isHighHype) ...[
            const Text('🔥', style: TextStyle(fontSize: 14)),
            const SizedBox(width: 4),
          ],
          Text(
            hypeScore.toString(),
            style: GoogleFonts.outfit(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
