import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/item.dart';
import '../models/service.dart';
import '../models/mechanic.dart';
import '../models/transaction.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  final DatabaseHelper _db = DatabaseHelper();
  final TextEditingController _customerController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _cashController = TextEditingController();

  List<Item> _availableItems = [];
  List<Service> _availableServices = [];
  List<Mechanic> _mechanics = [];

  Mechanic? _selectedMechanic;
  List<TransactionItem> _cartItems = [];
  List<TransactionService> _cartServices = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final items = await _db.getItems();
    final services = await _db.getServices();
    final mechanics = await _db.getMechanics(activeOnly: true);
    setState(() {
      _availableItems = items;
      _availableServices = services;
      _mechanics = mechanics;
      _isLoading = false;
    });
  }

  double get _totalItemsAmount =>
      _cartItems.fold(0, (sum, item) => sum + item.subtotal);

  double get _totalServicesAmount =>
      _cartServices.fold(0, (sum, svc) => sum + svc.price);

  double get _totalAmount => _totalItemsAmount + _totalServicesAmount;

  double get _totalMechanicShare =>
      _cartItems.fold(0.0, (sum, item) => sum + item.mechanicShare) +
      _cartServices.fold(0.0, (sum, svc) => sum + svc.mechanicShare);

  double get _totalOwnerShare =>
      _cartItems.fold(0.0, (sum, item) => sum + item.ownerShare) +
      _cartServices.fold(0.0, (sum, svc) => sum + svc.ownerShare);

  double get _cashAmount => double.tryParse(_cashController.text) ?? 0.0;
  
  double get _changeAmount {
    double change = _cashAmount - _totalAmount;
    return change < 0 ? 0 : change;
  }

  void _addItem(Item item) {
    showDialog(
      context: context,
      builder: (context) {
        int qty = 1;
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(item.name,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Harga: ${Formatters.currency(item.sellPrice)}',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                Text(
                  'Stok tersedia: ${item.stock} ${item.unit}',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: qty > 1
                          ? () => setDialogState(() => qty--)
                          : null,
                      icon: const Icon(Icons.remove_circle_outline),
                      color: AppColors.primary,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        qty.toString(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: qty < item.stock
                          ? () => setDialogState(() => qty++)
                          : null,
                      icon: const Icon(Icons.add_circle_outline),
                      color: AppColors.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Subtotal: ${Formatters.currency(item.sellPrice * qty)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal',
                    style: TextStyle(color: AppColors.textSecondary)),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _cartItems.add(TransactionItem(
                      itemId: item.id!,
                      itemName: item.name,
                      quantity: qty,
                      sellPrice: item.sellPrice,
                      buyPrice: item.buyPrice,
                      mechanicPercentage:
                          AppConstants.defaultItemMechanicPercent,
                      ownerPercentage: AppConstants.defaultItemOwnerPercent,
                    ));
                  });
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Tambahkan'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _addService(Service service) {
    final nameController = TextEditingController(text: service.name);
    final priceController = TextEditingController(text: service.price.toStringAsFixed(0));
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Detail Jasa', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Nama Jasa',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Harga Jasa',
                prefixText: 'Rp ',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _cartServices.add(TransactionService(
                  serviceId: service.id!,
                  serviceName: nameController.text,
                  price: double.tryParse(priceController.text) ?? 0,
                  mechanicPercentage: service.mechanicPercentage,
                  ownerPercentage: service.ownerPercentage,
                ));
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Tambahkan'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveTransaction() async {
    if (_cartItems.isEmpty && _cartServices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tambahkan minimal 1 barang atau jasa'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    if (_cashAmount > 0 && _cashAmount < _totalAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Uang tunai kurang dari total pembayaran'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    final now = DateTime.now();
    final dateStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final transaction = Transaction(
      date: dateStr,
      customerName: _customerController.text,
      mechanicId: _selectedMechanic?.id,
      mechanicName: _selectedMechanic?.name,
      totalAmount: _totalAmount,
      totalMechanicShare: _totalMechanicShare,
      totalOwnerShare: _totalOwnerShare,
      cashAmount: _cashAmount,
      changeAmount: _changeAmount,
      notes: _notesController.text,
    );

    await _db.insertTransaction(transaction, _cartItems, _cartServices);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Transaksi ${Formatters.currency(_totalAmount)} berhasil disimpan!'),
        backgroundColor: AppColors.success,
      ),
    );
    // Reset
    setState(() {
      _cartItems = [];
      _cartServices = [];
      _customerController.clear();
      _notesController.clear();
      _cashController.clear();
      _selectedMechanic = null;
    });
    _loadData(); // Refresh stock
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Transaksi Baru',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Customer & Mechanic Info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Info Transaksi',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _customerController,
                          decoration: InputDecoration(
                            labelText: 'Nama Pelanggan (opsional)',
                            prefixIcon: const Icon(Icons.person_outline,
                                color: AppColors.primary, size: 20),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: AppColors.primary, width: 2),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<Mechanic>(
                          initialValue: _selectedMechanic,
                          decoration: InputDecoration(
                            labelText: 'Pilih Mekanik',
                            prefixIcon: const Icon(Icons.engineering,
                                color: AppColors.primary, size: 20),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: AppColors.primary, width: 2),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                          ),
                          items: _mechanics.map((m) {
                            return DropdownMenuItem(
                              value: m,
                              child: Text(m.name),
                            );
                          }).toList(),
                          onChanged: (val) =>
                              setState(() => _selectedMechanic = val),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Add Items Section
                  _buildSectionHeader('Barang', Icons.inventory_2_rounded,
                      onAdd: () => _showItemPicker()),
                  const SizedBox(height: 8),
                  if (_cartItems.isEmpty)
                    _buildEmptyCard('Belum ada barang ditambahkan')
                  else
                    ..._cartItems.asMap().entries.map((entry) {
                      final i = entry.key;
                      final item = entry.value;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.inventory_2_outlined,
                                  color: AppColors.primary, size: 18),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.itemName,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13)),
                                  Text(
                                    '${item.quantity}x ${Formatters.currency(item.sellPrice)}',
                                    style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              Formatters.currency(item.subtotal),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () =>
                                  setState(() => _cartItems.removeAt(i)),
                              child: const Icon(Icons.close,
                                  size: 18, color: AppColors.danger),
                            ),
                          ],
                        ),
                      );
                    }),

                  const SizedBox(height: 16),

                  // Add Services Section
                  _buildSectionHeader('Jasa', Icons.build_circle_outlined,
                      onAdd: () => _showServicePicker()),
                  const SizedBox(height: 8),
                  if (_cartServices.isEmpty)
                    _buildEmptyCard('Belum ada jasa ditambahkan')
                  else
                    ..._cartServices.asMap().entries.map((entry) {
                      final i = entry.key;
                      final svc = entry.value;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.accent.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.build_circle_outlined,
                                  color: AppColors.accent, size: 18),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(svc.serviceName,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13)),
                                  Text(
                                    'Mek ${svc.mechanicPercentage.toStringAsFixed(0)}% • Pemilik ${svc.ownerPercentage.toStringAsFixed(0)}%',
                                    style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              Formatters.currency(svc.price),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.accent,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () =>
                                  setState(() => _cartServices.removeAt(i)),
                              child: const Icon(Icons.close,
                                  size: 18, color: AppColors.danger),
                            ),
                          ],
                        ),
                      );
                    }),

                  const SizedBox(height: 16),

                  // Notes
                  TextField(
                    controller: _notesController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Catatan (opsional)',
                      prefixIcon: const Icon(Icons.note_outlined,
                          color: AppColors.primary, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: AppColors.primary, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Summary Card
                  if (_cartItems.isNotEmpty || _cartServices.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildSummaryRow(
                              'Total Barang', Formatters.currency(_totalItemsAmount)),
                          _buildSummaryRow(
                              'Total Jasa', Formatters.currency(_totalServicesAmount)),
                          const Divider(color: Colors.white24, height: 20),
                          _buildSummaryRow(
                            'TOTAL',
                            Formatters.currency(_totalAmount),
                            isBold: true,
                            fontSize: 18,
                          ),
                          const SizedBox(height: 8),
                          _buildSummaryRow('Bagian Mekanik',
                              Formatters.currency(_totalMechanicShare),
                              fontSize: 12),
                          _buildSummaryRow('Bagian Pemilik',
                              Formatters.currency(_totalOwnerShare),
                              fontSize: 12),
                        ],
                      ),
                    ),

                  const SizedBox(height: 16),
                  
                  // Uang Tunai & Kembalian
                  if (_cartItems.isNotEmpty || _cartServices.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _cashController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Uang Tunai (Cash)',
                              prefixText: 'Rp ',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onChanged: (val) {
                              setState(() {}); // Update kembalian
                            },
                          ),
                          if (_cashAmount > 0) ...[
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Kembalian:',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold, fontSize: 16)),
                                Text(
                                  Formatters.currency(_changeAmount),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: _changeAmount > 0
                                        ? AppColors.primary
                                        : (_cashAmount < _totalAmount
                                            ? AppColors.danger
                                            : AppColors.textPrimary),
                                  ),
                                ),
                              ],
                            ),
                          ]
                        ],
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: _saveTransaction,
                      icon: const Icon(Icons.save_rounded),
                      label: const Text(
                        'Simpan Transaksi',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon,
      {VoidCallback? onAdd}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 15)),
          ],
        ),
        TextButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add_circle_outline, size: 18),
          label: const Text('Tambah'),
          style: TextButton.styleFrom(foregroundColor: AppColors.primary),
        ),
      ],
    );
  }

  Widget _buildEmptyCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, style: BorderStyle.solid),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.textLight, fontSize: 13),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value,
      {bool isBold = false, double fontSize = 14}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: isBold ? 1 : 0.8),
                fontSize: fontSize,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              )),
          Text(value,
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              )),
        ],
      ),
    );
  }

  void _showItemPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Material(
        color: Colors.transparent,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.6,
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
                  const Text('Pilih Barang',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _availableItems.length,
                itemBuilder: (context, index) {
                  final item = _availableItems[index];
                  return ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.inventory_2_outlined,
                          color: AppColors.primary, size: 20),
                    ),
                    title: Text(item.name,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(
                        'Stok: ${item.stock} ${item.unit}',
                        style: const TextStyle(fontSize: 12)),
                    trailing: Text(
                      Formatters.currency(item.sellPrice),
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold),
                    ),
                    onTap: item.stock > 0
                        ? () {
                            Navigator.pop(context);
                            _addItem(item);
                          }
                        : null,
                    enabled: item.stock > 0,
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

  void _showServicePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Material(
        color: Colors.transparent,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.6,
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
                  const Text('Pilih Jasa',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _availableServices.length,
                itemBuilder: (context, index) {
                  final svc = _availableServices[index];
                  return ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.build_circle_outlined,
                          color: AppColors.accent, size: 20),
                    ),
                    title: Text(svc.name,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(
                        svc.description ?? '',
                        style: const TextStyle(fontSize: 12)),
                    trailing: Text(
                      Formatters.currency(svc.price),
                      style: const TextStyle(
                          color: AppColors.accent,
                          fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _addService(svc);
                    },
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
  void dispose() {
    _customerController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
