import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hype_grid/utils/app_colors.dart';

enum SportFilter {
  all('All', 'All', 'All'),
  football('Football', '⚽', 'Football'),
  f1('F1', '🏎️', 'F1'),
  motogp('MotoGP', '🏍️', 'MotoGP'),
  nba('NBA', '🏀', 'NBA'),
  mma('MMA', '🥊', 'MMA'),
  mlbb('MLBB', '🎮', 'MLBB'),
  lol('LoL', '🎮', 'LoL'),
  csgo('CSGO', '🔫', 'CSGO'),
  dota2('Dota 2', '🛡️', 'Dota 2'),
  valorant('Valorant', '🎯', 'Valorant');

  final String label;
  final String icon;
  final String searchKey;

  const SportFilter(this.label, this.icon, this.searchKey);
}

class SportFilterChips extends StatelessWidget {
  final SportFilter selectedFilter;
  final ValueChanged<SportFilter> onSelected;

  const SportFilterChips({
    super.key,
    required this.selectedFilter,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: SportFilter.values.map((filter) {
          final isSelected = selectedFilter == filter;
          final isLast = filter == SportFilter.values.last;

          return Padding(
            padding: EdgeInsets.only(right: isLast ? 0 : 8),
            child: GestureDetector(
              onTap: () => onSelected(filter),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surfaceHighlight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.divider.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (filter != SportFilter.all) ...[
                      Text(filter.icon, style: const TextStyle(fontSize: 13)),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      filter.label,
                      style: GoogleFonts.inter(
                        color:
                            isSelected ? Colors.white : AppColors.textSecondary,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
