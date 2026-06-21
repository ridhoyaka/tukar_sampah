enum TransactionType { deposit, redeem }

class TransactionHistory {
  final String id;
  final String userId;
  final TransactionType tipe;
  final int poin;
  final String deskripsi;
  final DateTime createdAt;

  TransactionHistory({
    required this.id,
    required this.userId,
    required this.tipe,
    required this.poin,
    required this.deskripsi,
    required this.createdAt,
  });

  factory TransactionHistory.fromJson(Map<String, dynamic> json) {
    return TransactionHistory(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      tipe: json['tipe'] == 'deposit'
          ? TransactionType.deposit
          : TransactionType.redeem,
      poin: json['poin'] as int,
      deskripsi: json['deskripsi'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
