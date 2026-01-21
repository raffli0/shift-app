# Shift - Aplikasi Absensi Pintar

**Shift** adalah aplikasi absensi karyawan modern, aman, dan mudah digunakan yang dibangun dengan **Flutter**. Aplikasi ini menyederhanakan manajemen tenaga kerja dengan menggabungkan pelacakan lokasi (*real-time*), verifikasi biometrik (*Face Liveness*), dan alat administrasi yang lengkap.

## 🚀 Fitur Utama

### 👤 Untuk Karyawan
- **Check-in/Out Pintar**:
  - **Validasi Lokasi**: Memastikan karyawan berada dalam radius kantor yang ditentukan.
  - **Deteksi Kehidupan Wajah (*Face Liveness*)**: Proses verifikasi biometrik 5 langkah (kedip, senyum, toleh) untuk mencegah pemalsuan.
  - **Tangkap Foto**: Otomatis mengambil foto selfie setelah verifikasi wajah berhasil.
- **Manajemen Istirahat**: Mulai dan akhiri istirahat dengan mudah dengan pelacakan waktu yang akurat.
- **Pengajuan Cuti**: Ajukan cuti dan pantau statusnya (Pending, Disetujui, Ditolak) secara *real-time*.
- **Riwayat**: Lihat log absensi pribadi dan jam kerja harian.

### 🛡️ Untuk Admin
- **Dashboard Langsung**: Pantau aktivitas absensi dan status karyawan secara *real-time*.
- **Log Absensi**: Tampilan detail semua *check-in/out* disertai lokasi peta dan bukti foto.
- **Manajemen Karyawan**:
  - Kelola profil pengguna dan peran (Karyawan, Admin).
  - Konfigurasi jadwal shift individu atau massal.
- **Konfigurasi Kantor**:
  - Atur lokasi kantor secara interaktif menggunakan peta.
  - Tentukan radius kantor untuk *geofencing*.
- **Manajemen Shift**: Atur jam kerja global dan kebijakan perusahaan.

## 📱 Galeri Aplikasi

| Login & Liveness | Dashboard Karyawan | Check-In Sukses | Panel Admin |
|:---:|:---:|:---:|:---:|
| <img src="docs/screenshots/login.png" alt="Login" width="200"/> | <img src="docs/screenshots/home.png" alt="Dashboard" width="200"/> | <img src="docs/screenshots/checkin.png" alt="Check In" width="200"/> | <img src="docs/screenshots/admin.png" alt="Admin Panel" width="200"/> |

> *Catatan: Ganti path gambar di atas dengan screenshot aplikasi Anda yang sebenarnya.*

## 🛠️ Teknologi yang Digunakan

- **Framework**: Flutter
- **Backend & Database**: Firebase (Authentication, Firestore, Storage)
- **Manajemen State**: Bloc / Cubit
- **Peta**: `flutter_map` dengan OpenStreetMap & CartoDB
- **Biometrik**: Google ML Kit (Face Detection)
- **UI/UX**: Desain premium kustom dengan komponen `forui`.
- **Integrasi API**: Dukungan upload foto ke API kustom (PHP) dengan *fallback* ke Firebase Storage.

## 📦 Cara Memulai (Getting Started)

### Prasyarat
- Flutter SDK (versi stabil terbaru)
- Setup Proyek Firebase (GoogleService-Info.plist / google-services.json)

### Instalasi

1. **Clone repositori**
   ```bash
   git clone https://github.com/username-anda/shift.git
   cd shift
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Jalankan Aplikasi**
   ```bash
   flutter run
   ```

## � Lisensi

Proyek ini dilisensikan di bawah Lisensi MIT - lihat file [LICENSE](LICENSE) untuk detailnya.
