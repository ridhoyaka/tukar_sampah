import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';

class CalculatorScreen extends ConsumerStatefulWidget {
  const CalculatorScreen({super.key});

  @override
  ConsumerState<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends ConsumerState<CalculatorScreen> {
  String _selectedKategori = AppConstants.plastik;
  final _beratController = TextEditingController();
  int _hasilPoin = 0;
  final List<_CalculationItem> _daftarHitung = [];

  @override
  void dispose() {
    _beratController.dispose();
    super.dispose();
  }

  void _hitungPoin() {
    final berat = double.tryParse(_beratController.text);
    if (berat == null || berat <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan berat yang valid'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final poinPerKg = AppConstants.poinPerKg[_selectedKategori] ?? 0;
    final poin = (berat * poinPerKg).round();

    setState(() {
      _hasilPoin = poin;
      _daftarHitung.add(
        _CalculationItem(kategori: _selectedKategori, berat: berat, poin: poin),
      );
    });

    _beratController.clear();
  }

  int get _totalPoin => _daftarHitung.fold(0, (sum, item) => sum + item.poin);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kalkulator Poin')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Hitung estimasi poin dari sampah yang kamu kumpulkan',
                      style: TextStyle(color: Colors.blue[700], fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Kategori Dropdown
            DropdownButtonFormField<String>(
              initialValue: _selectedKategori,
              decoration: InputDecoration(
                labelText: 'Jenis Sampah',
                prefixIcon: const Icon(Icons.category),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: AppConstants.poinPerKg.keys.map((kategori) {
                return DropdownMenuItem(
                  value: kategori,
                  child: Text(
                    '$kategori (${AppConstants.poinPerKg[kategori]} poin/kg)',
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedKategori = value);
                }
              },
            ),
            const SizedBox(height: 16),

            // Berat Input
            TextFormField(
              controller: _beratController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'Berat (kg)',
                prefixIcon: const Icon(Icons.scale),
                suffixText: 'kg',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Hitung Button
            ElevatedButton.icon(
              onPressed: _hitungPoin,
              icon: const Icon(Icons.calculate),
              label: const Text('Hitung Poin'),
            ),
            const SizedBox(height: 24),

            // Hasil
            if (_hasilPoin > 0)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Estimasi Poin Terakhir',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.stars, color: Colors.amber, size: 32),
                        const SizedBox(width: 8),
                        Text(
                          '$_hasilPoin',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          ' poin',
                          style: TextStyle(color: Colors.white70, fontSize: 18),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            // Daftar Hitungan
            if (_daftarHitung.isNotEmpty) ...[
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Rincian Perhitungan',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _daftarHitung.clear();
                        _hasilPoin = 0;
                      });
                    },
                    child: const Text('Reset'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _daftarHitung.length,
                itemBuilder: (context, index) {
                  final item = _daftarHitung[index];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.green[100],
                        child: Icon(Icons.recycling, color: Colors.green[700]),
                      ),
                      title: Text(item.kategori),
                      subtitle: Text('${item.berat} kg'),
                      trailing: Text(
                        '+${item.poin} poin',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber[300]!),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Estimasi Poin:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '$_totalPoin poin',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.amber[800],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CalculationItem {
  final String kategori;
  final double berat;
  final int poin;

  _CalculationItem({
    required this.kategori,
    required this.berat,
    required this.poin,
  });
}
