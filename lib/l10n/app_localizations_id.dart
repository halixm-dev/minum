// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appName => 'Minum';

  @override
  String get loading => 'Memuat...';

  @override
  String get error => 'Kesalahan';

  @override
  String get success => 'Sukses';

  @override
  String get anErrorOccurred =>
      'Terjadi kesalahan yang tidak terduga. Silakan coba lagi.';

  @override
  String get tryAgain => 'Coba Lagi';

  @override
  String get ok => 'OKE';

  @override
  String get cancel => 'Batal';

  @override
  String get save => 'Simpan';

  @override
  String get delete => 'Hapus';

  @override
  String get edit => 'Edit';

  @override
  String get add => 'Tambah';

  @override
  String get done => 'Selesai';

  @override
  String get skip => 'Lewati';

  @override
  String get next => 'Selanjutnya';

  @override
  String get previous => 'Sebelumnya';

  @override
  String get submit => 'Kirim';

  @override
  String get search => 'Cari...';

  @override
  String get login => 'Masuk';

  @override
  String get logout => 'Keluar';

  @override
  String get register => 'Daftar';

  @override
  String get email => 'Email';

  @override
  String get password => 'Kata Sandi';

  @override
  String get confirmPassword => 'Konfirmasi Kata Sandi';

  @override
  String get forgotPassword => 'Lupa Kata Sandi?';

  @override
  String get dontHaveAccount => 'Belum punya akun? ';

  @override
  String get alreadyHaveAccount => 'Sudah punya akun? ';

  @override
  String get signUpHere => 'Daftar di sini';

  @override
  String get signInHere => 'Masuk di sini';

  @override
  String get loginWithGoogle => 'Masuk dengan Google';

  @override
  String get registerWithGoogle => 'Daftar dengan Google';

  @override
  String get passwordResetEmailSent =>
      'Email pengaturan ulang kata sandi telah dikirim. Periksa kotak masuk Anda.';

  @override
  String get weakPassword => 'Kata sandi terlalu lemah.';

  @override
  String get emailAlreadyInUse => 'Email ini sudah digunakan.';

  @override
  String get invalidEmail => 'Alamat email tidak valid.';

  @override
  String get userNotFound => 'Pengguna tidak ditemukan.';

  @override
  String get wrongPassword => 'Kata sandi salah.';

  @override
  String get passwordsDoNotMatch => 'Kata sandi tidak cocok.';

  @override
  String get homeTitle => 'Hidrasi Hari Ini';

  @override
  String get dailyGoal => 'Target Harian';

  @override
  String get consumed => 'Terkonsumsi';

  @override
  String get remaining => 'Tersisa';

  @override
  String get addWater => 'Tambah Air';

  @override
  String get ml => 'mL';

  @override
  String get oz => 'oz';

  @override
  String get motivationalQuote => 'Minum air, tetap segar!';

  @override
  String get logWaterTitle => 'Catat Asupan Air';

  @override
  String get howMuchWater => 'Berapa banyak yang Anda minum?';

  @override
  String get enterAmount => 'Masukkan jumlah';

  @override
  String get customAmount => 'Jumlah Khusus';

  @override
  String get quickAdd => 'Tambah Cepat';

  @override
  String get waterLoggedSuccessfully => 'Asupan air berhasil dicatat!';

  @override
  String get progressTitle => 'Kemajuan Hidrasi';

  @override
  String get historyTitle => 'Riwayat Hidrasi';

  @override
  String get dailyAverage => 'Rata-rata Harian';

  @override
  String get weekly => 'Mingguan';

  @override
  String get monthly => 'Bulanan';

  @override
  String get yearly => 'Tahunan';

  @override
  String get noDataAvailable => 'Tidak ada data tersedia untuk periode ini.';

  @override
  String get settingsTitle => 'Pengaturan';

  @override
  String get profile => 'Profil';

  @override
  String get general => 'Umum';

  @override
  String get notifications => 'Notifikasi';

  @override
  String get reminders => 'Pengingat';

  @override
  String get dailyWaterGoal => 'Target Air Harian';

  @override
  String get measurementUnit => 'Unit Pengukuran';

  @override
  String get reminderFrequency => 'Frekuensi Pengingat';

  @override
  String get reminderSound => 'Suara Pengingat';

  @override
  String get enableReminders => 'Aktifkan Pengingat';

  @override
  String get theme => 'Tema';

  @override
  String get lightTheme => 'Terang';

  @override
  String get darkTheme => 'Gelap';

  @override
  String get systemTheme => 'Bawaan Sistem';

  @override
  String get account => 'Akun';

  @override
  String get connectToGoogleFit => 'Hubungkan ke Google Fit';

  @override
  String get connectToHealthConnect => 'Hubungkan ke Health Connect';

  @override
  String get syncData => 'Sinkronisasi Data';

  @override
  String get about => 'Tentang';

  @override
  String get appVersion => 'Versi Aplikasi';

  @override
  String get privacyPolicy => 'Kebijakan Privasi';

  @override
  String get termsOfService => 'Ketentuan Layanan';

  @override
  String get rateApp => 'Beri Nilai Aplikasi';

  @override
  String get shareApp => 'Bagikan Aplikasi';

  @override
  String get reminderInterval => 'Interval Pengingat';

  @override
  String get startTime => 'Waktu Mulai';

  @override
  String get endTime => 'Waktu Selesai';

  @override
  String get reminderTitle => 'Tetap Terhidrasi!';

  @override
  String get reminderBody =>
      'Waktunya minum air. Tubuh Anda akan berterima kasih!';

  @override
  String smartReminderBody(String amount) {
    return 'Ini waktu yang tepat untuk ${amount}ml air!';
  }

  @override
  String get fieldRequired => 'Kolom ini wajib diisi.';

  @override
  String get invalidNumber => 'Masukkan angka yang valid.';

  @override
  String get positiveNumberRequired => 'Masukkan angka positif.';

  @override
  String get welcomeToMinum => 'Selamat datang di Minum!';

  @override
  String get onboarding1Title => 'Lacak Hidrasi Anda';

  @override
  String get onboarding1Desc =>
      'Catat asupan air Anda dengan mudah dan pantau kemajuan harian menuju target hidrasi Anda.';

  @override
  String get onboarding2Title => 'Pengingat Pintar';

  @override
  String get onboarding2Desc =>
      'Dapatkan pengingat yang dipersonalisasi untuk minum air sepanjang hari, menjaga Anda tetap di jalur.';

  @override
  String get onboarding3Title => 'Sinkronisasi & Analisis';

  @override
  String get onboarding3Desc =>
      'Hubungkan dengan aplikasi kesehatan dan lihat tren hidrasi Anda dari waktu ke waktu. Mari kita mulai!';

  @override
  String get getStarted => 'Mulai';

  @override
  String get weight => 'Berat Badan';

  @override
  String get kg => 'kg';

  @override
  String get lbs => 'lbs';

  @override
  String get activityLevel => 'Tingkat Aktivitas';

  @override
  String get sedentary => 'Sedentari (sedikit atau tanpa olahraga)';

  @override
  String get light => 'Ringan (olahraga ringan 1-3 hari/minggu)';

  @override
  String get moderate => 'Sedang (olahraga sedang 3-5 hari/minggu)';

  @override
  String get active => 'Aktif (olahraga keras 6-7 hari/minggu)';

  @override
  String get veryActive =>
      'Sangat Aktif (olahraga sangat keras & pekerjaan fisik atau latihan 2x)';

  @override
  String get weather => 'Cuaca';

  @override
  String get caloriesBurned => 'Kalori Terbakar';
}
