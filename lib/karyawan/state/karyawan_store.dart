import 'package:flutter/widgets.dart';

import 'package:qnex/karyawan/dummy_data/karyawan_dummy.dart';

class KaryawanStore extends ChangeNotifier {
  KaryawanStore({
    List<StockItem>? stock,
    List<ProductItem>? products,
    List<SampleTransaction>? transactions,
    List<SampleNotification>? notifications,
    List<bool>? readStates,
    DateTime Function()? now,
  }) : _stock = List<StockItem>.of(stock ?? KaryawanDummy.stockItems),
       _products = List<ProductItem>.of(products ?? KaryawanDummy.products),
       _transactions = List<SampleTransaction>.of(
         transactions ?? KaryawanDummy.transactions,
       ),
       _notifications = List<SampleNotification>.of(
         notifications ?? KaryawanDummy.notifications,
       ),
       _readStates = List<bool>.of(
         readStates ??
             (notifications ?? KaryawanDummy.notifications).map(
               (notification) => notification.isRead,
             ),
       ),
       _now = now ?? DateTime.now;

  final List<StockItem> _stock;
  final List<ProductItem> _products;
  final List<SampleTransaction> _transactions;
  final List<SampleNotification> _notifications;
  final List<bool> _readStates;
  final DateTime Function() _now;
  int _receiptSequence = 38;
  int _todayIncome = KaryawanDummy.initialDailyIncome;
  int _todayTransactionCount = KaryawanDummy.initialTransactionCount;

  List<StockItem> get stock => List<StockItem>.unmodifiable(_stock);

  List<ProductItem> get products => List<ProductItem>.unmodifiable(_products);

  List<SampleTransaction> get transactions =>
      List<SampleTransaction>.unmodifiable(_transactions);

  List<SampleNotification> get notifications =>
      List<SampleNotification>.unmodifiable(_notifications);

  List<bool> get readStates => List<bool>.unmodifiable(_readStates);

  bool get hasUnreadNotifications => _readStates.contains(false);

  String get shiftDate => KaryawanDummy.formatDateId(_now());

  String get timeGreeting {
    final hour = _now().hour;
    if (hour < 11) return 'Selamat pagi';
    if (hour < 15) return 'Selamat siang';
    if (hour < 18) return 'Selamat sore';
    return 'Selamat malam';
  }

  int get totalStockUnits =>
      _stock.fold(0, (total, item) => total + item.quantity);

  int get lowStockCount => _stock.where((item) => item.isLowStock).length;

  int get outOfStockCount => _stock.where((item) => item.isOutOfStock).length;

  List<StockItem> get restockItems =>
      _stock.where((item) => item.isOutOfStock || item.isLowStock).toList();

  String get restockSummary {
    final low = lowStockCount;
    final out = outOfStockCount;
    if (low + out == 0) return 'Semua stok dalam kondisi aman.';
    return '${low + out} barang perlu restock: $low menipis dan $out habis.';
  }

  int get transactionsToday => _todayTransactionCount;

  int get dailyIncome => _todayIncome;

  int get averageTransaction =>
      _todayTransactionCount == 0 ? 0 : _todayIncome ~/ _todayTransactionCount;

  double get targetProgress =>
      (dailyIncome / KaryawanDummy.dailyTargetAmount).clamp(0.0, 1.0);

  String get targetPercent => '${(targetProgress * 100).floor()}%';

  ProductItem? productById(String id) {
    for (final product in _products) {
      if (product.id == id) return product;
    }
    return null;
  }

  void markRead(int index) {
    if (index < 0 || index >= _readStates.length) return;
    if (_readStates[index]) return;
    _readStates[index] = true;
    notifyListeners();
  }

  void markAllRead() {
    if (!hasUnreadNotifications) return;
    for (var index = 0; index < _readStates.length; index++) {
      _readStates[index] = true;
    }
    notifyListeners();
  }

  SampleTransaction checkout({
    required Map<String, int> cart,
    required PaymentMethod method,
  }) {
    var total = 0;
    for (final entry in cart.entries) {
      if (entry.value <= 0) continue;
      final index = _products.indexWhere((product) => product.id == entry.key);
      if (index < 0) continue;
      final product = _products[index];
      final quantity = entry.value > product.availableStock
          ? product.availableStock
          : entry.value;
      if (quantity <= 0) continue;

      total += product.price * quantity;
      _products[index] = product.copyWith(
        availableStock: product.availableStock - quantity,
      );

      final stockIndex = _stock.indexWhere((item) => item.id == product.id);
      if (stockIndex >= 0) {
        final item = _stock[stockIndex];
        final remaining = item.quantity - quantity;
        _stock[stockIndex] = item.copyWith(
          quantity: remaining < 0 ? 0 : remaining,
        );
      }
    }

    final transaction = SampleTransaction(
      receiptNumber: _nextReceiptNumber(),
      time: KaryawanDummy.formatClock(_now()),
      paymentMethod: method,
      amountValue: total,
    );
    _transactions.insert(0, transaction);
    _todayIncome += total;
    _todayTransactionCount += 1;
    notifyListeners();
    return transaction;
  }

  String _nextReceiptNumber() {
    final now = _now();
    final year = (now.year % 100).toString().padLeft(2, '0');
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    _receiptSequence += 1;
    return 'QN-$year$month$day-${_receiptSequence.toString().padLeft(3, '0')}';
  }
}

class KaryawanScope extends InheritedNotifier<KaryawanStore> {
  const KaryawanScope({
    required KaryawanStore super.notifier,
    required super.child,
    super.key,
  });

  static KaryawanStore of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<KaryawanScope>();
    assert(scope != null, 'KaryawanScope tidak ditemukan pada widget tree.');
    return scope!.notifier!;
  }
}
