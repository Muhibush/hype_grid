import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hype_grid/model/hype_event.dart';
import 'package:hype_grid/pages/detail/event_detail_screen.dart';
import 'package:hype_grid/pages/home/widget/hype_badge.dart';
import 'package:hype_grid/utils/app_colors.dart';
import 'package:intl/intl.dart';

class HypeEventCard extends StatelessWidget {
  final HypeEvent event;
  final VoidCallback onTap;

  const HypeEventCard({super.key, required this.event, required this.onTap});

  bool get isHighHype => event.hypeScore >= 95;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. Glow Effect (for high hype)
          if (isHighHype)
            Positioned(
              top: -2,
              left: -2,
              right: -2,
              bottom: -2,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      Colors.purple.shade600,
                      AppColors.primary,
                    ],
                  ),
                ),
              ),
            ),

          // 2. Main Card Content
          GestureDetector(
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
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isHighHype ? AppColors.surfaceCardHype : AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isHighHype
                      ? AppColors.primary.withValues(alpha: 0.3)
                      : AppColors.divider.withValues(alpha: 0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: League/Sport + Hype Score
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (event.metadata?['league'] ?? event.sport).toUpperCase(),
                              style: GoogleFonts.inter(
                                color: isHighHype
                                    ? AppColors.primary.withValues(alpha: 0.8)
                                    : AppColors.textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          HypeBadge(hypeScore: event.hypeScore),
                          const SizedBox(height: 4),
                          Text(
                            'Hype Score',
                            style: GoogleFonts.inter(
                              color: AppColors.textSecondary.withValues(alpha: 0.6),
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Title
                  Text(
                    event.title,
                    style: GoogleFonts.outfit(
                      color: AppColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Divider
                  Container(
                    height: 1,
                    width: double.infinity,
                    color: AppColors.textPrimary.withValues(alpha: 0.05),
                  ),
                  const SizedBox(height: 20),

                  // Info Row (Time, Broadcast, Notify)
                  Row(
                    children: [
                      // Time Info
                      _buildInfoColumn(
                        label: event.sport.toLowerCase() == 'football'
                            ? 'KICK-OFF'
                            : 'START TIME',
                        value: '${DateFormat('HH:mm').format(event.startTime)} WIB',
                      ),

                      // Vertical Divider
                      Container(
                        width: 1,
                        height: 32,
                        color: AppColors.textPrimary.withValues(alpha: 0.1),
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                      ),

                      // Broadcast Info
                      _buildInfoColumn(
                        label: 'WATCH ON',
                        value: event.broadcastChannel,
                        valueColor: isHighHype ? AppColors.primary : AppColors.textPrimary,
                      ),

                      const Spacer(),

                      // Notify Button
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
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
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn({
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: AppColors.textSecondary.withValues(alpha: 0.6),
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.outfit(
            color: valueColor ?? AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
