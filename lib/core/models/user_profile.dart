class UserProfile {
  final String id;
  final String email;
  final String namaLengkap;
  final String noTelepon;
  final String alamat;
  final int totalPoin;
  final DateTime createdAt;

  UserProfile({
    required this.id,
    required this.email,
    required this.namaLengkap,
    required this.noTelepon,
    required this.alamat,
    required this.totalPoin,
    required this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String,
      namaLengkap: json['nama_lengkap'] as String? ?? '',
      noTelepon: json['no_telepon'] as String? ?? '',
      alamat: json['alamat'] as String? ?? '',
      totalPoin: json['total_poin'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nama_lengkap': namaLengkap,
      'no_telepon': noTelepon,
      'alamat': alamat,
      'total_poin': totalPoin,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
