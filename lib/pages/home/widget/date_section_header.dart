import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hype_grid/utils/app_colors.dart';
import 'package:intl/intl.dart';

class DateSectionHeader extends StatelessWidget {
  final DateTime date;

  const DateSectionHeader({super.key, required this.date});

  String _getRelativeDayString() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final upcomingDate = DateTime(date.year, date.month, date.day);

    final difference = upcomingDate.difference(today).inDays;

    if (difference == 0) return 'TODAY';
    if (difference == 1) return 'TOMORROW';

    return DateFormat('EEEE').format(date).toUpperCase(); // e.g., MONDAY
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 32, bottom: 16),
      child: Text(
        '${_getRelativeDayString()}, ${DateFormat('d MMM').format(date).toUpperCase()}',
        style: GoogleFonts.inter(
          color: AppColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 2.0,
        ),
      ),
    );
  }
}
