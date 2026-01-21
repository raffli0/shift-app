# Shift Aplikasi Absensi Berbasis Mobile

Shift adalah aplikasi absensi karyawan berbasis Flutter yang dikembangkan untuk mempermudah proses pencatatan kehadiran secara digital. Aplikasi ini memanfaatkan teknologi lokasi (geofencing) dan verifikasi wajah (face liveness detection) untuk meningkatkan keamanan serta keakuratan data absensi.

Aplikasi ini dibuat sebagai proyek pengembangan aplikasi mobile dengan tujuan menerapkan konsep autentikasi, manajemen data, serta integrasi teknologi biometrik dan lokasi.

## Tujuan Pengembangan

Tujuan dari pengembangan aplikasi Shift adalah:
1. Meningkatkan akurasi pencatatan kehadiran karyawan.
2. Mengurangi potensi kecurangan dalam proses absensi.
3. Mempermudah admin dalam memantau kehadiran dan jam kerja.
4. Menerapkan pemanfaatan teknologi mobile, lokasi, dan biometrik.

## Fitur Aplikasi

### Fitur Karyawan
- Check-in dan check-out berbasis lokasi (geofencing).
- Verifikasi wajah menggunakan face liveness detection.
- Pengambilan foto selfie sebagai bukti absensi.
- Manajemen waktu istirahat.
- Pengajuan cuti dan pemantauan status cuti.
- Riwayat absensi dan jam kerja harian.

### Fitur Admin
- Dashboard absensi karyawan secara real-time.
- Log absensi lengkap (waktu, lokasi, dan foto).
- Manajemen data karyawan dan peran pengguna.
- Pengaturan lokasi kantor dan radius absensi.
- Manajemen jadwal dan shift kerja.

## Tech Stack yang Digunakan
- Framework: Flutter  
- Backend & Database: Firebase  
  - Firebase Authentication(email & password) 
  - Firebase Firestore 
- State Management: Bloc / Cubit  
- Peta dan Lokasi:  
  - flutter_map  
  - OpenStreetMap  
  - CartoDB  
- Face Detection: Google ML Kit  
- UI: Komponen kustom menggunakan forui  
- Integrasi API: Upload foto ke API kustom (PHP) dengan fallback ke Firebase Storage  

## 📱 Galeri Aplikasi

| Login & Liveness | Dashboard Karyawan | Check-In Sukses | Panel Admin |
|:---:|:---:|:---:|:---:|
| <img src="docs/screenshots/login.png" alt="Login" width="200"/> | <img src="docs/screenshots/home.png" alt="Dashboard" width="200"/> | <img src="docs/screenshots/checkin.png" alt="Check In" width="200"/> | <img src="docs/screenshots/admin.png" alt="Admin Panel" width="200"/> |

> *Catatan: Ganti path gambar di atas dengan screenshot aplikasi yang sebenarnya.*

## (Getting Started)

### Syarat
- Flutter SDK (versi stabil terbaru)
- Setup Proyek Firebase (google-services.json)

### Instalasi

1. **Clone repositori**
   ```bash
   git clone https://github.com/raffli0/shift-app.git
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
### Kesimpulan
Aplikasi Shift merupakan implementasi sistem absensi digital yang mengintegrasikan teknologi mobile, lokasi, dan biometrik. Dengan adanya fitur geofencing dan face liveness detection, aplikasi ini diharapkan dapat meningkatkan keamanan serta keakuratan data kehadiran dibandingkan dengan sistem absensi konvensional.
