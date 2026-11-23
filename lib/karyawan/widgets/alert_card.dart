import 'package:flutter/material.dart';

import 'package:qnex/karyawan/theme/karyawan_theme.dart';

class AlertCard extends StatelessWidget {
  const AlertCard({required this.message, required this.onTap, super.key});

  final String message;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: KaryawanColors.dangerBackgroundAlt,
      borderRadius: BorderRadius.circular(KaryawanRadii.card),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(KaryawanRadii.card),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: KaryawanColors.surface.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(KaryawanRadii.icon),
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: KaryawanColors.dangerAccent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: KaryawanTextStyles.body.copyWith(
                    color: KaryawanColors.danger,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
              ),
              const SizedBox(width: 5),
              const Icon(
                Icons.chevron_right_rounded,
                color: KaryawanColors.danger,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
