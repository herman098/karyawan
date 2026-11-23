import 'package:flutter/material.dart';

import 'package:qnex/karyawan/theme/karyawan_theme.dart';

class KaryawanBottomNav extends StatelessWidget {
  const KaryawanBottomNav({
    required this.selectedIndex,
    required this.onItemSelected,
    required this.onCashierTap,
    super.key,
  });

  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final VoidCallback onCashierTap;

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final navHeight = 78.0 + ((textScale - 1).clamp(0.0, 1.0) * 26);

    return Container(
      color: KaryawanColors.amber,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: navHeight,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Positioned.fill(
                top: 13,
                child: Container(
                  decoration: const BoxDecoration(
                    color: KaryawanColors.amber,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: Row(
                    children: [
                      _KaryawanNavItem(
                        icon: Icons.home_rounded,
                        label: 'Beranda',
                        selected: selectedIndex == 0,
                        onTap: () => onItemSelected(0),
                      ),
                      _KaryawanNavItem(
                        icon: Icons.inventory_2_rounded,
                        label: 'Stok',
                        selected: selectedIndex == 1,
                        onTap: () => onItemSelected(1),
                      ),
                      const SizedBox(width: 70),
                      _KaryawanNavItem(
                        icon: Icons.receipt_long_rounded,
                        label: 'Laporan',
                        selected: selectedIndex == 2,
                        onTap: () => onItemSelected(2),
                      ),
                      _KaryawanNavItem(
                        icon: Icons.person_rounded,
                        label: 'Akun',
                        selected: selectedIndex == 3,
                        onTap: () => onItemSelected(3),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: -1,
                child: Semantics(
                  button: true,
                  label: 'Buka kasir',
                  child: Material(
                    color: KaryawanColors.primaryDark,
                    shape: const CircleBorder(
                      side: BorderSide(color: KaryawanColors.surface, width: 4),
                    ),
                    child: InkWell(
                      onTap: onCashierTap,
                      customBorder: const CircleBorder(),
                      child: const SizedBox(
                        width: 61,
                        height: 61,
                        child: Icon(
                          Icons.shopping_cart_rounded,
                          color: KaryawanColors.surface,
                          size: 26,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: navHeight - 17,
                child: Text(
                  'Kasir',
                  style: KaryawanTextStyles.label.copyWith(
                    color: KaryawanColors.heading,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KaryawanNavItem extends StatelessWidget {
  const _KaryawanNavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? KaryawanColors.heading
        : KaryawanColors.heading.withValues(alpha: 0.50);
    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        child: Material(
          color: KaryawanColors.transparent,
          child: InkWell(
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              padding: const EdgeInsets.only(top: 5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TweenAnimationBuilder<Color?>(
                    tween: ColorTween(end: color),
                    duration: const Duration(milliseconds: 220),
                    builder: (context, animatedColor, child) =>
                        Icon(icon, size: 21, color: animatedColor),
                  ),
                  const SizedBox(height: 3),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    style: KaryawanTextStyles.label.copyWith(
                      color: color,
                      fontSize: 10,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    ),
                    child: Text(label),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
