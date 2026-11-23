import 'package:flutter/material.dart';

import 'package:qnex/karyawan/state/karyawan_store.dart';
import 'package:qnex/karyawan/theme/karyawan_theme.dart';
import 'package:qnex/karyawan/widgets/karyawan_bottom_nav.dart';
import 'package:qnex/karyawan/screens/dashboard_screen.dart';
import 'package:qnex/karyawan/screens/laporan_harian_screen.dart';
import 'package:qnex/karyawan/screens/notifikasi_screen.dart';
import 'package:qnex/karyawan/screens/profil_screen.dart';
import 'package:qnex/karyawan/screens/stok_screen.dart';
import 'package:qnex/karyawan/screens/transaksi_baru_screen.dart';

class KaryawanMainScreen extends StatefulWidget {
  const KaryawanMainScreen({super.key});

  @override
  State<KaryawanMainScreen> createState() => _KaryawanMainScreenState();
}

class _KaryawanMainScreenState extends State<KaryawanMainScreen> {
  int _selectedIndex = 0;

  void _openCashier() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const TransaksiBaruScreen()),
    );
  }

  void _openNotifications() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const NotifikasiScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final store = KaryawanScope.of(context);
    return Scaffold(
      backgroundColor: KaryawanColors.background,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          DashboardScreen(
            onOpenNotifications: _openNotifications,
            onOpenCashier: _openCashier,
            onOpenStock: () => setState(() => _selectedIndex = 1),
            hasUnreadNotifications: store.hasUnreadNotifications,
          ),
          const StokScreen(),
          const LaporanHarianScreen(),
          const ProfilScreen(),
        ],
      ),
      bottomNavigationBar: KaryawanBottomNav(
        selectedIndex: _selectedIndex,
        onItemSelected: (index) => setState(() => _selectedIndex = index),
        onCashierTap: _openCashier,
      ),
    );
  }
}
