import 'package:flutter/material.dart';

import 'package:qnex/karyawan/theme/karyawan_theme.dart';

class HeroCard extends StatelessWidget {
  const HeroCard({
    required this.shiftTime,
    required this.onOpenCashier,
    super.key,
  });

  final String shiftTime;
  final VoidCallback onOpenCashier;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(KaryawanRadii.hero),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [KaryawanColors.primary, KaryawanColors.primaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(KaryawanRadii.hero),
        ),
        child: Stack(
          children: [
            Positioned(
              right: 0,
              top: 3,
              child: Icon(
                Icons.waving_hand_rounded,
                size: 93,
                color: KaryawanColors.surface.withValues(alpha: 0.16),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 44),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: KaryawanColors.surface.withValues(alpha: 0.20),
                      borderRadius: BorderRadius.circular(KaryawanRadii.pill),
                    ),
                    child: Text(
                      'SHIFT AKTIF',
                      style: KaryawanTextStyles.label.copyWith(
                        color: KaryawanColors.surface,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.7,
                      ),
                    ),
                  ),
                  const SizedBox(height: 13),
                  Text(
                    'Shift kamu hari ini lancar!',
                    style: KaryawanTextStyles.sectionTitle.copyWith(
                      color: KaryawanColors.surface,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Jam kerja $shiftTime',
                    style: KaryawanTextStyles.body.copyWith(
                      color: KaryawanColors.surface.withValues(alpha: 0.88),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Material(
                    color: KaryawanColors.heading,
                    borderRadius: BorderRadius.circular(KaryawanRadii.pill),
                    child: InkWell(
                      onTap: onOpenCashier,
                      borderRadius: BorderRadius.circular(KaryawanRadii.pill),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 17,
                          vertical: 10,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Buka Kasir',
                              style: KaryawanTextStyles.button.copyWith(
                                color: KaryawanColors.surface,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 7),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              size: 16,
                              color: KaryawanColors.surface,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
