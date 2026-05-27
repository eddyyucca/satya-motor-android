import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/transaction.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';
import '../widgets/stat_card.dart';
import '../widgets/chart_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DatabaseHelper _db = DatabaseHelper();

  double _todayIncome = 0;
  double _monthIncome = 0;
  int _todayTxCount = 0;
  int _totalItems = 0;
  int _lowStockCount = 0;
  List<Map<String, dynamic>> _chartData = [];
  List<Transaction> _recentTransactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _db.getTodayIncome(),
        _db.getMonthIncome(),
        _db.getTodayTransactionCount(),
        _db.getTotalItemCount(),
        _db.getLowStockCount(),
        _db.getLast7DaysIncome(),
        _db.getTransactions(limit: 5),
      ]);

      setState(() {
        _todayIncome = results[0] as double;
        _monthIncome = results[1] as double;
        _todayTxCount = results[2] as int;
        _totalItems = results[3] as int;
        _lowStockCount = results[4] as int;
        _chartData = results[5] as List<Map<String, dynamic>>;
        _recentTransactions = results[6] as List<Transaction>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _loadData,
              child: CustomScrollView(
                slivers: [
                  // App Bar
                  SliverAppBar(
                    expandedHeight: 120,
                    floating: false,
                    pinned: true,
                    elevation: 0,
                    flexibleSpace: Container(
                      decoration: const BoxDecoration(
                        gradient: AppColors.primaryGradient,
                      ),
                      child: FlexibleSpaceBar(
                        titlePadding: const EdgeInsets.only(
                            left: 20, bottom: 16, right: 20),
                        title: const Row(
                          children: [
                            Icon(Icons.build_circle,
                                color: Colors.white, size: 22),
                            SizedBox(width: 8),
                            Text(
                              'Satya Motor',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        background: Container(
                          decoration: const BoxDecoration(
                            gradient: AppColors.primaryGradient,
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                right: -30,
                                top: -30,
                                child: Container(
                                  width: 150,
                                  height: 150,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color:
                                        Colors.white.withValues(alpha: 0.08),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 40,
                                bottom: -20,
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color:
                                        Colors.white.withValues(alpha: 0.06),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Content
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // Stat Cards - Row 1
                        Row(
                          children: [
                            Expanded(
                              child: StatCard(
                                title: 'Pendapatan Hari Ini',
                                value: Formatters.compactCurrency(_todayIncome),
                                icon: Icons.account_balance_wallet_rounded,
                                gradient: AppColors.primaryGradient,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: StatCard(
                                title: 'Transaksi Hari Ini',
                                value: _todayTxCount.toString(),
                                icon: Icons.receipt_long_rounded,
                                iconColor: AppColors.info,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Stat Cards - Row 2
                        Row(
                          children: [
                            Expanded(
                              child: StatCard(
                                title: 'Pendapatan Bulan Ini',
                                value: Formatters.compactCurrency(_monthIncome),
                                icon: Icons.trending_up_rounded,
                                iconColor: AppColors.success,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: StatCard(
                                title: 'Total Barang',
                                value: _totalItems.toString(),
                                icon: Icons.inventory_2_rounded,
                                iconColor: AppColors.accent,
                              ),
                            ),
                          ],
                        ),

                        // Low stock warning
                        if (_lowStockCount > 0) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.danger.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color:
                                      AppColors.danger.withValues(alpha: 0.2)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.warning_amber_rounded,
                                    color: AppColors.danger, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    '$_lowStockCount barang dengan stok rendah (<5)',
                                    style: const TextStyle(
                                      color: AppColors.danger,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const Icon(Icons.chevron_right,
                                    color: AppColors.danger, size: 20),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 20),

                        // Chart
                        IncomeChartWidget(data: _chartData),

                        const SizedBox(height: 20),

                        // Recent Transactions
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Transaksi Terakhir',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                // Navigate to income screen
                              },
                              child: const Text(
                                'Lihat Semua',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        if (_recentTransactions.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Column(
                              children: [
                                Icon(Icons.receipt_long_outlined,
                                    size: 48, color: AppColors.textLight),
                                SizedBox(height: 8),
                                Text(
                                  'Belum ada transaksi',
                                  style: TextStyle(color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          )
                        else
                          ...(_recentTransactions.map((tx) => Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.03),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: AppColors.primary
                                            .withValues(alpha: 0.1),
                                        borderRadius:
                                            BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                        Icons.receipt_outlined,
                                        color: AppColors.primary,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            tx.customerName?.isNotEmpty == true
                                                ? tx.customerName!
                                                : 'Pelanggan',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${tx.mechanicName ?? "-"} • ${tx.date}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      Formatters.currency(tx.totalAmount),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ))),

                        const SizedBox(height: 20),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
