# Script PowerShell untuk melengkapi issue yang belum ada secara cerdas

Write-Host "=== Memastikan Label Modul & Status Tersedia ===" -ForegroundColor Cyan
gh label create "status:ready" --color "FBCA04" --description "Siap dikerjakan (Sprint 1)" --force
gh label create "status:backlog" --color "C5DEF5" --description "Backlog (Sprint 2 & 3)" --force
gh label create "module:auth" --color "D93F0B" --description "Modul Autentikasi" --force
gh label create "module:dashboard" --color "0075CA" --description "Modul Dashboard" --force
gh label create "module:projects" --color "F9D0C4" --description "Modul Projects" --force
gh label create "module:approvals" --color "E99695" --description "Modul Approvals" --force
gh label create "module:manpower" --color "BFD4F2" --description "Modul Manpower" --force
gh label create "module:clients" --color "D4C5F9" --description "Modul Clients" --force

$existingTitles = gh issue list --limit 100 --state open --json title --jq '.[].title'

function Check-And-Create($title, $labels, $body) {
    if ($existingTitles -contains $title) {
        Write-Host "✓ Issue sudah ada: '$title' (dilewati)" -ForegroundColor Gray
    } else {
        Write-Host "+ Membuat issue yang hilang: '$title'" -ForegroundColor Green
        gh issue create --title $title --label $labels --body $body
    }
}

Write-Host "=== Sinkronisasi 17 Target Issue ===" -ForegroundColor Cyan
Check-And-Create "[AUTH] Integrasi API Login & Token Storage" "status:ready,module:auth" "Hubungkan login page dengan API backend & flutter_secure_storage."
Check-And-Create "[CORE] Setup Dio Auth Interceptor & Router Guard" "status:ready,module:auth" "Setup auth header Bearer token dan redirect guard GoRouter."
Check-And-Create "[DASHBOARD] Integrasi Widget KPI Cards dengan Real API" "status:backlog,module:dashboard" "Ganti mock KPI cards dengan response API."
Check-And-Create "[DASHBOARD] Implementasi Project Calendar menggunakan table_calendar" "status:backlog,module:dashboard" "Implementasi kalender jadwal project."
Check-And-Create "[DASHBOARD] Implementasi Financial & Project Chart menggunakan fl_chart" "status:backlog,module:dashboard" "Implementasi chart performa keuangan."
Check-And-Create "[PROFILE] Halaman Profil & Role-based Sidebar" "status:backlog,module:auth" "Profil user, tombol logout, dan role filter sidebar."
Check-And-Create "[PROJECTS] Integrasi API Get All Projects (Replace Mock Data)" "status:ready,module:projects" "Hubungkan ProjectListPage dengan real API via Dio."
Check-And-Create "[PROJECTS] Form Tambah & Edit Project" "status:ready,module:projects" "Form input untuk create dan edit project."
Check-And-Create "[PROJECTS] Halaman Detail Project (/projects/:id)" "status:backlog,module:projects" "Halaman detail project dan list manpower bertugas."
Check-And-Create "[APPROVALS] Halaman List Production Cost Approval" "status:backlog,module:approvals" "List pengajuan biaya produksi yang butuh approval."
Check-And-Create "[APPROVALS] Detail Approval & Action Approve/Reject dengan Catatan" "status:backlog,module:approvals" "Aksi approve atau reject rincian biaya."
Check-And-Create "[HISTORY] Halaman History Project dengan Filter Status & Tahun" "status:backlog,module:projects" "Arsip riwayat project selesai."
Check-And-Create "[MANPOWER] Halaman List Manpower dengan ResponsiveDataView" "status:ready,module:manpower" "Daftar manpower dan filter status ketersediaan."
Check-And-Create "[MANPOWER] Form Tambah & Edit Data Manpower" "status:ready,module:manpower" "Form CRUD data SDM manpower."
Check-And-Create "[SKILLS] CRUD Skill Management (/skills)" "status:ready,module:manpower" "Manajemen master keahlian tim."
Check-And-Create "[CLIENTS] Halaman Data Client & Form CRUD Client" "status:ready,module:clients" "CRUD data kontak client."
Check-And-Create "[COMPANIES] Halaman Data Perusahaan & Form CRUD Company" "status:backlog,module:clients" "CRUD data instansi/rekanan perusahaan."

Write-Host "=== Selesai! Seluruh 17 Issue Lengkap ===" -ForegroundColor Green
