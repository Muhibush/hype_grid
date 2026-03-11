import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hype_grid/model/hype_event.dart';
import 'package:hype_grid/pages/detail/event_detail_screen.dart';
import 'package:hype_grid/pages/home/widget/hype_badge.dart';
import 'package:hype_grid/pages/home/widget/sport_tag.dart';
import 'package:hype_grid/utils/app_colors.dart';
import 'package:intl/intl.dart';

class HypeEventCard extends StatelessWidget {
  final HypeEvent event;
  final VoidCallback onTap;

  const HypeEventCard({super.key, required this.event, required this.onTap});

  bool get isHighHype => event.hypeScore >= 95;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailScreen(event: event),
          ),
        );
        onTap();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isHighHype ? AppColors.surfaceCardHype : AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(20),
          border: isHighHype
              ? Border.all(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  width: 1.5,
                )
              : Border.all(color: AppColors.divider.withValues(alpha: 0.5), width: 1),
          boxShadow: isHighHype
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    blurRadius: 24,
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: League/Sport + Hype Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SportTag(sport: event.sport),
                      const SizedBox(height: 8),
                      Text(
                        event.metadata?['league']?.toUpperCase() ??
                            event.sport.toUpperCase(),
                        style: GoogleFonts.inter(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                HypeBadge(hypeScore: event.hypeScore),
              ],
            ),
            const SizedBox(height: 16),
            // Title
            Text(
              event.title,
              style: GoogleFonts.outfit(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 20),
            // Bottom Info Row
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _buildSubInfo(
                    icon: Icons.access_time_filled_rounded,
                    label: event.sport.toLowerCase() == 'football'
                        ? 'KICKOFF'
                        : 'START',
                    value: '${DateFormat('HH:mm').format(event.startTime)} WIB',
                  ),
                  Container(
                    width: 1,
                    height: 24,
                    color: AppColors.divider.withValues(alpha: 0.5),
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  _buildSubInfo(
                    icon: Icons.tv_rounded,
                    label: 'BROADCAST',
                    value: event.broadcastChannel,
                    valueColor: AppColors.primary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubInfo({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary.withValues(alpha: 0.5), size: 14),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    color: AppColors.textSecondary,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.outfit(
                    color: valueColor ?? AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
