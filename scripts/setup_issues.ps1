# Script PowerShell untuk menutup semua issue lama dan membuat 17 issue baru

Write-Host "=== 1. Membersihkan Label Anggota (Jika Ada) ===" -ForegroundColor Yellow
gh label delete "anggota-1" --yes 2>$null
gh label delete "anggota-2" --yes 2>$null
gh label delete "anggota-3" --yes 2>$null

Write-Host "=== 2. Memastikan Label Modul & Status Tersedia ===" -ForegroundColor Cyan
gh label create "status:ready" --color "FBCA04" --description "Siap dikerjakan (Sprint 1)" --force
gh label create "status:backlog" --color "C5DEF5" --description "Backlog (Sprint 2 & 3)" --force
gh label create "module:auth" --color "D93F0B" --description "Modul Autentikasi" --force
gh label create "module:dashboard" --color "0075CA" --description "Modul Dashboard" --force
gh label create "module:projects" --color "F9D0C4" --description "Modul Projects" --force
gh label create "module:approvals" --color "E99695" --description "Modul Approvals" --force
gh label create "module:manpower" --color "BFD4F2" --description "Modul Manpower" --force
gh label create "module:clients" --color "D4C5F9" --description "Modul Clients" --force

Write-Host "=== 3. Menutup Seluruh Open Issue yang Ada ===" -ForegroundColor Yellow
$openIssues = gh issue list --limit 200 --state open --json number --jq '.[].number'
foreach ($num in $openIssues) {
    if ($num) {
        Write-Host "Menutup Issue #$num..."
        gh issue close $num
    }
}

Write-Host "=== 4. Membuat 17 Issue Baru yang Bersih ===" -ForegroundColor Cyan
gh issue create --title "[AUTH] Integrasi API Login & Token Storage" --label "status:ready,module:auth" --body "Hubungkan login page dengan API backend & flutter_secure_storage."
gh issue create --title "[CORE] Setup Dio Auth Interceptor & Router Guard" --label "status:ready,module:auth" --body "Setup auth header Bearer token dan redirect guard GoRouter."
gh issue create --title "[DASHBOARD] Integrasi Widget KPI Cards dengan Real API" --label "status:backlog,module:dashboard" --body "Ganti mock KPI cards dengan response API."
gh issue create --title "[DASHBOARD] Implementasi Project Calendar menggunakan table_calendar" --label "status:backlog,module:dashboard" --body "Implementasi kalender jadwal project."
gh issue create --title "[DASHBOARD] Implementasi Financial & Project Chart menggunakan fl_chart" --label "status:backlog,module:dashboard" --body "Implementasi chart performa keuangan."
gh issue create --title "[PROFILE] Halaman Profil & Role-based Sidebar" --label "status:backlog,module:auth" --body "Profil user, tombol logout, dan role filter sidebar."
gh issue create --title "[PROJECTS] Integrasi API Get All Projects (Replace Mock Data)" --label "status:ready,module:projects" --body "Hubungkan ProjectListPage dengan real API via Dio."
gh issue create --title "[PROJECTS] Form Tambah & Edit Project" --label "status:ready,module:projects" --body "Form input untuk create dan edit project."
gh issue create --title "[PROJECTS] Halaman Detail Project (/projects/:id)" --label "status:backlog,module:projects" --body "Halaman detail project dan list manpower bertugas."
gh issue create --title "[APPROVALS] Halaman List Production Cost Approval" --label "status:backlog,module:approvals" --body "List pengajuan biaya produksi yang butuh approval."
gh issue create --title "[APPROVALS] Detail Approval & Action Approve/Reject dengan Catatan" --label "status:backlog,module:approvals" --body "Aksi approve atau reject rincian biaya."
gh issue create --title "[HISTORY] Halaman History Project dengan Filter Status & Tahun" --label "status:backlog,module:projects" --body "Arsip riwayat project selesai."
gh issue create --title "[MANPOWER] Halaman List Manpower dengan ResponsiveDataView" --label "status:ready,module:manpower" --body "Daftar manpower dan filter status ketersediaan."
gh issue create --title "[MANPOWER] Form Tambah & Edit Data Manpower" --label "status:ready,module:manpower" --body "Form CRUD data SDM manpower."
gh issue create --title "[SKILLS] CRUD Skill Management (/skills)" --label "status:ready,module:manpower" --body "Manajemen master keahlian tim."
gh issue create --title "[CLIENTS] Halaman Data Client & Form CRUD Client" --label "status:ready,module:clients" --body "CRUD data kontak client."
gh issue create --title "[COMPANIES] Halaman Data Perusahaan & Form CRUD Company" --label "status:backlog,module:clients" --body "CRUD data instansi/rekanan perusahaan."

Write-Host "=== Selesai! Semua Issue Lama Ditutup & 17 Issue Baru Aktif ===" -ForegroundColor Green
