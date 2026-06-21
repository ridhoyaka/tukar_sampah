enum PickupStatus { pending, confirmed, onTheWay, completed, cancelled }

class PickupSchedule {
  final String id;
  final String userId;
  final DateTime tanggalJemput;
  final String waktuJemput;
  final String alamatJemput;
  final String catatan;
  final List<String> jenisSampah;
  final double estimasiBerat;
  final PickupStatus status;
  final DateTime createdAt;

  PickupSchedule({
    required this.id,
    required this.userId,
    required this.tanggalJemput,
    required this.waktuJemput,
    required this.alamatJemput,
    required this.catatan,
    required this.jenisSampah,
    required this.estimasiBerat,
    required this.status,
    required this.createdAt,
  });

  factory PickupSchedule.fromJson(Map<String, dynamic> json) {
    return PickupSchedule(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      tanggalJemput: DateTime.parse(json['tanggal_jemput'] as String),
      waktuJemput: json['waktu_jemput'] as String,
      alamatJemput: json['alamat_jemput'] as String,
      catatan: json['catatan'] as String? ?? '',
      jenisSampah: List<String>.from(json['jenis_sampah'] as List),
      estimasiBerat: (json['estimasi_berat'] as num).toDouble(),
      status: PickupStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PickupStatus.pending,
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'tanggal_jemput': tanggalJemput.toIso8601String(),
      'waktu_jemput': waktuJemput,
      'alamat_jemput': alamatJemput,
      'catatan': catatan,
      'jenis_sampah': jenisSampah,
      'estimasi_berat': estimasiBerat,
      'status': status.name,
    };
  }

  String get statusLabel {
    switch (status) {
      case PickupStatus.pending:
        return 'Menunggu Konfirmasi';
      case PickupStatus.confirmed:
        return 'Dikonfirmasi';
      case PickupStatus.onTheWay:
        return 'Dalam Perjalanan';
      case PickupStatus.completed:
        return 'Selesai';
      case PickupStatus.cancelled:
        return 'Dibatalkan';
    }
  }
}
