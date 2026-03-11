import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hype_grid/utils/app_colors.dart';

class HypeEmptyState extends StatelessWidget {
  final VoidCallback onReset;

  const HypeEmptyState({super.key, required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.surfaceHighlight.withValues(alpha: 0.3),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.divider.withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 80,
                color: AppColors.textSecondary.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'NO HYPE FOUND',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'The grid is quiet right now. Try adjusting your filters to find more action.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: AppColors.textSecondary,
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: onReset,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
                shadowColor: AppColors.primary.withValues(alpha: 0.5),
              ),
              child: Text(
                'RESET FILTERS',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
