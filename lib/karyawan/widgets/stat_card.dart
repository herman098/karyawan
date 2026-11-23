import 'package:flutter/material.dart';

import 'package:qnex/karyawan/theme/karyawan_theme.dart';

class StatCard extends StatelessWidget {
  const StatCard({
    required this.label,
    required this.value,
    required this.icon,
    this.note,
    super.key,
  });

  final String label;
  final String value;
  final IconData icon;
  final String? note;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: KaryawanColors.surface,
        borderRadius: BorderRadius.circular(KaryawanRadii.card),
        border: Border.all(color: KaryawanColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: KaryawanColors.warningBackground,
              borderRadius: BorderRadius.circular(KaryawanRadii.icon),
            ),
            child: Icon(icon, size: 21, color: KaryawanColors.brown),
          ),
          const SizedBox(height: 14),
          Text(label, style: KaryawanTextStyles.label),
          const SizedBox(height: 3),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            switchInCurve: Curves.easeOutCubic,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.25),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            child: FittedBox(
              key: ValueKey<String>(value),
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(value, style: KaryawanTextStyles.metric),
            ),
          ),
          if (note != null) ...[
            const SizedBox(height: 5),
            Text(
              note!,
              style: KaryawanTextStyles.label.copyWith(
                color: KaryawanColors.success,
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
