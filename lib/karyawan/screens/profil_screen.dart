import 'package:flutter/material.dart';

import 'package:qnex/karyawan/dummy_data/karyawan_dummy.dart';
import 'package:qnex/karyawan/state/karyawan_store.dart';
import 'package:qnex/karyawan/theme/karyawan_theme.dart';
import 'package:qnex/karyawan/widgets/status_badge.dart';

class ProfilScreen extends StatelessWidget {
  const ProfilScreen({super.key});

  Future<void> _confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: KaryawanColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KaryawanRadii.card),
        ),
        title: Text(
          'Keluar dari akun?',
          style: KaryawanTextStyles.sectionTitle,
        ),
        content: Text(
          'Kamu perlu masuk kembali untuk melanjutkan shift.',
          style: KaryawanTextStyles.body.copyWith(
            color: KaryawanColors.secondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Batal',
              style: TextStyle(color: KaryawanColors.brown),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Keluar',
              style: TextStyle(color: KaryawanColors.danger),
            ),
          ),
        ],
      ),
    );

    if (shouldLogout != true || !context.mounted) return;
    // TODO: Sambungkan API Backend untuk logout dan mengakhiri sesi karyawan.
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            'Fitur keluar akun akan segera tersedia.',
            style: KaryawanTextStyles.body.copyWith(
              color: KaryawanColors.danger,
              fontWeight: FontWeight.w700,
            ),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: KaryawanColors.dangerBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(KaryawanRadii.button),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final store = KaryawanScope.of(context);
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          KaryawanSpacing.screen,
          18,
          KaryawanSpacing.screen,
          30,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Profil Saya', style: KaryawanTextStyles.headline),
                const SizedBox(height: 19),
                const _ProfileIdentity(),
                const SizedBox(height: KaryawanSpacing.item),
                _ShiftCard(shiftDate: store.shiftDate),
                const SizedBox(height: KaryawanSpacing.item),
                const _StoreCard(),
                const SizedBox(height: 26),
                _LogoutButton(onPressed: () => _confirmLogout(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileIdentity extends StatelessWidget {
  const _ProfileIdentity();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 23, horizontal: 18),
      decoration: BoxDecoration(
        color: KaryawanColors.surface,
        borderRadius: BorderRadius.circular(KaryawanRadii.card),
        border: Border.all(color: KaryawanColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 74,
            height: 74,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [KaryawanColors.primary, KaryawanColors.primaryDark],
              ),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Text(
              KaryawanDummy.cashierName.substring(0, 1).toUpperCase(),
              style: KaryawanTextStyles.headline.copyWith(
                color: KaryawanColors.surface,
                fontSize: 30,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            KaryawanDummy.cashierName,
            style: KaryawanTextStyles.sectionTitle.copyWith(fontSize: 19),
          ),
          const SizedBox(height: 5),
          const StatusBadge(label: 'Kasir', type: StatusBadgeType.warning),
        ],
      ),
    );
  }
}

class _ShiftCard extends StatelessWidget {
  const _ShiftCard({required this.shiftDate});

  final String shiftDate;

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      title: 'Informasi Shift',
      icon: Icons.schedule_rounded,
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.access_time_rounded,
            label: 'Jam kerja',
            value: KaryawanDummy.shiftTime,
          ),
          const Divider(height: 22, color: KaryawanColors.border),
          _InfoRow(
            icon: Icons.calendar_today_rounded,
            label: 'Tanggal',
            value: shiftDate,
          ),
          const Divider(height: 22, color: KaryawanColors.border),
          _InfoRow(
            icon: Icons.verified_rounded,
            label: 'Status',
            value: KaryawanDummy.shiftStatus,
            valueColor: KaryawanColors.success,
          ),
        ],
      ),
    );
  }
}

class _StoreCard extends StatelessWidget {
  const _StoreCard();

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      title: 'Informasi Toko',
      icon: Icons.storefront_rounded,
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.store_rounded,
            label: 'Nama toko',
            value: KaryawanDummy.storeName,
          ),
          const Divider(height: 22, color: KaryawanColors.border),
          _InfoRow(
            icon: Icons.location_on_rounded,
            label: 'Lokasi',
            value: KaryawanDummy.storeAddress,
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: KaryawanColors.surface,
        borderRadius: BorderRadius.circular(KaryawanRadii.card),
        border: Border.all(color: KaryawanColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 19, color: KaryawanColors.brown),
              const SizedBox(width: 8),
              Text(
                title,
                style: KaryawanTextStyles.sectionTitle.copyWith(fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 15),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 17, color: KaryawanColors.secondary),
        const SizedBox(width: 9),
        Expanded(child: Text(label, style: KaryawanTextStyles.label)),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: KaryawanTextStyles.body.copyWith(
              color: valueColor ?? KaryawanColors.heading,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: KaryawanColors.dangerBackground,
      borderRadius: BorderRadius.circular(KaryawanRadii.button),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(KaryawanRadii.button),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.logout_rounded, color: KaryawanColors.danger),
              const SizedBox(width: 9),
              Text(
                'Keluar dari akun',
                style: KaryawanTextStyles.button.copyWith(
                  color: KaryawanColors.danger,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
