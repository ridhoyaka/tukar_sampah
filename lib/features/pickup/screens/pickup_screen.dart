import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/models/pickup_schedule.dart';

class PickupScreen extends ConsumerStatefulWidget {
  const PickupScreen({super.key});

  @override
  ConsumerState<PickupScreen> createState() => _PickupScreenState();
}

class _PickupScreenState extends ConsumerState<PickupScreen> {
  List<PickupSchedule> _pickups = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPickups();
  }

  Future<void> _loadPickups() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      final data = await Supabase.instance.client
          .from('pickup_schedules')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      setState(() {
        _pickups = (data as List)
            .map((json) => PickupSchedule.fromJson(json))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Color _getStatusColor(PickupStatus status) {
    switch (status) {
      case PickupStatus.pending:
        return Colors.orange;
      case PickupStatus.confirmed:
        return Colors.blue;
      case PickupStatus.onTheWay:
        return Colors.purple;
      case PickupStatus.completed:
        return Colors.green;
      case PickupStatus.cancelled:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Penjemputan Sampah')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push('/schedule-pickup');
          _loadPickups();
        },
        icon: const Icon(Icons.add),
        label: const Text('Jadwalkan'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pickups.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: _loadPickups,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _pickups.length,
                itemBuilder: (context, index) {
                  return _buildPickupCard(_pickups[index]);
                },
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_shipping_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada jadwal penjemputan',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Tekan tombol + untuk menjadwalkan',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildPickupCard(PickupSchedule pickup) {
    final dateFormat = DateFormat('dd MMM yyyy', 'id');
    final statusColor = _getStatusColor(pickup.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      dateFormat.format(pickup.tanggalJemput),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
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
                    pickup.statusLabel,
                    style: TextStyle(
                      fontSize: 12,
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(pickup.waktuJemput),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Expanded(child: Text(pickup.alamatJemput)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.scale, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text('Estimasi: ${pickup.estimasiBerat} kg'),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: pickup.jenisSampah.map((jenis) {
                return Chip(
                  label: Text(jenis, style: const TextStyle(fontSize: 11)),
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  backgroundColor: Colors.green[50],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
