import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SportTag extends StatelessWidget {
  final String sport;
  final bool compact;

  const SportTag({super.key, required this.sport, this.compact = false});

  Color _getSportColor() {
    switch (sport.toLowerCase()) {
      case 'football':
        return const Color(0xFF4CAF50); // Mapped from AppColors
      case 'f1':
        return const Color(0xFFFF5722);
      case 'motogp':
        return const Color(0xFF2196F3);
      default:
        return Colors.grey;
    }
  }

  String _getSportIcon() {
    switch (sport.toLowerCase()) {
      case 'football':
        return '⚽';
      case 'f1':
        return '🏎️';
      case 'motogp':
        return '🏍️';
      default:
        return '🏅';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (!compact) ...[
          Text(_getSportIcon(), style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
        ],
        Text(
          sport.toUpperCase(),
          style: GoogleFonts.inter(
            color: _getSportColor(),
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}
