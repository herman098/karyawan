import 'package:flutter/material.dart';

import 'package:qnex/karyawan/theme/karyawan_theme.dart';

class KaryawanBackButton extends StatelessWidget {
  const KaryawanBackButton({
    required this.onPressed,
    this.showLabel = false,
    super.key,
  });

  final VoidCallback onPressed;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Kembali ke halaman sebelumnya',
      child: Tooltip(
        message: 'Kembali ke halaman sebelumnya',
        child: Material(
          color: showLabel
              ? KaryawanColors.surface
              : KaryawanColors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(KaryawanRadii.pill),
            side: showLabel
                ? const BorderSide(color: KaryawanColors.border)
                : BorderSide.none,
          ),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(KaryawanRadii.pill),
            child: Padding(
              padding: EdgeInsets.only(right: showLabel ? 8 : 0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: showLabel
                          ? KaryawanColors.transparent
                          : KaryawanColors.surface,
                      shape: BoxShape.circle,
                      border: showLabel
                          ? null
                          : Border.all(color: KaryawanColors.border),
                    ),
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      color: KaryawanColors.brown,
                      size: 20,
                    ),
                  ),
                  if (showLabel) ...[
                    const SizedBox(width: 7),
                    Text(
                      'Kembali',
                      style: KaryawanTextStyles.body.copyWith(
                        color: KaryawanColors.brownDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
