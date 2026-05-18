import { initializeApp } from "https://www.gstatic.com/firebasejs/10.8.1/firebase-app.js";
import { getAuth, signInWithEmailAndPassword, onAuthStateChanged, signOut } from "https://www.gstatic.com/firebasejs/10.8.1/firebase-auth.js";
import { getFirestore, collection, addDoc, onSnapshot, query, doc, getDoc, updateDoc, deleteDoc, setDoc } from "https://www.gstatic.com/firebasejs/10.8.1/firebase-firestore.js";

lucide.createIcons();

        const firebaseConfig = {
            apiKey: "AIzaSyBeKy3OVPFZxzKSTMF03JPSHb79luKca64",
            authDomain: "mitra-rizki-admin.firebaseapp.com",
            projectId: "mitra-rizki-admin",
            storageBucket: "mitra-rizki-admin.firebasestorage.app",
            messagingSenderId: "262153091353",
            appId: "1:262153091353:web:75126235d26d8967802d88",
            measurementId: "G-LJ62E1HF6D"
        };

        const app = initializeApp(firebaseConfig);
        const auth = getAuth(app);
        const db = getFirestore(app);
        const appId = 'mitra-rizki-admin';

        const ui = {
            login: document.getElementById('login-screen'),
            sidebar: document.getElementById('sidebar'),
            navs: ['dashboard', 'proyek', 'database', 'jadwal', 'laporan', 'stok', 'katalog', 'paket', 'artikel', 'promo', 'chat'],
            contents: ['dashboard-content', 'main-content', 'database-content', 'jadwal-content', 'laporan-content', 'stok-content', 'katalog-content', 'paket-content', 'artikel-content', 'promo-content', 'chat-content', 'detail-content', 'print-content']
        };

        let state = { activeProjectId: null, activeProjectData: null, activeRabItems: [], katalog: [], stok: [], laporanList: [], proyekList: [], klienList: [], pekerjaList: [], jadwalList: [], paketList: [], artikelList: [], promoList: [], showArchived: false };
        let currentBhpForm = []; 
        let currentPaketItems = [];
        let editingLaporanId = null;

        const formatRupiah = n => new Intl.NumberFormat('id-ID').format(n);
        
        const parseImageUrl = (url) => {
            if(!url) return '';
            if (url.includes('drive.google.com/file/d/')) {
                const match = url.match(/\/d\/([a-zA-Z0-9_-]+)/);
                if (match && match[1]) return `https://drive.google.com/uc?export=view&id=${match[1]}`;
            } else if (url.includes('drive.google.com/open?id=')) {
                const urlParams = new URLSearchParams(url.split('?')[1]);
                if (urlParams.has('id')) return `https://drive.google.com/uc?export=view&id=${urlParams.get('id')}`;
            }
            return url;
        };
        
        window.uploadMedia = async (fileInput, targetInputId) => {
            const file = fileInput.files[0];
            if (!file) return;
            
            const targetInput = document.getElementById(targetInputId);
            const originalPlaceholder = targetInput.placeholder;
            targetInput.value = 'Mengunggah file...';
            targetInput.disabled = true;

            const formData = new FormData();
            formData.append('file', file);

            try {
                const res = await fetch('/api/upload', {
                    method: 'POST',
                    body: formData
                });
                const data = await res.json();
                if (res.ok && data.url) {
                    // Simpan URL lengkap agar Flutter tidak bingung
                    const absoluteUrl = data.url.startsWith('/') ? window.location.origin + data.url : data.url;
                    targetInput.value = absoluteUrl;
                } else {
                    alert('Gagal unggah: ' + (data.message || 'Error'));
                    targetInput.value = '';
                }
            } catch (e) {
                alert('Terjadi kesalahan koneksi saat mengunggah.');
                targetInput.value = '';
            } finally {
                targetInput.disabled = false;
                targetInput.placeholder = originalPlaceholder;
                fileInput.value = ''; 
            }
        };

        // --- CLOCK SCRIPT ---
        function updateClock() {
            const now = new Date();
            const timeEl = document.getElementById('clock-time');
            const dateEl = document.getElementById('clock-date');
            if(timeEl) timeEl.innerText = now.toLocaleTimeString('id-ID', { hour: '2-digit', minute: '2-digit', second: '2-digit' });
            if(dateEl) dateEl.innerText = now.toLocaleDateString('id-ID', { weekday: 'long', day: 'numeric', month: 'long', year: 'numeric' });
        }
        setInterval(updateClock, 1000);
        updateClock();

        const switchView = (contentId) => {
            ui.contents.forEach(id => { const el = document.getElementById(id); if(el) { el.classList.add('hidden'); el.classList.remove('flex'); } });
            const target = document.getElementById(contentId);
            if(target) { target.classList.remove('hidden'); target.classList.add('flex'); }
            ui.navs.forEach(nav => {
                const el = document.getElementById(`nav-${nav}`);
                if(!el) return;
                if (contentId.includes(nav)) { el.classList.add('bg-green-800', 'text-white', 'font-black'); el.classList.remove('text-green-100'); } 
                else { el.classList.remove('bg-green-800', 'text-white', 'font-black'); el.classList.add('text-green-100'); }
            });
            lucide.createIcons();
            
            // Set Header Title based on view
            const titles = {
                'dashboard': 'Workspace / Ringkasan',
                'proyek': 'Workspace / Manajemen Proyek',
                'database': 'Workspace / Database Master',
                'jadwal': 'Workspace / Jadwal Proyek',
                'laporan': 'Workspace / Laporan Lapangan',
                'stok': 'Workspace / Stok & Alat',
                'katalog': 'Workspace / Katalog Harga',
                'paket': 'Workspace / Katalog Layanan (B2C)',
                'artikel': 'Workspace / Artikel & Inspirasi',
                'promo': 'Workspace / Banner Promo (B2C)',
                'chat': 'Workspace / Chat Konsultasi',
                'detail': 'Workspace / Detail Proyek',
                'print': 'Workspace / Preview Dokumen'
            };
            const currentNav = ui.navs.find(n => contentId.includes(n)) || (contentId.includes('detail') ? 'detail' : 'print');
            document.getElementById('topbar-title').innerText = titles[currentNav] || 'Mitra Rizki Workspace';
        };

        ui.navs.forEach(nav => {
            const el = document.getElementById(`nav-${nav}`);
            if(el) el.onclick = () => { switchView(`${nav === 'proyek' ? 'main' : nav}-content`); }
        });

        // AUTH
        document.getElementById('btn-do-login').onclick = async () => {
            const email = document.getElementById('login-email').value.trim();
            const pass = document.getElementById('login-pass').value;
            if(!email || !pass) return;
            const btn = document.getElementById('btn-do-login'); btn.disabled = true; btn.innerHTML = "Memproses...";
            try { await signInWithEmailAndPassword(auth, email, pass); } catch (err) {
                document.getElementById('login-error').classList.remove('hidden'); btn.disabled = false; btn.innerHTML = "Masuk ke Panel";
            }
        };
        document.getElementById('btn-logout').onclick = async () => { if(confirm("Keluar sesi?")) { await signOut(auth); window.location.reload(); }};
        onAuthStateChanged(auth, user => {
            if (user) { ui.login.classList.add('hidden'); ui.sidebar.classList.remove('hidden'); switchView('dashboard-content'); initDataListeners(); } 
            else { ui.login.classList.remove('hidden'); ui.sidebar.classList.add('hidden'); }
        });

        // AUTOMATED SPK FUNCTION
        function runAutomatedSPK() {
            const insightsContainer = document.getElementById('automated-spk-insights');
            if(!insightsContainer) return;
            insightsContainer.innerHTML = '';
            let insights = [];

            // Rule 1: Stok Kritis
            const criticalStok = state.stok.filter(s => s.jumlah <= 5);
            if(criticalStok.length > 0) {
                insights.push({
                    type: 'warning',
                    title: 'Krisis Material Terdeteksi',
                    desc: `Terdapat ${criticalStok.length} barang (termasuk ${criticalStok[0].nama}) dengan stok kritis. Segera restock untuk menghindari berhentinya pengerjaan.`
                });
            } else {
                insights.push({ type: 'good', title: 'Stok Material Aman', desc: 'Semua persediaan material dalam kondisi mencukupi (> 5 unit) untuk operasional saat ini.'});
            }

            // Rule 2: Proyek Menggantung (Menunggu Survei)
            const surveiPending = state.proyekList.filter(p => p.status === 'Menunggu Survei');
            if(surveiPending.length > 0) {
                insights.push({
                    type: 'action',
                    title: 'Tindak Lanjut Klien',
                    desc: `Ada ${surveiPending.length} klien menunggu jadwal survei. Prioritaskan penjadwalan agar klien tidak beralih ke kompetitor.`
                });
            }

            // Rule 3: Analisa Beban Kerja (Jadwal)
            const jadwalBerjalan = state.jadwalList.filter(j => j.status !== 'Selesai');
            if(jadwalBerjalan.length >= 3) {
                 insights.push({
                    type: 'alert',
                    title: 'Beban Kerja Tim Tinggi',
                    desc: `Ada ${jadwalBerjalan.length} penugasan yang sedang berjalan atau belum dimulai. Pertimbangkan menambah pekerja harian lepas.`
                });
            }

            // Rule 4: Progres Macet (Proyek Sedang Dikerjakan, tapi tidak ada laporan hari ini)
            const proyekJalan = state.proyekList.filter(p => p.status === 'Sedang Dikerjakan');
            const laporansToday = state.laporanList.filter(l => {
                const lapDate = l.tanggal ? l.tanggal.toDate().toDateString() : '';
                return lapDate === new Date().toDateString();
            });
            const lapProyekIds = laporansToday.map(l => l.proyek_id);
            const unhandledProyek = proyekJalan.filter(p => !lapProyekIds.includes(p.id));

            if(unhandledProyek.length > 0) {
                insights.push({
                    type: 'warning',
                    title: 'Monitoring Progres Lapangan',
                    desc: `${unhandledProyek.length} proyek sedang berjalan namun belum ada laporan masuk hari ini. Minta mandor segera update sistem.`
                });
            }

            // Render
            if(insights.length === 0) {
                insightsContainer.innerHTML = '<p class="text-sm opacity-70 italic col-span-2 px-4">Sistem berjalan optimal. Belum ada rekomendasi khusus saat ini.</p>';
            } else {
                insights.forEach(ins => {
                    let icon = 'info', colorClass = 'bg-white/10 border-white/20 text-white';
                    if(ins.type === 'warning') { icon = 'alert-triangle'; colorClass = 'bg-rose-500/30 border-rose-500/40 text-rose-50'; }
                    if(ins.type === 'action') { icon = 'briefcase'; colorClass = 'bg-blue-500/30 border-blue-500/40 text-blue-50'; }
                    if(ins.type === 'alert') { icon = 'activity'; colorClass = 'bg-amber-500/30 border-amber-500/40 text-amber-50'; }
                    if(ins.type === 'good') { icon = 'check-circle'; colorClass = 'bg-emerald-500/30 border-emerald-500/40 text-emerald-50'; }

                    insightsContainer.innerHTML += `
                        <div class="p-5 rounded-2xl border ${colorClass} backdrop-blur-sm flex items-start">
                            <i data-lucide="${icon}" class="w-6 h-6 mr-4 shrink-0 mt-0.5 opacity-80"></i>
                            <div>
                                <h3 class="font-black text-sm mb-1 uppercase tracking-wider">${ins.title}</h3>
                                <p class="text-xs opacity-90 leading-relaxed font-medium">${ins.desc}</p>
                            </div>
                        </div>
                    `;
                });
            }
            lucide.createIcons();
        }

        function initDataListeners() {
            const paths = {
                klien: collection(db, 'artifacts', appId, 'public', 'data', 'klien'),
                pekerja: collection(db, 'artifacts', appId, 'public', 'data', 'pekerja'),
                proyek: collection(db, 'artifacts', appId, 'public', 'data', 'proyek'),
                stok: collection(db, 'artifacts', appId, 'public', 'data', 'stok'),
                katalog: collection(db, 'artifacts', appId, 'public', 'data', 'katalog'),
                laporan: collection(db, 'artifacts', appId, 'public', 'data', 'laporan_harian'),
                learning: collection(db, 'artifacts', appId, 'public', 'data', 'spk_learning'),
                jadwal: collection(db, 'artifacts', appId, 'public', 'data', 'jadwal'),
                paket_layanan: collection(db, 'artifacts', appId, 'public', 'data', 'paket_layanan'),
                artikel: collection(db, 'artifacts', appId, 'public', 'data', 'artikel'),
                promos: collection(db, 'artifacts', appId, 'public', 'data', 'promos')
            };

            // JADWAL LISTENER
            onSnapshot(paths.jadwal, (snap) => {
                const table = document.getElementById('jadwal-table-body');
                const dashList = document.getElementById('dashboard-jadwal-list');
                if(!table || !dashList) return;

                let jadwalArr = [];
                snap.forEach(d => jadwalArr.push({id: d.id, ...d.data()}));
                jadwalArr.sort((a,b) => new Date(a.tanggal) - new Date(b.tanggal));
                state.jadwalList = jadwalArr;

                table.innerHTML = ''; dashList.innerHTML = '';
                let upcCount = 0;

                if(jadwalArr.length === 0) {
                    table.innerHTML = '<tr><td colspan="5" class="p-8 text-center text-gray-400 italic font-medium">Belum ada jadwal terdaftar.</td></tr>';
                    dashList.innerHTML = '<p class="text-xs text-gray-400 italic">Belum ada jadwal terdekat.</p>';
                }

                jadwalArr.forEach(j => {
                    const tgl = new Date(j.tanggal).toLocaleDateString('id-ID', {day:'numeric', month:'long', year:'numeric'});
                    
                    if(j.status !== 'Selesai' && upcCount < 4) {
                        upcCount++;
                        dashList.innerHTML += `
                            <div class="p-4 bg-blue-50/50 rounded-2xl border border-blue-100 flex justify-between items-center group hover:bg-blue-50 transition-colors">
                                <div>
                                    <p class="text-[10px] font-black text-blue-600 uppercase tracking-widest mb-1">${tgl}</p>
                                    <p class="font-bold text-gray-800 text-sm leading-tight">${j.tugas}</p>
                                    <p class="text-[10px] text-gray-500 mt-1 font-medium flex items-center"><i data-lucide="map-pin" class="w-3 h-3 mr-1 text-gray-400"></i> ${j.nama_proyek}</p>
                                </div>
                                <div class="text-right">
                                    <span class="bg-white border border-blue-200 text-blue-700 px-3 py-1.5 rounded-full text-[10px] font-black shadow-sm">${j.tim}</span>
                                </div>
                            </div>
                        `;
                    }

                    const statusOpts = ['Belum Mulai', 'Berjalan', 'Selesai'].map(opt => `<option value="${opt}" ${j.status === opt ? 'selected':''}>${opt}</option>`).join('');
                    
                    table.innerHTML += `
                        <tr class="border-b border-gray-100 text-sm text-gray-700 hover:bg-gray-50 transition-colors">
                            <td class="p-4 font-black">${tgl}</td>
                            <td class="p-4">
                                <p class="font-bold text-gray-800">${j.tugas}</p>
                                <p class="text-[10px] text-gray-400 uppercase tracking-widest mt-1">${j.nama_proyek}</p>
                            </td>
                            <td class="p-4"><span class="bg-blue-50 text-blue-600 px-3 py-1 rounded-full text-[10px] font-black">${j.tim}</span></td>
                            <td class="p-4">
                                <select onchange="window.ubahStatusJadwal('${j.id}', this.value)" class="bg-white border border-gray-200 px-3 py-1.5 rounded-xl text-xs font-bold outline-none cursor-pointer shadow-sm focus:ring-2 focus:ring-blue-500">
                                    ${statusOpts}
                                </select>
                            </td>
                            <td class="p-4 text-right">
                                <button onclick="window.hapusJadwal('${j.id}')" class="text-red-300 hover:text-red-600 p-2 bg-white rounded-lg shadow-sm border border-gray-100 transition-colors"><i data-lucide="trash-2" class="w-4 h-4"></i></button>
                            </td>
                        </tr>
                    `;
                });
                if(upcCount === 0 && jadwalArr.length > 0) {
                    dashList.innerHTML = '<p class="text-xs text-gray-400 italic">Semua jadwal telah selesai dikerjakan.</p>';
                }
                lucide.createIcons();
                runAutomatedSPK();
            });

            // DATABASE KLIEN
            onSnapshot(paths.klien, (snap) => {
                const table = document.getElementById('klien-table-body'); const selKlien = document.getElementById('input-klien-id');
                const recentList = document.getElementById('dashboard-recent-klien');
                if(!table || !selKlien) return; table.innerHTML = ''; selKlien.innerHTML = '<option value="">-- Pilih Klien Terdaftar --</option>';
                if(recentList) recentList.innerHTML = '';
                
                let kArr = []; snap.forEach(docSnap => kArr.push({ id: docSnap.id, ...docSnap.data() })); 
                kArr.sort((a,b) => a.nama.localeCompare(b.nama));
                state.klienList = kArr;
                
                const statKlienEl = document.getElementById('stat-klien');
                if(statKlienEl) statKlienEl.innerText = kArr.length;

                // Urutkan berdasarkan tanggal terbaru untuk widget dashboard
                let recentKArr = [...kArr].sort((a, b) => (b.createdAt?.seconds || 0) - (a.createdAt?.seconds || 0)).slice(0, 5);
                if(recentKArr.length === 0 && recentList) recentList.innerHTML = '<p class="text-xs text-gray-400 italic">Belum ada klien mendaftar.</p>';
                recentKArr.forEach(k => {
                    const d = k.createdAt ? k.createdAt.toDate().toLocaleDateString('id-ID', {day:'numeric', month:'short'}) : 'Baru';
                    if(recentList) recentList.innerHTML += `<div class="p-3 bg-blue-50/50 rounded-2xl border border-blue-100 flex justify-between items-center group"><div class="flex items-center"><div class="w-8 h-8 bg-blue-100 text-blue-600 rounded-full flex items-center justify-center font-black mr-3 shadow-sm text-xs">${k.nama.charAt(0)}</div><div><p class="font-bold text-gray-800 text-xs">${k.nama}</p><p class="text-[9px] text-gray-400 flex items-center mt-0.5"><i data-lucide="mail" class="w-3 h-3 mr-1"></i> ${k.email || '-'}</p></div></div><span class="text-[10px] font-black text-gray-400 bg-white px-2 py-1 rounded-lg shadow-sm border border-gray-50">${d}</span></div>`;
                });

                if(kArr.length === 0) table.innerHTML = '<tr><td colspan="5" class="p-8 text-center text-gray-400 italic">Database klien kosong.</td></tr>';
                kArr.forEach(k => {
                    selKlien.innerHTML += `<option value="${k.id}">${k.nama} (${k.wa})</option>`;
                    table.innerHTML += `<tr class="border-b hover:bg-blue-50 font-medium"><td class="p-4 text-gray-900 font-bold">${k.nama}</td><td class="p-4 text-gray-600">${k.email || '-'}</td><td class="p-4 text-blue-600 font-bold"><a href="https://wa.me/${k.wa.replace(/[^0-9]/g, '')}" target="_blank" class="hover:underline flex items-center"><i data-lucide="phone" class="w-3 h-3 mr-1"></i>${k.wa}</a></td><td class="p-4 text-xs text-gray-500">${k.alamat || '-'}</td><td class="p-4 text-right flex justify-end space-x-2"><button onclick="window.editKlien('${k.id}')" class="text-amber-500 hover:text-amber-700 p-1.5 bg-amber-50 rounded-lg"><i data-lucide="pencil" class="w-4 h-4"></i></button><button onclick="window.hapusKlien('${k.id}')" class="text-red-400 hover:text-red-600 p-1.5 bg-red-50 rounded-lg"><i data-lucide="trash-2" class="w-4 h-4"></i></button></td></tr>`;
                });
                lucide.createIcons();
            });

            // DATABASE PEKERJA
            onSnapshot(paths.pekerja, (snap) => {
                const table = document.getElementById('pekerja-table-body');
                if(!table) return; table.innerHTML = '';
                let pArr = []; snap.forEach(docSnap => pArr.push({ id: docSnap.id, ...docSnap.data() })); pArr.sort((a,b) => a.nama.localeCompare(b.nama));
                state.pekerjaList = pArr;
                if(pArr.length === 0) table.innerHTML = '<tr><td colspan="4" class="p-8 text-center text-gray-400 italic">Database pekerja kosong.</td></tr>';
                pArr.forEach(p => {
                    table.innerHTML += `<tr class="border-b hover:bg-blue-50 font-medium"><td class="p-4 text-gray-900 font-bold">${p.nama}</td><td class="p-4 text-gray-600">${p.posisi}</td><td class="p-4 text-blue-600 font-bold"><a href="https://wa.me/${p.hp.replace(/[^0-9]/g, '')}" target="_blank" class="hover:underline flex items-center"><i data-lucide="phone" class="w-3 h-3 mr-1"></i>${p.hp}</a></td><td class="p-4 text-right flex justify-end space-x-2"><button onclick="window.editPekerja('${p.id}')" class="text-amber-500 hover:text-amber-700 p-1.5 bg-amber-50 rounded-lg"><i data-lucide="pencil" class="w-4 h-4"></i></button><button onclick="window.hapusPekerja('${p.id}')" class="text-red-400 hover:text-red-600 p-1.5 bg-red-50 rounded-lg"><i data-lucide="trash-2" class="w-4 h-4"></i></button></td></tr>`;
                });
                lucide.createIcons();
            });

            // API MYSQL UNTUK PROYEK
            window.loadProyekAPI = async () => {
                try {
                    const res = await fetch('/api/projects');
                    const data = await res.json();
                    const table = document.getElementById('table-body'); 
                    const selLaporan = document.getElementById('in-laporan-proyek');
                    const selJadwal = document.getElementById('in-jadwal-proyek');
                    if(!table) return; table.innerHTML = ''; 
                    selLaporan.innerHTML = '<option value="">Pilih Proyek...</option>';
                    if(selJadwal) selJadwal.innerHTML = '<option value="">Pilih Proyek...</option>';

                    let stats = { total: 0, aktif: 0, omzet: 0 }; let monthlyTrend = { 'Jan': 0, 'Feb': 0, 'Mar': 0, 'Apr': 0, 'Mei': 0, 'Jun': 0 }; let proyekArr = data;
                    
                    proyekArr.forEach(d => {
                        if(d.created_at) { 
                            const dDate = new Date(d.created_at);
                            const mName = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'][dDate.getMonth()]; 
                            if(monthlyTrend[mName] !== undefined) monthlyTrend[mName]++; 
                        }
                        selLaporan.innerHTML += `<option value="${d.id}">${d.nama_klien}</option>`;
                        if(selJadwal) selJadwal.innerHTML += `<option value="${d.id}">${d.nama_klien}</option>`;
                    });
                    state.proyekList = proyekArr; 
                    proyekArr.sort((a, b) => new Date(b.created_at||0) - new Date(a.created_at||0));
                    
                    const visibleProyek = state.showArchived ? proyekArr : proyekArr.filter(p => p.is_archived != 1);

                    // Update proyek badge
                    const pendingSurvei = proyekArr.filter(p => p.status === 'Menunggu Survei').length;
                    const badgeProyek = document.getElementById('badge-proyek');
                    if (badgeProyek) {
                        badgeProyek.innerText = pendingSurvei;
                        if (pendingSurvei > 0) badgeProyek.classList.remove('hidden');
                        else badgeProyek.classList.add('hidden');
                    }

                    if(visibleProyek.length === 0) table.innerHTML = `<tr><td colspan="4" class="p-8 text-center text-gray-400 italic">${state.showArchived ? 'Tidak ada proyek diarsip.' : 'Belum ada proyek berjalan.'}</td></tr>`;
                    
                    visibleProyek.forEach(d => {
                        stats.total++; if (d.status !== 'Selesai' && d.status !== 'Batal') stats.aktif++; 
                        if(typeof d.rabItems === 'string') { try { d.rabItems = JSON.parse(d.rabItems); } catch(e) {} }
                        if (d.status !== 'Batal' && d.rabItems && Array.isArray(d.rabItems)) d.rabItems.forEach(i => stats.omzet += (i.qty*i.harga));
                        
                        const isArchived = d.is_archived == 1;
                        let statusColor = 'bg-gray-50';
                        if (['Selesai'].includes(d.status)) statusColor = 'bg-green-50 border-green-200 text-green-700';
                        else if (['Sedang Dikerjakan'].includes(d.status)) statusColor = 'bg-blue-50 border-blue-200 text-blue-700';
                        else if (['Menunggu Survei', 'Pembuatan RAB', 'Negosiasi', 'Survey'].includes(d.status)) statusColor = 'bg-amber-50 border-amber-200 text-amber-700';
                        else if (['Batal'].includes(d.status)) statusColor = 'bg-red-50 border-red-200 text-red-700';

                        const selectHtml = `<select onchange="window.ubahStatusProyek('${d.id}', this.value)" class="${statusColor} border px-2 py-1.5 rounded-lg text-xs font-bold outline-none cursor-pointer">` + ['Survey', 'Menunggu Survei', 'Pembuatan RAB', 'Negosiasi', 'Sedang Dikerjakan', 'Selesai', 'Batal'].map(opt => `<option value="${opt}" ${d.status === opt ? 'selected' : ''} class="text-gray-800 bg-white">${opt}</option>`).join('') + `</select>`;
                        table.innerHTML += `<tr class="border-b hover:bg-green-50 font-bold ${isArchived ? 'opacity-60 bg-gray-50' : ''}"><td class="p-4 text-sm">${d.nama_klien} ${isArchived ? '<span class="ml-2 text-[9px] bg-gray-200 text-gray-500 px-1.5 py-0.5 rounded-full uppercase">Arsip</span>' : ''}</td><td class="text-xs text-gray-400 leading-relaxed">${d.alamat || '-'}</td><td class="p-4">${selectHtml}</td><td class="p-4 text-right flex justify-end items-center space-x-2"><button onclick="window.bukaDetail('${d.id}')" class="text-green-600 bg-green-50 px-3 py-1 rounded-lg border text-xs hover:bg-green-600 hover:text-white transition">RAB</button>${isArchived ? `<button onclick="window.arsipProyek('${d.id}', 0)" title="Kembalikan dari Arsip" class="text-blue-500 bg-blue-50 p-1.5 rounded-lg border border-blue-100 hover:bg-blue-500 hover:text-white transition"><i data-lucide="archive-restore" class="w-4 h-4"></i></button>` : ''}<button onclick="window.hapusProyek('${d.id}')" class="text-red-300 hover:text-red-600"><i data-lucide="trash-2" class="w-4 h-4"></i></button></td></tr>`;
                    });

                    // Add Archive Toggle if not exists
                    if(!document.getElementById('archive-toggle-container')) {
                        const header = document.querySelector('#main-content .flex.justify-between.items-center');
                        const toggleDiv = document.createElement('div');
                        toggleDiv.id = 'archive-toggle-container';
                        toggleDiv.className = 'flex items-center ml-4';
                        toggleDiv.innerHTML = `<label class="flex items-center cursor-pointer"><div class="relative"><input type="checkbox" id="chk-show-archived" class="sr-only" ${state.showArchived ? 'checked' : ''}><div class="block bg-gray-200 w-10 h-6 rounded-full"></div><div class="dot absolute left-1 top-1 bg-white w-4 h-4 rounded-full transition"></div></div><div class="ml-3 text-gray-400 text-xs font-bold uppercase tracking-wider">Lihat Arsip</div></label>`;
                        header.insertBefore(toggleDiv, header.lastElementChild);
                        document.getElementById('chk-show-archived').onchange = (e) => {
                            state.showArchived = e.target.checked;
                            window.loadProyekAPI();
                        };
                    }
                    document.getElementById('stat-total').innerText = stats.total; document.getElementById('stat-aktif').innerText = stats.aktif; document.getElementById('stat-nilai').innerText = 'Rp ' + formatRupiah(stats.omzet);
                    renderChart(monthlyTrend); lucide.createIcons();
                    if(state.activeProjectId) window.renderRealisasiBhp(state.activeProjectId);
                    runAutomatedSPK();
                } catch(e) { console.error("Gagal load proyek MySQL", e); }
            };
            window.loadProyekAPI();

            onSnapshot(paths.laporan, (snap) => {
                const container = document.getElementById('laporan-list');
                if(!container) return;
                container.innerHTML = '';
                let lapArr = [];
                snap.forEach(docSnap => lapArr.push({ id: docSnap.id, ...docSnap.data() }));
                lapArr.sort((a,b) => (b.tanggal?.seconds||0) - (a.tanggal?.seconds||0));
                state.laporanList = lapArr;

                if(lapArr.length === 0) {
                    container.innerHTML = `<div class="p-16 bg-white rounded-3xl text-center border-2 border-dashed border-gray-200">
                        <div class="w-16 h-16 bg-gray-100 rounded-3xl flex items-center justify-center mx-auto mb-4"><i data-lucide="clipboard" class="w-8 h-8 text-gray-300"></i></div>
                        <p class="font-black text-gray-400 mb-2">Belum ada laporan lapangan</p>
                    </div>`;
                    lucide.createIcons(); return;
                }

                const grupByProyek = {};
                lapArr.forEach(lap => {
                    const pid = lap.proyek_id || 'unknown';
                    const proj = state.proyekList.find(p => p.id == pid);
                    
                    // Skip reports for archived projects unless viewing all
                    if(proj && proj.is_archived == 1) return;

                    if(!grupByProyek[pid]) { 
                        grupByProyek[pid] = { 
                            proyek_id: pid, 
                            nama: lap.nama_klien || 'Proyek Umum', 
                            laporan: [], 
                            progressVerified: 0, 
                            progressPending: 0,
                            status: proj ? proj.status : ''
                        }; 
                    }
                    grupByProyek[pid].laporan.push(lap);
                    if(lap.status === 'Disetujui') grupByProyek[pid].progressVerified += (lap.progress || 0);
                    else grupByProyek[pid].progressPending += (lap.progress || 0);
                });

                Object.keys(grupByProyek).forEach(pid => {
                    const grp = grupByProyek[pid];
                    const verified = Math.min(grp.progressVerified, 100);
                    const pending  = Math.min(grp.progressPending, Math.max(0, 100 - verified));

                    const laporanHTML = grp.laporan.map(lap => {
                        const tgl = lap.tanggal ? lap.tanggal.toDate().toLocaleDateString('id-ID', {day:'numeric', month:'short'}) : 'Hari ini';
                        const isPending = lap.status === 'Pending' || !lap.status;
                        const matHtml = (lap.materials && lap.materials.length > 0) ? `<div class="flex flex-wrap gap-1 mt-2">${lap.materials.map(m => `<span class="bg-white border text-gray-500 px-2 py-0.5 rounded-lg text-[10px] font-bold">${m.nama} (${m.qty})</span>`).join('')}</div>` : '';
                        const statusBadge = isPending ? `<span class="bg-amber-100 text-amber-700 px-2 py-0.5 rounded-full text-[10px] font-black">Pending</span>` : `<span class="bg-green-100 text-green-700 px-2 py-0.5 rounded-full text-[10px] font-black">Disetujui</span>`;
                        const actionBtns = isPending
                            ? `<div class="flex gap-2 mt-3"><button onclick="window.editLaporan('${lap.id}')" class="flex-1 bg-white border py-2 rounded-xl text-[10px] font-black hover:bg-gray-50 transition">Edit</button><button onclick="window.setujuiLaporan('${lap.id}')" class="flex-2 bg-green-600 text-white py-2 px-4 rounded-xl text-[10px] font-black hover:bg-green-700">Setujui</button><button onclick="window.hapusLaporan('${lap.id}')" class="bg-red-50 text-red-400 p-2 rounded-xl"><i data-lucide="trash-2" class="w-3 h-3"></i></button></div>`
                            : `<div class="flex justify-between items-center mt-2"><a href="${lap.foto}" target="_blank" class="text-blue-400 text-[10px] font-bold hover:underline">Foto Bukti</a><button onclick="window.hapusLaporan('${lap.id}')" class="text-red-200"><i data-lucide="trash-2" class="w-3 h-3"></i></button></div>`;
                        
                        return `<div class="p-4 bg-gray-50 rounded-2xl ${isPending ? 'border-l-4 border-amber-400' : 'border-l-4 border-green-400'}"><div class="flex justify-between items-start mb-2"><div class="flex items-center gap-2"><span class="text-[10px] font-bold text-gray-400">${tgl}</span>${statusBadge}</div><span class="font-black text-xl text-gray-700">+${lap.progress}%</span></div><p class="text-xs text-gray-500 italic">"${lap.catatan || '-'}"</p>${matHtml}${actionBtns}</div>`;
                    }).join('');

                    const isSelesai = grp.status === 'Selesai';
                    container.innerHTML += `
                        <div class="bg-white rounded-3xl border shadow-sm overflow-hidden">
                            <div class="p-6 cursor-pointer hover:bg-gray-50" onclick="window.toggleProyekLaporan('${pid}')">
                                <div class="flex justify-between items-start">
                                    <div>
                                        <p class="text-[10px] font-black text-gray-400 mb-1">Proyek</p>
                                        <h3 class="font-black text-lg leading-tight">${grp.nama}</h3>
                                        ${isSelesai ? '<span class="mt-2 inline-block bg-green-100 text-green-700 text-[9px] font-black px-2 py-0.5 rounded-full uppercase">Pekerjaan Selesai</span>' : ''}
                                    </div>
                                    <div class="flex items-start gap-2">
                                        ${isSelesai ? `<button onclick="event.stopPropagation(); window.arsipProyek('${pid}', 1)" title="Pindahkan ke Arsip" class="bg-amber-50 text-amber-600 px-3 py-1.5 rounded-xl text-[10px] font-black border border-amber-200 hover:bg-amber-600 hover:text-white transition flex items-center"><i data-lucide="archive" class="w-3 h-3 mr-1"></i> Arsipkan</button>` : ''}
                                        <button onclick="event.stopPropagation(); window.hapusSeluruhLaporan('${pid}')" title="Hapus Seluruh Laporan Proyek" class="bg-red-50 text-red-500 p-2 rounded-xl border border-red-100 hover:bg-red-600 hover:text-white transition group"><i data-lucide="trash-2" class="w-4 h-4"></i></button>
                                        <div class="text-right ml-2">
                                            <p class="text-[10px] font-black text-gray-400">Terverifikasi</p>
                                            <p class="font-black text-3xl text-green-700">${verified}%</p>
                                        </div>
                                    </div>
                                </div>
                                <div class="mt-5">
                                    <div class="w-full bg-gray-100 rounded-full h-3 flex">
                                        <div class="bg-green-500 h-full rounded-l-full" style="width:${verified}%"></div>
                                        <div class="bg-amber-400 h-full" style="width:${pending}%"></div>
                                    </div>
                                </div>
                            </div>
                            <div id="acc-lap-${pid}" class="hidden">
                                <div class="border-t p-6 space-y-3">
                                    ${laporanHTML}
                                    <button onclick="window.tambahLaporanUntuk('${pid}')" class="w-full mt-2 py-3 border-2 border-dashed border-blue-200 rounded-2xl text-xs font-black text-blue-500 hover:bg-blue-50">Tambah Laporan</button>
                                </div>
                            </div>
                        </div>`;
                });
                lucide.createIcons();
                if(state.activeProjectId) window.renderRealisasiBhp(state.activeProjectId);
                runAutomatedSPK();
            });

            // API MYSQL UNTUK STOK
            window.loadStokAPI = async () => {
                try {
                    const res = await fetch('/api/inventory');
                    const data = await res.json();
                    const table = document.getElementById('stok-table-body'); const lowStockList = document.getElementById('low-stock-list');
                    if(!table) return; table.innerHTML = ''; lowStockList.innerHTML = '';
                    let lowCount = 0; let stokArr = data;
                    stokArr.sort((a, b) => a.nama.localeCompare(b.nama));
                    state.stok = stokArr;
                    stokArr.forEach(d => {
                        if(d.jumlah <= 5) { lowCount++; lowStockList.innerHTML += `<div class="flex justify-between items-center p-3 bg-rose-50 rounded-2xl border border-rose-100"><span class="font-black text-rose-700 text-[11px]">${d.nama}</span><span class="bg-rose-600 text-white px-2 py-0.5 rounded-lg text-[10px] font-black">${d.jumlah}</span></div>`; }
                        
                        let jumlahColor = d.jumlah <= 5 ? 'text-rose-600 bg-rose-50 border border-rose-100 px-2 py-1 rounded-lg' : (d.jumlah <= 15 ? 'text-amber-600 bg-amber-50 border border-amber-100 px-2 py-1 rounded-lg' : 'text-gray-800');
                        table.innerHTML += `<tr class="border-b text-sm text-gray-700"><td class="p-4 font-black">${d.nama}</td><td class="p-4 font-black"><span class="${jumlahColor}">${d.jumlah}</span></td><td class="p-4"><span class="text-[10px] font-black px-2 py-0.5 rounded-full ${d.kondisi === 'Bagus' ? 'bg-green-100 text-green-700':'bg-orange-100 text-orange-700'}">${d.kondisi}</span></td><td class="p-4 text-xs text-gray-400">${d.lokasi || '-'}</td><td class="p-4 text-right flex justify-end space-x-2"><button onclick="window.adjustStok('${d.id}', 1)" class="p-1.5 bg-green-50 text-green-600 rounded-lg border border-green-100 hover:bg-green-600 hover:text-white transition"><i data-lucide="plus-circle" class="w-4 h-4"></i></button><button onclick="window.adjustStok('${d.id}', -1)" class="p-1.5 bg-red-50 text-red-600 rounded-lg border border-red-100 hover:bg-red-600 hover:text-white transition"><i data-lucide="minus-circle" class="w-4 h-4"></i></button></td></tr>`;
                    });
                    
                    const badgeStok = document.getElementById('badge-stok');
                    if (badgeStok) {
                        badgeStok.innerText = lowCount;
                        if (lowCount > 0) badgeStok.classList.remove('hidden');
                        else badgeStok.classList.add('hidden');
                    }

                    if(lowCount === 0) lowStockList.innerHTML += '<p class="text-xs text-gray-400 italic font-medium">Semua stok terpantau aman.</p>';
                    document.getElementById('stat-stok-low').innerText = lowCount;
                    lucide.createIcons();
                    runAutomatedSPK();
                } catch(e) { console.error("Gagal load stok MySQL", e); }
            };
            window.loadStokAPI();

            onSnapshot(paths.learning, (snap) => {
                const container = document.getElementById('operational-activity');
                if(!container) return; container.innerHTML = '';
                let entries = []; snap.forEach(docSnap => entries.push(docSnap.data()));
                entries.sort((a,b) => b.timestamp - a.timestamp);
                if(entries.length === 0) container.innerHTML = '<p class="text-xs opacity-50">Belum ada aktivitas.</p>';
                entries.slice(0, 5).forEach(entry => {
                    const date = entry.timestamp ? entry.timestamp.toDate().toLocaleTimeString('id-ID', {hour:'2-digit', minute:'2-digit'}) : 'Baru';
                    container.innerHTML += `<div class="bg-white/10 p-3 rounded-2xl border border-white/10 mb-2"><div class="flex justify-between items-center mb-1"><span class="text-[10px] font-black text-green-300 uppercase">${entry.user.split('@')[0]}</span><span class="text-[9px] opacity-40">${date}</span></div><p class="text-[11px] leading-snug">${entry.correction || 'Feedback Sistem'}</p></div>`;
                });
            });

            // API MYSQL UNTUK KATALOG
            window.loadKatalogAPI = async () => {
                try {
                    const res = await fetch('/api/catalogs');
                    const data = await res.json();
                    const select = document.getElementById('select-katalog'); const table = document.getElementById('katalog-table-body');
                    if(!select || !table) return; select.innerHTML = '<option value="">+ Katalog</option>'; table.innerHTML = '';
                    let katalogArr = data;
                    katalogArr.sort((a, b) => a.nama.localeCompare(b.nama)); state.katalog = katalogArr;
                    katalogArr.forEach((d, i) => {
                        select.innerHTML += `<option value="${i}">${d.nama}</option>`;
                        table.innerHTML += `<tr class="border-b text-gray-700"><td class="p-4 font-bold text-gray-700">${d.nama}</td><td class="text-gray-400">${d.satuan}</td><td class="font-black text-green-700">Rp ${formatRupiah(d.harga)}</td><td class="p-4 text-center"><button onclick="window.hapusKatalog('${d.id}')" class="text-red-300 hover:text-red-500 transition"><i data-lucide="trash-2" class="w-4 h-4 mx-auto"></i></button></td></tr>`;
                    });
                    lucide.createIcons();
                } catch(e) { console.error("Gagal load katalog MySQL", e); }
            };
            window.loadKatalogAPI();

            // PAKET LAYANAN B2C
            onSnapshot(paths.paket_layanan, (snap) => {
                const container = document.getElementById('paket-list-container');
                if(!container) return; container.innerHTML = '';
                let pArr = []; snap.forEach(docSnap => pArr.push({ id: docSnap.id, ...docSnap.data() }));
                pArr.sort((a,b) => (a.createdAt?.seconds||0) - (b.createdAt?.seconds||0));
                state.paketList = pArr;
                
                if(pArr.length === 0) container.innerHTML = '<div class="col-span-full p-12 text-center text-gray-400 border border-dashed rounded-3xl">Belum ada paket layanan.</div>';
                
                pArr.forEach(p => {
                    container.innerHTML += `
                        <div class="bg-white rounded-3xl border shadow-sm overflow-hidden flex flex-col">
                            <img src="${parseImageUrl(p.imageUrl) || 'https://via.placeholder.com/400x200'}" alt="${p.name}" class="w-full h-48 object-cover" onerror="this.src='https://via.placeholder.com/400x200?text=Gambar+Gagal+Dimuat'">
                            <div class="p-5 flex-1 flex flex-col">
                                <h3 class="font-bold text-lg text-gray-800">${p.name}</h3>
                                <p class="text-xs text-gray-500 mt-1 line-clamp-2">${p.description}</p>
                                <div class="mt-4 mt-auto pt-4 border-t border-gray-100 flex justify-between items-center">
                                    <span class="font-black text-green-600">Rp ${formatRupiah(p.price)}</span>
                                    <div class="flex space-x-2">
                                        <button onclick="window.editPaket('${p.id}')" class="text-amber-500 bg-amber-50 p-2 rounded-lg hover:bg-amber-100"><i data-lucide="pencil" class="w-4 h-4"></i></button>
                                        <button onclick="window.hapusPaket('${p.id}')" class="text-red-400 bg-red-50 p-2 rounded-lg hover:bg-red-100"><i data-lucide="trash-2" class="w-4 h-4"></i></button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    `;
                });
                lucide.createIcons();
            });

            // PROMO BANNER B2C
            onSnapshot(paths.promos, (snap) => {
                const container = document.getElementById('promo-list-container');
                if(!container) return; container.innerHTML = '';
                let proArr = []; snap.forEach(docSnap => proArr.push({ id: docSnap.id, ...docSnap.data() }));
                proArr.sort((a,b) => (a.order||0) - (b.order||0));
                state.promoList = proArr;
                
                if(proArr.length === 0) container.innerHTML = '<div class="col-span-full p-12 text-center text-gray-400 border border-dashed rounded-3xl">Belum ada banner promo. Klik "Tambah Banner" untuk menambahkan.</div>';
                
                proArr.forEach((p, idx) => {
                    const parsedImg = parseImageUrl(p.imageUrl) || '';
                    container.innerHTML += `
                        <div class="bg-white rounded-3xl border shadow-sm overflow-hidden flex flex-col">
                            <div class="relative">
                                ${parsedImg ? `<img src="${parsedImg}" alt="${p.title||'Banner'}" class="w-full h-48 object-cover" onerror="this.style.display='none'">` : `<div class="w-full h-48 bg-gradient-to-br from-pink-100 to-purple-100 flex items-center justify-center"><i data-lucide="image" class="w-16 h-16 text-pink-300"></i></div>`}
                                <div class="absolute top-3 right-3 bg-black/50 text-white text-xs font-black px-2 py-1 rounded-full">Urutan #${idx+1}</div>
                            </div>
                            <div class="p-5 flex-1 flex flex-col">
                                <h3 class="font-bold text-lg text-gray-800">${p.title || '(Tanpa Judul)'}</h3>
                                <div class="mt-4 pt-4 border-t border-gray-100 flex justify-end items-center space-x-2">
                                    <button onclick="window.editPromo('${p.id}')" class="text-amber-500 bg-amber-50 p-2 rounded-lg hover:bg-amber-100"><i data-lucide="pencil" class="w-4 h-4"></i></button>
                                    <button onclick="window.hapusPromo('${p.id}')" class="text-red-400 bg-red-50 p-2 rounded-lg hover:bg-red-100"><i data-lucide="trash-2" class="w-4 h-4"></i></button>
                                </div>
                            </div>
                        </div>
                    `;
                });
                lucide.createIcons();
            });

            // TESTIMONI IG API
            window.loadTestimoniAPI = async () => {
                const container = document.getElementById('testimoni-list-container');
                if(!container) return; 
                container.innerHTML = '<div class="col-span-full p-12 text-center flex flex-col items-center justify-center border border-dashed rounded-3xl"><div class="animate-spin rounded-full h-8 w-8 border-b-2 border-pink-600 mb-4"></div><p class="text-gray-400 font-medium">Memuat Testimoni...</p></div>';
                try {
                    const res = await fetch('/api/testimonials');
                    const data = await res.json();
                    container.innerHTML = '';
                    
                    let aArr = data;
                    aArr.sort((a,b) => new Date(b.created_at||0) - new Date(a.created_at||0));
                    state.testimoniList = aArr;
                    
                    if(aArr.length === 0) container.innerHTML = '<div class="col-span-full p-12 text-center flex flex-col items-center border border-dashed rounded-3xl"><div class="w-16 h-16 bg-gray-50 rounded-full flex items-center justify-center mb-4"><i data-lucide="instagram" class="w-8 h-8 text-gray-300"></i></div><p class="text-gray-400 font-bold">Belum ada testimoni.</p><p class="text-xs text-gray-400 mt-1">Tambahkan testimoni pertama Anda dari tombol di atas.</p></div>';
                    
                    aArr.forEach(a => {
                        let parsedThumb = parseImageUrl(a.thumbnail_url);
                        let thumbHtml = parsedThumb ? `<img src="${parsedThumb}" alt="Thumbnail" class="w-full h-40 object-cover border-b" onerror="this.src='https://via.placeholder.com/400x200?text=Gambar+Gagal+Dimuat'">` : `<div class="w-full h-40 bg-pink-50 flex items-center justify-center border-b"><i data-lucide="instagram" class="w-12 h-12 text-pink-200"></i></div>`;
                        container.innerHTML += `
                            <div class="bg-white rounded-3xl border shadow-sm overflow-hidden flex flex-col">
                                ${thumbHtml}
                                <div class="p-5 flex-1 flex flex-col">
                                    <h3 class="font-bold text-lg text-gray-800 line-clamp-2 mb-2">${a.title || 'Testimoni Instagram'}</h3>
                                    <a href="${a.ig_url}" target="_blank" class="text-pink-600 text-sm font-bold truncate hover:underline mb-4"><i data-lucide="instagram" class="inline w-4 h-4 mr-1"></i> Buka Postingan IG</a>
                                    <div class="mt-auto pt-4 border-t border-gray-100 flex justify-end items-center space-x-2">
                                        <button onclick="window.editTestimoni('${a.id}')" class="text-amber-500 bg-amber-50 p-2 rounded-lg hover:bg-amber-100"><i data-lucide="pencil" class="w-4 h-4"></i></button>
                                        <button onclick="window.hapusTestimoni('${a.id}')" class="text-red-400 bg-red-50 p-2 rounded-lg hover:bg-red-100"><i data-lucide="trash-2" class="w-4 h-4"></i></button>
                                    </div>
                                </div>
                            </div>
                        `;
                    });
                    lucide.createIcons();
                } catch(e) { 
                    container.innerHTML = '<div class="col-span-full p-12 text-center text-red-400 border border-red-100 bg-red-50 rounded-3xl font-bold">Gagal memuat testimoni. Silakan coba lagi nanti.</div>';
                    console.error("Gagal load testimoni MySQL", e); 
                }
            };
            window.loadTestimoniAPI();

            // Polling MySQL APIs for real-time updates
            setInterval(() => {
                if (document.getElementById('main-content') && !document.getElementById('main-content').classList.contains('hidden')) {
                    window.loadProyekAPI();
                }
                if (document.getElementById('stok-content') && !document.getElementById('stok-content').classList.contains('hidden')) {
                    window.loadStokAPI();
                }
                if (document.getElementById('katalog-content') && !document.getElementById('katalog-content').classList.contains('hidden')) {
                    window.loadKatalogAPI();
                }
                if (document.getElementById('artikel-content') && !document.getElementById('artikel-content').classList.contains('hidden')) {
                    window.loadTestimoniAPI();
                }
            }, 5000);
        }

        let myChart = null;
        function renderChart(data) {
            const container = document.getElementById('chart-container'); 
            if (!container) return;
            
            // if canvas doesn't exist, create it
            let canvas = document.getElementById('monthly-trend-chart');
            if (!canvas) {
                container.innerHTML = '<canvas id="monthly-trend-chart" class="w-full h-64"></canvas>';
                canvas = document.getElementById('monthly-trend-chart');
            }

            const ctx = canvas.getContext('2d');
            
            const labels = Object.keys(data);
            const values = Object.values(data);

            if (myChart) {
                myChart.data.labels = labels;
                myChart.data.datasets[0].data = values;
                myChart.update();
            } else {
                myChart = new Chart(ctx, {
                    type: 'bar',
                    data: {
                        labels: labels,
                        datasets: [{
                            label: 'Jumlah Proyek',
                            data: values,
                            backgroundColor: 'rgba(16, 185, 129, 0.2)', // Emerald 500 with opacity
                            borderColor: 'rgba(16, 185, 129, 1)',
                            borderWidth: 2,
                            borderRadius: 6,
                            hoverBackgroundColor: 'rgba(16, 185, 129, 0.4)'
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        scales: {
                            y: {
                                beginAtZero: true,
                                ticks: { stepSize: 1, color: '#9CA3AF' },
                                grid: { color: '#F3F4F6', borderDash: [5, 5] }
                            },
                            x: {
                                ticks: { color: '#6B7280', font: { weight: 'bold' } },
                                grid: { display: false }
                            }
                        },
                        plugins: {
                            legend: { display: false },
                            tooltip: {
                                backgroundColor: '#1F2937',
                                titleFont: { size: 13, family: 'Inter, sans-serif' },
                                bodyFont: { size: 14, weight: 'bold', family: 'Inter, sans-serif' },
                                padding: 12,
                                cornerRadius: 8,
                                displayColors: false
                            }
                        }
                    }
                });
            }
        }

        // --- MANAJEMEN DATABASE MASTER ---
        document.getElementById('db-selector').addEventListener('change', (e) => {
            if(e.target.value === 'klien') {
                document.getElementById('view-db-klien').classList.remove('hidden');
                document.getElementById('view-db-pekerja').classList.add('hidden');
            } else {
                document.getElementById('view-db-klien').classList.add('hidden');
                document.getElementById('view-db-pekerja').classList.remove('hidden');
            }
        });

        document.getElementById('btn-tambah-db').onclick = () => {
            if(document.getElementById('db-selector').value === 'klien') {
                document.getElementById('modal-klien').classList.remove('hidden');
            } else {
                document.getElementById('modal-pekerja').classList.remove('hidden');
            }
        };

        // Klien
        let editingKlienId = null;
        document.getElementById('btn-batal-klien').onclick = () => { document.getElementById('modal-klien').classList.add('hidden'); editingKlienId = null; };
        document.getElementById('btn-simpan-klien').onclick = async () => {
            const n = document.getElementById('in-klien-nama').value.trim(); const w = document.getElementById('in-klien-wa').value.trim(); const a = document.getElementById('in-klien-alamat').value.trim(); const e = document.getElementById('in-klien-email') ? document.getElementById('in-klien-email').value.trim() : '';
            if(!n || !w) return alert("Nama dan WhatsApp wajib diisi!");
            const btn = document.getElementById('btn-simpan-klien'); btn.innerText = "Menyimpan...";
            if (editingKlienId) {
                await updateDoc(doc(db, 'artifacts', appId, 'public', 'data', 'klien', editingKlienId), { nama: n, wa: w, alamat: a, email: e });
                editingKlienId = null;
            } else {
                await addDoc(collection(db, 'artifacts', appId, 'public', 'data', 'klien'), { nama: n, wa: w, alamat: a, email: e, createdAt: new Date() });
            }
            btn.innerText = "Simpan Data";
            document.getElementById('modal-klien').classList.add('hidden');
        };
        window.editKlien = (id) => {
            const k = state.klienList.find(x => x.id === id);
            if(!k) return;
            editingKlienId = id;
            document.getElementById('in-klien-nama').value = k.nama || '';
            document.getElementById('in-klien-wa').value = k.wa || '';
            document.getElementById('in-klien-alamat').value = k.alamat || '';
            if(document.getElementById('in-klien-email')) document.getElementById('in-klien-email').value = k.email || '';
            document.getElementById('modal-klien').classList.remove('hidden');
        };
        window.hapusKlien = id => confirm("Hapus klien dari database?") && deleteDoc(doc(db, 'artifacts', appId, 'public', 'data', 'klien', id));

        // Pekerja
        let editingPekerjaId = null;
        document.getElementById('btn-batal-pekerja').onclick = () => { document.getElementById('modal-pekerja').classList.add('hidden'); editingPekerjaId = null; };
        document.getElementById('btn-simpan-pekerja').onclick = async () => {
            const n = document.getElementById('in-pekerja-nama').value.trim();
            const email = document.getElementById('in-pekerja-email') ? document.getElementById('in-pekerja-email').value.trim() : '';
            const pass = document.getElementById('in-pekerja-password') ? document.getElementById('in-pekerja-password').value.trim() : '';
            const p = document.getElementById('in-pekerja-posisi').value.trim();
            const hp = document.getElementById('in-pekerja-hp').value.trim();
            
            if(!n || !hp || !email || !pass) return alert("Nama, Email, Password, dan No. HP wajib diisi!");
            
            const btn = document.getElementById('btn-simpan-pekerja'); btn.innerText = "Menyimpan...";
            
            try {
                // Save to MySQL for Login
                const mysqlRes = await fetch('/api/auth/register_worker', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/json'},
                    body: JSON.stringify({ name: n, email: email, password: pass, phone: hp })
                });
                
                if (!mysqlRes.ok) {
                    const errData = await mysqlRes.json();
                    alert("Gagal register di MySQL: " + (errData.messages?.error || "Cek console"));
                    console.error(errData);
                    btn.innerText = "Simpan Data";
                    return;
                }

                // Save to Firebase for Dashboard View
                if (editingPekerjaId) {
                    await updateDoc(doc(db, 'artifacts', appId, 'public', 'data', 'pekerja', editingPekerjaId), { nama: n, posisi: p, hp: hp, email: email });
                    editingPekerjaId = null;
                } else {
                    await addDoc(collection(db, 'artifacts', appId, 'public', 'data', 'pekerja'), { nama: n, posisi: p, hp: hp, email: email, createdAt: new Date() });
                }
                
                btn.innerText = "Simpan Data";
                document.getElementById('modal-pekerja').classList.add('hidden');
            } catch (e) {
                console.error(e);
                alert("Terjadi kesalahan sistem.");
                btn.innerText = "Simpan Data";
            }
        };
        window.editPekerja = (id) => {
            const k = state.pekerjaList.find(x => x.id === id);
            if(!k) return;
            editingPekerjaId = id;
            document.getElementById('in-pekerja-nama').value = k.nama || '';
            document.getElementById('in-pekerja-posisi').value = k.posisi || '';
            document.getElementById('in-pekerja-hp').value = k.hp || '';
            document.getElementById('modal-pekerja').classList.remove('hidden');
        };
        window.hapusPekerja = id => confirm("Hapus pekerja ini dari database?") && deleteDoc(doc(db, 'artifacts', appId, 'public', 'data', 'pekerja', id));


        // --- MANAJEMEN JADWAL ---
        document.getElementById('btn-tambah-jadwal').onclick = () => document.getElementById('modal-jadwal').classList.remove('hidden');
        document.getElementById('btn-batal-jadwal').onclick = () => document.getElementById('modal-jadwal').classList.add('hidden');
        document.getElementById('btn-simpan-jadwal').onclick = async () => {
            const tanggal = document.getElementById('in-jadwal-tanggal').value;
            const proyek_id = document.getElementById('in-jadwal-proyek').value;
            const tugas = document.getElementById('in-jadwal-tugas').value.trim();
            const tim = document.getElementById('in-jadwal-tim').value;

            if(!tanggal || !proyek_id || !tugas) return alert('Mohon lengkapi Tanggal, Proyek, dan Tugas!');

            const projObj = state.proyekList.find(p => p.id === proyek_id);

            await addDoc(collection(db, 'artifacts', appId, 'public', 'data', 'jadwal'), {
                tanggal: tanggal,
                proyek_id: proyek_id,
                nama_proyek: projObj ? projObj.nama_klien : 'Umum',
                tugas: tugas,
                tim: tim,
                status: 'Belum Mulai',
                createdAt: new Date()
            });

            document.getElementById('modal-jadwal').classList.add('hidden');
            document.getElementById('in-jadwal-tugas').value = '';
        };

        window.hapusJadwal = id => confirm("Hapus jadwal ini?") && deleteDoc(doc(db, 'artifacts', appId, 'public', 'data', 'jadwal', id));
        window.ubahStatusJadwal = async (id, statusBaru) => { try { await updateDoc(doc(db, 'artifacts', appId, 'public', 'data', 'jadwal', id), { status: statusBaru }); } catch (e) {} };


        // --- MANAJEMEN Laporan ---
        window.renderLaporanMaterials = () => {
            const container = document.getElementById('bhp-list-container'); container.innerHTML = '';
            currentBhpForm.forEach((item, idx) => {
                let opts = '<option value="">-- Cari Gudang --</option>';
                state.stok.forEach(s => opts += `<option value="${s.id}" ${s.id === item.stok_id ? 'selected' : ''}>${s.nama} (Sisa: ${s.jumlah})</option>`);
                container.innerHTML += `<div class="flex space-x-2 mb-2"><select onchange="window.updateLapMat(${idx}, 'stok_id', this.value)" class="flex-1 border rounded-xl p-2 text-xs outline-none bg-white font-bold">${opts}</select><input type="number" onchange="window.updateLapMat(${idx}, 'qty', this.value)" value="${item.qty}" class="w-16 border rounded-xl p-2 text-xs outline-none text-center bg-white font-bold" min="1"><button onclick="window.hapusLapMat(${idx})" class="text-red-400 hover:text-red-600 bg-white p-2 rounded-xl border"><i data-lucide="trash-2" class="w-4 h-4"></i></button></div>`;
            });
            lucide.createIcons();
        };

        const resetModalLaporan = () => {
            editingLaporanId = null;
            currentBhpForm = []; window.renderLaporanMaterials();
            const modal = document.getElementById('modal-laporan');
            modal.querySelector('h2').innerHTML = '<i data-lucide="clipboard-check" class="mr-2 text-blue-600"></i> Form Laporan Lapangan';
            document.getElementById('in-laporan-proyek').value = '';
            document.getElementById('in-laporan-progress').value = '';
            document.getElementById('in-laporan-pekerja').value = '';
            document.getElementById('in-laporan-catatan').value = '';
            document.getElementById('in-laporan-foto').value = '';
            const btn = document.getElementById('btn-simpan-laporan');
            btn.textContent = 'Kirim Approval';
            btn.className = btn.className.replace('bg-amber-500 hover:bg-amber-600', 'bg-blue-600 hover:bg-blue-700');
            lucide.createIcons();
        };

        window.toggleProyekLaporan = (pid) => {
            const acc = document.getElementById(`acc-lap-${pid}`);
            if (acc.classList.contains('hidden')) { acc.classList.remove('hidden'); } else { acc.classList.add('hidden'); }
        };

        window.tambahLaporanUntuk = (pid) => {
            resetModalLaporan();
            document.getElementById('in-laporan-proyek').value = pid;
            document.getElementById('modal-laporan').classList.remove('hidden');
        };

        window.updateLapMat = (idx, key, val) => { currentBhpForm[idx][key] = key === 'qty' ? parseInt(val)||1 : val; };
        window.hapusLapMat = idx => { currentBhpForm.splice(idx, 1); window.renderLaporanMaterials(); };

        document.getElementById('btn-tambah-bhp').onclick = () => { currentBhpForm.push({ stok_id: '', qty: 1 }); window.renderLaporanMaterials(); };
        document.getElementById('btn-tambah-laporan').onclick = () => { resetModalLaporan(); document.getElementById('modal-laporan').classList.remove('hidden'); };
        document.getElementById('btn-batal-laporan').onclick = () => { editingLaporanId = null; document.getElementById('modal-laporan').classList.add('hidden'); };
        
        document.getElementById('btn-simpan-laporan').onclick = async () => {
            const pid = document.getElementById('in-laporan-proyek').value;
            const progress = document.getElementById('in-laporan-progress').value;
            const pekerja = document.getElementById('in-laporan-pekerja').value;
            const catatan = document.getElementById('in-laporan-catatan').value.trim();
            const fotoUrl = document.getElementById('in-laporan-foto').value.trim();
            const projObj = state.proyekList.find(p => p.id === pid);
            
            if(!progress || !pekerja) return alert("Progres dan Pekerja wajib diisi.");
            
            const validMats = currentBhpForm.filter(m => m.stok_id !== '' && m.qty > 0).map(m => {
                const s = state.stok.find(x => x.id === m.stok_id); return { stok_id: m.stok_id, nama: s ? s.nama : 'Unknown', qty: m.qty };
            });

            if(editingLaporanId) {
                await updateDoc(doc(db, 'artifacts', appId, 'public', 'data', 'laporan_harian', editingLaporanId), {
                    proyek_id: pid, nama_klien: projObj ? projObj.nama_klien : 'Umum',
                    progress: parseInt(progress), pekerja: parseInt(pekerja), catatan: catatan, foto: fotoUrl,
                    materials: validMats, editedAt: new Date(), editedBy: auth.currentUser.email
                });
                editingLaporanId = null;
            } else {
                await addDoc(collection(db, 'artifacts', appId, 'public', 'data', 'laporan_harian'), { 
                    proyek_id: pid, nama_klien: projObj ? projObj.nama_klien : 'Umum', 
                    progress: parseInt(progress), pekerja: parseInt(pekerja), catatan: catatan, foto: fotoUrl,
                    materials: validMats, status: 'Pending', tanggal: new Date(), user: auth.currentUser.email 
                });
            }
            document.getElementById('modal-laporan').classList.add('hidden');
        };

        window.setujuiLaporan = async (lapId) => {
            if(!confirm("Setujui laporan ini? Stok gudang akan otomatis dipotong sesuai data BHP.")) return;
            const lapRef = doc(db, 'artifacts', appId, 'public', 'data', 'laporan_harian', lapId);
            const snap = await getDoc(lapRef);
            if(!snap.exists()) return;
            const lapData = snap.data();

            if(lapData.materials && lapData.materials.length > 0) {
                for(let m of lapData.materials) {
                    const sRef = doc(db, 'artifacts', appId, 'public', 'data', 'stok', m.stok_id);
                    const sSnap = await getDoc(sRef);
                    if(sSnap.exists()) {
                        const curQty = sSnap.data().jumlah || 0;
                        await updateDoc(sRef, { jumlah: curQty - m.qty });
                    }
                }
            }
            await updateDoc(lapRef, { status: 'Disetujui' });

            // Sync progress to MySQL so Flutter customer app shows accurate progress
            if(lapData.proyek_id && lapData.progress) {
                try {
                    await fetch(`/api/projects/${lapData.proyek_id}`, {
                        method: 'PUT',
                        headers: {'Content-Type': 'application/json'},
                        body: JSON.stringify({ progress: parseInt(lapData.progress) })
                    });
                } catch(e) { console.warn('Gagal sinkronisasi progress ke MySQL', e); }
            }

            alert("Laporan disetujui, stok telah dipotong otomatis dan progres proyek diperbarui.");
        };

        window.hapusLaporan = id => confirm("Hapus laporan ini secara permanen?") && deleteDoc(doc(db, 'artifacts', appId, 'public', 'data', 'laporan_harian', id));

        window.hapusSeluruhLaporan = async (proyekId) => {
            const warning = "⚠️ PERINGATAN KERAS ⚠️\n\nAnda akan menghapus SELURUH laporan harian untuk proyek ini. Tindakan ini:\n1. Menghapus semua catatan progres.\n2. Menghapus semua foto bukti pengerjaan.\n3. TIDAK DAPAT DIBATALKAN atau dikembalikan.\n\nKetik 'KONFIRMASI HAPUS' untuk melanjutkan:";
            const confirmText = prompt(warning);
            
            if (confirmText === 'KONFIRMASI HAPUS') {
                const reportsToDelete = state.laporanList.filter(l => l.proyek_id == proyekId);
                if(reportsToDelete.length === 0) return alert("Tidak ada laporan untuk dihapus.");
                
                try {
                    for (let lap of reportsToDelete) {
                        await deleteDoc(doc(db, 'artifacts', appId, 'public', 'data', 'laporan_harian', lap.id));
                    }
                    alert("Seluruh laporan untuk proyek ini telah dihapus secara permanen.");
                } catch (e) {
                    alert("Terjadi kesalahan saat menghapus: " + e.message);
                }
            } else if (confirmText !== null) {
                alert("Konfirmasi gagal. Teks yang dimasukkan tidak cocok.");
            }
        };

        window.editLaporan = (lapId) => {
            const lap = state.laporanList.find(l => l.id === lapId);
            if(!lap) return;
            editingLaporanId = lapId;
            document.getElementById('in-laporan-proyek').value = lap.proyek_id || '';
            document.getElementById('in-laporan-progress').value = lap.progress || '';
            document.getElementById('in-laporan-pekerja').value = lap.pekerja || '';
            document.getElementById('in-laporan-catatan').value = lap.catatan || '';
            document.getElementById('in-laporan-foto').value = lap.foto || '';

            currentBhpForm = (lap.materials || []).map(m => ({ stok_id: m.stok_id, qty: m.qty }));
            window.renderLaporanMaterials();

            const modal = document.getElementById('modal-laporan');
            modal.querySelector('h2').innerHTML = '<i data-lucide="pencil" class="mr-2 text-amber-500"></i> Edit Laporan Lapangan';
            document.getElementById('btn-simpan-laporan').textContent = 'Simpan Perubahan';
            document.getElementById('btn-simpan-laporan').className = document.getElementById('btn-simpan-laporan').className.replace('bg-blue-600 hover:bg-blue-700', 'bg-amber-500 hover:bg-amber-600');
            modal.classList.remove('hidden');
            lucide.createIcons();
        };

        window.renderRealisasiBhp = (proyekId) => {
            const container = document.getElementById('realisasi-list');
            if(!container) return;
            const lapApproved = state.laporanList.filter(l => l.proyek_id === proyekId && l.status === 'Disetujui');
            let usedBhp = {}; let totalPekerja = 0;

            lapApproved.forEach(lap => {
                totalPekerja += lap.pekerja || 0;
                if(lap.materials) {
                    lap.materials.forEach(m => {
                        if(usedBhp[m.nama]) usedBhp[m.nama] += m.qty;
                        else usedBhp[m.nama] = m.qty;
                    });
                }
            });

            container.innerHTML = `<li class="flex justify-between border-b border-blue-100 pb-1 mb-1"><span class="text-blue-800 font-black text-xs">Total Tenaga Harian</span><span class="text-blue-600">${totalPekerja} HK</span></li>`;
            
            if(Object.keys(usedBhp).length === 0) {
                container.innerHTML += `<li class="text-[10px] text-gray-400 italic">Belum ada BHP ditarik.</li>`;
            } else {
                Object.keys(usedBhp).forEach(key => {
                    const rabItem = state.activeRabItems.find(r => r.nama.toLowerCase().includes(key.toLowerCase()));
                    let warning = '';
                    if(rabItem && usedBhp[key] > rabItem.qty) {
                        warning = `<span class="text-[9px] bg-red-100 text-red-600 px-1 py-0.5 rounded ml-1 font-black">OVER RAB! (Batas: ${rabItem.qty})</span>`;
                    }
                    container.innerHTML += `<li class="flex justify-between items-center text-xs border-b border-blue-100/50 py-1"><span class="text-gray-600">${key} ${warning}</span><span class="font-black text-blue-700">${usedBhp[key]}</span></li>`;
                });
            }
        };

        // PROYEK MYSQL API
        document.getElementById('btn-tambah').onclick = () => document.getElementById('modal-form').classList.remove('hidden');
        document.getElementById('btn-batal-modal').onclick = () => document.getElementById('modal-form').classList.add('hidden');
        document.getElementById('btn-simpan-modal').onclick = async () => {
            const klienId = document.getElementById('input-klien-id').value; const alamatSpec = document.getElementById('input-alamat-proyek').value.trim();
            if(!klienId) return alert("Pilih klien terlebih dahulu.");
            const klienObj = state.klienList.find(k => k.id === klienId);
            await fetch('/api/projects', {method: 'POST', headers:{'Content-Type':'application/json'}, body: JSON.stringify({
                nama_klien: klienObj.nama,
                telepon: klienObj.wa,
                klien_email: (klienObj.email || '').toLowerCase(),
                alamat: alamatSpec !== "" ? alamatSpec : klienObj.alamat,
                status: 'Menunggu Survei',
                progress: 0,
                survey: {p:0, l:0},
                rabItems: []
            })});
            document.getElementById('modal-form').classList.add('hidden');
            window.loadProyekAPI();
        };

        window.hapusProyek = async id => { if(confirm("Hapus proyek ini secara permanen?")) { await fetch(`/api/projects/${id}`, {method: 'DELETE'}); window.loadProyekAPI(); } };
        window.arsipProyek = async (id, val = 1) => { 
            const msg = val == 1 ? "Arsipkan proyek ini? Proyek akan disembunyikan dari daftar aktif." : "Kembalikan proyek dari arsip?";
            if(confirm(msg)) { 
                try { 
                    await fetch(`/api/projects/${id}`, {
                        method: 'PUT', 
                        headers:{'Content-Type':'application/json'}, 
                        body: JSON.stringify({is_archived: val})
                    }); 
                    window.loadProyekAPI(); 
                } catch(e) {} 
            } 
        };
        window.ubahStatusProyek = async (id, statusBaru) => { try { await fetch(`/api/projects/${id}`, {method: 'PUT', headers:{'Content-Type':'application/json'}, body: JSON.stringify({status: statusBaru})}); window.loadProyekAPI(); } catch(e) {} };

        window.updateLuas = () => {
            const p = parseFloat(document.getElementById('survey-panjang').value) || 0;
            const l = parseFloat(document.getElementById('survey-lebar').value) || 0;
            const lu = document.getElementById('survey-luas');
            if(lu) lu.innerText = (p * l).toFixed(2);
        };

        window.bukaDetail = async id => {
            state.activeProjectId = id;
            try {
                const res = await fetch(`/api/projects/${id}`);
                const data = await res.json();
                state.activeProjectData = data;
                if(typeof data.rabItems === 'string') { try { data.rabItems = JSON.parse(data.rabItems); } catch(e) { data.rabItems = []; } }
                if(typeof data.survey === 'string') { try { data.survey = JSON.parse(data.survey); } catch(e) { data.survey = {p:0,l:0}; } }
                if(typeof data.timeline === 'string') { try { data.timeline = JSON.parse(data.timeline); } catch(e) { data.timeline = {}; } }
                
                state.activeRabItems = Array.isArray(data.rabItems) ? data.rabItems : [];
                document.getElementById('detail-nama').innerText = state.activeProjectData.nama_klien;
                document.getElementById('detail-wa').innerHTML = `<i data-lucide="phone" class="w-3 h-3 mr-1"></i> ${state.activeProjectData.telepon || 'Tidak ada kontak'}`;
                document.getElementById('detail-alamat').innerText = state.activeProjectData.alamat || '-';
                document.getElementById('survey-panjang').value = state.activeProjectData.survey?.p || 0;
                document.getElementById('survey-lebar').value = state.activeProjectData.survey?.l || 0;
                
                // Populate Timeline
                const t = state.activeProjectData.timeline || {};
                document.getElementById('timeline-survei').value = t.survei || '';
                document.getElementById('timeline-desain').value = t.desain || '';
                document.getElementById('timeline-lahan').value = t.lahan || '';
                document.getElementById('timeline-penanaman').value = t.penanaman || '';
                document.getElementById('timeline-serah-terima').value = t.serah_terima || '';

                window.updateLuas(); renderRabTable(); switchView('detail-content');
                window.renderRealisasiBhp(id); // Muat data pemakaian
            } catch (e) { console.error("Gagal load detail proyek MySQL", e); }
        };

        const renderRabTable = () => {
            const body = document.getElementById('rab-table-body'); body.innerHTML = ''; let total = 0;
            state.activeRabItems.forEach((item, idx) => {
                let sub = 0;
                let isPersen = (item.satuan && (item.satuan.toUpperCase() === 'PERSEN' || item.satuan === '%'));
                
                if (isPersen) {
                    sub = -Math.round(total * (item.qty || 0) / 100);
                } else {
                    sub = (item.qty || 0) * (item.harga || 0);
                }
                total += sub;

                let readonlyHarga = isPersen ? 'readonly title="Harga otomatis dihitung dari persentase"' : '';
                let hargaClass = isPersen ? 'text-gray-400 opacity-50 cursor-not-allowed' : 'text-gray-700';

                body.innerHTML += `<tr class="border-b border-gray-100">
                    <td class="py-3 pr-2"><input type="text" onchange="window.editRab(${idx},'nama',this.value)" value="${item.nama}" class="w-full bg-transparent font-bold outline-none border-b border-transparent focus:border-green-500 text-gray-700"></td>
                    <td class="w-16 px-1"><input type="number" onchange="window.editRab(${idx},'qty',this.value)" value="${item.qty}" class="w-full bg-gray-50 border border-gray-200 text-center outline-none rounded-lg py-1"></td>
                    <td class="w-16 px-1"><input type="text" onchange="window.editRab(${idx},'satuan',this.value)" value="${item.satuan}" class="w-full bg-gray-50 border border-gray-200 text-center outline-none rounded-lg py-1 text-[10px] uppercase font-bold text-gray-500"></td>
                    <td class="w-32 px-1"><div class="flex items-center bg-gray-50 border border-gray-200 rounded-lg px-2 py-1"><span class="text-[10px] text-gray-400 font-bold mr-1">Rp</span><input type="number" ${readonlyHarga} onchange="window.editRab(${idx},'harga',this.value)" value="${isPersen ? 0 : item.harga}" class="w-full bg-transparent text-right outline-none font-black ${hargaClass}"></div></td>
                    <td class="text-right font-black ${sub < 0 ? 'text-red-500' : 'text-gray-800'}">${sub < 0 ? '-' : ''}Rp ${formatRupiah(Math.abs(sub))}</td>
                    <td class="text-right pl-2"><button onclick="window.hapusRab(${idx})" class="text-red-200 hover:text-red-500 transition"><i data-lucide="x-circle" class="w-4 h-4"></i></button></td>
                </tr>`;
            });
            document.getElementById('rab-grand-total').innerText = 'Rp ' + formatRupiah(total);
            lucide.createIcons();
            if(state.activeProjectId) window.renderRealisasiBhp(state.activeProjectId); // Refresh peringatan jika qty RAB diubah
        };

        window.editRab = (idx, key, val) => { state.activeRabItems[idx][key] = (key === 'qty' || key === 'harga') ? parseFloat(val) : val; renderRabTable(); };
        window.hapusRab = idx => { state.activeRabItems.splice(idx, 1); renderRabTable(); };
        document.getElementById('btn-tambah-rab').onclick = () => { state.activeRabItems.push({nama: 'Item Baru', qty: 1, satuan: 'm2', harga: 0}); renderRabTable(); };
        document.getElementById('select-katalog').onchange = e => { const v = e.target.value; if(v !== "") { const m = state.katalog[v]; state.activeRabItems.push({nama: m.nama, qty: 1, satuan: m.satuan, harga: m.harga}); renderRabTable(); e.target.value = ""; } };

        document.getElementById('btn-simpan-detail').onclick = async () => {
            const btn = document.getElementById('btn-simpan-detail'); btn.innerText = "Simpan...";
            const p = parseFloat(document.getElementById('survey-panjang').value) || 0;
            const l = parseFloat(document.getElementById('survey-lebar').value) || 0;
            
            const timeline = {
                survei: document.getElementById('timeline-survei').value,
                desain: document.getElementById('timeline-desain').value,
                lahan: document.getElementById('timeline-lahan').value,
                penanaman: document.getElementById('timeline-penanaman').value,
                serah_terima: document.getElementById('timeline-serah-terima').value
            };

            await fetch(`/api/projects/${state.activeProjectId}`, {
                method: 'PUT', 
                headers:{'Content-Type':'application/json'}, 
                body: JSON.stringify({ survey: {p, l}, rabItems: state.activeRabItems, timeline: timeline })
            });
            btn.innerHTML = '<i data-lucide="save" class="w-4 h-4 mr-2"></i> Simpan Proyek'; alert("Tersimpan!");
            window.loadProyekAPI();
        };

        document.getElementById('btn-kembali').onclick = () => switchView('main-content');
        
        // STOK & KATALOG MYSQL API
        window.adjustStok = async (id, val) => { const curStok = state.stok.find(s => s.id == id); if(curStok) { const cur = parseInt(curStok.jumlah) || 0; if(cur + val < 0) return alert("Stok habis!"); await fetch(`/api/inventory/${id}`, {method: 'PUT', headers:{'Content-Type':'application/json'}, body: JSON.stringify({jumlah: cur + val})}); window.loadStokAPI(); } };
        document.getElementById('btn-simpan-stok').onclick = async () => { const n = document.getElementById('in-stok-nama').value.trim(); const j = parseInt(document.getElementById('in-stok-jumlah').value) || 0; const k = document.getElementById('in-stok-kondisi').value; const l = document.getElementById('in-stok-lokasi').value.trim(); if(!n) return; await fetch('/api/inventory', {method: 'POST', headers:{'Content-Type':'application/json'}, body: JSON.stringify({nama: n, jumlah: j, kondisi: k, lokasi: l})}); document.getElementById('modal-stok').classList.add('hidden'); window.loadStokAPI(); };
        document.getElementById('btn-tambah-stok').onclick = () => document.getElementById('modal-stok').classList.remove('hidden');
        document.getElementById('btn-batal-stok').onclick = () => document.getElementById('modal-stok').classList.add('hidden');
        window.hapusStok = async id => { if(confirm("Hapus barang?")) { await fetch(`/api/inventory/${id}`, {method: 'DELETE'}); window.loadStokAPI(); } };
        window.hapusKatalog = async id => { if(confirm("Hapus item master?")) { await fetch(`/api/catalogs/${id}`, {method: 'DELETE'}); window.loadKatalogAPI(); } };
        document.getElementById('btn-tambah-katalog').onclick = async () => { const n = prompt("Nama Material:"); const s = prompt("Satuan:", "m2"); const h = prompt("Harga:", "0"); if(n && h) { await fetch('/api/catalogs', {method: 'POST', headers:{'Content-Type':'application/json'}, body: JSON.stringify({nama: n, satuan: s, harga: parseFloat(h)})}); window.loadKatalogAPI(); } };

        // PAKET LAYANAN B2C LOGIC
        window.renderPaketItems = () => {
            const container = document.getElementById('item-paket-container'); 
            if(!container) return;
            container.innerHTML = '';
            currentPaketItems.forEach((item, idx) => {
                container.innerHTML += `
                    <div class="flex space-x-2 items-center bg-gray-50 p-2 rounded-xl border border-gray-100">
                        <input type="text" placeholder="Nama Item" onchange="window.updatePaketItem(${idx}, 'nama', this.value)" value="${item.nama}" class="flex-1 bg-transparent text-[10px] font-bold outline-none border-b border-transparent focus:border-green-500">
                        <input type="number" placeholder="Qty" onchange="window.updatePaketItem(${idx}, 'qty', this.value)" value="${item.qty}" class="w-12 bg-white border rounded-lg p-1 text-[10px] text-center outline-none">
                        <input type="text" placeholder="Satuan" onchange="window.updatePaketItem(${idx}, 'satuan', this.value)" value="${item.satuan}" class="w-12 bg-white border rounded-lg p-1 text-[10px] text-center outline-none uppercase">
                        <input type="number" placeholder="Harga" onchange="window.updatePaketItem(${idx}, 'harga', this.value)" value="${item.harga}" class="w-20 bg-white border rounded-lg p-1 text-[10px] text-right outline-none">
                        <button onclick="window.hapusPaketItem(${idx})" class="text-red-400 hover:text-red-600"><i data-lucide="x-circle" class="w-4 h-4"></i></button>
                    </div>
                `;
            });
            lucide.createIcons();
        };

        window.updatePaketItem = (idx, key, val) => {
            currentPaketItems[idx][key] = (key === 'qty' || key === 'harga') ? parseFloat(val) || 0 : val;
        };

        window.hapusPaketItem = (idx) => {
            currentPaketItems.splice(idx, 1);
            window.renderPaketItems();
        };

        document.getElementById('btn-tambah-item-paket').onclick = () => {
            currentPaketItems.push({ nama: 'Item Baru', qty: 1, satuan: 'm2', harga: 0 });
            window.renderPaketItems();
        };

        document.getElementById('btn-tambah-paket').onclick = () => {
            document.getElementById('in-paket-id').value = '';
            document.getElementById('in-paket-nama').value = '';
            document.getElementById('in-paket-harga').value = '';
            document.getElementById('in-paket-gambar').value = '';
            document.getElementById('in-paket-deskripsi').value = '';
            currentPaketItems = [];
            window.renderPaketItems();
            document.getElementById('modal-paket').classList.remove('hidden');
        };

        document.getElementById('btn-batal-paket').onclick = () => document.getElementById('modal-paket').classList.add('hidden');

        document.getElementById('btn-simpan-paket').onclick = async () => {
            const id = document.getElementById('in-paket-id').value;
            const nama = document.getElementById('in-paket-nama').value.trim();
            const harga = parseFloat(document.getElementById('in-paket-harga').value) || 0;
            const gambar = parseImageUrl(document.getElementById('in-paket-gambar').value.trim());
            const desc = document.getElementById('in-paket-deskripsi').value.trim();
            
            if(!nama || !harga) return alert('Nama dan Harga paket wajib diisi!');
            
            const btn = document.getElementById('btn-simpan-paket');
            btn.innerText = 'Menyimpan...'; btn.disabled = true;
            
            const data = { 
                name: nama, 
                price: harga, 
                imageUrl: gambar, 
                description: desc,
                includedItems: currentPaketItems
            };

            if(id) {
                await updateDoc(doc(db, 'artifacts', appId, 'public', 'data', 'paket_layanan', id), data);
            } else {
                await addDoc(collection(db, 'artifacts', appId, 'public', 'data', 'paket_layanan'), { ...data, createdAt: new Date() });
            }
            
            btn.innerText = 'Simpan Paket'; btn.disabled = false;
            document.getElementById('modal-paket').classList.add('hidden');
        };

        window.editPaket = (id) => {
            const p = state.paketList.find(x => x.id === id);
            if(!p) return;
            document.getElementById('in-paket-id').value = id;
            document.getElementById('in-paket-nama').value = p.name || '';
            document.getElementById('in-paket-harga').value = p.price || '';
            document.getElementById('in-paket-gambar').value = p.imageUrl || '';
            document.getElementById('in-paket-deskripsi').value = p.description || '';
            currentPaketItems = p.includedItems || [];
            window.renderPaketItems();
            document.getElementById('modal-paket').classList.remove('hidden');
        };

        window.hapusPaket = id => confirm("Hapus paket layanan ini?") && deleteDoc(doc(db, 'artifacts', appId, 'public', 'data', 'paket_layanan', id));

        // PROMO BANNER B2C LOGIC
        document.getElementById('btn-tambah-promo').onclick = () => {
            document.getElementById('in-promo-id').value = '';
            document.getElementById('in-promo-judul').value = '';
            document.getElementById('in-promo-gambar').value = '';
            document.getElementById('in-promo-deskripsi').value = '';
            document.getElementById('in-promo-content').value = '';
            document.getElementById('in-promo-cta-label').value = '';
            document.getElementById('in-promo-cta-url').value = '';
            document.getElementById('in-promo-order').value = '0';
            document.getElementById('modal-promo').classList.remove('hidden');
        };
        document.getElementById('btn-batal-promo').onclick = () => document.getElementById('modal-promo').classList.add('hidden');
        document.getElementById('btn-simpan-promo').onclick = async () => {
            const id = document.getElementById('in-promo-id').value;
            const judul = document.getElementById('in-promo-judul').value.trim();
            const gambar = parseImageUrl(document.getElementById('in-promo-gambar').value.trim());
            const deskripsi = document.getElementById('in-promo-deskripsi').value.trim();
            const content = document.getElementById('in-promo-content').value.trim();
            const ctaLabel = document.getElementById('in-promo-cta-label').value.trim();
            const ctaUrl = document.getElementById('in-promo-cta-url').value.trim();
            const order = parseInt(document.getElementById('in-promo-order').value) || 0;
            
            if(!gambar) return alert('URL Gambar Banner wajib diisi!');
            
            const btn = document.getElementById('btn-simpan-promo');
            btn.innerText = 'Menyimpan...'; btn.disabled = true;
            
            const promoData = { title: judul, imageUrl: gambar, description: deskripsi, content: content, ctaLabel: ctaLabel, ctaUrl: ctaUrl, order: order };
            if(id) {
                await updateDoc(doc(db, 'artifacts', appId, 'public', 'data', 'promos', id), promoData);
            } else {
                await addDoc(collection(db, 'artifacts', appId, 'public', 'data', 'promos'), { ...promoData, createdAt: new Date() });
            }
            
            btn.innerText = 'Simpan Banner'; btn.disabled = false;
            document.getElementById('modal-promo').classList.add('hidden');
        };
        window.editPromo = (id) => {
            const p = state.promoList.find(x => x.id === id);
            if(!p) return;
            document.getElementById('in-promo-id').value = id;
            document.getElementById('in-promo-judul').value = p.title || '';
            document.getElementById('in-promo-gambar').value = p.imageUrl || '';
            document.getElementById('in-promo-deskripsi').value = p.description || '';
            document.getElementById('in-promo-content').value = p.content || '';
            document.getElementById('in-promo-cta-label').value = p.ctaLabel || '';
            document.getElementById('in-promo-cta-url').value = p.ctaUrl || '';
            document.getElementById('in-promo-order').value = p.order || 0;
            document.getElementById('modal-promo').classList.remove('hidden');
        };
        window.hapusPromo = id => confirm("Hapus banner promo ini?") && deleteDoc(doc(db, 'artifacts', appId, 'public', 'data', 'promos', id));

        // TESTIMONI IG LOGIC
        document.getElementById('btn-tambah-testimoni').onclick = () => {
            document.getElementById('in-testimoni-id').value = '';
            document.getElementById('in-testimoni-judul').value = '';
            document.getElementById('in-testimoni-url').value = '';
            if(document.getElementById('in-testimoni-thumbnail')) document.getElementById('in-testimoni-thumbnail').value = '';
            document.getElementById('modal-testimoni').classList.remove('hidden');
        };
        document.getElementById('btn-batal-testimoni').onclick = () => document.getElementById('modal-testimoni').classList.add('hidden');
        document.getElementById('btn-simpan-testimoni').onclick = async () => {
            const id = document.getElementById('in-testimoni-id').value;
            const judul = document.getElementById('in-testimoni-judul').value.trim();
            const url = document.getElementById('in-testimoni-url').value.trim();
            const thumb = parseImageUrl(document.getElementById('in-testimoni-thumbnail') ? document.getElementById('in-testimoni-thumbnail').value.trim() : '');
            
            if(!url || !url.includes('instagram.com')) return alert('URL Instagram tidak valid!');
            
            const btn = document.getElementById('btn-simpan-testimoni');
            btn.innerText = 'Menyimpan...'; btn.disabled = true;
            
            if(id) {
                await fetch(`/api/testimonials/${id}`, {method: 'PUT', headers:{'Content-Type':'application/json'}, body: JSON.stringify({ title: judul, ig_url: url, thumbnail_url: thumb })});
            } else {
                await fetch('/api/testimonials', {method: 'POST', headers:{'Content-Type':'application/json'}, body: JSON.stringify({ title: judul, ig_url: url, thumbnail_url: thumb })});
            }
            
            btn.innerText = 'Simpan Testimoni'; btn.disabled = false;
            document.getElementById('modal-testimoni').classList.add('hidden');
            window.loadTestimoniAPI();
        };
        window.editTestimoni = (id) => {
            const a = state.testimoniList.find(x => x.id == id);
            if(!a) return;
            document.getElementById('in-testimoni-id').value = id;
            document.getElementById('in-testimoni-judul').value = a.title || '';
            document.getElementById('in-testimoni-url').value = a.ig_url || '';
            if(document.getElementById('in-testimoni-thumbnail')) document.getElementById('in-testimoni-thumbnail').value = a.thumbnail_url || '';
            document.getElementById('modal-testimoni').classList.remove('hidden');
        };
        window.hapusTestimoni = async id => { if(confirm("Hapus testimoni ini?")) { await fetch(`/api/testimonials/${id}`, {method: 'DELETE'}); window.loadTestimoniAPI(); } };



        // PRINT VIEW
        document.getElementById('btn-preview-print').onclick = () => {
            document.getElementById('print-nama').innerText = state.activeProjectData.nama_klien; document.getElementById('print-kontak').innerText = state.activeProjectData.telepon || '-'; document.getElementById('print-alamat').innerText = state.activeProjectData.alamat || '-'; document.getElementById('print-tanggal').innerText = "Jakarta, " + new Date().toLocaleDateString('id-ID', {dateStyle:'long'});
            const p = parseFloat(document.getElementById('survey-panjang').value) || 0; const l = parseFloat(document.getElementById('survey-lebar').value) || 0; document.getElementById('print-luas').innerText = p * l;
            const b = document.getElementById('print-table-body'); b.innerHTML = ''; let t = 0;
            state.activeRabItems.forEach((it, i) => { 
                let sub = 0;
                let isPersen = (it.satuan && (it.satuan.toUpperCase() === 'PERSEN' || it.satuan === '%'));
                if (isPersen) {
                    sub = -Math.round(t * (it.qty || 0) / 100);
                } else {
                    sub = (it.qty || 0) * (it.harga || 0); 
                }
                t += sub; 
                b.innerHTML += `<tr class="border-b"><td class="p-3 text-center text-xs">${i+1}</td><td class="p-3 font-bold text-xs">${it.nama}</td><td class="p-3 text-center text-xs">${it.qty} ${it.satuan}</td><td class="p-3 text-right text-xs">Rp ${isPersen ? 0 : formatRupiah(it.harga)}</td><td class="p-3 text-right font-black text-xs ${sub < 0 ? 'text-red-500' : ''}">${sub < 0 ? '-' : ''}Rp ${formatRupiah(Math.abs(sub))}</td></tr>`; 
            });
            document.getElementById('print-grand-total').innerText = 'Rp ' + formatRupiah(t); switchView('print-content');
        };
        document.getElementById('btn-kembali-print').onclick = () => switchView('detail-content');

        // --- CHAT MANAGEMENT ---
        let activeChatCustomer = null;

        const updateChatBadge = async () => {
            try {
                const res = await fetch('/api/chat/unread-count');
                const data = await res.json();
                const badge = document.getElementById('chat-badge');
                if (badge) {
                    if (data.count > 0) {
                        badge.innerText = data.count;
                        badge.classList.remove('hidden');
                    } else {
                        badge.classList.add('hidden');
                    }
                }
            } catch (e) { console.error("Gagal update badge chat", e); }
        };

        const loadChatList = async () => {
            try {
                const res = await fetch('/api/chat');
                const messages = await res.json();
                const listContainer = document.getElementById('chat-list');
                if (!listContainer) return;

                // Group by customer name
                const groups = {};
                messages.forEach(m => {
                    const name = m.customer_name || 'Guest';
                    if (!groups[name]) groups[name] = { lastMessage: m, unread: 0 };
                    if (m.created_at > groups[name].lastMessage.created_at) groups[name].lastMessage = m;
                    if (m.is_read == 0 && m.sender_role == 'customer') groups[name].unread++;
                });

                listContainer.innerHTML = '';
                const keys = Object.keys(groups);
                if (keys.length === 0) {
                    listContainer.innerHTML = '<div class="p-8 text-center text-gray-400 italic text-sm">Belum ada percakapan</div>';
                    return;
                }

                keys.forEach(name => {
                    const g = groups[name];
                    const isActive = activeChatCustomer === name;
                    listContainer.innerHTML += `
                        <div onclick="window.selectChat('${name}')" class="p-4 border-b cursor-pointer transition ${isActive ? 'bg-green-50 border-r-4 border-green-600' : 'hover:bg-gray-50'}">
                            <div class="flex justify-between items-start mb-1">
                                <h4 class="font-bold text-sm text-gray-800">${name}</h4>
                                <span class="text-[10px] text-gray-400">${new Date(g.lastMessage.created_at).toLocaleTimeString('id-ID', {hour:'2-digit', minute:'2-digit'})}</span>
                            </div>
                            <div class="flex justify-between items-center">
                                <p class="text-xs text-gray-500 truncate w-4/5">${g.lastMessage.message}</p>
                                ${g.unread > 0 ? `<span class="bg-green-600 text-white text-[9px] font-black px-1.5 py-0.5 rounded-full">${g.unread}</span>` : ''}
                            </div>
                        </div>
                    `;
                });
            } catch (e) { console.error("Gagal load chat list", e); }
        };

        window.selectChat = async (name) => {
            activeChatCustomer = name;
            document.getElementById('chat-window-header').classList.remove('hidden');
            document.getElementById('chat-input-container').classList.remove('hidden');
            document.getElementById('active-chat-name').innerText = name;
            
            await loadMessages(name);
            loadChatList(); 
            updateChatBadge();
        };

        const loadMessages = async (name) => {
            try {
                const res = await fetch('/api/chat');
                const allMessages = await res.json();
                const messages = allMessages.filter(m => m.customer_name === name);
                const container = document.getElementById('chat-messages');
                
                container.innerHTML = '';
                messages.forEach(m => {
                    const isMe = m.sender_role === 'admin';
                    const isBot = m.sender_role === 'bot';
                    container.innerHTML += `
                        <div class="flex ${isMe ? 'justify-end' : 'justify-start'}">
                            <div class="max-w-[80%] p-3 rounded-2xl shadow-sm text-sm ${isMe ? 'bg-green-600 text-white' : (isBot ? 'bg-green-100 text-green-800 italic' : 'bg-white text-gray-800')}">
                                ${isBot ? '<span class="text-[9px] block font-black uppercase mb-1 opacity-50">SiramBot AI</span>' : ''}
                                <p>${m.message}</p>
                                <span class="text-[9px] block mt-1 opacity-50 text-right">${new Date(m.created_at).toLocaleTimeString('id-ID', {hour:'2-digit', minute:'2-digit'})}</span>
                            </div>
                        </div>
                    `;
                });
                container.scrollTop = container.scrollHeight;

                // Mark as read
                await fetch('/api/chat/mark-as-read', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                    body: `customer_name=${encodeURIComponent(name)}`
                });
            } catch (e) { console.error("Gagal load messages", e); }
        };

        document.getElementById('btn-send-chat').onclick = async () => {
            const input = document.getElementById('chat-input');
            const message = input.value.trim();
            if (!message || !activeChatCustomer) return;

            try {
                await fetch('/api/chat/send', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                    body: `customer_name=${encodeURIComponent(activeChatCustomer)}&message=${encodeURIComponent(message)}&sender_role=admin`
                });
                input.value = '';
                loadMessages(activeChatCustomer);
            } catch (e) { console.error("Gagal kirim chat", e); }
        };

        setInterval(() => {
            updateChatBadge();
            if (!document.getElementById('chat-content').classList.contains('hidden')) {
                loadChatList();
                if (activeChatCustomer) loadMessages(activeChatCustomer);
            }
        }, 5000);

        updateChatBadge();