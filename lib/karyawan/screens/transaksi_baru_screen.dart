import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:qnex/karyawan/dummy_data/karyawan_dummy.dart';
import 'package:qnex/karyawan/state/karyawan_store.dart';
import 'package:qnex/karyawan/theme/karyawan_theme.dart';
import 'package:qnex/karyawan/widgets/karyawan_back_button.dart';
import 'package:qnex/karyawan/widgets/status_badge.dart';

class TransaksiBaruScreen extends StatefulWidget {
  const TransaksiBaruScreen({super.key});

  @override
  State<TransaksiBaruScreen> createState() => _TransaksiBaruScreenState();
}

class _TransaksiBaruScreenState extends State<TransaksiBaruScreen> {
  final _searchController = TextEditingController();
  final _cashReceivedController = TextEditingController();
  final Map<String, int> _cart = {};
  String _query = '';
  String _category = 'Semua';
  PaymentMethod _paymentMethod = PaymentMethod.cash;
  bool _stockWarning = false;

  KaryawanStore get _store => KaryawanScope.of(context);

  ProductItem? _productById(String id) => _store.productById(id);

  int get _itemCount =>
      _cart.values.fold(0, (total, quantity) => total + quantity);

  int get _total => _cart.entries.fold(0, (total, entry) {
    final product = _productById(entry.key);
    return total + (product == null ? 0 : product.price * entry.value);
  });

  int get _cashReceived =>
      int.tryParse(_cashReceivedController.text.trim()) ?? 0;

  int get _changeDue {
    final change = _cashReceived - _total;
    return change > 0 ? change : 0;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _cashReceivedController.dispose();
    super.dispose();
  }

  void _changeQuantity(
    ProductItem product,
    int change, {
    bool showInlineWarning = false,
  }) {
    final current = _cart[product.id] ?? 0;
    final next = current + change;

    if (change > 0 && next > product.availableStock) {
      if (showInlineWarning) {
        setState(() => _stockWarning = true);
      } else {
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                'Stok ${product.name} tinggal '
                '${product.availableStock} ${product.unit}.',
              ),
            ),
          );
      }
      return;
    }

    HapticFeedback.selectionClick();
    setState(() {
      _stockWarning = false;
      if (next <= 0) {
        _cart.remove(product.id);
      } else {
        _cart[product.id] = next;
      }
      if (_cart.isEmpty) _cashReceivedController.clear();
    });
  }

  Future<void> _handleBack() async {
    if (_cart.isEmpty) {
      Navigator.of(context).pop();
      return;
    }

    final shouldDiscard = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: KaryawanColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KaryawanRadii.card),
        ),
        title: Text(
          'Batalkan transaksi?',
          style: KaryawanTextStyles.sectionTitle,
        ),
        content: Text(
          'Keranjang berisi $_itemCount barang. Isinya akan dibuang jika kamu keluar.',
          style: KaryawanTextStyles.body.copyWith(
            color: KaryawanColors.secondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              'Lanjutkan',
              style: KaryawanTextStyles.button.copyWith(
                color: KaryawanColors.brownDark,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              'Keluar dari kasir',
              style: KaryawanTextStyles.button.copyWith(
                color: KaryawanColors.danger,
              ),
            ),
          ),
        ],
      ),
    );

    if (shouldDiscard == true && mounted) {
      Navigator.of(context).pop();
    }
  }

  void _openCart() {
    setState(() => _stockWarning = false);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: KaryawanColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: _KaryawanCartSheet(
              cart: _cart,
              productById: _productById,
              itemCount: _itemCount,
              total: _total,
              paymentMethod: _paymentMethod,
              cashReceivedController: _cashReceivedController,
              cashReceived: _cashReceived,
              changeDue: _changeDue,
              stockWarning: _stockWarning,
              onCashReceivedChanged: (_) => setSheetState(() {}),
              onQuantityChanged: (product, change) {
                _changeQuantity(product, change, showInlineWarning: true);
                setSheetState(() {});
              },
              onPaymentChanged: (method) {
                setState(() => _paymentMethod = method);
                setSheetState(() {});
              },
              onCheckout: _completeCheckout,
            ),
          );
        },
      ),
    );
  }

  Future<void> _completeCheckout() async {
    if (_cart.isEmpty) return;
    if (_paymentMethod == PaymentMethod.cash && _cashReceived < _total) return;

    final payment = _paymentMethod;
    final changeDue = _changeDue;
    final transaction = _store.checkout(
      cart: Map<String, int>.of(_cart),
      method: payment,
    );
    HapticFeedback.mediumImpact();
    if (!mounted) return;

    Navigator.of(context).pop();
    setState(() {
      _cart.clear();
      _paymentMethod = PaymentMethod.cash;
      _cashReceivedController.clear();
      _stockWarning = false;
    });
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: KaryawanColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KaryawanRadii.card),
        ),
        icon: const Icon(
          Icons.check_circle_rounded,
          color: KaryawanColors.success,
          size: 42,
        ),
        title: Text(
          'Transaksi berhasil',
          style: KaryawanTextStyles.sectionTitle,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              payment == PaymentMethod.cash
                  ? 'Total ${KaryawanDummy.formatRupiah(transaction.amountValue)}. '
                        'Kembalian ${KaryawanDummy.formatRupiah(changeDue)}.'
                  : '${KaryawanDummy.formatRupiah(transaction.amountValue)} '
                        'dibayar dengan ${_paymentLabel(payment)}.',
              textAlign: TextAlign.center,
              style: KaryawanTextStyles.body,
            ),
            const SizedBox(height: 10),
            Text(
              'No. ${transaction.receiptNumber}',
              style: KaryawanTextStyles.label.copyWith(
                color: KaryawanColors.mutedBrown,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(
              'Selesai',
              style: TextStyle(
                color: KaryawanColors.brownDark,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = KaryawanScope.of(context);
    final categories = <String>[
      'Semua',
      ...store.products.map((product) => product.category).toSet(),
    ];
    final products = store.products.where((product) {
      final matchesQuery = product.name.toLowerCase().contains(_query);
      final matchesCategory =
          _category == 'Semua' || product.category == _category;
      return matchesQuery && matchesCategory;
    }).toList();
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final cardExtent = 176.0 + (textScale - 1).clamp(0.0, 0.4) * 70;

    return PopScope(
      canPop: _cart.isEmpty,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _handleBack();
      },
      child: Scaffold(
        backgroundColor: KaryawanColors.background,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [KaryawanColors.backgroundTop, KaryawanColors.background],
              begin: Alignment.topCenter,
              end: Alignment.center,
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final contentWidth = constraints.maxWidth > 680
                    ? 680.0
                    : constraints.maxWidth;
                return Align(
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: contentWidth,
                    height: constraints.maxHeight,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        KaryawanSpacing.screen,
                        15,
                        KaryawanSpacing.screen,
                        12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              KaryawanBackButton(
                                showLabel: true,
                                onPressed: _handleBack,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Transaksi Baru',
                                      style: KaryawanTextStyles.sectionTitle,
                                    ),
                                    Text(
                                      '${KaryawanDummy.storeName} Â· '
                                      '${KaryawanDummy.shiftTime}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: KaryawanTextStyles.label,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: KaryawanSpacing.item),
                          TextField(
                            controller: _searchController,
                            onChanged: (value) => setState(
                              () => _query = value.trim().toLowerCase(),
                            ),
                            textInputAction: TextInputAction.search,
                            decoration: InputDecoration(
                              hintText: 'Cari nama barang',
                              hintStyle: KaryawanTextStyles.label,
                              prefixIcon: const Icon(
                                Icons.search_rounded,
                                color: KaryawanColors.brown,
                              ),
                              suffixIcon: _query.isEmpty
                                  ? null
                                  : IconButton(
                                      tooltip: 'Hapus pencarian',
                                      icon: const Icon(
                                        Icons.close_rounded,
                                        size: 19,
                                        color: KaryawanColors.brown,
                                      ),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() => _query = '');
                                      },
                                    ),
                              filled: true,
                              fillColor: KaryawanColors.surface,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 14,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  KaryawanRadii.button,
                                ),
                                borderSide: const BorderSide(
                                  color: KaryawanColors.border,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  KaryawanRadii.button,
                                ),
                                borderSide: const BorderSide(
                                  color: KaryawanColors.amber,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 38,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: categories.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(width: 8),
                              itemBuilder: (context, index) {
                                final category = categories[index];
                                return _CategoryChip(
                                  label: category,
                                  selected: _category == category,
                                  onTap: () =>
                                      setState(() => _category = category),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Pilih barang belanja',
                                  style: KaryawanTextStyles.sectionTitle,
                                ),
                              ),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                child: Text(
                                  '${products.length} barang',
                                  key: ValueKey<int>(products.length),
                                  style: KaryawanTextStyles.label,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Tekan â€œTambahâ€ untuk memasukkan barang. '
                            'Total dihitung otomatis.',
                            style: KaryawanTextStyles.label,
                          ),
                          const SizedBox(height: 10),
                          Expanded(
                            child: products.isEmpty
                                ? const _EmptyProducts()
                                : LayoutBuilder(
                                    builder: (context, gridConstraints) {
                                      final columns =
                                          gridConstraints.maxWidth >= 520
                                          ? 3
                                          : gridConstraints.maxWidth >= 300
                                          ? 2
                                          : 1;
                                      return GridView.builder(
                                        padding: const EdgeInsets.only(
                                          bottom: 8,
                                        ),
                                        itemCount: products.length,
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: columns,
                                              crossAxisSpacing: 11,
                                              mainAxisSpacing: 11,
                                              mainAxisExtent: cardExtent,
                                            ),
                                        itemBuilder: (context, index) {
                                          final product = products[index];
                                          final quantity =
                                              _cart[product.id] ?? 0;
                                          return _KaryawanProductCard(
                                            product: product,
                                            quantity: quantity,
                                            isAvailable:
                                                product.availableStock >
                                                quantity,
                                            onAdd: () =>
                                                _changeQuantity(product, 1),
                                            onRemove: () =>
                                                _changeQuantity(product, -1),
                                          );
                                        },
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            decoration: const BoxDecoration(
              color: KaryawanColors.surface,
              border: Border(top: BorderSide(color: KaryawanColors.border)),
            ),
            child: Center(
              heightFactor: 1,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _itemCount == 0
                                ? 'Pilih barang â€¢ total otomatis'
                                : '$_itemCount barang dipilih',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: KaryawanTextStyles.label.copyWith(
                              color: KaryawanColors.brown,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 220),
                            transitionBuilder: (child, animation) =>
                                FadeTransition(
                                  opacity: animation,
                                  child: SizeTransition(
                                    sizeFactor: animation,
                                    axisAlignment: -1,
                                    child: child,
                                  ),
                                ),
                            child: Text(
                              KaryawanDummy.formatRupiah(_total),
                              key: ValueKey<int>(_total),
                              style: KaryawanTextStyles.sectionTitle.copyWith(
                                fontSize: 17,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    FilledButton.icon(
                      onPressed: _openCart,
                      style: FilledButton.styleFrom(
                        backgroundColor: KaryawanColors.primaryDark,
                        foregroundColor: KaryawanColors.surface,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            KaryawanRadii.button,
                          ),
                        ),
                      ),
                      icon: Badge(
                        isLabelVisible: _itemCount > 0,
                        label: Text('$_itemCount'),
                        backgroundColor: KaryawanColors.heading,
                        child: const Icon(
                          Icons.shopping_bag_outlined,
                          size: 18,
                        ),
                      ),
                      label: const Text('Lihat keranjang'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _KaryawanProductCard extends StatelessWidget {
  const _KaryawanProductCard({
    required this.product,
    required this.quantity,
    required this.isAvailable,
    required this.onAdd,
    required this.onRemove,
  });

  final ProductItem product;
  final int quantity;
  final bool isAvailable;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: KaryawanColors.surface,
        borderRadius: BorderRadius.circular(KaryawanRadii.card),
        border: Border.all(
          color: quantity > 0 ? KaryawanColors.amber : KaryawanColors.border,
          width: quantity > 0 ? 1.4 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _ProductImage(product: product),
              const Spacer(),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) =>
                    ScaleTransition(scale: animation, child: child),
                child: quantity > 0
                    ? StatusBadge(
                        key: ValueKey<int>(quantity),
                        label: 'x$quantity',
                        type: StatusBadgeType.warning,
                      )
                    : product.availableStock == 0
                    ? const StatusBadge(
                        key: ValueKey<String>('habis'),
                        label: 'Habis',
                        type: StatusBadgeType.danger,
                      )
                    : const SizedBox(key: ValueKey<String>('kosong')),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            product.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: KaryawanTextStyles.body.copyWith(
              color: KaryawanColors.heading,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${product.formattedPrice} / ${product.unit}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: KaryawanTextStyles.label.copyWith(
              color: KaryawanColors.brown,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            product.availableStock == 0
                ? 'Stok habis'
                : 'Tersedia ${product.availableStock} ${product.unit}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: KaryawanTextStyles.label.copyWith(
              color: product.availableStock == 0
                  ? KaryawanColors.danger
                  : KaryawanColors.secondary,
              fontSize: 10,
            ),
          ),
          const Spacer(),
          if (product.availableStock == 0)
            const _StockAvailabilityLabel(label: 'Stok habis')
          else if (quantity == 0)
            SizedBox(
              width: double.infinity,
              height: 32,
              child: FilledButton.icon(
                onPressed: onAdd,
                style: _productButtonStyle(),
                icon: const Icon(Icons.add_rounded, size: 17),
                label: Text(
                  'Tambah ke keranjang',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: KaryawanTextStyles.label.copyWith(
                    color: KaryawanColors.brownDark,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            )
          else
            Row(
              children: [
                _ProductQuantityButton(
                  icon: Icons.remove_rounded,
                  onPressed: onRemove,
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: Text(
                      '$quantity',
                      key: ValueKey<int>(quantity),
                      textAlign: TextAlign.center,
                      style: KaryawanTextStyles.body.copyWith(
                        color: KaryawanColors.heading,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                _ProductQuantityButton(
                  icon: Icons.add_rounded,
                  onPressed: isAvailable ? onAdd : null,
                ),
              ],
            ),
        ],
      ),
    );
  }
}

ButtonStyle _productButtonStyle() {
  return FilledButton.styleFrom(
    backgroundColor: KaryawanColors.orangeTint,
    foregroundColor: KaryawanColors.brownDark,
    padding: const EdgeInsets.symmetric(horizontal: 6),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  );
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.product});

  final ProductItem product;

  @override
  Widget build(BuildContext context) {
    final imageAsset = product.imageAsset;
    return ClipRRect(
      borderRadius: BorderRadius.circular(KaryawanRadii.icon),
      child: SizedBox(
        width: 48,
        height: 48,
        child: imageAsset == null
            ? _fallback()
            : Image.asset(
                imageAsset,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _fallback(),
              ),
      ),
    );
  }

  Widget _fallback() {
    return ColoredBox(
      color: KaryawanColors.warningBackground,
      child: Icon(product.icon, color: KaryawanColors.brown, size: 22),
    );
  }
}

class _StockAvailabilityLabel extends StatelessWidget {
  const _StockAvailabilityLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 32,
      child: Center(
        child: Text(
          label,
          style: KaryawanTextStyles.label.copyWith(
            color: KaryawanColors.danger,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _ProductQuantityButton extends StatelessWidget {
  const _ProductQuantityButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;
    return Material(
      color: isEnabled
          ? KaryawanColors.orangeTint
          : KaryawanColors.backgroundTop,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 32,
          height: 32,
          child: Icon(
            icon,
            size: 18,
            color: isEnabled
                ? KaryawanColors.brownDark
                : KaryawanColors.secondary,
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      decoration: BoxDecoration(
        color: selected ? KaryawanColors.brownDark : KaryawanColors.surface,
        borderRadius: BorderRadius.circular(KaryawanRadii.pill),
        border: Border.all(
          color: selected ? KaryawanColors.brownDark : KaryawanColors.border,
        ),
      ),
      child: Material(
        color: KaryawanColors.transparent,
        borderRadius: BorderRadius.circular(KaryawanRadii.pill),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(KaryawanRadii.pill),
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 220),
              style: KaryawanTextStyles.label.copyWith(
                color: selected ? KaryawanColors.surface : KaryawanColors.brown,
                fontWeight: FontWeight.w700,
              ),
              child: Text(label),
            ),
          ),
        ),
      ),
    );
  }
}

class _KaryawanCartSheet extends StatelessWidget {
  const _KaryawanCartSheet({
    required this.cart,
    required this.productById,
    required this.itemCount,
    required this.total,
    required this.paymentMethod,
    required this.cashReceivedController,
    required this.cashReceived,
    required this.changeDue,
    required this.stockWarning,
    required this.onCashReceivedChanged,
    required this.onQuantityChanged,
    required this.onPaymentChanged,
    required this.onCheckout,
  });

  final Map<String, int> cart;
  final ProductItem? Function(String id) productById;
  final int itemCount;
  final int total;
  final PaymentMethod paymentMethod;
  final TextEditingController cashReceivedController;
  final int cashReceived;
  final int changeDue;
  final bool stockWarning;
  final ValueChanged<String> onCashReceivedChanged;
  final void Function(ProductItem, int) onQuantityChanged;
  final ValueChanged<PaymentMethod> onPaymentChanged;
  final VoidCallback onCheckout;

  void _fillCash(int amount) {
    final text = '$amount';
    cashReceivedController.text = text;
    cashReceivedController.selection = TextSelection.collapsed(
      offset: text.length,
    );
    onCashReceivedChanged(text);
  }

  @override
  Widget build(BuildContext context) {
    final lines = <(ProductItem, int)>[];
    for (final entry in cart.entries) {
      final product = productById(entry.key);
      if (product != null) lines.add((product, entry.value));
    }

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: KaryawanColors.border,
                  borderRadius: BorderRadius.circular(KaryawanRadii.pill),
                ),
              ),
            ),
            const SizedBox(height: 17),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Keranjang belanja',
                    style: KaryawanTextStyles.sectionTitle,
                  ),
                ),
                StatusBadge(
                  label: '$itemCount barang',
                  type: StatusBadgeType.warning,
                ),
              ],
            ),
            const SizedBox(height: 10),
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: stockWarning
                  ? Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: KaryawanColors.dangerBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: KaryawanColors.dangerAccent.withValues(
                            alpha: 0.45,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            size: 18,
                            color: KaryawanColors.danger,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Stok tidak mencukupi untuk menambah barang ini.',
                              style: KaryawanTextStyles.label.copyWith(
                                color: KaryawanColors.danger,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            if (lines.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 26),
                child: _EmptyCart(),
              )
            else
              Column(
                children: [
                  for (var index = 0; index < lines.length; index++) ...[
                    _CartItemRow(
                      product: lines[index].$1,
                      quantity: lines[index].$2,
                      onDecrease: () => onQuantityChanged(lines[index].$1, -1),
                      onIncrease: () => onQuantityChanged(lines[index].$1, 1),
                    ),
                    if (index < lines.length - 1)
                      const Divider(height: 1, color: KaryawanColors.border),
                  ],
                ],
              ),
            if (cart.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text('Metode pembayaran', style: KaryawanTextStyles.sectionTitle),
              const SizedBox(height: 8),
              Row(
                children: [
                  for (final method in PaymentMethod.values)
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: method == PaymentMethod.values.last ? 0 : 8,
                        ),
                        child: _PaymentOption(
                          method: method,
                          selected: paymentMethod == method,
                          onTap: () => onPaymentChanged(method),
                        ),
                      ),
                    ),
                ],
              ),
              if (paymentMethod == PaymentMethod.cash) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: cashReceivedController,
                  onChanged: onCashReceivedChanged,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: 'Uang diterima',
                    hintText: 'Contoh: 100000',
                    prefixText: 'Rp ',
                    prefixStyle: KaryawanTextStyles.body.copyWith(
                      color: KaryawanColors.brown,
                      fontWeight: FontWeight.w700,
                    ),
                    filled: true,
                    fillColor: KaryawanColors.backgroundTop,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(KaryawanRadii.button),
                      borderSide: const BorderSide(
                        color: KaryawanColors.border,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(KaryawanRadii.button),
                      borderSide: const BorderSide(
                        color: KaryawanColors.amber,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: [
                    _QuickAmountChip(
                      label: 'Uang pas',
                      onTap: () => _fillCash(total),
                    ),
                    for (final amount in [50000, 100000, 200000, 500000])
                      if (amount > total)
                        _QuickAmountChip(
                          label: KaryawanDummy.formatRupiah(amount),
                          onTap: () => _fillCash(amount),
                        ),
                  ],
                ),
                const SizedBox(height: 7),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        cashReceived >= total
                            ? 'Kembalian'
                            : cashReceived == 0
                            ? 'Masukkan uang diterima'
                            : 'Kurang bayar',
                        style: KaryawanTextStyles.label.copyWith(
                          color: cashReceived >= total
                              ? KaryawanColors.success
                              : KaryawanColors.danger,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      cashReceived == 0
                          ? 'â€”'
                          : KaryawanDummy.formatRupiah(
                              cashReceived >= total
                                  ? changeDue
                                  : total - cashReceived,
                            ),
                      style: KaryawanTextStyles.label.copyWith(
                        color: cashReceived >= total
                            ? KaryawanColors.success
                            : KaryawanColors.danger,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ],
            const SizedBox(height: 13),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Total pembayaran',
                    style: KaryawanTextStyles.body,
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: Text(
                    KaryawanDummy.formatRupiah(total),
                    key: ValueKey<int>(total),
                    style: KaryawanTextStyles.sectionTitle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed:
                    cart.isEmpty ||
                        (paymentMethod == PaymentMethod.cash &&
                            cashReceived < total)
                    ? null
                    : onCheckout,
                style: FilledButton.styleFrom(
                  backgroundColor: KaryawanColors.primaryDark,
                  foregroundColor: KaryawanColors.surface,
                  disabledBackgroundColor: KaryawanColors.border,
                  disabledForegroundColor: KaryawanColors.secondary,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(KaryawanRadii.button),
                  ),
                ),
                child: Text(
                  'Proses Pembayaran',
                  style: KaryawanTextStyles.button,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAmountChip extends StatelessWidget {
  const _QuickAmountChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: KaryawanColors.warningBackground,
      borderRadius: BorderRadius.circular(KaryawanRadii.pill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(KaryawanRadii.pill),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
          child: Text(
            label,
            style: KaryawanTextStyles.label.copyWith(
              color: KaryawanColors.brownDark,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ),
      ),
    );
  }
}

class _CartItemRow extends StatelessWidget {
  const _CartItemRow({
    required this.product,
    required this.quantity,
    required this.onDecrease,
    required this.onIncrease,
  });

  final ProductItem product;
  final int quantity;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: KaryawanTextStyles.body.copyWith(
                    color: KaryawanColors.heading,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${product.formattedPrice} / ${product.unit}',
                  style: KaryawanTextStyles.label,
                ),
                const SizedBox(height: 3),
                Text(
                  'Subtotal '
                  '${KaryawanDummy.formatRupiah(product.price * quantity)}',
                  style: KaryawanTextStyles.label.copyWith(
                    color: KaryawanColors.brown,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          _SmallQuantityButton(icon: Icons.remove_rounded, onTap: onDecrease),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              '$quantity',
              style: KaryawanTextStyles.body.copyWith(
                color: KaryawanColors.heading,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          _SmallQuantityButton(icon: Icons.add_rounded, onTap: onIncrease),
        ],
      ),
    );
  }
}

class _SmallQuantityButton extends StatelessWidget {
  const _SmallQuantityButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: KaryawanColors.warningBackground,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 32,
          height: 32,
          child: Icon(icon, size: 18, color: KaryawanColors.brownDark),
        ),
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  const _PaymentOption({
    required this.method,
    required this.selected,
    required this.onTap,
  });

  final PaymentMethod method;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (label, icon) = switch (method) {
      PaymentMethod.cash => ('Tunai', Icons.payments_rounded),
      PaymentMethod.qris => ('QRIS', Icons.qr_code_rounded),
      PaymentMethod.transfer => ('Transfer', Icons.account_balance_rounded),
    };

    return Material(
      color: selected ? KaryawanColors.orangeTint : KaryawanColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? KaryawanColors.amber : KaryawanColors.border,
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, size: 18, color: KaryawanColors.brown),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                style: KaryawanTextStyles.label.copyWith(
                  color: KaryawanColors.brownDark,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.shopping_bag_outlined,
            size: 34,
            color: KaryawanColors.brown,
          ),
          const SizedBox(height: 9),
          Text('Keranjang masih kosong', style: KaryawanTextStyles.body),
          const SizedBox(height: 4),
          Text(
            'Pilih barang untuk memulai transaksi.',
            style: KaryawanTextStyles.label,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _EmptyProducts extends StatelessWidget {
  const _EmptyProducts();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: KaryawanColors.surface,
        borderRadius: BorderRadius.circular(KaryawanRadii.card),
        border: Border.all(color: KaryawanColors.border),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.search_off_rounded,
            color: KaryawanColors.brown,
            size: 30,
          ),
          const SizedBox(height: 8),
          Text(
            'Barang tidak ditemukan',
            style: KaryawanTextStyles.body.copyWith(
              color: KaryawanColors.heading,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Coba kata kunci atau kategori lain.',
            style: KaryawanTextStyles.label,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

String _paymentLabel(PaymentMethod method) {
  return switch (method) {
    PaymentMethod.cash => 'Tunai',
    PaymentMethod.qris => 'QRIS',
    PaymentMethod.transfer => 'Transfer',
  };
}
