#!/usr/bin/env bash
set -e

echo "=== Memulai Pembuatan Label ==="

# 1. Buat Label Tim & Modul
gh label create "anggota-1" --color "0E8A16" --description "Tugas Anggota 1: Auth & Dashboard" --force || true
gh label create "anggota-2" --color "1D76DB" --description "Tugas Anggota 2: Projects & Approvals" --force || true
gh label create "anggota-3" --color "5319E7" --description "Tugas Anggota 3: Manpower & Clients" --force || true
gh label create "status:ready" --color "FBCA04" --description "Siap dikerjakan (Sprint 1)" --force || true
gh label create "status:backlog" --color "C5DEF5" --description "Backlog (Sprint 2 & 3)" --force || true
gh label create "module:auth" --color "D93F0B" --description "Modul Autentikasi" --force || true
gh label create "module:dashboard" --color "0075CA" --description "Modul Dashboard" --force || true
gh label create "module:projects" --color "F9D0C4" --description "Modul Projects" --force || true
gh label create "module:approvals" --color "E99695" --description "Modul Approvals" --force || true
gh label create "module:manpower" --color "BFD4F2" --description "Modul Manpower" --force || true
gh label create "module:clients" --color "D4C5F9" --description "Modul Clients" --force || true

echo "=== Label Berhasil Dibuat ==="
echo "=== Membuat Issues Anggota 1 (Auth, Core & Dashboard) ==="

gh issue create \
  --title "[AUTH] Integrasi API Login & Token Storage" \
  --label "anggota-1,status:ready,module:auth" \
  --body "### Deskripsi
Hubungkan halaman login dengan API backend dan simpan JWT token ke local secure storage.

### Checklist
- [ ] Validasi form email & password
- [ ] Request API POST /login via Dio
- [ ] Simpan token & refresh token ke flutter_secure_storage
- [ ] Error feedback jika login gagal (snack/banner)
- [ ] State auth disimpan di Riverpod"

gh issue create \
  --title "[CORE] Setup Dio Auth Interceptor & Router Guard" \
  --label "anggota-1,status:ready,module:auth" \
  --body "### Deskripsi
Konfigurasi Dio Interceptor untuk inject header Authorization dan redirect guard di go_router.

### Checklist
- [ ] Auth interceptor: tambahkan header 'Authorization: Bearer <token>' pada tiap request
- [ ] Error interceptor: jika response 401 Unauthorized, hapus token dan redirect ke /login
- [ ] GoRouter redirect guard: cegah akses halaman dalam jika belum login"

gh issue create \
  --title "[DASHBOARD] Integrasi Widget KPI Cards dengan Real API" \
  --label "anggota-1,status:backlog,module:dashboard" \
  --body "### Deskripsi
Ganti nilai statis pada card Dashboard dengan response real dari endpoint summary/statistik BE.

### Checklist
- [ ] Buat model KPI/Summary
- [ ] Fetch data dari API summary dashboard
- [ ] Tampilkan Total Contract, Paid, Rest of Bill, dan Project Cost
- [ ] Handle loading shimmer & error state"

gh issue create \
  --title "[DASHBOARD] Implementasi Project Calendar menggunakan table_calendar" \
  --label "anggota-1,status:backlog,module:dashboard" \
  --body "### Deskripsi
Tampilkan kalender project dan event di halaman Dashboard menggunakan package table_calendar.

### Checklist
- [ ] Setup table_calendar di dashboard_page
- [ ] Tandai tanggal yang memiliki jadwal event project
- [ ] Tampilkan list event yang terjadi pada tanggal yang diklik"

gh issue create \
  --title "[DASHBOARD] Implementasi Financial & Project Chart menggunakan fl_chart" \
  --label "anggota-1,status:backlog,module:dashboard" \
  --body "### Deskripsi
Implementasikan grafik visualisasi data pada dashboard menggunakan fl_chart.

### Checklist
- [ ] Buat Bar Chart / Line Chart tren pendapatan atau status project
- [ ] Tooltip saat bar chart disentuh
- [ ] Desain responsif mengikuti lebar layar"

gh issue create \
  --title "[PROFILE] Halaman Profil & Role-based Sidebar" \
  --label "anggota-1,status:backlog,module:auth" \
  --body "### Deskripsi
Halaman profil pengguna dan filter menu sidebar berdasarkan role akun.

### Checklist
- [ ] Tampilkan informasi profil user (nama, role, email)
- [ ] Fitur Logout (clear token, reset state, redirect ke /login)
- [ ] Filter item sidebar AppShell berdasarkan role pengguna"

echo "=== Membuat Issues Anggota 2 (Projects & Approvals) ==="

gh issue create \
  --title "[PROJECTS] Integrasi API Get All Projects (Replace Mock Data)" \
  --label "anggota-2,status:ready,module:projects" \
  --body "### Deskripsi
Ganti MockProjectRepository dengan HttpProjectRepository yang memanggil REST API backend.

### Checklist
- [ ] Sesuaikan model Project dengan JSON backend
- [ ] Buat repository Dio untuk fetch list project
- [ ] Implementasi search query ke backend
- [ ] Tampilkan data asli pada ProjectListPage"

gh issue create \
  --title "[PROJECTS] Form Tambah & Edit Project" \
  --label "anggota-2,status:ready,module:projects" \
  --body "### Deskripsi
Buat form dialog atau halaman untuk membuat project baru dan mengedit project yang sudah ada.

### Checklist
- [ ] Form input: Nama, Kategori, PM, Nilai Kontrak, Tanggal Event
- [ ] Validasi form input
- [ ] Request POST project baru ke BE
- [ ] Request PUT/PATCH edit project ke BE
- [ ] Integrasi tombol delete project dengan konfirmasi dialog"

gh issue create \
  --title "[PROJECTS] Halaman Detail Project (/projects/:id)" \
  --label "anggota-2,status:backlog,module:projects" \
  --body "### Deskripsi
Halaman detail project yang menampilkan informasi lengkap dan daftar tim yang bertugas.

### Checklist
- [ ] Route dinamis /projects/:id di AppRouter
- [ ] Fetch detail project by ID dari BE
- [ ] Tampilkan rincian biaya, client, dan status milestone
- [ ] Tampilkan tim manpower yang di-assign ke project"

gh issue create \
  --title "[APPROVALS] Halaman List Production Cost Approval" \
  --label "anggota-2,status:backlog,module:approvals" \
  --body "### Deskripsi
Halaman list pengajuan biaya produksi yang memerlukan persetujuan.

### Checklist
- [ ] Buat model & repository untuk Production Cost Approval
- [ ] Tampilan list menggunakan ResponsiveDataView
- [ ] Badge status approval (Pending, Approved, Rejected)
- [ ] Filter berdasarkan status pengajuan"

gh issue create \
  --title "[APPROVALS] Detail Approval & Action Approve/Reject dengan Catatan" \
  --label "anggota-2,status:backlog,module:approvals" \
  --body "### Deskripsi
Aksi approve atau reject pengajuan biaya produksi.

### Checklist
- [ ] Dialog/Halaman rincian item pengeluaran biaya
- [ ] Tombol Approve -> memicu API POST /approve
- [ ] Tombol Reject -> buka dialog input alasan penolakan -> memicu API POST /reject
- [ ] Refresh data otomatis setelah aksi berhasil"

gh issue create \
  --title "[HISTORY] Halaman History Project dengan Filter Status & Tahun" \
  --label "anggota-2,status:backlog,module:projects" \
  --body "### Deskripsi
Halaman arsip project yang telah selesai atau ditutup.

### Checklist
- [ ] Tampilan list history project
- [ ] Filter berdasarkan tahun dan kategori
- [ ] Ringkasan pencapaian dan total nilai kontrak project selesai"

echo "=== Membuat Issues Anggota 3 (Manpower, Skills & Clients) ==="

gh issue create \
  --title "[MANPOWER] Halaman List Manpower dengan ResponsiveDataView" \
  --label "anggota-3,status:ready,module:manpower" \
  --body "### Deskripsi
Tampilkan daftar seluruh manpower/SDM tim menggunakan ResponsiveDataView.

### Checklist
- [ ] Model Manpower & repository Dio
- [ ] Tampilan data manpower (nama, role/keahlian, status ketersediaan, kontak)
- [ ] Search & filter manpower berdasarkan ketersediaan (Available / On Project)"

gh issue create \
  --title "[MANPOWER] Form Tambah & Edit Data Manpower" \
  --label "anggota-3,status:ready,module:manpower" \
  --body "### Deskripsi
Fitur untuk menambahkan manpower baru dan memperbarui data manpower.

### Checklist
- [ ] Form input data manpower (nama, kontak, keahlian/skill, role)
- [ ] Integrasi endpoint POST /manpower
- [ ] Integrasi endpoint PUT /manpower/:id
- [ ] Aksi hapus manpower dengan dialog konfirmasi"

gh issue create \
  --title "[SKILLS] CRUD Skill Management (/skills)" \
  --label "anggota-3,status:ready,module:manpower" \
  --body "### Deskripsi
Manajemen data master keahlian/skill tim.

### Checklist
- [ ] Tampilan list skills (/skills)
- [ ] Dialog tambah skill baru
- [ ] Dialog edit skill & hapus skill
- [ ] Integrasi API CRUD skills"

gh issue create \
  --title "[CLIENTS] Halaman Data Client & Form CRUD Client" \
  --label "anggota-3,status:ready,module:clients" \
  --body "### Deskripsi
Manajemen data kontak client perorangan atau PIC perusahaan.

### Checklist
- [ ] List data client menggunakan ResponsiveDataView
- [ ] Search client by nama / email / no telp
- [ ] Form tambah & edit client
- [ ] Hapus data client dengan konfirmasi"

gh issue create \
  --title "[COMPANIES] Halaman Data Perusahaan & Form CRUD Company" \
  --label "anggota-3,status:backlog,module:clients" \
  --body "### Deskripsi
Manajemen data perusahaan / instansi rekanan klien.

### Checklist
- [ ] List data instansi/company
- [ ] Form tambah & edit data perusahaan (nama instansi, alamat, nomor kontak)
- [ ] Tampilkan daftar project yang terhubung dengan company tersebut"

echo "=== Selesai! Semua 17 Issue Berhasil Dibuat ==="

