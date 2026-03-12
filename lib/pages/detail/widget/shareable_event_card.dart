import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hype_grid/model/hype_event.dart';
import 'package:hype_grid/utils/app_colors.dart';
import 'package:hype_grid/widget/hype_score_bar.dart';
import 'package:intl/intl.dart';

class ShareableEventCard extends StatelessWidget {
  final HypeEvent event;
  final int computedHypeScore;

  const ShareableEventCard({
    super.key,
    required this.event,
    required this.computedHypeScore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(36),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.1),
            blurRadius: 40,
            spreadRadius: -10,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Premium Radial Gradient "Spotlight" effect
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.8, -0.8),
                  radius: 1.6,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.2),
                    AppColors.background,
                    AppColors.background,
                  ],
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
            ),
          ),

          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row with Sport Type (White and tightly packed with title)
                Text(
                  event.sport.toUpperCase(),
                  style: GoogleFonts.inter(
                    color: AppColors.textPrimary.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                    letterSpacing: 4.0,
                  ),
                ),
                
                const SizedBox(height: 4),
                
                // Event Title - More Visible
                Text(
                  event.title,
                  style: GoogleFonts.outfit(
                    color: AppColors.textPrimary,
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    height: 1.0,
                    letterSpacing: -0.5,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Date & Time Info
                Row(
                  children: [
                    _InfoBadge(
                      icon: Icons.calendar_today_rounded,
                      text: DateFormat('EEE, d MMM').format(event.startTime).toUpperCase(),
                    ),
                    const SizedBox(width: 8),
                    _InfoBadge(
                      icon: Icons.access_time_rounded,
                      text: '${DateFormat('HH:mm').format(event.startTime)} WIB',
                    ),
                  ],
                ),
                
                const SizedBox(height: 48),
                
                // Hype Score Bar
                HypeScoreBar(score: computedHypeScore),
                
                const SizedBox(height: 48),
                
                // Simplified Broadcast info
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceHighlight,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.divider.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Icon(
                        Icons.tv_rounded,
                        color: AppColors.primary,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'BROADCAST',
                          style: GoogleFonts.inter(
                            color: AppColors.textSecondary,
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          event.broadcastChannel.toUpperCase(),
                          style: GoogleFonts.outfit(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 64),
                
                // Footer with scaled down HYPE GRID logo
                Center(
                  child: Column(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.whatshot, size: 14, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Text(
                            'HYPE',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                              letterSpacing: -0.5,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'GRID',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.5,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'FIND THE NEXT BIG EVENT ON HYPEGRID.APP',
                        style: GoogleFonts.inter(
                          color: AppColors.textSecondary.withValues(alpha: 0.4),
                          fontSize: 7,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


}

class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoBadge({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceHighlight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 12),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.inter(
              color: AppColors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

