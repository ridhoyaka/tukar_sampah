import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminPickupsScreen extends StatefulWidget {
  const AdminPickupsScreen({super.key});

  @override
  State<AdminPickupsScreen> createState() => _AdminPickupsScreenState();
}

class _AdminPickupsScreenState extends State<AdminPickupsScreen> {
  List<Map<String, dynamic>> _pickups = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPickups();
  }

  Future<void> _loadPickups() async {
    try {
      final data = await Supabase.instance.client
          .from('pickup_schedules')
          .select('*, profiles(nama_lengkap)')
          .order('created_at', ascending: false);

      setState(() {
        _pickups = List<Map<String, dynamic>>.from(data as List);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading pickups: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStatus(String pickupId, String newStatus) async {
    try {
      await Supabase.instance.client
          .from('pickup_schedules')
          .update({'status': newStatus})
          .eq('id', pickupId);

      _loadPickups();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status diubah ke: ${_getStatusLabel(newStatus)}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal update status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Menunggu';
      case 'confirmed':
        return 'Dikonfirmasi';
      case 'onTheWay':
        return 'Dalam Perjalanan';
      case 'completed':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'onTheWay':
        return Colors.purple;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Penjemputan')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pickups.isEmpty
          ? const Center(child: Text('Belum ada jadwal penjemputan'))
          : RefreshIndicator(
              onRefresh: _loadPickups,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _pickups.length,
                itemBuilder: (context, index) {
                  final pickup = _pickups[index];
                  return _buildPickupCard(pickup);
                },
              ),
            ),
    );
  }

  Widget _buildPickupCard(Map<String, dynamic> pickup) {
    final status = pickup['status'] as String? ?? 'pending';
    final statusColor = _getStatusColor(status);
    final namaUser =
        pickup['profiles']?['nama_lengkap'] as String? ?? 'Unknown';
    final tanggal = pickup['tanggal_jemput'] as String? ?? '';
    final waktu = pickup['waktu_jemput'] as String? ?? '';
    final alamat = pickup['alamat_jemput'] as String? ?? '';
    final berat = pickup['estimasi_berat'] ?? 0;
    final jenisSampah = List<String>.from(pickup['jenis_sampah'] ?? []);

    String formattedDate = tanggal;
    try {
      formattedDate = DateFormat('dd MMM yyyy').format(DateTime.parse(tanggal));
    } catch (_) {}

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    namaUser,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Text(
                    _getStatusLabel(status),
                    style: TextStyle(
                      fontSize: 11,
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Details
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Text(
                  '$formattedDate, $waktu',
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(alamat, style: const TextStyle(fontSize: 13)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.scale, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Text('$berat kg', style: const TextStyle(fontSize: 13)),
                const SizedBox(width: 16),
                Expanded(
                  child: Wrap(
                    spacing: 4,
                    children: jenisSampah
                        .map(
                          (j) => Chip(
                            label: Text(
                              j,
                              style: const TextStyle(fontSize: 10),
                            ),
                            padding: EdgeInsets.zero,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            backgroundColor: Colors.green[50],
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Action Buttons
            Row(
              children: [
                const Text(
                  'Ubah status: ',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _StatusButton(
                          label: 'Konfirmasi',
                          color: Colors.blue,
                          onTap: () => _updateStatus(pickup['id'], 'confirmed'),
                        ),
                        const SizedBox(width: 6),
                        _StatusButton(
                          label: 'OTW',
                          color: Colors.purple,
                          onTap: () => _updateStatus(pickup['id'], 'onTheWay'),
                        ),
                        const SizedBox(width: 6),
                        _StatusButton(
                          label: 'Selesai',
                          color: Colors.green,
                          onTap: () => _updateStatus(pickup['id'], 'completed'),
                        ),
                        const SizedBox(width: 6),
                        _StatusButton(
                          label: 'Batal',
                          color: Colors.red,
                          onTap: () => _updateStatus(pickup['id'], 'cancelled'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _StatusButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
