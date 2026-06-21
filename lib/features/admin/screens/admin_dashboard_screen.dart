import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _totalUsers = 0;
  int _totalPickups = 0;
  int _pendingPickups = 0;
  int _totalCatalogItems = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final client = Supabase.instance.client;

      final usersData = await client.from('profiles').select('id');
      final pickupsData = await client
          .from('pickup_schedules')
          .select('id, status');
      final catalogData = await client.from('catalog_items').select('id');

      setState(() {
        _totalUsers = (usersData as List).length;
        _totalPickups = (pickupsData as List).length;
        _pendingPickups = (pickupsData)
            .where((p) => p['status'] == 'pending')
            .length;
        _totalCatalogItems = (catalogData as List).length;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading admin stats: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Yakin ingin keluar dari akun admin?'),
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
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStats,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1B5E20), Color(0xFF388E3C)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Panel Admin 🛠️',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Kelola aplikasi TukarSampah dari sini',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Stats Grid
                    Text(
                      'Statistik',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.4,
                      children: [
                        _StatCard(
                          icon: Icons.people,
                          label: 'Total User',
                          value: '$_totalUsers',
                          color: Colors.blue,
                        ),
                        _StatCard(
                          icon: Icons.local_shipping,
                          label: 'Total Jemput',
                          value: '$_totalPickups',
                          color: Colors.orange,
                        ),
                        _StatCard(
                          icon: Icons.pending_actions,
                          label: 'Pending',
                          value: '$_pendingPickups',
                          color: Colors.red,
                        ),
                        _StatCard(
                          icon: Icons.card_giftcard,
                          label: 'Item Katalog',
                          value: '$_totalCatalogItems',
                          color: Colors.purple,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Quick Actions
                    Text(
                      'Aksi Cepat',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _AdminActionTile(
                      icon: Icons.card_giftcard,
                      title: 'Kelola Katalog',
                      subtitle: 'Tambah, edit, hapus item penukaran',
                      onTap: () => context.go('/admin/catalog'),
                    ),
                    _AdminActionTile(
                      icon: Icons.local_shipping,
                      title: 'Kelola Penjemputan',
                      subtitle: 'Konfirmasi & update status penjemputan',
                      onTap: () => context.go('/admin/pickups'),
                    ),
                    _AdminActionTile(
                      icon: Icons.people,
                      title: 'Kelola Users',
                      subtitle: 'Lihat & kelola data pengguna',
                      onTap: () => context.go('/admin/users'),
                    ),
                  ],
                ),
              ),
            ),
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
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }
}

class _AdminActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _AdminActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green[50],
          child: Icon(icon, color: Colors.green[700]),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
