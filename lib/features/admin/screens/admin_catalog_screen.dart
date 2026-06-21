import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/models/catalog_item.dart';

class AdminCatalogScreen extends StatefulWidget {
  const AdminCatalogScreen({super.key});

  @override
  State<AdminCatalogScreen> createState() => _AdminCatalogScreenState();
}

class _AdminCatalogScreenState extends State<AdminCatalogScreen> {
  List<CatalogItem> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    try {
      final data = await Supabase.instance.client
          .from('catalog_items')
          .select()
          .order('kategori')
          .order('poin_dibutuhkan');

      setState(() {
        _items = (data as List)
            .map((json) => CatalogItem.fromJson(json))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading catalog: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteItem(CatalogItem item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Item'),
        content: Text('Yakin ingin menghapus "${item.nama}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await Supabase.instance.client
            .from('catalog_items')
            .delete()
            .eq('id', item.id);
        _loadItems();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Item berhasil dihapus'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menghapus: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _showAddEditDialog({CatalogItem? item}) async {
    final namaController = TextEditingController(text: item?.nama ?? '');
    final deskripsiController = TextEditingController(
      text: item?.deskripsi ?? '',
    );
    final poinController = TextEditingController(
      text: item?.poinDibutuhkan.toString() ?? '',
    );
    final nominalController = TextEditingController(text: item?.nominal ?? '');
    final stokController = TextEditingController(
      text: item?.stok.toString() ?? '0',
    );
    String selectedKategori = item?.kategori.name ?? 'pulsa';

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(item == null ? 'Tambah Item' : 'Edit Item'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: namaController,
                  decoration: const InputDecoration(labelText: 'Nama Item'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: deskripsiController,
                  decoration: const InputDecoration(labelText: 'Deskripsi'),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: selectedKategori,
                  decoration: const InputDecoration(labelText: 'Kategori'),
                  items: const [
                    DropdownMenuItem(value: 'pulsa', child: Text('Pulsa')),
                    DropdownMenuItem(
                      value: 'tokenListrik',
                      child: Text('Token Listrik'),
                    ),
                    DropdownMenuItem(value: 'eWallet', child: Text('E-Wallet')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => selectedKategori = value);
                    }
                  },
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: nominalController,
                  decoration: const InputDecoration(
                    labelText: 'Nominal (cth: Rp 10.000)',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: poinController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Poin Dibutuhkan',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: stokController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Stok'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(item == null ? 'Tambah' : 'Simpan'),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      final data = {
        'nama': namaController.text.trim(),
        'deskripsi': deskripsiController.text.trim(),
        'kategori': selectedKategori,
        'nominal': nominalController.text.trim(),
        'poin_dibutuhkan': int.tryParse(poinController.text) ?? 0,
        'stok': int.tryParse(stokController.text) ?? 0,
        'is_active': true,
      };

      try {
        if (item == null) {
          await Supabase.instance.client.from('catalog_items').insert(data);
        } else {
          await Supabase.instance.client
              .from('catalog_items')
              .update(data)
              .eq('id', item.id);
        }
        _loadItems();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                item == null
                    ? 'Item berhasil ditambah'
                    : 'Item berhasil diupdate',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menyimpan: $e'),
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
      appBar: AppBar(title: const Text('Kelola Katalog')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
          ? const Center(child: Text('Belum ada item katalog'))
          : RefreshIndicator(
              onRefresh: _loadItems,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.green[50],
                        child: Icon(
                          _getIcon(item.kategori),
                          color: Colors.green[700],
                        ),
                      ),
                      title: Text(
                        item.nama,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        '${item.nominal} • ${item.poinDibutuhkan} poin • Stok: ${item.stok}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: PopupMenuButton(
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 18),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 18, color: Colors.red),
                                SizedBox(width: 8),
                                Text(
                                  'Hapus',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                        onSelected: (value) {
                          if (value == 'edit') {
                            _showAddEditDialog(item: item);
                          } else if (value == 'delete') {
                            _deleteItem(item);
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  IconData _getIcon(CatalogCategory category) {
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
