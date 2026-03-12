import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hype_grid/model/hype_event.dart';
import 'package:hype_grid/pages/detail/event_detail_screen.dart';
import 'package:hype_grid/pages/home/bloc/home_bloc.dart';
import 'package:hype_grid/pages/home/widget/hype_badge.dart';
import 'package:hype_grid/pages/home/widget/sport_tag.dart';
import 'package:hype_grid/utils/app_colors.dart';
import 'package:intl/intl.dart';

class HypeEventCard extends StatelessWidget {
  final HypeEvent event;
  final VoidCallback onTap;
  final VoidCallback onCalendarAdd;

  const HypeEventCard({
    super.key,
    required this.event,
    required this.onTap,
    required this.onCalendarAdd,
  });

  bool get isHighHype => event.totalHypeScore >= 90;

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
              final homeBloc = context.read<HomeBloc>();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BlocProvider.value(
                    value: homeBloc,
                    child: EventDetailScreen(event: event),
                  ),
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
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SportTag(sport: event.sport, compact: false),
                                if (event.metadata?['league'] != null) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    event.metadata!['league']
                                        .toString()
                                        .toUpperCase(),
                                    style: GoogleFonts.inter(
                                      color: AppColors.textSecondary,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          HypeBadge(hypeScore: event.totalHypeScore),
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
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Time Info
                            _buildInfoColumn(
                              label: event.sport.toLowerCase() == 'football'
                                  ? 'KICK-OFF'
                                  : 'START TIME',
                              value:
                                  '${DateFormat('HH:mm').format(event.startTime)} WIB',
                            ),
                            const SizedBox(height: 16),
                            // Broadcast Info
                            _buildInfoColumn(
                              label: 'WATCH ON',
                              value: event.broadcastChannel,
                              valueColor: AppColors.textPrimary,
                            ),
                          ],
                        ),
                      ),

                      // Add to Calendar Button
                      IconButton(
                        onPressed: onCalendarAdd,
                        icon: const Icon(
                          Icons.event_available_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                          padding: const EdgeInsets.all(8),
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
