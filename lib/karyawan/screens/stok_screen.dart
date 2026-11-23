import 'package:flutter/material.dart';

import 'package:qnex/karyawan/dummy_data/karyawan_dummy.dart';
import 'package:qnex/karyawan/state/karyawan_store.dart';
import 'package:qnex/karyawan/theme/karyawan_theme.dart';
import 'package:qnex/karyawan/widgets/status_badge.dart';

class StokScreen extends StatefulWidget {
  const StokScreen({super.key});

  @override
  State<StokScreen> createState() => _StokScreenState();
}

class _StokScreenState extends State<StokScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  String _filter = 'Semua';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = KaryawanScope.of(context);
    final visibleItems = store.stock.where((item) {
      final matchesQuery = item.name.toLowerCase().contains(_query);
      final matchesFilter = switch (_filter) {
        'Menipis' => item.isLowStock,
        'Habis' => item.isOutOfStock,
        _ => true,
      };
      return matchesQuery && matchesFilter;
    }).toList();

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
                Text('Stok Barang', style: KaryawanTextStyles.headline),
                const SizedBox(height: 5),
                Text(
                  'Pantau ketersediaan barang di toko',
                  style: KaryawanTextStyles.body.copyWith(
                    color: KaryawanColors.secondary,
                  ),
                ),
                const SizedBox(height: KaryawanSpacing.item),
                _StockSummary(
                  totalUnits: store.totalStockUnits,
                  lowCount: store.lowStockCount,
                  outCount: store.outOfStockCount,
                ),
                const SizedBox(height: KaryawanSpacing.section),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Daftar barang',
                        style: KaryawanTextStyles.sectionTitle,
                      ),
                    ),
                    Text(
                      '${visibleItems.length} barang',
                      style: KaryawanTextStyles.label,
                    ),
                  ],
                ),
                const SizedBox(height: 11),
                TextField(
                  controller: _searchController,
                  onChanged: (value) =>
                      setState(() => _query = value.trim().toLowerCase()),
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
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
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
                const SizedBox(height: 11),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final filter in ['Semua', 'Menipis', 'Habis'])
                      _FilterChip(
                        label: filter,
                        selected: _filter == filter,
                        onTap: () => setState(() => _filter = filter),
                      ),
                  ],
                ),
                const SizedBox(height: 11),
                AnimatedSize(
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeOutCubic,
                  alignment: Alignment.topCenter,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: visibleItems.isEmpty
                        ? const _EmptyStockSearch()
                        : _StockList(
                            key: ValueKey<String>('$_filter|$_query'),
                            items: visibleItems,
                          ),
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

class _StockSummary extends StatelessWidget {
  const _StockSummary({
    required this.totalUnits,
    required this.lowCount,
    required this.outCount,
  });

  final int totalUnits;
  final int lowCount;
  final int outCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: KaryawanColors.surface,
        borderRadius: BorderRadius.circular(KaryawanRadii.card),
        border: Border.all(color: KaryawanColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SummaryValue(
              label: 'Unit tersedia',
              value: '$totalUnits',
              color: KaryawanColors.brown,
              icon: Icons.inventory_2_rounded,
            ),
          ),
          Container(width: 1, height: 45, color: KaryawanColors.border),
          Expanded(
            child: _SummaryValue(
              label: 'Menipis',
              value: '$lowCount barang',
              color: KaryawanColors.amber,
              icon: Icons.warning_amber_rounded,
            ),
          ),
          Container(width: 1, height: 45, color: KaryawanColors.border),
          Expanded(
            child: _SummaryValue(
              label: 'Habis',
              value: '$outCount barang',
              color: KaryawanColors.dangerAccent,
              icon: Icons.remove_shopping_cart_rounded,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryValue extends StatelessWidget {
  const _SummaryValue({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Icon(icon, size: 19, color: color),
          const SizedBox(height: 7),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: KaryawanTextStyles.body.copyWith(
              color: KaryawanColors.heading,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: KaryawanTextStyles.label.copyWith(fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
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
      duration: const Duration(milliseconds: 200),
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            child: Text(
              label,
              style: KaryawanTextStyles.label.copyWith(
                color: selected ? KaryawanColors.surface : KaryawanColors.brown,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StockList extends StatelessWidget {
  const _StockList({required this.items, super.key});

  final List<StockItem> items;

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
            _StockItemRow(
              item: items[index],
              showDivider: index < items.length - 1,
            ),
        ],
      ),
    );
  }
}

class _StockItemRow extends StatelessWidget {
  const _StockItemRow({required this.item, required this.showDivider});

  final StockItem item;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final status = item.isOutOfStock
        ? StatusBadgeType.danger
        : item.isLowStock
        ? StatusBadgeType.warning
        : StatusBadgeType.success;
    final statusLabel = switch (status) {
      StatusBadgeType.danger => 'Habis',
      StatusBadgeType.warning => 'Menipis',
      StatusBadgeType.success => 'Tersedia',
    };

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: BoxDecoration(
        border: showDivider
            ? const Border(bottom: BorderSide(color: KaryawanColors.border))
            : null,
      ),
      child: Row(
        children: [
          _StockThumbnail(item: item),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: KaryawanTextStyles.body.copyWith(
                    color: KaryawanColors.heading,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Sisa ${item.quantity} ${item.unit}',
                  style: KaryawanTextStyles.label,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          StatusBadge(label: statusLabel, type: status),
        ],
      ),
    );
  }
}

class _StockThumbnail extends StatelessWidget {
  const _StockThumbnail({required this.item});

  final StockItem item;

  @override
  Widget build(BuildContext context) {
    final assetPath = item.imageAsset;
    return ClipRRect(
      borderRadius: BorderRadius.circular(KaryawanRadii.icon),
      child: SizedBox(
        width: 54,
        height: 54,
        child: assetPath == null
            ? _fallback()
            : Image.asset(
                assetPath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _fallback(),
              ),
      ),
    );
  }

  Widget _fallback() {
    return ColoredBox(
      color: item.isOutOfStock
          ? KaryawanColors.dangerBackground
          : KaryawanColors.warningBackground,
      child: Icon(
        item.isOutOfStock
            ? Icons.remove_shopping_cart_rounded
            : Icons.inventory_2_rounded,
        color: item.isOutOfStock
            ? KaryawanColors.dangerAccent
            : KaryawanColors.brown,
        size: 22,
      ),
    );
  }
}

class _EmptyStockSearch extends StatelessWidget {
  const _EmptyStockSearch();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 18),
      decoration: BoxDecoration(
        color: KaryawanColors.surface,
        borderRadius: BorderRadius.circular(KaryawanRadii.card),
        border: Border.all(color: KaryawanColors.border),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.search_off_rounded,
            size: 30,
            color: KaryawanColors.brown,
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
            'Coba kata kunci atau filter yang berbeda.',
            style: KaryawanTextStyles.label,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
