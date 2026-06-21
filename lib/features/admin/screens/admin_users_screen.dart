import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final data = await Supabase.instance.client
          .from('profiles')
          .select()
          .order('created_at', ascending: false);

      setState(() {
        _users = List<Map<String, dynamic>>.from(data as List);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading users: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updatePoin(
    String userId,
    String namaUser,
    int currentPoin,
  ) async {
    final controller = TextEditingController(text: currentPoin.toString());

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Poin - $namaUser'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Total Poin',
            prefixIcon: Icon(Icons.stars),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        final newPoin = int.tryParse(controller.text) ?? currentPoin;
        await Supabase.instance.client
            .from('profiles')
            .update({'total_poin': newPoin})
            .eq('id', userId);

        _loadUsers();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Poin berhasil diupdate'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal update: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Users')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _users.isEmpty
          ? const Center(child: Text('Belum ada user'))
          : RefreshIndicator(
              onRefresh: _loadUsers,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _users.length,
                itemBuilder: (context, index) {
                  final user = _users[index];
                  final nama = user['nama_lengkap'] as String? ?? 'No Name';
                  final email = user['email'] as String? ?? '';
                  final poin = user['total_poin'] as int? ?? 0;
                  final role = user['role'] as String? ?? 'user';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: role == 'admin'
                            ? Colors.orange[100]
                            : Colors.green[100],
                        child: Text(
                          nama.isNotEmpty ? nama[0].toUpperCase() : '?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: role == 'admin'
                                ? Colors.orange[800]
                                : Colors.green[800],
                          ),
                        ),
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              nama,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (role == 'admin')
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange[100],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'ADMIN',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange[800],
                                ),
                              ),
                            ),
                        ],
                      ),
                      subtitle: Text(
                        '$email • $poin poin',
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: () =>
                            _updatePoin(user['id'] as String, nama, poin),
                        tooltip: 'Edit Poin',
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
