import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/service.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';
import '../widgets/item_tile.dart';

class ServiceScreen extends StatefulWidget {
  const ServiceScreen({super.key});

  @override
  State<ServiceScreen> createState() => _ServiceScreenState();
}

class _ServiceScreenState extends State<ServiceScreen> {
  final DatabaseHelper _db = DatabaseHelper();
  List<Service> _services = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final services = await _db.getServices();
    setState(() {
      _services = services;
      _isLoading = false;
    });
  }

  void _showAddEditDialog({Service? service}) {
    final nameController = TextEditingController(text: service?.name ?? '');
    final priceController =
        TextEditingController(text: service?.price.toStringAsFixed(0) ?? '');
    final descController =
        TextEditingController(text: service?.description ?? '');
    double mechanicPct = service?.mechanicPercentage ?? 50;
    double ownerPct = service?.ownerPercentage ?? 50;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
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
                  service != null ? 'Edit Jasa' : 'Tambah Jasa',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 20),
                _buildTextField(nameController, 'Nama Jasa', Icons.build_circle),
                const SizedBox(height: 12),
                _buildTextField(
                  priceController,
                  'Harga Jasa (Rp)',
                  Icons.attach_money,
                  isNumber: true,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                    descController, 'Deskripsi', Icons.description_outlined),
                const SizedBox(height: 20),

                // Percentage slider
                const Text(
                  'Pembagian Pendapatan',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.engineering,
                                  size: 18, color: AppColors.info),
                              const SizedBox(width: 6),
                              Text(
                                'Mekanik: ${mechanicPct.toStringAsFixed(0)}%',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.info,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(Icons.store,
                                  size: 18, color: AppColors.primary),
                              const SizedBox(width: 6),
                              Text(
                                'Pemilik: ${ownerPct.toStringAsFixed(0)}%',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SliderTheme(
                        data: SliderThemeData(
                          activeTrackColor: AppColors.primary,
                          inactiveTrackColor: AppColors.info.withValues(alpha: 0.3),
                          thumbColor: AppColors.primary,
                          overlayColor: AppColors.primary.withValues(alpha: 0.2),
                        ),
                        child: Slider(
                          value: ownerPct,
                          min: 0,
                          max: 100,
                          divisions: 20,
                          onChanged: (val) {
                            setSheetState(() {
                              ownerPct = val;
                              mechanicPct = 100 - val;
                            });
                          },
                        ),
                      ),
                      // Visual bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Row(
                          children: [
                            Expanded(
                              flex: ownerPct.round(),
                              child: Container(
                                height: 8,
                                color: AppColors.primary,
                              ),
                            ),
                            Expanded(
                              flex: mechanicPct.round(),
                              child: Container(
                                height: 8,
                                color: AppColors.info,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (nameController.text.isEmpty) return;
                      final newService = Service(
                        id: service?.id,
                        name: nameController.text,
                        price: double.tryParse(priceController.text) ?? 0,
                        description: descController.text,
                        mechanicPercentage: mechanicPct,
                        ownerPercentage: ownerPct,
                      );
                      if (service != null) {
                        await _db.updateService(newService);
                      } else {
                        await _db.insertService(newService);
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
                      service != null ? 'Simpan Perubahan' : 'Tambah Jasa',
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

  Future<void> _deleteService(Service service) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Jasa'),
        content: Text('Yakin ingin menghapus "${service.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal',
                style: TextStyle(color: AppColors.textSecondary)),
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
      await _db.deleteService(service.id!);
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Daftar Jasa',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : _services.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.build_outlined,
                          size: 64, color: AppColors.textLight),
                      const SizedBox(height: 12),
                      const Text(
                        'Belum ada jasa',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 16),
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
                  padding: const EdgeInsets.all(16),
                  itemCount: _services.length,
                  itemBuilder: (context, index) {
                    final service = _services[index];
                    return Dismissible(
                      key: Key(service.id.toString()),
                      background: Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 20),
                        decoration: BoxDecoration(
                          color: AppColors.info,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.edit, color: Colors.white),
                      ),
                      secondaryBackground: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: AppColors.danger,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (direction) async {
                        if (direction == DismissDirection.startToEnd) {
                          _showAddEditDialog(service: service);
                          return false;
                        } else {
                          _deleteService(service);
                          return false;
                        }
                      },
                      child: ItemTile(
                        title: service.name,
                        subtitle:
                            'Mekanik ${service.mechanicPercentage.toStringAsFixed(0)}% • Pemilik ${service.ownerPercentage.toStringAsFixed(0)}%',
                        trailingTop: Formatters.currency(service.price),
                        trailingBottom: service.description,
                        leadingIcon: Icons.build_circle_outlined,
                        leadingColor: AppColors.accent,
                        onTap: () => _showAddEditDialog(service: service),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
