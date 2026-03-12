import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hype_grid/utils/app_colors.dart';

class HypeFilterFAB extends StatelessWidget {
  final bool isActive;
  final VoidCallback onTap;

  const HypeFilterFAB({
    super.key,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 24, right: 16),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: isActive
              ? const LinearGradient(
                  colors: [
                    AppColors.primary,
                    Color(0xFFB0304C),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isActive
              ? null
              : AppColors.surface.withValues(alpha: 0.95),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
            if (isActive)
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 2,
              ),
          ],
          border: Border.all(
            color: isActive
                ? Colors.white.withValues(alpha: 0.3)
                : AppColors.divider.withValues(alpha: 0.6),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                isActive
                    ? Icons.local_fire_department_rounded
                    : Icons.local_fire_department_outlined,
                key: ValueKey<bool>(isActive),
                color: isActive ? Colors.white : AppColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'HYPE MODE',
              style: GoogleFonts.outfit(
                color: isActive ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w900,
                fontSize: 14,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
