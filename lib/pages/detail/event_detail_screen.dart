import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hype_grid/pages/home/bloc/home_bloc.dart';
import 'package:hype_grid/pages/home/bloc/home_event_state.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hype_grid/model/hype_event.dart';
import 'package:hype_grid/utils/app_colors.dart';
import 'package:hype_grid/pages/home/widget/sport_tag.dart';
import 'package:hype_grid/widget/hype_score_bar.dart';
import 'package:hype_grid/services/hype_repository.dart';
import 'package:hype_grid/services/hype_debouncer.dart';
import 'package:hype_grid/pages/detail/widget/shareable_event_card.dart';
import 'package:hype_grid/services/calendar_service.dart';
import 'package:intl/intl.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    with TickerProviderStateMixin {
  late int _localCommunityHype;
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  // New Controller for the limit info banner
  late AnimationController _limitInfoController;
  late Animation<double> _limitSlideAnimation;
  bool _isLimitInfoVisible = false;
  Timer? _hideLimitTimer;

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

    // Initialise professional slide animation
    _limitInfoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _limitSlideAnimation = CurvedAnimation(
      parent: _limitInfoController,
      curve: Curves.elasticOut,
    );

    _loadLocalContribution();
  }

  Future<void> _loadLocalContribution() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final key = 'hype_${widget.event.eventId}_$today';
    final savedContribution = prefs.getInt(key) ?? 0;
    
    if (mounted && savedContribution > 0) {
      setState(() {
        // We add the saved local contribution to the state
        // but we need to be careful not to double-count if the DB has been updated.
        // For simplicity as requested for "instant persistence", we trust the local plus.
        _localCommunityHype = widget.event.communityHype + savedContribution;
      });
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _limitInfoController.dispose();
    _hideLimitTimer?.cancel();
    super.dispose();
  }

  int get _computedHypeScore {
    return widget.event
        .copyWith(communityHype: _localCommunityHype)
        .totalHypeScore;
  }

  void _onHypeTapped() async {
    int added = await HypeDebouncer().increment(widget.event.eventId);
    if (added > 0) {
      final newTotal = _localCommunityHype + added;
      setState(() {
        _localCommunityHype = newTotal;
      });

      // Reflection: Update HomeBloc state so the Grid is updated instantly
      if (mounted) {
        context.read<HomeBloc>().add(
              UpdateCommunityHype(widget.event.eventId, newTotal),
            );
      }

      _animController.forward().then((_) => _animController.reverse());
    } else {
      _showLimitInfoBanner();
    }
  }

  void _showLimitInfoBanner() {
    if (!mounted) return;
    
    // Reset timer
    _hideLimitTimer?.cancel();
    
    setState(() {
      _isLimitInfoVisible = true;
    });
    
    _limitInfoController.forward();
    
    _hideLimitTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        _limitInfoController.reverse().then((_) {
          if (mounted) {
            setState(() {
              _isLimitInfoVisible = false;
            });
          }
        });
      }
    });
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
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share: $e'),
            backgroundColor: AppColors.surfaceHighlight,
            behavior: SnackBarBehavior.floating,
          ),
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
      body: Stack(
        children: [
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SportTag(sport: widget.event.sport, compact: false),
                      if (widget.event.metadata?['league'] != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          widget.event.metadata!['league'].toString().toUpperCase(),
                          style: GoogleFonts.inter(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: _onHypeTapped,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceHighlight,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.whatshot, size: 20, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Text(
                            '$_localCommunityHype',
                            style: GoogleFonts.outfit(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              widget.event.title,
              style: GoogleFonts.outfit(
                color: AppColors.textPrimary,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                height: 1.1,
              ),
            ),

            const SizedBox(height: 32),

            // Hype Score (Moved up)
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
                        ? 'KICK-OFF'
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
                    label: 'WATCH ON',
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
                    onPressed: () {
                      CalendarService.addEventToCalendar(widget.event);
                    },
                    icon: const Icon(Icons.event_available_rounded),
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
      _buildLimitOverlay(),
    ],
  ),
);
}

Widget _buildLimitOverlay() {
if (!_isLimitInfoVisible) return const SizedBox.shrink();

return Positioned(
  top: 0,
  left: 24,
  right: 24,
  child: AnimatedBuilder(
    animation: _limitSlideAnimation,
    builder: (context, child) {
      double yOffset = -80 * (1.0 - _limitSlideAnimation.value);
      return Transform.translate(
        offset: Offset(0, yOffset + 10),
        child: Opacity(
          opacity: _limitSlideAnimation.value.clamp(0.0, 1.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.surfaceHighlight,
                  AppColors.surfaceCard.withValues(alpha: 0.9),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  blurRadius: 25,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.info_outline_rounded,
                    color: AppColors.textSecondary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'DAILY LIMIT REACHED',
                        style: GoogleFonts.inter(
                          color: AppColors.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                      Text(
                        'Hype cap met for this event 🔥',
                        style: GoogleFonts.inter(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  ),
);
}

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(height: 12),
          Text(
            label,
            style: GoogleFonts.inter(
              color: AppColors.textSecondary.withValues(alpha: 0.7),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.outfit(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
