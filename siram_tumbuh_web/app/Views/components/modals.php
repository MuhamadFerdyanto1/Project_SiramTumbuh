<!-- MODAL JADWAL -->
    <div id="modal-jadwal" class="fixed inset-0 bg-black/70 z-50 flex justify-center items-center hidden p-4">
        <div class="bg-white rounded-[2rem] w-full max-w-md p-8 shadow-2xl space-y-4">
            <h2 class="text-xl font-bold flex items-center text-gray-800"><i data-lucide="calendar-plus" class="mr-2 text-blue-600"></i> Buat Jadwal Baru</h2>
            <div>
                <label class="text-[10px] uppercase font-bold text-gray-400 ml-2">Tanggal Pelaksanaan</label>
                <input type="date" id="in-jadwal-tanggal" class="w-full border border-gray-200 bg-gray-50 rounded-2xl p-3 outline-none focus:ring-2 focus:ring-blue-500 font-medium">
            </div>
            <div>
                <label class="text-[10px] uppercase font-bold text-gray-400 ml-2">Pilih Proyek (Lokasi)</label>
                <select id="in-jadwal-proyek" class="w-full border border-gray-200 bg-gray-50 rounded-2xl p-3 outline-none focus:ring-2 focus:ring-blue-500 font-medium"></select>
            </div>
            <div>
                <label class="text-[10px] uppercase font-bold text-gray-400 ml-2">Tugas / Pekerjaan Utama</label>
                <input type="text" id="in-jadwal-tugas" class="w-full border border-gray-200 bg-gray-50 rounded-2xl p-3 outline-none focus:ring-2 focus:ring-blue-500 font-medium" placeholder="Contoh: Pengiriman material dan perataan tanah">
            </div>
            <div>
                <label class="text-[10px] uppercase font-bold text-gray-400 ml-2">Penugasan Tim</label>
                <select id="in-jadwal-tim" class="w-full border border-gray-200 bg-gray-50 rounded-2xl p-3 outline-none focus:ring-2 focus:ring-blue-500 font-medium">
                    <option value="Tim Mandor A">Tim Mandor A</option>
                    <option value="Tim Mandor B">Tim Mandor B</option>
                    <option value="Tim Perawatan">Tim Perawatan</option>
                    <option value="Driver / Gudang">Driver / Gudang</option>
                </select>
            </div>
            <div class="flex space-x-3 pt-4">
                <button id="btn-batal-jadwal" class="flex-1 py-3 bg-gray-100 hover:bg-gray-200 text-gray-600 rounded-xl font-bold transition">Batal</button>
                <button id="btn-simpan-jadwal" class="flex-1 py-3 bg-blue-600 hover:bg-blue-700 text-white rounded-xl font-bold shadow-lg transition">Simpan Jadwal</button>
            </div>
        </div>
    </div>

    <!-- MODAL LAPORAN HARIAN DENGAN INPUT BHP -->
    <div id="modal-laporan" class="fixed inset-0 bg-black/70 z-50 flex justify-center items-center hidden p-4 overflow-y-auto">
        <div class="bg-white rounded-[2rem] w-full max-w-lg p-8 shadow-2xl space-y-4 my-auto">
            <h2 class="text-xl font-bold flex items-center text-gray-800"><i data-lucide="clipboard-check" class="mr-2 text-blue-600"></i> Form Laporan Lapangan</h2>
            <div><label class="text-[10px] uppercase font-bold text-gray-400 mb-1 block">Pilih Proyek</label><select id="in-laporan-proyek" class="w-full border rounded-2xl p-3 outline-none focus:ring-2 focus:ring-blue-500 bg-gray-50 text-sm"></select></div>
            <div class="grid grid-cols-2 gap-4">
                <div><label class="text-[10px] uppercase font-bold text-gray-400 mb-1 block">Progres Hari Ini (%)</label><input type="number" id="in-laporan-progress" class="w-full border rounded-2xl p-3 outline-none focus:ring-2 focus:ring-blue-500 text-sm" placeholder="0-100"></div>
                <div><label class="text-[10px] uppercase font-bold text-gray-400 mb-1 block">Tenaga Kerja (Orang)</label><input type="number" id="in-laporan-pekerja" class="w-full border rounded-2xl p-3 outline-none focus:ring-2 focus:ring-blue-500 text-sm" placeholder="Jml Tukang"></div>
            </div>
            
            <div class="mt-4 pt-4 border-t border-gray-100">
                <div class="flex justify-between items-center mb-2">
                    <label class="text-[10px] uppercase font-bold text-gray-400 block">Material Digunakan (BHP)</label>
                    <button id="btn-tambah-bhp" class="text-[10px] font-black bg-blue-50 text-blue-600 px-2 py-1 rounded-lg hover:bg-blue-100 transition">+ Item</button>
                </div>
                <div id="bhp-list-container" class="space-y-2 mb-2 max-h-32 overflow-y-auto custom-scroll pr-1"></div>
            </div>

            <div><label class="text-[10px] uppercase font-bold text-gray-400 mb-1 block mt-2">Bukti Foto / URL (Wajib)</label><input type="url" id="in-laporan-foto" class="w-full border rounded-2xl p-3 outline-none focus:ring-2 focus:ring-blue-500 bg-gray-50 text-sm" placeholder="https://link-foto-lapangan.com/foto.jpg"></div>
            <div><label class="text-[10px] uppercase font-bold text-gray-400 mb-1 block">Catatan Kendala</label><textarea id="in-laporan-catatan" rows="2" class="w-full border rounded-2xl p-3 outline-none focus:ring-2 focus:ring-blue-500 bg-gray-50 text-sm" placeholder="Catatan hasil kerja..."></textarea></div>
            <div class="flex space-x-2 pt-2"><button id="btn-batal-laporan" class="flex-1 py-3 text-gray-400 font-bold bg-gray-100 rounded-2xl hover:bg-gray-200">Batal</button><button id="btn-simpan-laporan" class="flex-1 py-3 bg-blue-600 text-white rounded-2xl font-bold shadow-lg shadow-blue-100 hover:bg-blue-700">Kirim Approval</button></div>
        </div>
    </div>

    <!-- Modals Database Master -->
    <div id="modal-klien" class="fixed inset-0 bg-black/70 z-50 flex justify-center items-center hidden p-4"><div class="bg-white rounded-[2rem] w-full max-w-md p-8 shadow-2xl space-y-4"><h2 class="text-2xl font-black text-gray-800 mb-2 flex items-center"><i data-lucide="user-plus" class="mr-2 text-blue-600"></i> Register Klien</h2><div><label class="text-[10px] uppercase font-bold text-gray-400 ml-2">Nama Lengkap</label><input type="text" id="in-klien-nama" class="w-full border border-gray-200 bg-gray-50 rounded-2xl p-3 outline-none focus:ring-2 focus:ring-blue-500 font-medium" placeholder="Contoh: Budi Santoso"></div><div><label class="text-[10px] uppercase font-bold text-gray-400 ml-2">Email</label><input type="email" id="in-klien-email" class="w-full border border-gray-200 bg-gray-50 rounded-2xl p-3 outline-none focus:ring-2 focus:ring-blue-500 font-medium" placeholder="klien@email.com"></div><div><label class="text-[10px] uppercase font-bold text-gray-400 ml-2">No. WhatsApp</label><input type="text" id="in-klien-wa" class="w-full border border-gray-200 bg-gray-50 rounded-2xl p-3 outline-none focus:ring-2 focus:ring-blue-500 font-medium" placeholder="0812..."></div><div><label class="text-[10px] uppercase font-bold text-gray-400 ml-2">Alamat</label><textarea id="in-klien-alamat" rows="2" class="w-full border border-gray-200 bg-gray-50 rounded-2xl p-3 outline-none focus:ring-2 focus:ring-blue-500 font-medium"></textarea></div><div class="flex space-x-3 pt-4"><button id="btn-batal-klien" class="flex-1 py-3 bg-gray-100 hover:bg-gray-200 text-gray-600 rounded-xl font-bold transition">Batal</button><button id="btn-simpan-klien" class="flex-1 py-3 bg-blue-600 hover:bg-blue-700 text-white rounded-xl font-bold shadow-lg transition">Simpan Data</button></div></div></div>
    
    <div id="modal-pekerja" class="fixed inset-0 bg-black/70 z-50 flex justify-center items-center hidden p-4"><div class="bg-white rounded-[2rem] w-full max-w-md p-8 shadow-2xl space-y-4"><h2 class="text-2xl font-black text-gray-800 mb-2 flex items-center"><i data-lucide="hard-hat" class="mr-2 text-blue-600"></i> Register Pekerja</h2><div><label class="text-[10px] uppercase font-bold text-gray-400 ml-2">Nama Pekerja</label><input type="text" id="in-pekerja-nama" class="w-full border border-gray-200 bg-gray-50 rounded-2xl p-3 outline-none focus:ring-2 focus:ring-blue-500 font-medium" placeholder="Nama pekerja..."></div><div><label class="text-[10px] uppercase font-bold text-gray-400 ml-2">Email (Untuk Login)</label><input type="email" id="in-pekerja-email" class="w-full border border-gray-200 bg-gray-50 rounded-2xl p-3 outline-none focus:ring-2 focus:ring-blue-500 font-medium" placeholder="Pekerja email..."></div><div><label class="text-[10px] uppercase font-bold text-gray-400 ml-2">Password (Untuk Login)</label><input type="text" id="in-pekerja-password" class="w-full border border-gray-200 bg-gray-50 rounded-2xl p-3 outline-none focus:ring-2 focus:ring-blue-500 font-medium" placeholder="Minimal 6 karakter..."></div><div><label class="text-[10px] uppercase font-bold text-gray-400 ml-2">Keahlian / Posisi</label><input type="text" id="in-pekerja-posisi" class="w-full border border-gray-200 bg-gray-50 rounded-2xl p-3 outline-none focus:ring-2 focus:ring-blue-500 font-medium" placeholder="Contoh: Mandor, Tukang Taman..."></div><div><label class="text-[10px] uppercase font-bold text-gray-400 ml-2">No. HP / WA</label><input type="text" id="in-pekerja-hp" class="w-full border border-gray-200 bg-gray-50 rounded-2xl p-3 outline-none focus:ring-2 focus:ring-blue-500 font-medium" placeholder="0812..."></div><div class="flex space-x-3 pt-4"><button id="btn-batal-pekerja" class="flex-1 py-3 bg-gray-100 hover:bg-gray-200 text-gray-600 rounded-xl font-bold transition">Batal</button><button id="btn-simpan-pekerja" class="flex-1 py-3 bg-blue-600 hover:bg-blue-700 text-white rounded-xl font-bold shadow-lg transition">Simpan Data</button></div></div></div>

    <div id="modal-form" class="fixed inset-0 bg-black/70 z-50 flex justify-center items-center hidden p-4"><div class="bg-white rounded-[2rem] w-full max-w-md p-8 shadow-2xl space-y-5"><h2 class="text-2xl font-black text-gray-800 flex items-center"><i data-lucide="briefcase" class="mr-2 text-green-600"></i> Proyek Baru</h2><div class="bg-blue-50 p-4 rounded-2xl border border-blue-100"><label class="text-[10px] uppercase font-black text-blue-800 mb-2 block tracking-widest">Pilih Klien</label><select id="input-klien-id" class="w-full border border-blue-200 bg-white rounded-xl p-3 outline-none focus:ring-2 focus:ring-blue-500 font-bold text-gray-700 cursor-pointer"></select></div><div><label class="text-[10px] uppercase font-bold text-gray-400 mb-1 block ml-2">Alamat Proyek (Opsional)</label><textarea id="input-alamat-proyek" rows="2" class="w-full border border-gray-200 bg-gray-50 rounded-xl p-3 outline-none focus:ring-2 focus:ring-green-500 text-sm"></textarea></div><div class="flex space-x-3 pt-2"><button id="btn-batal-modal" class="flex-1 py-3 bg-gray-100 hover:bg-gray-200 text-gray-600 rounded-xl font-bold transition">Batal</button><button id="btn-simpan-modal" class="flex-1 py-3 bg-green-600 hover:bg-green-700 text-white rounded-xl font-bold shadow-lg transition">Buat Proyek</button></div></div></div>
    <div id="modal-stok" class="fixed inset-0 bg-black/70 z-50 flex justify-center items-center hidden p-4"><div class="bg-white rounded-3xl w-full max-w-md p-8 shadow-2xl space-y-4"><h2 class="text-xl font-bold text-gray-800">Register Inventaris</h2><input type="text" id="in-stok-nama" class="w-full border rounded-2xl p-3 outline-none focus:ring-2 focus:ring-green-500" placeholder="Nama Barang"><div class="grid grid-cols-2 gap-4"><input type="number" id="in-stok-jumlah" class="w-full border rounded-2xl p-3 outline-none focus:ring-2 focus:ring-green-500" placeholder="Qty"><select id="in-stok-kondisi" class="w-full border rounded-2xl p-3 outline-none focus:ring-2 focus:ring-green-500"><option>Bagus</option><option>Rusak Ringan</option><option>Rusak Berat</option></select></div><input type="text" id="in-stok-lokasi" class="w-full border rounded-2xl p-3 outline-none focus:ring-2 focus:ring-green-500" placeholder="Lokasi (Gudang/Proyek)"><div class="flex space-x-2"><button id="btn-batal-stok" class="flex-1 py-3 text-gray-400 font-bold bg-gray-100 rounded-xl">Batal</button><button id="btn-simpan-stok" class="flex-1 py-3 bg-green-600 text-white rounded-xl font-bold shadow-lg">Simpan</button></div></div></div>

    <!-- MODAL PAKET LAYANAN -->
    <div id="modal-paket" class="fixed inset-0 bg-black/70 z-50 flex justify-center items-center hidden p-4">
        <div class="bg-white rounded-[2rem] w-full max-w-lg p-8 shadow-2xl space-y-4">
            <h2 class="text-xl font-black text-gray-800 flex items-center mb-4"><i data-lucide="shopping-bag" class="mr-2 text-green-600"></i> Form Paket Layanan</h2>
            <input type="hidden" id="in-paket-id">
            <div>
                <label class="text-[10px] uppercase font-bold text-gray-400 ml-2">Nama Paket</label>
                <input type="text" id="in-paket-nama" class="w-full border border-gray-200 bg-gray-50 rounded-2xl p-3 outline-none focus:ring-2 focus:ring-green-500 font-medium" placeholder="Contoh: Paket Taman Minimalis">
            </div>
            <div>
                <label class="text-[10px] uppercase font-bold text-gray-400 ml-2">Harga (Rp)</label>
                <input type="number" id="in-paket-harga" class="w-full border border-gray-200 bg-gray-50 rounded-2xl p-3 outline-none focus:ring-2 focus:ring-green-500 font-medium" placeholder="Contoh: 5000000">
            </div>
            <div>
                <label class="text-[10px] uppercase font-bold text-gray-400 ml-2">URL Gambar / Upload File</label>
                <div class="flex space-x-2">
                    <input type="text" id="in-paket-gambar" class="flex-1 border border-gray-200 bg-gray-50 rounded-2xl p-3 outline-none focus:ring-2 focus:ring-green-500 font-medium" placeholder="https://link-gambar.com/foto.jpg">
                    <label class="bg-green-100 text-green-700 hover:bg-green-200 px-4 py-3 rounded-2xl cursor-pointer flex items-center justify-center font-bold transition">
                        <i data-lucide="upload" class="w-5 h-5 mr-1"></i> Upload
                        <input type="file" class="hidden" accept="image/*,video/*" onchange="uploadMedia(this, 'in-paket-gambar')">
                    </label>
                </div>
            </div>
            <div>
                <label class="text-[10px] uppercase font-bold text-gray-400 ml-2">Deskripsi Layanan</label>
                <textarea id="in-paket-deskripsi" rows="2" class="w-full border border-gray-200 bg-gray-50 rounded-2xl p-3 outline-none focus:ring-2 focus:ring-green-500 font-medium" placeholder="Deskripsi lengkap paket layanan ini..."></textarea>
            </div>
            <div class="mt-2 pt-2 border-t border-gray-100">
                <div class="flex justify-between items-center mb-2">
                    <label class="text-[10px] uppercase font-bold text-gray-400 block ml-2">Rincian RAB (Item Include)</label>
                    <button id="btn-tambah-item-paket" class="text-[10px] font-black bg-blue-50 text-blue-600 px-2 py-1 rounded-lg hover:bg-blue-100 transition">+ Tambah Item</button>
                </div>
                <div id="item-paket-container" class="space-y-2 max-h-40 overflow-y-auto pr-1"></div>
            </div>
            <div class="flex space-x-3 pt-4">
                <button id="btn-batal-paket" class="flex-1 py-3 bg-gray-100 hover:bg-gray-200 text-gray-600 rounded-xl font-bold transition">Batal</button>
                <button id="btn-simpan-paket" class="flex-1 py-3 bg-green-600 hover:bg-green-700 text-white rounded-xl font-bold shadow-lg transition">Simpan Paket</button>
            </div>
        </div>
    </div>

    <!-- MODAL TESTIMONI -->
    <div id="modal-testimoni" class="fixed inset-0 bg-black/70 z-50 flex justify-center items-center hidden p-4">
        <div class="bg-white rounded-[2rem] w-full max-w-lg p-8 shadow-2xl space-y-4">
            <h2 class="text-xl font-black text-gray-800 flex items-center mb-4"><i data-lucide="instagram" class="mr-2 text-pink-600"></i> Form Testimoni IG</h2>
            <input type="hidden" id="in-testimoni-id">
            <div>
                <label class="text-[10px] uppercase font-bold text-gray-400 ml-2">Judul (Opsional)</label>
                <input type="text" id="in-testimoni-judul" class="w-full border border-gray-200 bg-gray-50 rounded-2xl p-3 outline-none focus:ring-2 focus:ring-pink-500 font-medium" placeholder="Contoh: Pemasangan Taman Bpk. Andi">
            </div>
            <div>
                <label class="text-[10px] uppercase font-bold text-gray-400 ml-2">URL Postingan Instagram</label>
                <input type="url" id="in-testimoni-url" class="w-full border border-gray-200 bg-gray-50 rounded-2xl p-3 outline-none focus:ring-2 focus:ring-pink-500 font-medium" placeholder="https://www.instagram.com/p/...">
            </div>
            <div>
                <label class="text-[10px] uppercase font-bold text-gray-400 ml-2">Thumbnail / Gambar (Opsional)</label>
                <div class="flex space-x-2">
                    <input type="text" id="in-testimoni-thumbnail" class="flex-1 border border-gray-200 bg-gray-50 rounded-2xl p-3 outline-none focus:ring-2 focus:ring-pink-500 font-medium" placeholder="https://link-gambar.com/foto.jpg">
                    <label class="bg-pink-100 text-pink-700 hover:bg-pink-200 px-4 py-3 rounded-2xl cursor-pointer flex items-center justify-center font-bold transition">
                        <i data-lucide="upload" class="w-5 h-5 mr-1"></i> Upload
                        <input type="file" class="hidden" accept="image/*,video/*" onchange="uploadMedia(this, 'in-testimoni-thumbnail')">
                    </label>
                </div>
            </div>
            <div class="flex space-x-3 pt-4">
                <button id="btn-batal-testimoni" class="flex-1 py-3 bg-gray-100 hover:bg-gray-200 text-gray-600 rounded-xl font-bold transition">Batal</button>
                <button id="btn-simpan-testimoni" class="flex-1 py-3 bg-pink-600 hover:bg-pink-700 text-white rounded-xl font-bold shadow-lg transition">Simpan Testimoni</button>
            </div>
        </div>
    </div>

    <!-- MODAL BANNER PROMO -->
    <div id="modal-promo" class="fixed inset-0 bg-black/70 z-50 flex justify-center items-center hidden p-4 overflow-y-auto">
        <div class="bg-white rounded-[2rem] w-full max-w-lg p-8 shadow-2xl space-y-4 my-auto">
            <h2 class="text-xl font-black text-gray-800 flex items-center mb-4"><i data-lucide="image" class="mr-2 text-pink-600"></i> Form Banner Promo</h2>
            <input type="hidden" id="in-promo-id">
            <div>
                <label class="text-[10px] uppercase font-bold text-gray-400 ml-2">Judul Banner</label>
                <input type="text" id="in-promo-judul" class="w-full border border-gray-200 bg-gray-50 rounded-2xl p-3 outline-none focus:ring-2 focus:ring-pink-500 font-medium" placeholder="Contoh: Promo Lebaran 50%">
            </div>
            <div>
                <label class="text-[10px] uppercase font-bold text-gray-400 ml-2">URL Gambar Banner</label>
                <div class="flex space-x-2">
                    <input type="text" id="in-promo-gambar" class="flex-1 border border-gray-200 bg-gray-50 rounded-2xl p-3 outline-none focus:ring-2 focus:ring-pink-500 font-medium" placeholder="https://link-gambar.com/banner.jpg">
                    <label class="bg-pink-100 text-pink-700 hover:bg-pink-200 px-4 py-3 rounded-2xl cursor-pointer flex items-center justify-center font-bold transition">
                        <i data-lucide="upload" class="w-5 h-5 mr-1"></i> Upload
                        <input type="file" class="hidden" accept="image/*" onchange="uploadMedia(this, 'in-promo-gambar')">
                    </label>
                </div>
                <p class="text-[10px] text-gray-400 ml-2 mt-1">Rekomendasi ukuran: 800x300px (rasio 2.7:1)</p>
            </div>
            <div>
                <label class="text-[10px] uppercase font-bold text-gray-400 ml-2">Deskripsi Singkat (Opsional)</label>
                <input type="text" id="in-promo-deskripsi" class="w-full border border-gray-200 bg-gray-50 rounded-2xl p-3 outline-none focus:ring-2 focus:ring-pink-500 font-medium" placeholder="Contoh: Dapatkan diskon taman hingga 50% untuk pemesanan bulan ini">
            </div>
            <div>
                <label class="text-[10px] uppercase font-bold text-gray-400 ml-2">Isi Konten Detail (Opsional)</label>
                <textarea id="in-promo-content" rows="4" class="w-full border border-gray-200 bg-gray-50 rounded-2xl p-3 outline-none focus:ring-2 focus:ring-pink-500 font-medium" placeholder="Tulis detail promo di sini. Contoh: Syarat dan ketentuan, daftar layanan yang termasuk promo, dll."></textarea>
            </div>
            <div class="grid grid-cols-2 gap-3">
                <div>
                    <label class="text-[10px] uppercase font-bold text-gray-400 ml-2">Teks Tombol CTA (Opsional)</label>
                    <input type="text" id="in-promo-cta-label" class="w-full border border-gray-200 bg-gray-50 rounded-2xl p-3 outline-none focus:ring-2 focus:ring-pink-500 font-medium" placeholder="Contoh: Hubungi Kami">
                </div>
                <div>
                    <label class="text-[10px] uppercase font-bold text-gray-400 ml-2">URL Tombol CTA (Opsional)</label>
                    <input type="text" id="in-promo-cta-url" class="w-full border border-gray-200 bg-gray-50 rounded-2xl p-3 outline-none focus:ring-2 focus:ring-pink-500 font-medium" placeholder="https://wa.me/...">
                </div>
            </div>
            <div>
                <label class="text-[10px] uppercase font-bold text-gray-400 ml-2">Urutan Tampil (Angka Kecil = Tampil Pertama)</label>
                <input type="number" id="in-promo-order" class="w-full border border-gray-200 bg-gray-50 rounded-2xl p-3 outline-none focus:ring-2 focus:ring-pink-500 font-medium" placeholder="0" min="0">
            </div>
            <div class="flex space-x-3 pt-4">
                <button id="btn-batal-promo" class="flex-1 py-3 bg-gray-100 hover:bg-gray-200 text-gray-600 rounded-xl font-bold transition">Batal</button>
                <button id="btn-simpan-promo" class="flex-1 py-3 bg-pink-600 hover:bg-pink-700 text-white rounded-xl font-bold shadow-lg transition">Simpan Banner</button>
            </div>
        </div>
    </div>