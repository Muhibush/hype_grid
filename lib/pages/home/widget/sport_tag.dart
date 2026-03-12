import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hype_grid/utils/app_colors.dart';

class SportTag extends StatelessWidget {
  final String sport;
  final bool compact;

  const SportTag({super.key, required this.sport, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Text(
      sport.toUpperCase(),
      style: GoogleFonts.inter(
        color: AppColors.textSecondary,
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.5,
      ),
    );
  }
}
