import 'package:flutter/material.dart';

import 'package:qnex/karyawan/theme/karyawan_theme.dart';

class PrimaryButton extends StatefulWidget {
  const PrimaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.isOutlined = false,
    this.expand = true,
    super.key,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool isOutlined;
  final bool expand;

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final label = Text(
      widget.label,
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: KaryawanTextStyles.button,
    );
    final content = Row(
      mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          Icon(widget.icon, size: 19),
          const SizedBox(width: 9),
        ],
        if (widget.expand) Flexible(child: label) else label,
      ],
    );

    return AnimatedScale(
      scale: _pressed ? 0.985 : 1,
      duration: const Duration(milliseconds: 220),
      child: Material(
        color: widget.isOutlined
            ? KaryawanColors.surface
            : KaryawanColors.primaryDark,
        borderRadius: BorderRadius.circular(KaryawanRadii.button),
        child: InkWell(
          onTap: widget.onPressed,
          onHighlightChanged: (value) => setState(() => _pressed = value),
          borderRadius: BorderRadius.circular(KaryawanRadii.button),
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            decoration: BoxDecoration(
              gradient: widget.isOutlined
                  ? null
                  : const LinearGradient(
                      colors: [
                        KaryawanColors.primary,
                        KaryawanColors.primaryDark,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              border: widget.isOutlined
                  ? Border.all(color: KaryawanColors.amber, width: 1.2)
                  : null,
              borderRadius: BorderRadius.circular(KaryawanRadii.button),
            ),
            child: DefaultTextStyle(
              style: KaryawanTextStyles.button.copyWith(
                color: widget.isOutlined
                    ? KaryawanColors.brownDark
                    : KaryawanColors.surface,
              ),
              child: IconTheme(
                data: IconThemeData(
                  color: widget.isOutlined
                      ? KaryawanColors.brownDark
                      : KaryawanColors.surface,
                ),
                child: content,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
