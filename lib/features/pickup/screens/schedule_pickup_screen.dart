import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_constants.dart';

class SchedulePickupScreen extends ConsumerStatefulWidget {
  const SchedulePickupScreen({super.key});

  @override
  ConsumerState<SchedulePickupScreen> createState() =>
      _SchedulePickupScreenState();
}

class _SchedulePickupScreenState extends ConsumerState<SchedulePickupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _alamatController = TextEditingController();
  final _catatanController = TextEditingController();
  final _beratController = TextEditingController();

  DateTime? _selectedDate;
  String _selectedWaktu = '08:00 - 10:00';
  final List<String> _selectedJenisSampah = [];
  bool _isLoading = false;

  final List<String> _waktuOptions = [
    '08:00 - 10:00',
    '10:00 - 12:00',
    '13:00 - 15:00',
    '15:00 - 17:00',
  ];

  @override
  void dispose() {
    _alamatController.dispose();
    _catatanController.dispose();
    _beratController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submitSchedule() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih tanggal penjemputan'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_selectedJenisSampah.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih minimal satu jenis sampah'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      await Supabase.instance.client.from('pickup_schedules').insert({
        'user_id': userId,
        'tanggal_jemput': _selectedDate!.toIso8601String(),
        'waktu_jemput': _selectedWaktu,
        'alamat_jemput': _alamatController.text.trim(),
        'catatan': _catatanController.text.trim(),
        'jenis_sampah': _selectedJenisSampah,
        'estimasi_berat': double.parse(_beratController.text),
        'status': 'pending',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Jadwal penjemputan berhasil dibuat!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuat jadwal: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Jadwalkan Penjemputan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Tanggal
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today),
                title: Text(
                  _selectedDate != null
                      ? DateFormat(
                          'EEEE, dd MMMM yyyy',
                          'id',
                        ).format(_selectedDate!)
                      : 'Pilih Tanggal Penjemputan',
                  style: TextStyle(
                    color: _selectedDate != null ? null : Colors.grey[600],
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: _selectDate,
              ),
              const Divider(),
              const SizedBox(height: 8),

              // Waktu
              DropdownButtonFormField<String>(
                initialValue: _selectedWaktu,
                decoration: InputDecoration(
                  labelText: 'Waktu Penjemputan',
                  prefixIcon: const Icon(Icons.access_time),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _waktuOptions.map((waktu) {
                  return DropdownMenuItem(value: waktu, child: Text(waktu));
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _selectedWaktu = value);
                },
              ),
              const SizedBox(height: 16),

              // Alamat
              TextFormField(
                controller: _alamatController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Alamat Penjemputan',
                  prefixIcon: const Icon(Icons.location_on),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Alamat tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Jenis Sampah
              Text(
                'Jenis Sampah',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AppConstants.poinPerKg.keys.map((jenis) {
                  final isSelected = _selectedJenisSampah.contains(jenis);
                  return FilterChip(
                    label: Text(jenis),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedJenisSampah.add(jenis);
                        } else {
                          _selectedJenisSampah.remove(jenis);
                        }
                      });
                    },
                    selectedColor: Colors.green[100],
                    checkmarkColor: Colors.green[800],
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Estimasi Berat
              TextFormField(
                controller: _beratController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Estimasi Berat (kg)',
                  prefixIcon: const Icon(Icons.scale),
                  suffixText: 'kg',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Estimasi berat tidak boleh kosong';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Masukkan angka yang valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Catatan
              TextFormField(
                controller: _catatanController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Catatan (opsional)',
                  prefixIcon: const Icon(Icons.note),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _submitSchedule,
                icon: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check),
                label: Text(_isLoading ? 'Menyimpan...' : 'Buat Jadwal'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
