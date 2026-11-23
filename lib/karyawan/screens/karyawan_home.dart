import 'package:flutter/material.dart';

import 'package:qnex/karyawan/screens/karyawan_main_screen.dart';
import 'package:qnex/karyawan/state/karyawan_store.dart';

class KaryawanHome extends StatefulWidget {
  const KaryawanHome({super.key});

  @override
  State<KaryawanHome> createState() => _KaryawanHomeState();
}

class _KaryawanHomeState extends State<KaryawanHome> {
  final KaryawanStore _store = KaryawanStore();

  @override
  void dispose() {
    _store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KaryawanScope(notifier: _store, child: const KaryawanMainScreen());
  }
}
