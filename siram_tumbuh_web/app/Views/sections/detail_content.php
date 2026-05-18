<div id="detail-content" class="hidden p-8 fade-in flex-col bg-white min-h-full">
                <div class="flex justify-between items-center mb-6"><button id="btn-kembali" class="text-gray-500 flex items-center font-bold bg-gray-50 px-4 py-2 rounded-xl hover:bg-gray-100 transition"><i data-lucide="arrow-left" class="mr-2"></i> Kembali</button><div class="flex space-x-3"><button id="btn-preview-print" class="bg-gray-100 px-4 py-2 rounded-xl font-bold hover:bg-gray-200 transition text-gray-700 flex items-center"><i data-lucide="printer" class="w-4 h-4 mr-2"></i> Preview Penawaran</button><button id="btn-simpan-detail" class="bg-green-600 text-white px-6 py-2 rounded-xl font-bold shadow-lg flex items-center hover:bg-green-700 transition"><i data-lucide="save" class="w-4 h-4 mr-2"></i> Simpan Proyek</button></div></div>
                <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
                    <div class="space-y-6">
                        <div class="p-6 bg-gray-50 rounded-3xl border border-gray-100 shadow-sm">
                            <h2 class="font-black text-green-700 uppercase text-xs mb-4 tracking-widest flex items-center"><i data-lucide="user" class="w-4 h-4 mr-2"></i> Profil Klien & Lokasi</h2>
                            <p id="detail-nama" class="font-black text-xl mb-1"></p>
                            <p id="detail-wa" class="text-blue-600 text-sm font-bold flex items-center mb-2"><i data-lucide="phone" class="w-3 h-3 mr-1"></i> <span></span></p>
                            <p id="detail-alamat" class="text-gray-500 text-sm mb-4 bg-white p-3 rounded-xl border border-gray-100"></p>
                            <div class="grid grid-cols-2 gap-4 border-t pt-4"><div><label class="text-[10px] uppercase font-bold text-gray-400">P (m)</label><input type="number" id="survey-panjang" oninput="window.updateLuas()" class="w-full border rounded-xl p-3 font-bold outline-none focus:ring-2 focus:ring-green-500 bg-white shadow-sm"></div><div><label class="text-[10px] uppercase font-bold text-gray-400">L (m)</label><input type="number" id="survey-lebar" oninput="window.updateLuas()" class="w-full border rounded-xl p-3 font-bold outline-none focus:ring-2 focus:ring-green-500 bg-white shadow-sm"></div></div>
                            <div class="mt-4 flex justify-between items-center bg-green-100 p-4 rounded-xl border border-green-200"><p class="font-bold text-green-700 uppercase text-xs">Luas Tanah:</p><p class="font-black text-green-900 text-2xl"><span id="survey-luas">0</span> m&sup2;</p></div>
                        </div>
                        <div class="p-6 bg-blue-50 rounded-3xl border border-blue-100 shadow-sm">
                            <h2 class="font-black text-blue-700 uppercase text-xs mb-3 tracking-widest flex items-center"><i data-lucide="bar-chart-2" class="w-4 h-4 mr-2"></i> Realisasi Pemakaian BHP</h2>
                            <p class="text-[10px] text-blue-600 mb-3 leading-tight">Data ditarik otomatis dari Laporan Harian yang disetujui.</p>
                            <ul id="realisasi-list" class="space-y-2 text-sm font-bold text-gray-700"></ul>
                        </div>
                        
                        <!-- Timeline Section -->
                        <div class="p-6 bg-amber-50 rounded-3xl border border-amber-100 shadow-sm">
                            <h2 class="font-black text-amber-700 uppercase text-xs mb-4 tracking-widest flex items-center"><i data-lucide="calendar" class="w-4 h-4 mr-2"></i> Timeline Pengerjaan</h2>
                            <div class="space-y-3">
                                <div><label class="text-[9px] uppercase font-bold text-gray-400">Survei Lokasi Selesai</label><input type="date" id="timeline-survei" class="w-full border rounded-xl p-2 text-xs font-bold outline-none focus:ring-2 focus:ring-amber-500 bg-white"></div>
                                <div><label class="text-[9px] uppercase font-bold text-gray-400">Desain Disetujui</label><input type="date" id="timeline-desain" class="w-full border rounded-xl p-2 text-xs font-bold outline-none focus:ring-2 focus:ring-amber-500 bg-white"></div>
                                <div><label class="text-[9px] uppercase font-bold text-gray-400">Pengerjaan Lahan</label><input type="date" id="timeline-lahan" class="w-full border rounded-xl p-2 text-xs font-bold outline-none focus:ring-2 focus:ring-amber-500 bg-white"></div>
                                <div><label class="text-[9px] uppercase font-bold text-gray-400">Penanaman & Irigasi</label><input type="date" id="timeline-penanaman" class="w-full border rounded-xl p-2 text-xs font-bold outline-none focus:ring-2 focus:ring-amber-500 bg-white"></div>
                                <div><label class="text-[9px] uppercase font-bold text-gray-400">Serah Terima</label><input type="date" id="timeline-serah-terima" class="w-full border rounded-xl p-2 text-xs font-bold outline-none focus:ring-2 focus:ring-amber-500 bg-white"></div>
                            </div>
                        </div>
                    </div>
                    <div class="lg:col-span-2 bg-white p-6 shadow-sm border border-gray-100 rounded-3xl flex flex-col h-full">
                        <div class="flex justify-between items-center mb-6"><h2 class="font-black text-green-700 uppercase text-xs tracking-widest">Daftar Biaya RAB (Rencana)</h2><div class="flex space-x-2"><select id="select-katalog" class="text-xs border rounded-lg px-2 outline-none font-bold bg-gray-50"><option value="">+ Dari Katalog</option></select><button id="btn-tambah-rab" class="text-xs bg-green-50 text-green-600 px-3 py-1 font-black rounded-lg border border-green-100 hover:bg-green-100 transition">+ Item Manual</button></div></div>
                        <div class="overflow-x-auto flex-1">
                            <table class="w-full text-xs">
                                <thead class="text-gray-400 uppercase font-bold border-b-2"><tr><th class="pb-2 text-left">Deskripsi Pekerjaan/Material</th><th class="pb-2 text-center w-16">Vol</th><th class="pb-2 w-12 text-center">Unit</th><th class="pb-2 text-right">Harga</th><th class="pb-2 text-right">Total</th><th></th></tr></thead>
                                <tbody id="rab-table-body"></tbody>
                            </table>
                        </div>
                        <div class="mt-6 p-5 bg-green-900 text-white rounded-2xl flex justify-between items-center shadow-lg"><p class="font-bold opacity-60 uppercase tracking-widest text-[10px]">Grand Total Estimasi</p><p id="rab-grand-total" class="font-black text-2xl"></p></div>
                    </div>
                </div>
            </div>