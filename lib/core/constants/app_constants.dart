class AppConstants {
  AppConstants._();

  // Nama kategori sampah
  static const String plastik = 'Plastik';
  static const String kertas = 'Kertas';
  static const String elektronik = 'Elektronik';
  static const String logam = 'Logam';
  static const String kaca = 'Kaca';

  // Poin per kg untuk setiap kategori
  static const Map<String, int> poinPerKg = {
    plastik: 50,
    kertas: 30,
    elektronik: 200,
    logam: 100,
    kaca: 40,
  };

  // Deskripsi kategori
  static const Map<String, String> kategoriDeskripsi = {
    plastik: 'Botol plastik, kantong plastik, wadah plastik',
    kertas: 'Koran, majalah, kardus, kertas HVS',
    elektronik: 'HP bekas, charger, kabel, baterai',
    logam: 'Kaleng aluminium, besi bekas',
    kaca: 'Botol kaca, pecahan kaca',
  };

  // Icon kategori (Material Icons code points)
  static const Map<String, int> kategoriIcons = {
    plastik: 0xe5f5, // local_drink
    kertas: 0xe873, // description
    elektronik: 0xe1c1, // devices
    logam: 0xe84e, // build
    kaca: 0xe894, // local_bar
  };
}
