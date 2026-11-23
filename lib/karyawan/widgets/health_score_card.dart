import 'package:flutter/material.dart';

import 'package:qnex/karyawan/theme/karyawan_theme.dart';
import 'package:qnex/karyawan/widgets/status_badge.dart';

class HealthScoreCard extends StatelessWidget {
  const HealthScoreCard({
    required this.progress,
    required this.percentLabel,
    super.key,
  });

  final double progress;
  final String percentLabel;

  @override
  Widget build(BuildContext context) {
    final (message, badgeLabel, badgeType) = switch (progress) {
      >= 1.0 => (
        'Target tercapai. Kerja bagus hari ini!',
        'Target tercapai',
        StatusBadgeType.success,
      ),
      >= 0.7 => (
        'Sedikit lagi! Pertahankan semangatmu.',
        'Sesuai target',
        StatusBadgeType.success,
      ),
      _ => (
        'Ayo kejar target sebelum shift berakhir.',
        'Perlu ditingkatkan',
        StatusBadgeType.warning,
      ),
    };

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: KaryawanColors.surface,
        borderRadius: BorderRadius.circular(KaryawanRadii.card),
        border: Border.all(color: KaryawanColors.border),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            height: 72,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.expand(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: progress),
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) => CircularProgressIndicator(
                      value: value,
                      strokeWidth: 7,
                      strokeCap: StrokeCap.round,
                      backgroundColor: KaryawanColors.successBackground,
                      valueColor: const AlwaysStoppedAnimation(
                        KaryawanColors.success,
                      ),
                    ),
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: Text(
                    percentLabel,
                    key: ValueKey<String>(percentLabel),
                    style: KaryawanTextStyles.body.copyWith(
                      color: KaryawanColors.heading,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Target Penjualan Hari Ini',
                  style: KaryawanTextStyles.sectionTitle.copyWith(fontSize: 15),
                ),
                const SizedBox(height: 5),
                Text(
                  message,
                  style: KaryawanTextStyles.label.copyWith(height: 1.45),
                ),
                const SizedBox(height: 9),
                StatusBadge(label: badgeLabel, type: badgeType),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
