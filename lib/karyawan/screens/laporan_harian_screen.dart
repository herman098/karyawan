import 'package:flutter/material.dart';

import 'package:qnex/karyawan/dummy_data/karyawan_dummy.dart';
import 'package:qnex/karyawan/state/karyawan_store.dart';
import 'package:qnex/karyawan/theme/karyawan_theme.dart';
import 'package:qnex/karyawan/widgets/status_badge.dart';
import 'package:qnex/karyawan/widgets/transaction_tile.dart';

class LaporanHarianScreen extends StatelessWidget {
  const LaporanHarianScreen({super.key});

  static int _hourOf(SampleTransaction transaction) {
    return int.tryParse(transaction.time.split('.').first) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final store = KaryawanScope.of(context);
    final transactions = store.transactions;
    final pagi = transactions.where((item) => _hourOf(item) < 12).toList();
    final siang = transactions
        .where((item) => _hourOf(item) >= 12 && _hourOf(item) < 15)
        .toList();
    final sore = transactions
        .where((item) => _hourOf(item) >= 15 && _hourOf(item) < 18)
        .toList();
    final malam = transactions.where((item) => _hourOf(item) >= 18).toList();

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          KaryawanSpacing.screen,
          18,
          KaryawanSpacing.screen,
          28,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Laporan Hari Ini', style: KaryawanTextStyles.headline),
                const SizedBox(height: 5),
                Text(
                  'Ringkasan transaksi pada shift kamu',
                  style: KaryawanTextStyles.body.copyWith(
                    color: KaryawanColors.secondary,
                  ),
                ),
                const SizedBox(height: KaryawanSpacing.item),
                _IncomeCard(income: store.dailyIncome),
                const SizedBox(height: KaryawanSpacing.item),
                Row(
                  children: [
                    Expanded(
                      child: _ReportMetric(
                        icon: Icons.receipt_long_rounded,
                        label: 'Jumlah transaksi',
                        value: '${store.transactionsToday}',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ReportMetric(
                        icon: Icons.calculate_rounded,
                        label: 'Rata-rata transaksi',
                        value: KaryawanDummy.formatRupiah(
                          store.averageTransaction,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: KaryawanSpacing.section),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Transaksi terbaru',
                        style: KaryawanTextStyles.sectionTitle,
                      ),
                    ),
                    const StatusBadge(
                      label: 'Hari ini',
                      type: StatusBadgeType.warning,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                AnimatedSize(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutCubic,
                  alignment: Alignment.topCenter,
                  child: Column(
                    children: [
                      if (pagi.isNotEmpty) ...[
                        const _SessionLabel(label: 'Pagi'),
                        _TransactionGroup(transactions: pagi),
                        const SizedBox(height: 14),
                      ],
                      if (siang.isNotEmpty) ...[
                        const _SessionLabel(label: 'Siang'),
                        _TransactionGroup(transactions: siang),
                        const SizedBox(height: 14),
                      ],
                      if (sore.isNotEmpty) ...[
                        const _SessionLabel(label: 'Sore'),
                        _TransactionGroup(transactions: sore),
                        const SizedBox(height: 14),
                      ],
                      if (malam.isNotEmpty) ...[
                        const _SessionLabel(label: 'Malam'),
                        _TransactionGroup(transactions: malam),
                      ],
                      if (transactions.isEmpty) const _EmptyTransactions(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IncomeCard extends StatelessWidget {
  const _IncomeCard({required this.income});

  final int income;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [KaryawanColors.primary, KaryawanColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(KaryawanRadii.hero),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total pemasukan hari ini',
            style: KaryawanTextStyles.body.copyWith(
              color: KaryawanColors.surface.withValues(alpha: 0.88),
            ),
          ),
          const SizedBox(height: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            child: Text(
              KaryawanDummy.formatRupiah(income),
              key: ValueKey<int>(income),
              style: KaryawanTextStyles.metric.copyWith(
                color: KaryawanColors.surface,
                fontSize: 28,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(
                Icons.schedule_rounded,
                size: 15,
                color: KaryawanColors.surface,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  'Diperbarui sesuai transaksi hari ini',
                  style: KaryawanTextStyles.label.copyWith(
                    color: KaryawanColors.surface.withValues(alpha: 0.82),
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReportMetric extends StatelessWidget {
  const _ReportMetric({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 128),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: KaryawanColors.surface,
        borderRadius: BorderRadius.circular(KaryawanRadii.card),
        border: Border.all(color: KaryawanColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 21, color: KaryawanColors.brown),
          const SizedBox(height: 12),
          Text(label, style: KaryawanTextStyles.label),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: KaryawanTextStyles.body.copyWith(
                color: KaryawanColors.heading,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionLabel extends StatelessWidget {
  const _SessionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Text(
        label,
        style: KaryawanTextStyles.label.copyWith(
          color: KaryawanColors.brown,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _TransactionGroup extends StatelessWidget {
  const _TransactionGroup({required this.transactions});

  final List<SampleTransaction> transactions;

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
          for (var index = 0; index < transactions.length; index++)
            TransactionTile(
              transaction: transactions[index],
              showDivider: index < transactions.length - 1,
            ),
        ],
      ),
    );
  }
}

class _EmptyTransactions extends StatelessWidget {
  const _EmptyTransactions();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 34, horizontal: 18),
      decoration: BoxDecoration(
        color: KaryawanColors.surface,
        borderRadius: BorderRadius.circular(KaryawanRadii.card),
        border: Border.all(color: KaryawanColors.border),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.receipt_long_outlined,
            size: 32,
            color: KaryawanColors.brown,
          ),
          const SizedBox(height: 8),
          Text(
            'Belum ada transaksi hari ini',
            style: KaryawanTextStyles.body.copyWith(
              color: KaryawanColors.heading,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Transaksi baru akan muncul di sini.',
            style: KaryawanTextStyles.label,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
