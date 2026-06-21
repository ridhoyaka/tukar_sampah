import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/models/catalog_item.dart';

class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key});

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<CatalogItem> _items = [];
  bool _isLoading = true;
  int _userPoin = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;

      // Load catalog items
      final catalogData = await Supabase.instance.client
          .from('catalog_items')
          .select()
          .eq('is_active', true)
          .order('poin_dibutuhkan');

      // Load user poin
      if (userId != null) {
        final profileData = await Supabase.instance.client
            .from('profiles')
            .select('total_poin')
            .eq('id', userId)
            .single();
        _userPoin = profileData['total_poin'] as int? ?? 0;
      }

      setState(() {
        _items = (catalogData as List)
            .map((json) => CatalogItem.fromJson(json))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  List<CatalogItem> _getFilteredItems(CatalogCategory category) {
    return _items.where((item) => item.kategori == category).toList();
  }

  Future<void> _redeemItem(CatalogItem item) async {
    if (_userPoin < item.poinDibutuhkan) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Poin kamu tidak cukup!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Penukaran'),
        content: Text('Tukar ${item.poinDibutuhkan} poin untuk ${item.nama}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Tukar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      // Kurangi poin user
      await Supabase.instance.client
          .from('profiles')
          .update({'total_poin': _userPoin - item.poinDibutuhkan})
          .eq('id', userId);

      // Catat transaksi
      await Supabase.instance.client.from('transactions').insert({
        'user_id': userId,
        'tipe': 'redeem',
        'poin': item.poinDibutuhkan,
        'deskripsi': 'Penukaran: ${item.nama}',
      });

      setState(() {
        _userPoin -= item.poinDibutuhkan;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Berhasil menukar ${item.nama}!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menukar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Katalog Penukaran'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Pulsa'),
            Tab(text: 'Token Listrik'),
            Tab(text: 'E-Wallet'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Poin Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: Colors.green[50],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.stars, color: Colors.amber),
                      const SizedBox(width: 8),
                      Text(
                        'Poin kamu: $_userPoin',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[800],
                        ),
                      ),
                    ],
                  ),
                ),
                // Tab Content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildItemList(_getFilteredItems(CatalogCategory.pulsa)),
                      _buildItemList(
                        _getFilteredItems(CatalogCategory.tokenListrik),
                      ),
                      _buildItemList(
                        _getFilteredItems(CatalogCategory.eWallet),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildItemList(List<CatalogItem> items) {
    if (items.isEmpty) {
      return const Center(child: Text('Belum ada item tersedia'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final canRedeem = _userPoin >= item.poinDibutuhkan;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: _getCategoryColor(
                      item.kategori,
                    ).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getCategoryIcon(item.kategori),
                    color: _getCategoryColor(item.kategori),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.nama,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.nominal,
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.stars,
                            color: Colors.amber,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${item.poinDibutuhkan} poin',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.amber,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Redeem Button
                ElevatedButton(
                  onPressed: canRedeem ? () => _redeemItem(item) : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  child: const Text('Tukar'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getCategoryColor(CatalogCategory category) {
    switch (category) {
      case CatalogCategory.pulsa:
        return Colors.blue;
      case CatalogCategory.tokenListrik:
        return Colors.orange;
      case CatalogCategory.eWallet:
        return Colors.purple;
    }
  }

  IconData _getCategoryIcon(CatalogCategory category) {
    switch (category) {
      case CatalogCategory.pulsa:
        return Icons.phone_android;
      case CatalogCategory.tokenListrik:
        return Icons.bolt;
      case CatalogCategory.eWallet:
        return Icons.account_balance_wallet;
    }
  }
}
