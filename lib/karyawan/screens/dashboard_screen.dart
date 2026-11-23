import 'package:flutter/material.dart';

import 'package:qnex/karyawan/dummy_data/karyawan_dummy.dart';
import 'package:qnex/karyawan/state/karyawan_store.dart';
import 'package:qnex/karyawan/theme/karyawan_theme.dart';
import 'package:qnex/karyawan/widgets/alert_card.dart';
import 'package:qnex/karyawan/widgets/health_score_card.dart';
import 'package:qnex/karyawan/widgets/hero_card.dart';
import 'package:qnex/karyawan/widgets/primary_button.dart';
import 'package:qnex/karyawan/widgets/stat_card.dart';
import 'package:qnex/karyawan/widgets/status_badge.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    required this.onOpenNotifications,
    required this.onOpenCashier,
    required this.onOpenStock,
    required this.hasUnreadNotifications,
    super.key,
  });

  final VoidCallback onOpenNotifications;
  final VoidCallback onOpenCashier;
  final VoidCallback onOpenStock;
  final bool hasUnreadNotifications;

  @override
  Widget build(BuildContext context) {
    final store = KaryawanScope.of(context);
    final restockItems = store.restockItems;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [KaryawanColors.backgroundTop, KaryawanColors.background],
          begin: Alignment.topCenter,
          end: Alignment.center,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            KaryawanSpacing.screen,
            12,
            KaryawanSpacing.screen,
            28,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DashboardHeader(
                    onOpenNotifications: onOpenNotifications,
                    hasUnreadNotifications: hasUnreadNotifications,
                  ),
                  const SizedBox(height: 22),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      '${store.timeGreeting}, ${KaryawanDummy.cashierName}',
                      key: ValueKey<String>(store.timeGreeting),
                      style: KaryawanTextStyles.greeting.copyWith(
                        color: KaryawanColors.brown,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Semangat jualan hari ini!',
                    style: KaryawanTextStyles.headline,
                  ),
                  const SizedBox(height: KaryawanSpacing.item),
                  HeroCard(
                    shiftTime: KaryawanDummy.shiftTime,
                    onOpenCashier: onOpenCashier,
                  ),
                  const SizedBox(height: KaryawanSpacing.item),
                  LayoutBuilder(
                    builder: (context, rowConstraints) {
                      final gap = rowConstraints.maxWidth < 350 ? 10.0 : 12.0;
                      return IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: StatCard(
                                label: 'Total Stok Tersedia',
                                value: '${store.totalStockUnits}',
                                icon: Icons.inventory_2_rounded,
                                note: store.lowStockCount == 0
                                    ? 'Stok aman'
                                    : '${store.lowStockCount} barang menipis',
                              ),
                            ),
                            SizedBox(width: gap),
                            Expanded(
                              child: StatCard(
                                label: 'Transaksi Hari Ini',
                                value: '${store.transactionsToday}',
                                icon: Icons.receipt_long_rounded,
                                note:
                                    'Pemasukan ${KaryawanDummy.formatRupiah(store.dailyIncome)}',
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: KaryawanSpacing.item),
                  HealthScoreCard(
                    progress: store.targetProgress,
                    percentLabel: store.targetPercent,
                  ),
                  const SizedBox(height: KaryawanSpacing.item),
                  PrimaryButton(
                    label: 'Buka Kasir / Transaksi Baru',
                    icon: Icons.shopping_cart_checkout_rounded,
                    onPressed: onOpenCashier,
                  ),
                  const SizedBox(height: 10),
                  PrimaryButton(
                    label: 'Pantau Daftar Stok',
                    icon: Icons.inventory_2_rounded,
                    isOutlined: true,
                    onPressed: onOpenStock,
                  ),
                  const SizedBox(height: KaryawanSpacing.section),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Perlu Restock',
                          style: KaryawanTextStyles.sectionTitle,
                        ),
                      ),
                      TextButton(
                        onPressed: onOpenStock,
                        style: TextButton.styleFrom(
                          foregroundColor: KaryawanColors.brownDark,
                          textStyle: KaryawanTextStyles.label.copyWith(
                            color: KaryawanColors.brownDark,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        child: const Text('Lihat stok'),
                      ),
                    ],
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOutCubic,
                    alignment: Alignment.topCenter,
                    child: restockItems.isEmpty
                        ? const _AllStockSafe()
                        : Column(
                            children: [
                              AlertCard(
                                message: store.restockSummary,
                                onTap: onOpenStock,
                              ),
                              const SizedBox(height: 9),
                              _RestockList(
                                items: restockItems,
                                onTap: onOpenStock,
                              ),
                            ],
                          ),
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

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({
    required this.onOpenNotifications,
    required this.hasUnreadNotifications,
  });

  final VoidCallback onOpenNotifications;
  final bool hasUnreadNotifications;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [KaryawanColors.primary, KaryawanColors.primaryDark],
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            'Q',
            style: KaryawanTextStyles.sectionTitle.copyWith(
              color: KaryawanColors.surface,
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                KaryawanDummy.storeName,
                style: KaryawanTextStyles.body.copyWith(
                  color: KaryawanColors.heading,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(KaryawanDummy.storeTagline, style: KaryawanTextStyles.label),
            ],
          ),
        ),
        Material(
          color: KaryawanColors.surface,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onOpenNotifications,
            customBorder: const CircleBorder(),
            child: SizedBox(
              width: 44,
              height: 44,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(
                    Icons.notifications_none_rounded,
                    color: KaryawanColors.brown,
                    size: 23,
                  ),
                  Positioned(
                    right: 10,
                    top: 9,
                    child: AnimatedScale(
                      scale: hasUnreadNotifications ? 1 : 0,
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutBack,
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: const BoxDecoration(
                          color: KaryawanColors.dangerAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AllStockSafe extends StatelessWidget {
  const _AllStockSafe();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: KaryawanColors.successBackground,
        borderRadius: BorderRadius.circular(KaryawanRadii.card),
        border: Border.all(color: KaryawanColors.successAccent),
      ),
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
              Icons.check_circle_rounded,
              color: KaryawanColors.success,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Semua stok aman. Tidak ada barang yang perlu restock.',
              style: KaryawanTextStyles.body.copyWith(
                color: KaryawanColors.success,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RestockList extends StatelessWidget {
  const _RestockList({required this.items, required this.onTap});

  final List<StockItem> items;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: KaryawanColors.surface,
        borderRadius: BorderRadius.circular(KaryawanRadii.card),
        border: Border.all(color: KaryawanColors.border),
      ),
      child: Column(
        children: [
          for (var index = 0; index < items.length; index++)
            _RestockRow(
              item: items[index],
              showDivider: index < items.length - 1,
              onTap: onTap,
            ),
        ],
      ),
    );
  }
}

class _RestockRow extends StatelessWidget {
  const _RestockRow({
    required this.item,
    required this.showDivider,
    required this.onTap,
  });

  final StockItem item;
  final bool showDivider;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final type = item.isOutOfStock
        ? StatusBadgeType.danger
        : StatusBadgeType.warning;
    return Material(
      color: KaryawanColors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: showDivider
                ? const Border(bottom: BorderSide(color: KaryawanColors.border))
                : null,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: KaryawanTextStyles.body.copyWith(
                    color: KaryawanColors.heading,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '${item.quantity} ${item.unit}',
                style: KaryawanTextStyles.label.copyWith(
                  color: KaryawanColors.bodyAlt,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 9),
              StatusBadge(
                label: item.isOutOfStock ? 'Habis' : 'Menipis',
                type: type,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
