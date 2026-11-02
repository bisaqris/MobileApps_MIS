# Script PowerShell untuk membuat Labels dan Issues secara otomatis
# Prasyarat jika dijalankan lokal: install gh cli (`winget install GitHub.cli`) dan login (`gh auth login`)

Write-Host "=== Memulai Pembuatan Label ===" -ForegroundColor Cyan

gh label create "anggota-1" --color "0E8A16" --description "Tugas Anggota 1: Auth & Dashboard" --force
gh label create "anggota-2" --color "1D76DB" --description "Tugas Anggota 2: Projects & Approvals" --force
gh label create "anggota-3" --color "5319E7" --description "Tugas Anggota 3: Manpower & Clients" --force
gh label create "status:ready" --color "FBCA04" --description "Siap dikerjakan (Sprint 1)" --force
gh label create "status:backlog" --color "C5DEF5" --description "Backlog (Sprint 2 & 3)" --force
gh label create "module:auth" --color "D93F0B" --description "Modul Autentikasi" --force
gh label create "module:dashboard" --color "0075CA" --description "Modul Dashboard" --force
gh label create "module:projects" --color "F9D0C4" --description "Modul Projects" --force
gh label create "module:approvals" --color "E99695" --description "Modul Approvals" --force
gh label create "module:manpower" --color "BFD4F2" --description "Modul Manpower" --force
gh label create "module:clients" --color "D4C5F9" --description "Modul Clients" --force

Write-Host "=== Label Berhasil Dibuat ===" -ForegroundColor Green
Write-Host "=== Membuat Issues Anggota 1 ===" -ForegroundColor Cyan

gh issue create --title "[AUTH] Integrasi API Login & Token Storage" --label "anggota-1,status:ready,module:auth" --body "Hubungkan login page dengan API backend & flutter_secure_storage."
gh issue create --title "[CORE] Setup Dio Auth Interceptor & Router Guard" --label "anggota-1,status:ready,module:auth" --body "Setup auth header Bearer token dan redirect guard GoRouter."
gh issue create --title "[DASHBOARD] Integrasi Widget KPI Cards dengan Real API" --label "anggota-1,status:backlog,module:dashboard" --body "Ganti mock KPI cards dengan response API."
gh issue create --title "[DASHBOARD] Implementasi Project Calendar menggunakan table_calendar" --label "anggota-1,status:backlog,module:dashboard" --body "Implementasi kalender jadwal project."
gh issue create --title "[DASHBOARD] Implementasi Financial & Project Chart menggunakan fl_chart" --label "anggota-1,status:backlog,module:dashboard" --body "Implementasi chart performa keuangan."
gh issue create --title "[PROFILE] Halaman Profil & Role-based Sidebar" --label "anggota-1,status:backlog,module:auth" --body "Profil user, tombol logout, dan role filter sidebar."

Write-Host "=== Membuat Issues Anggota 2 ===" -ForegroundColor Cyan

gh issue create --title "[PROJECTS] Integrasi API Get All Projects (Replace Mock Data)" --label "anggota-2,status:ready,module:projects" --body "Hubungkan ProjectListPage dengan real API via Dio."
gh issue create --title "[PROJECTS] Form Tambah & Edit Project" --label "anggota-2,status:ready,module:projects" --body "Form input untuk create dan edit project."
gh issue create --title "[PROJECTS] Halaman Detail Project (/projects/:id)" --label "anggota-2,status:backlog,module:projects" --body "Halaman detail project dan list manpower bertugas."
gh issue create --title "[APPROVALS] Halaman List Production Cost Approval" --label "anggota-2,status:backlog,module:approvals" --body "List pengajuan biaya produksi yang butuh approval."
gh issue create --title "[APPROVALS] Detail Approval & Action Approve/Reject dengan Catatan" --label "anggota-2,status:backlog,module:approvals" --body "Aksi approve atau reject rincian biaya."
gh issue create --title "[HISTORY] Halaman History Project dengan Filter Status & Tahun" --label "anggota-2,status:backlog,module:projects" --body "Arsip riwayat project selesai."

Write-Host "=== Membuat Issues Anggota 3 ===" -ForegroundColor Cyan

gh issue create --title "[MANPOWER] Halaman List Manpower dengan ResponsiveDataView" --label "anggota-3,status:ready,module:manpower" --body "Daftar manpower dan filter status ketersediaan."
gh issue create --title "[MANPOWER] Form Tambah & Edit Data Manpower" --label "anggota-3,status:ready,module:manpower" --body "Form CRUD data SDM manpower."
gh issue create --title "[SKILLS] CRUD Skill Management (/skills)" --label "anggota-3,status:ready,module:manpower" --body "Manajemen master keahlian tim."
gh issue create --title "[CLIENTS] Halaman Data Client & Form CRUD Client" --label "anggota-3,status:ready,module:clients" --body "CRUD data kontak client."
gh issue create --title "[COMPANIES] Halaman Data Perusahaan & Form CRUD Company" --label "anggota-3,status:backlog,module:clients" --body "CRUD data instansi/rekanan perusahaan."

Write-Host "=== Selesai! Semua 17 Issue Berhasil Dibuat ===" -ForegroundColor Green

