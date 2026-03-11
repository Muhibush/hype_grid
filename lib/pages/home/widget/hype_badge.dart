import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hype_grid/utils/app_colors.dart';

class HypeBadge extends StatelessWidget {
  final int hypeScore;

  const HypeBadge({super.key, required this.hypeScore});

  bool get isHighHype => hypeScore >= 90;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isHighHype
            ? AppColors.hypeBadgeBackground
            : AppColors.normalBadgeBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isHighHype) ...[
            const Text('🔥', style: TextStyle(fontSize: 12)),
            const SizedBox(width: 4),
          ],
          Text(
            hypeScore.toString(),
            style: GoogleFonts.outfit(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
