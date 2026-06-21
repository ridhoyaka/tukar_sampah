enum CatalogCategory { pulsa, tokenListrik, eWallet }

class CatalogItem {
  final String id;
  final String nama;
  final String deskripsi;
  final int poinDibutuhkan;
  final CatalogCategory kategori;
  final String nominal;
  final int stok;
  final String? imageUrl;
  final bool isActive;

  CatalogItem({
    required this.id,
    required this.nama,
    required this.deskripsi,
    required this.poinDibutuhkan,
    required this.kategori,
    required this.nominal,
    required this.stok,
    this.imageUrl,
    required this.isActive,
  });

  factory CatalogItem.fromJson(Map<String, dynamic> json) {
    return CatalogItem(
      id: json['id'] as String,
      nama: json['nama'] as String,
      deskripsi: json['deskripsi'] as String? ?? '',
      poinDibutuhkan: json['poin_dibutuhkan'] as int,
      kategori: CatalogCategory.values.firstWhere(
        (e) => e.name == json['kategori'],
        orElse: () => CatalogCategory.pulsa,
      ),
      nominal: json['nominal'] as String,
      stok: json['stok'] as int? ?? 0,
      imageUrl: json['image_url'] as String?,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  String get kategoriLabel {
    switch (kategori) {
      case CatalogCategory.pulsa:
        return 'Voucher Pulsa';
      case CatalogCategory.tokenListrik:
        return 'Token Listrik';
      case CatalogCategory.eWallet:
        return 'Saldo E-Wallet';
    }
  }
}
