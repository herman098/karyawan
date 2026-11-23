import 'package:flutter/material.dart';

import 'package:qnex/karyawan/theme/karyawan_theme.dart';

enum StatusBadgeType { success, warning, danger }

class StatusBadge extends StatelessWidget {
  const StatusBadge({required this.label, required this.type, super.key});

  final String label;
  final StatusBadgeType type;

  @override
  Widget build(BuildContext context) {
    final (foreground, background) = switch (type) {
      StatusBadgeType.success => (
        KaryawanColors.success,
        KaryawanColors.successBackground,
      ),
      StatusBadgeType.warning => (
        KaryawanColors.brownDark,
        KaryawanColors.warningBackground,
      ),
      StatusBadgeType.danger => (
        KaryawanColors.danger,
        KaryawanColors.dangerBackground,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(KaryawanRadii.pill),
      ),
      child: Text(
        label,
        style: KaryawanTextStyles.label.copyWith(
          color: foreground,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }
}
