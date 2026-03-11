import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hype_grid/model/hype_event.dart';
import 'package:hype_grid/utils/app_colors.dart';
import 'package:hype_grid/pages/home/widget/sport_tag.dart';
import 'package:hype_grid/widget/hype_score_bar.dart';
import 'package:hype_grid/services/hype_repository.dart';
import 'package:hype_grid/services/hype_debouncer.dart';
import 'package:hype_grid/pages/detail/widget/shareable_event_card.dart';
import 'package:intl/intl.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

class EventDetailRouteWrapper extends StatelessWidget {
  final String eventId;

  const EventDetailRouteWrapper({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<HypeEvent?>(
      future: HypeRepository().fetchEventById(eventId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }
        if (snapshot.hasError || snapshot.data == null) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: AppColors.background,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            body: const Center(
              child: Text(
                'Event not found',
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        }
        return EventDetailScreen(event: snapshot.data!);
      },
    );
  }
}

class EventDetailScreen extends StatefulWidget {
  final HypeEvent event;

  const EventDetailScreen({super.key, required this.event});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen>
    with SingleTickerProviderStateMixin {
  late int _localCommunityHype;
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _localCommunityHype = widget.event.communityHype;
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  int get _computedHypeScore {
    int addedHype = _localCommunityHype;
    if (addedHype > 20) addedHype = 20; // Cap community contribution locally
    int total = widget.event.hypeScore + addedHype;
    return total > 100 ? 100 : total;
  }

  void _onHypeTapped() async {
    int added = await HypeDebouncer().increment(widget.event.eventId);
    if (added > 0) {
      setState(() {
        _localCommunityHype += added;
      });
      _animController.forward().then((_) => _animController.reverse());
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Daily hype limit reached for this event! 🔥'),
            duration: Duration(seconds: 2),
            backgroundColor: AppColors.surfaceCard,
          ),
        );
      }
    }
  }

  Future<void> _shareEvent() async {
    try {
      final screenshotController = ScreenshotController();
      final imageBytes = await screenshotController.captureFromWidget(
        ShareableEventCard(
          event: widget.event,
          computedHypeScore: _computedHypeScore,
        ),
        delay: const Duration(milliseconds: 100),
      );

      final directory = await getApplicationDocumentsDirectory();
      final imagePath = await File('${directory.path}/share_${widget.event.eventId}.png').create();
      await imagePath.writeAsBytes(imageBytes);

      await Share.shareXFiles(
        [XFile(imagePath.path)],
        text: 'Check out ${widget.event.title} on HypeGrid! 🔥\nhypegrid://hype.grid/event/${widget.event.eventId}',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to share: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SportTag(sport: widget.event.sport),
                    const SizedBox(width: 8),
                    Text(
                      widget.event.metadata?['league']?.toUpperCase() ??
                          widget.event.sport.toUpperCase(),
                      style: GoogleFonts.inter(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: _onHypeTapped,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceHighlight,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.primary.withAlpha(50)),
                      ),
                      child: Row(
                        children: [
                          const Text('🔥', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 4),
                          Text(
                            '$_localCommunityHype',
                            style: GoogleFonts.outfit(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              widget.event.title,
              style: GoogleFonts.outfit(
                color: AppColors.textPrimary,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            // Placeholder for Hero Image (would normally be in metadata)
            Container(
              height: 180,
              margin: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: AppColors.surfaceHighlight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Icon(
                  Icons.image_outlined,
                  size: 48,
                  color: AppColors.textSecondary.withValues(alpha: 0.5),
                ),
              ),
            ),

            // Hype Score
            HypeScoreBar(score: _computedHypeScore),

            const SizedBox(height: 32),

            // Timing & Broadcast Grid
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildInfoCard(
                    icon: Icons.calendar_today_rounded,
                    label: 'DATE',
                    value: DateFormat('E, d MMM y').format(widget.event.startTime),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInfoCard(
                    icon: Icons.access_time_rounded,
                    label: widget.event.sport.toLowerCase() == 'football'
                        ? 'KICKOFF'
                        : 'START TIME',
                    value:
                        '${DateFormat('HH:mm').format(widget.event.startTime)} WIB',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildInfoCard(
                    icon: Icons.timer_outlined,
                    label: 'DURATION',
                    value: '~${widget.event.durationMinutes} mins',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInfoCard(
                    icon: Icons.tv_rounded,
                    label: 'BROADCASTER',
                    value: widget.event.broadcastChannel,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Hype Breakdown (Dummy data based on mockup)
            Text(
              'HYPE BREAKDOWN',
              style: GoogleFonts.inter(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 16),
            _buildBreakdownRow('Importance', 80),
            const SizedBox(height: 8),
            _buildBreakdownRow('Competitiveness', 60),
            const SizedBox(height: 8),
            _buildBreakdownRow('Context', 40),

            const SizedBox(height: 32),

            // Actions
            Row(
              spacing: 16,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.notifications_none_rounded),
                    label: Text(
                      'Remind Me',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _shareEvent,
                    icon: const Icon(Icons.share_rounded),
                    label: Text(
                      'Share',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 48), // Bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.outfit(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
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

  Widget _buildBreakdownRow(String label, int score) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(
            label,
            style: GoogleFonts.inter(
              color: AppColors.textPrimary,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          flex: 4,
          child: Container(
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.surfaceHighlight,
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: score / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          width: 40,
          child: Text(
            score.toString(),
            textAlign: TextAlign.right,
            style: GoogleFonts.outfit(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
