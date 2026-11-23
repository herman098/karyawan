import 'package:flutter/material.dart';

class StockItem {
  const StockItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    this.imageAsset,
  });

  final String id;
  final String name;
  final int quantity;
  final String unit;
  final String? imageAsset;

  bool get isOutOfStock => quantity <= 0;

  bool get isLowStock =>
      !isOutOfStock && quantity <= KaryawanDummy.lowStockThreshold;

  StockItem copyWith({int? quantity}) {
    return StockItem(
      id: id,
      name: name,
      quantity: quantity ?? this.quantity,
      unit: unit,
      imageAsset: imageAsset,
    );
  }
}

class ProductItem {
  const ProductItem({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.icon,
    required this.availableStock,
    required this.unit,
    this.imageAsset,
  });

  final String id;
  final String name;
  final String category;
  final int price;
  final IconData icon;
  final int availableStock;
  final String unit;
  final String? imageAsset;

  String get formattedPrice => KaryawanDummy.formatRupiah(price);

  ProductItem copyWith({int? availableStock}) {
    return ProductItem(
      id: id,
      name: name,
      category: category,
      price: price,
      icon: icon,
      availableStock: availableStock ?? this.availableStock,
      unit: unit,
      imageAsset: imageAsset,
    );
  }
}

enum PaymentMethod { cash, qris, transfer }

enum NotificationType { stock, transaction, info }

class SampleTransaction {
  const SampleTransaction({
    required this.receiptNumber,
    required this.time,
    required this.paymentMethod,
    required this.amountValue,
  });

  final String receiptNumber;
  final String time;
  final PaymentMethod paymentMethod;
  final int amountValue;

  String get amount => KaryawanDummy.formatRupiah(amountValue);

  String get paymentLabel {
    return switch (paymentMethod) {
      PaymentMethod.cash => 'Tunai',
      PaymentMethod.qris => 'QRIS',
      PaymentMethod.transfer => 'Transfer',
    };
  }

  IconData get paymentIcon {
    return switch (paymentMethod) {
      PaymentMethod.cash => Icons.payments_rounded,
      PaymentMethod.qris => Icons.qr_code_rounded,
      PaymentMethod.transfer => Icons.account_balance_rounded,
    };
  }
}

class SampleNotification {
  const SampleNotification({
    required this.title,
    required this.message,
    required this.time,
    required this.icon,
    required this.type,
    required this.isRead,
  });

  final String title;
  final String message;
  final String time;
  final IconData icon;
  final NotificationType type;
  final bool isRead;
}

abstract final class KaryawanDummy {
  static const cashierName = 'Dina';
  static const storeName = 'QNEX';
  static const storeTagline = 'Toko tempat kamu bertugas';
  static const shiftTime = '14.00 – 22.00';
  static const shiftStatus = 'Sedang bertugas';
  static const storeAddress = 'Jl. Melati No. 18, Bandung';
  static const lowStockThreshold = 5;
  static const dailyTargetAmount = 3000000;
  static const initialDailyIncome = 2482000;
  static const initialTransactionCount = 38;

  static const stockItems = <StockItem>[
    StockItem(
      id: 'susu',
      name: 'Susu UHT 1L',
      quantity: 2,
      unit: 'pcs',
      imageAsset: 'assets/karyawan/stock/susu.jpg',
    ),
    StockItem(
      id: 'minyak',
      name: 'Minyak Goreng 2L',
      quantity: 0,
      unit: 'pcs',
      imageAsset: 'assets/karyawan/stock/minyak.jpg',
    ),
    StockItem(
      id: 'mi',
      name: 'Mi Instan Goreng',
      quantity: 5,
      unit: 'pcs',
      imageAsset: 'assets/karyawan/stock/mi.jpg',
    ),
    StockItem(
      id: 'air',
      name: 'Air Mineral 600ml',
      quantity: 7,
      unit: 'botol',
      imageAsset: 'assets/karyawan/stock/air.jpg',
    ),
    StockItem(
      id: 'kopi',
      name: 'Kopi Susu Botol',
      quantity: 12,
      unit: 'botol',
      imageAsset: 'assets/karyawan/stock/kopi.jpg',
    ),
    StockItem(
      id: 'roti',
      name: 'Roti Cokelat',
      quantity: 9,
      unit: 'pcs',
      imageAsset: 'assets/karyawan/stock/roti.jpg',
    ),
    StockItem(id: 'tisu', name: 'Tisu Wajah', quantity: 23, unit: 'pak'),
    StockItem(id: 'sabun', name: 'Sabun Mandi', quantity: 15, unit: 'pcs'),
  ];

  static const transactions = <SampleTransaction>[
    SampleTransaction(
      receiptNumber: 'QN-261119-038',
      time: '20.56',
      paymentMethod: PaymentMethod.qris,
      amountValue: 128000,
    ),
    SampleTransaction(
      receiptNumber: 'QN-261119-037',
      time: '20.32',
      paymentMethod: PaymentMethod.cash,
      amountValue: 46500,
    ),
    SampleTransaction(
      receiptNumber: 'QN-261119-036',
      time: '20.15',
      paymentMethod: PaymentMethod.transfer,
      amountValue: 215000,
    ),
  ];

  static const notifications = <SampleNotification>[
    SampleNotification(
      title: 'Stok mulai menipis',
      message: 'Susu UHT 1L tersisa 2 pcs. Cek stok sebelum kehabisan.',
      time: '5 menit lalu',
      icon: Icons.inventory_2_rounded,
      type: NotificationType.stock,
      isRead: false,
    ),
    SampleNotification(
      title: 'Transaksi berhasil',
      message: 'Transaksi QRIS sebesar Rp 128.000 berhasil dicatat.',
      time: '18 menit lalu',
      icon: Icons.receipt_long_rounded,
      type: NotificationType.transaction,
      isRead: false,
    ),
    SampleNotification(
      title: 'Shift dimulai',
      message: 'Semangat bertugas, Dina! Shift kamu berakhir pukul 22.00.',
      time: '7 jam lalu',
      icon: Icons.info_outline_rounded,
      type: NotificationType.info,
      isRead: true,
    ),
  ];

  static const products = <ProductItem>[
    ProductItem(
      id: 'susu',
      name: 'Susu UHT 1L',
      category: 'Minuman',
      price: 18500,
      icon: Icons.local_drink_rounded,
      availableStock: 2,
      unit: 'pcs',
      imageAsset: 'assets/karyawan/stock/susu.jpg',
    ),
    ProductItem(
      id: 'air',
      name: 'Air Mineral 600ml',
      category: 'Minuman',
      price: 4500,
      icon: Icons.water_drop_rounded,
      availableStock: 7,
      unit: 'botol',
      imageAsset: 'assets/karyawan/stock/air.jpg',
    ),
    ProductItem(
      id: 'kopi',
      name: 'Kopi Susu Botol',
      category: 'Minuman',
      price: 12000,
      icon: Icons.coffee_rounded,
      availableStock: 12,
      unit: 'botol',
      imageAsset: 'assets/karyawan/stock/kopi.jpg',
    ),
    ProductItem(
      id: 'mi',
      name: 'Mi Instan Goreng',
      category: 'Makanan',
      price: 3500,
      icon: Icons.ramen_dining_rounded,
      availableStock: 5,
      unit: 'pcs',
      imageAsset: 'assets/karyawan/stock/mi.jpg',
    ),
    ProductItem(
      id: 'roti',
      name: 'Roti Cokelat',
      category: 'Makanan',
      price: 8500,
      icon: Icons.bakery_dining_rounded,
      availableStock: 9,
      unit: 'pcs',
      imageAsset: 'assets/karyawan/stock/roti.jpg',
    ),
    ProductItem(
      id: 'minyak',
      name: 'Minyak Goreng 2L',
      category: 'Rumah tangga',
      price: 36500,
      icon: Icons.oil_barrel_rounded,
      availableStock: 0,
      unit: 'pcs',
      imageAsset: 'assets/karyawan/stock/minyak.jpg',
    ),
    ProductItem(
      id: 'tisu',
      name: 'Tisu Wajah',
      category: 'Rumah tangga',
      price: 11000,
      icon: Icons.cleaning_services_rounded,
      availableStock: 23,
      unit: 'pak',
    ),
    ProductItem(
      id: 'sabun',
      name: 'Sabun Mandi',
      category: 'Perawatan',
      price: 7500,
      icon: Icons.spa_rounded,
      availableStock: 15,
      unit: 'pcs',
    ),
  ];

  static const _dayNames = <String>[
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  static const _monthNames = <String>[
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  static String formatRupiah(int amount) {
    final grouped = amount.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => '.',
    );
    return 'Rp $grouped';
  }

  static String formatDateId(DateTime date) {
    return '${_dayNames[date.weekday - 1]}, ${date.day} '
        '${_monthNames[date.month - 1]} ${date.year}';
  }

  static String formatClock(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour.$minute';
  }
}
