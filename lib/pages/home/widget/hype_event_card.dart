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

  bool get isHighHype => event.hypeScore >= 80;

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
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isHighHype ? AppColors.surfaceCardHype : AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(16),
          border: isHighHype
              ? Border.all(
                  color: AppColors.primary.withOpacity(0.5),
                  width: 1.5,
                )
              : Border.all(color: AppColors.divider, width: 1),
          boxShadow: isHighHype
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.15),
                    blurRadius: 20,
                    spreadRadius: 2,
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
                      const SizedBox(height: 6),
                      Text(
                        event.metadata?['league'] ?? event.sport.toUpperCase(),
                        style: GoogleFonts.inter(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                HypeBadge(hypeScore: event.hypeScore),
              ],
            ),
            const SizedBox(height: 12),

            // Title
            Text(
              event.title,
              style: GoogleFonts.outfit(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),

            // Bottom Row: Time and Broadcast
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.sport.toLowerCase() == 'football'
                            ? 'Kick-off'
                            : 'Start Time',
                        style: GoogleFonts.inter(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${DateFormat('HH:mm').format(event.startTime)} WIB',
                        style: GoogleFonts.outfit(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: AppColors.divider,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Watch on',
                        style: GoogleFonts.inter(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        event.broadcastChannel,
                        style: GoogleFonts.outfit(
                          color: AppColors.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                // Reminder Icon placeholder
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications_none_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
