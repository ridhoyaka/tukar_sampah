import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/models/transaction_history.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  Map<String, dynamic>? _profile;
  List<TransactionHistory> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        setState(() => _isLoading = false);
        return;
      }

      final profileData = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      final transData = await Supabase.instance.client
          .from('transactions')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(20);

      setState(() {
        _profile = profileData;
        _transactions = (transData as List)
            .map((json) => TransactionHistory.fromJson(json))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading profile data: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Yakin ingin keluar dari akun?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await Supabase.instance.client.auth.signOut();
      if (mounted) {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Profile Card
                    _buildProfileCard(),
                    const SizedBox(height: 24),

                    // Stats
                    _buildStatsRow(),
                    const SizedBox(height: 24),

                    // Transaction History
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Riwayat Transaksi',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildTransactionList(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.green[100],
            child: Text(
              (_profile?['nama_lengkap'] as String? ?? 'U')
                  .substring(0, 1)
                  .toUpperCase(),
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _profile?['nama_lengkap'] ?? 'Pengguna',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            _profile?['email'] ?? '',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 4),
          Text(
            _profile?['no_telepon'] ?? '',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on, size: 16, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text(
                _profile?['alamat'] ?? '-',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    final totalPoin = _profile?['total_poin'] ?? 0;
    final totalDeposit = _transactions
        .where((t) => t.tipe == TransactionType.deposit)
        .fold(0, (sum, t) => sum + t.poin);
    final totalRedeem = _transactions
        .where((t) => t.tipe == TransactionType.redeem)
        .fold(0, (sum, t) => sum + t.poin);

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.stars,
            label: 'Total Poin',
            value: '$totalPoin',
            color: Colors.amber,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.arrow_upward,
            label: 'Diperoleh',
            value: '$totalDeposit',
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.arrow_downward,
            label: 'Ditukar',
            value: '$totalRedeem',
            color: Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionList() {
    if (_transactions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.receipt_long, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text(
              'Belum ada transaksi',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _transactions.length,
      itemBuilder: (context, index) {
        final trans = _transactions[index];
        final isDeposit = trans.tipe == TransactionType.deposit;
        final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isDeposit ? Colors.green[50] : Colors.red[50],
              child: Icon(
                isDeposit ? Icons.arrow_upward : Icons.arrow_downward,
                color: isDeposit ? Colors.green : Colors.red,
              ),
            ),
            title: Text(trans.deskripsi, style: const TextStyle(fontSize: 14)),
            subtitle: Text(
              dateFormat.format(trans.createdAt),
              style: const TextStyle(fontSize: 12),
            ),
            trailing: Text(
              '${isDeposit ? '+' : '-'}${trans.poin}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDeposit ? Colors.green : Colors.red,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        ],
      ),
    );
  }
}
