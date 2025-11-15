# EcoSort

Aplikasi Flutter untuk mengenali jenis sampah dan memberi saran pemilahan/daur ulang. Fitur utama adalah scan gambar (kamera/galeri), klasifikasi via Gemini API, serta tips ramah lingkungan dan ide reuse.

## Ringkasan Fitur

-  **Scan & Klasifikasi:** Ambil/unggah gambar sampah, kirim ke Gemini, terima label, kategori, tingkat akurasi, dan rekomendasi.
-  **Riwayat Scan:** Menyimpan hasil scan (menggunakan `sqflite`) agar bisa ditinjau kembali.
-  **Offline Handling:** Saat offline, tombol Scan dinonaktifkan dan muncul banner peringatan. Permintaan ke API tidak dijalankan.
-  **Navigasi & Tema:** Named routes terpusat dan tema konsisten dari `core`.

## Arsitektur & Struktur Proyek

Proyek diorganisasikan per fitur (`feature-based`), dengan pemisahan `presentation`, `domain`, dan `data` untuk skalabilitas.

```
lib/
	core/
		app.dart
		router.dart
		theme.dart
		widgets/
			bottom_navbar.dart
	features/
		splash/
			presentation/pages/splash_page.dart
		home/
			presentation/pages/home_page.dart
			presentation/widgets/...
		history/
			presentation/pages/history_page.dart
			presentation/controller/...
		scan/
			data/
				gemini_client.dart        // Panggilan API Gemini + parsing respons
				scan_repository.dart       // Mapping respons ke entity
			domain/
				entities/scan_result.dart  // Entity hasil scan
			presentation/
				controllers/scan_controller.dart  // State scan + offline handling
				pages/scan_page.dart              // UI scan + offline banner
				pages/scan_result_page.dart       // UI hasil scan + tips
				widgets/result_sections.dart
	main.dart
```

## Teknologi yang Digunakan

-  `flutter`, `dart`
-  `dio` (HTTP client)
-  `image_picker` (kamera/galeri)
-  `provider` (state management sederhana)
-  `flutter_dotenv` (konfigurasi `.env` untuk API key)
-  `connectivity_plus` (deteksi konektivitas)
-  `sqflite`, `path_provider` (penyimpanan lokal riwayat)

## Persiapan & Konfigurasi

1. Pastikan Flutter SDK terpasang dan dapat digunakan.

   ```powershell
   flutter --version
   ```

2. Buat file `.env` di root proyek berisi API key Gemini:

   ```env
   GEMINI_API_KEY=YOUR_API_KEY_HERE
   # Opsional: base URL jika perlu override
   # GEMINI_BASE_URL=https://generativelanguage.googleapis.com/v1beta
   ```

3. Ambil dependencies:

   ```powershell
   flutter pub get
   ```

## Menjalankan Aplikasi

```powershell
flutter run
```

Secara default akan memuat `.env` dan menggunakan `GEMINI_API_KEY` untuk `GeminiClient`.

## Perilaku Offline

-  `ScanController` memonitor konektivitas. Saat `offline`, state `isOffline` menjadi `true`.
-  `scan_page.dart` menampilkan banner peringatan dan menonaktifkan tombol Scan.
-  Pemanggilan API dibatalkan dan akan mengembalikan `OfflineException` jika dipaksa.

## Build APK (Android)

Untuk produksi gunakan mode release, dan rekomendasi `split-per-abi` agar ukuran lebih kecil:

```powershell
flutter build apk --release --split-per-abi
```

Hasil build berada di `build\app\outputs\flutter-apk\` dan akan menghasilkan:

-  `app-armeabi-v7a-release.apk`
-  `app-arm64-v8a-release.apk`
-  `app-x86_64-release.apk`

Play Store akan memilih APK sesuai arsitektur perangkat pengguna.

## Testing

Tersedia contoh `widget_test.dart`.

```powershell
flutter test
```

## Troubleshooting

-  **Offline / Koneksi bermasalah:** Pastikan jaringan aktif. Banner offline akan muncul; tombol Scan nonaktif.
-  **API key kosong/invalid:** Pastikan `.env` berisi `GEMINI_API_KEY` yang benar.
-  **Gagal parse JSON dari Gemini:** Periksa respons API; `gemini_client.dart` sudah mencoba mengekstrak blok JSON bila ada teks tambahan.
-  **Asset tidak tampil:** Pastikan jalur asset benar di `pubspec.yaml` dan file berada di folder `assets/`.

## Lisensi & Privasi

Aplikasi ini melakukan panggilan ke layanan Gemini. Pastikan mematuhi syarat penggunaan layanan dan tidak mengunggah data sensitif. Tidak ada lisensi spesifik ditentukan di repositori ini; sesuaikan kebutuhan proyek Anda.
