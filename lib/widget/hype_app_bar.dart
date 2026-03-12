import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hype_grid/utils/app_colors.dart';

class HypeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HypeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.whatshot, size: 22, color: AppColors.primary),
            const SizedBox(width: 10),
            Text(
              'HYPE',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w900,
                color: AppColors.primary,
                letterSpacing: -0.5,
                fontSize: 24,
              ),
            ),
            Text(
              'GRID',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
                fontSize: 24,
              ),
            ),
          ],
        ),
      ),
      actions: const [
        SizedBox(width: 48), // Balancing for the centerTitle if needed, or lead spacing
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
