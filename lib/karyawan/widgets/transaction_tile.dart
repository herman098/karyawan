import 'package:flutter/material.dart';

import 'package:qnex/karyawan/dummy_data/karyawan_dummy.dart';
import 'package:qnex/karyawan/theme/karyawan_theme.dart';
import 'package:qnex/karyawan/widgets/status_badge.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({
    required this.transaction,
    this.showDivider = true,
    super.key,
  });

  final SampleTransaction transaction;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: BoxDecoration(
        border: showDivider
            ? const Border(bottom: BorderSide(color: KaryawanColors.border))
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: KaryawanColors.warningBackground,
              borderRadius: BorderRadius.circular(KaryawanRadii.icon),
            ),
            child: Icon(
              transaction.paymentIcon,
              size: 19,
              color: KaryawanColors.brown,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.receiptNumber,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: KaryawanTextStyles.body.copyWith(
                    color: KaryawanColors.heading,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${transaction.time} · ${transaction.paymentLabel}',
                  style: KaryawanTextStyles.label,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                transaction.amount,
                style: KaryawanTextStyles.body.copyWith(
                  color: KaryawanColors.heading,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 5),
              const StatusBadge(
                label: 'Berhasil',
                type: StatusBadgeType.success,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
