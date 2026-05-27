import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/item.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';
import '../widgets/item_tile.dart';

class StockScreen extends StatefulWidget {
  const StockScreen({super.key});

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  final DatabaseHelper _db = DatabaseHelper();
  List<Item> _items = [];
  List<String> _categories = [];
  String _selectedCategory = 'Semua';
  String _searchQuery = '';
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final items = await _db.getItems(
      search: _searchQuery.isNotEmpty ? _searchQuery : null,
      category: _selectedCategory != 'Semua' ? _selectedCategory : null,
    );
    final categories = await _db.getCategories();
    setState(() {
      _items = items;
      _categories = ['Semua', ...categories];
      _isLoading = false;
    });
  }

  void _showAddEditDialog({Item? item}) {
    final nameController = TextEditingController(text: item?.name ?? '');
    final categoryController =
        TextEditingController(text: item?.category ?? '');
    final buyPriceController =
        TextEditingController(text: item?.buyPrice.toStringAsFixed(0) ?? '');
    final sellPriceController =
        TextEditingController(text: item?.sellPrice.toStringAsFixed(0) ?? '');
    final stockController =
        TextEditingController(text: item?.stock.toString() ?? '');
    final minStockController =
        TextEditingController(text: item?.minStock.toString() ?? '5');
    final maxStockController =
        TextEditingController(text: item?.maxStock.toString() ?? '20');
    final unitController = TextEditingController(text: item?.unit ?? 'pcs');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                item != null ? 'Edit Barang' : 'Tambah Barang',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField(nameController, 'Nama Barang', Icons.inventory_2),
              const SizedBox(height: 12),
              _buildTextField(
                  categoryController, 'Kategori', Icons.category_outlined),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      buyPriceController,
                      'Harga Beli',
                      Icons.shopping_cart_outlined,
                      isNumber: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      sellPriceController,
                      'Harga Jual',
                      Icons.sell_outlined,
                      isNumber: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      stockController,
                      'Stok',
                      Icons.numbers,
                      isNumber: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                        unitController, 'Satuan', Icons.straighten),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      minStockController,
                      'Min Stok',
                      Icons.arrow_downward,
                      isNumber: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      maxStockController,
                      'Max Stok',
                      Icons.arrow_upward,
                      isNumber: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isEmpty) return;
                    final newItem = Item(
                      id: item?.id,
                      name: nameController.text,
                      category: categoryController.text,
                      buyPrice:
                          double.tryParse(buyPriceController.text) ?? 0,
                      sellPrice:
                          double.tryParse(sellPriceController.text) ?? 0,
                      stock: int.tryParse(stockController.text) ?? 0,
                      minStock: int.tryParse(minStockController.text) ?? 5,
                      maxStock: int.tryParse(maxStockController.text) ?? 20,
                      unit: unitController.text.isNotEmpty
                          ? unitController.text
                          : 'pcs',
                    );
                    if (item != null) {
                      await _db.updateItem(newItem);
                    } else {
                      await _db.insertItem(newItem);
                    }
                    if (context.mounted) {
                      Navigator.pop(context);
                      _loadData();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    item != null ? 'Simpan Perubahan' : 'Tambah Barang',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isNumber = false,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: AppColors.textPrimary),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  Future<void> _deleteItem(Item item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Barang'),
        content: Text('Yakin ingin menghapus "${item.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child:
                const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _db.deleteItem(item.id!);
      _loadData();
    }
  }

  Future<void> _showRestockList() async {
    final restockItems = await _db.getRestockItems();
    if (!mounted) return;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Material(
        color: Colors.transparent,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Daftar Restock (Belanja)',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  Text(
                    'Barang yang stoknya <= minimum',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                ],
              ),
            ),
            Expanded(
              child: restockItems.isEmpty
                  ? Center(
                      child: Text('Semua stok aman!',
                          style: TextStyle(color: AppColors.textLight)))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: restockItems.length,
                      itemBuilder: (context, index) {
                        final item = restockItems[index];
                        final needed = item.maxStock - item.stock;
                        return ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.danger.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.warning_amber_rounded,
                                color: AppColors.danger, size: 20),
                          ),
                          title: Text(item.name,
                              style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(
                              'Stok: ${item.stock} / Min: ${item.minStock}',
                              style: const TextStyle(fontSize: 12)),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Beli: $needed ${item.unit}',
                                style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Stok Barang',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_checkout),
            tooltip: 'Daftar Restock',
            onPressed: _showRestockList,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                // Search bar
                TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    _searchQuery = val;
                    _loadData();
                  },
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Cari barang...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear,
                                color: AppColors.textSecondary),
                            onPressed: () {
                              _searchController.clear();
                              _searchQuery = '';
                              _loadData();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                const SizedBox(height: 12),
                // Category filter chips
                SizedBox(
                  height: 36,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final cat = _categories[index];
                      final isSelected = cat == _selectedCategory;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(
                            cat,
                            style: TextStyle(
                              color: isSelected ? Colors.white : AppColors.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() => _selectedCategory = cat);
                            _loadData();
                          },
                          backgroundColor: Colors.white,
                          selectedColor: AppColors.textPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          showCheckmark: false,
                          side: BorderSide.none,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Item count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_items.length} Barang',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const Icon(Icons.sort, color: AppColors.textSecondary, size: 20),
              ],
            ),
          ),

          // Items list
          Expanded(
            child: _isLoading
                ? const Center(
                    child:
                        CircularProgressIndicator(color: AppColors.primary))
                : _items.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inventory_2_outlined,
                                size: 64,
                                color: AppColors.textLight),
                            const SizedBox(height: 12),
                            const Text(
                              'Belum ada barang',
                              style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Tap + untuk menambahkan',
                              style: TextStyle(
                                  color: AppColors.textLight, fontSize: 13),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _items.length,
                        itemBuilder: (context, index) {
                          final item = _items[index];
                          final isLowStock =
                              item.stock < AppConstants.lowStockThreshold;
                          return Dismissible(
                            key: Key(item.id.toString()),
                            background: Container(
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.only(left: 20),
                              decoration: BoxDecoration(
                                color: AppColors.info,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.edit,
                                  color: Colors.white),
                            ),
                            secondaryBackground: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              decoration: BoxDecoration(
                                color: AppColors.danger,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.delete,
                                  color: Colors.white),
                            ),
                            confirmDismiss: (direction) async {
                              if (direction ==
                                  DismissDirection.startToEnd) {
                                _showAddEditDialog(item: item);
                                return false;
                              } else {
                                _deleteItem(item);
                                return false;
                              }
                            },
                            child: ItemTile(
                              title: item.name,
                              subtitle:
                                  '${item.category} • Stok: ${item.stock} ${item.unit}',
                              trailingTop:
                                  Formatters.currency(item.sellPrice),
                              trailingBottom:
                                  'Beli: ${Formatters.currency(item.buyPrice)}',
                              leadingIcon: _getCategoryIcon(item.category),
                              leadingColor: isLowStock
                                  ? AppColors.danger
                                  : AppColors.primary,
                              showWarning: isLowStock,
                              onTap: () => _showAddEditDialog(item: item),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'oli':
        return Icons.water_drop_outlined;
      case 'ban':
        return Icons.tire_repair;
      case 'sparepart':
        return Icons.settings_outlined;
      case 'aksesoris':
        return Icons.auto_awesome;
      default:
        return Icons.inventory_2_outlined;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
