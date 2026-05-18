<div id="print-content" class="hidden p-8 fade-in flex-col bg-gray-200 min-h-full">
                <div class="flex justify-between max-w-4xl mx-auto mb-6 print-hidden"><button id="btn-kembali-print" class="bg-white px-4 py-2 rounded-xl font-bold flex items-center"><i data-lucide="arrow-left" class="mr-2 w-4 h-4"></i> Kembali Edit</button><button onclick="window.print()" class="bg-blue-600 text-white px-6 py-2 rounded-xl font-bold flex items-center shadow-lg"><i data-lucide="printer" class="mr-2 w-4 h-4"></i> Download PDF</button></div>
                <div id="print-document" class="bg-white p-12 shadow-2xl mx-auto max-w-4xl min-h-[1000px]">
                    <div class="flex justify-between border-b-4 border-green-800 pb-6 mb-8 text-green-900"><div><h1 class="text-4xl font-black text-green-800 leading-none mb-1" contenteditable="true" spellcheck="false" class="outline-none hover:bg-gray-50 focus:bg-green-50 rounded px-1 transition-colors cursor-text">MITRA RIZKI</h1><p contenteditable="true" spellcheck="false" class="uppercase font-bold tracking-widest text-[10px] opacity-60 outline-none hover:bg-gray-50 focus:bg-green-50 rounded px-1 transition-colors cursor-text mt-1 inline-block">Landscape & Gardening Service</p></div><div contenteditable="true" spellcheck="false" class="text-right opacity-60 text-xs font-medium outline-none hover:bg-gray-50 focus:bg-green-50 rounded px-2 transition-colors cursor-text">Jl. Parit Demang, Parit Tokaya,<br>Kec. Pontianak Selatan, Kota Pontianak, Kalimantan Barat<br>Pontianak, Indonesia 78115<br>WA: 0895618164691</div></div>
                    <div class="text-right mb-6"><p id="print-tanggal" contenteditable="true" spellcheck="false" class="text-sm text-gray-700 outline-none hover:bg-gray-50 focus:bg-green-50 rounded inline-block px-2 transition-colors cursor-text"></p></div>
                    
                    <div class="flex flex-col mb-8 text-sm text-gray-800">
                        <div class="flex mb-1"><div class="w-24">Nomor</div><div class="mr-2">:</div><div contenteditable="true" spellcheck="false" class="flex-1 outline-none hover:bg-gray-50 focus:bg-green-50 rounded px-1 cursor-text">-</div></div>
                        <div class="flex mb-1"><div class="w-24">Lampiran</div><div class="mr-2">:</div><div contenteditable="true" spellcheck="false" class="flex-1 outline-none hover:bg-gray-50 focus:bg-green-50 rounded px-1 cursor-text">1 (Satu) Bendel</div></div>
                        <div class="flex mb-1"><div class="w-24">Hal</div><div class="mr-2">:</div><div contenteditable="true" spellcheck="false" class="flex-1 outline-none hover:bg-gray-50 focus:bg-green-50 rounded px-1 cursor-text font-bold">Penawaran Harga Taman / Konstruksi</div></div>
                    </div>

                    <div class="mb-8 text-sm text-gray-800 leading-relaxed">
                        <p class="mb-1">Kepada Yth,</p>
                        <p id="print-nama" class="font-bold text-base uppercase"></p>
                        <p id="print-kontak" class="text-xs text-gray-500 font-bold mb-2"></p>
                        <p>di</p>
                        <p id="print-alamat" contenteditable="true" spellcheck="false" class="outline-none hover:bg-gray-50 focus:bg-green-50 rounded px-1 cursor-text w-full max-w-md"></p>
                    </div>

                    <div class="mb-6">
                        <p contenteditable="true" spellcheck="false" class="text-sm text-gray-700 leading-relaxed outline-none hover:bg-gray-50 focus:bg-green-50 rounded px-2 py-1 transition-colors cursor-text border border-transparent hover:border-gray-200 focus:border-green-200">Dengan hormat,<br><br>Bersama surat ini, kami dari Mitra Rizki bermaksud menyampaikan penawaran harga untuk pekerjaan pembuatan/renovasi di lokasi Bapak/Ibu. Berikut adalah rincian estimasi biaya yang kami tawarkan:</p>
                    </div>
                    
                    <div class="flex justify-between items-end mb-3">
                        <h3 class="font-bold text-green-900 text-sm">Rincian Anggaran Biaya</h3>
                        <p class="text-xs font-bold text-gray-500 bg-gray-100 px-3 py-1 rounded-lg">Luas Lahan: <span id="print-luas" class="text-green-700 font-black">0</span> m&sup2;</p>
                    </div>
                    <table class="w-full border-collapse mb-10 text-sm"><thead><tr class="bg-green-800 text-white uppercase text-[10px] tracking-wider"><th class="p-3 text-center w-10 rounded-tl-lg">No</th><th class="p-3 text-left">Deskripsi Pekerjaan / Material</th><th class="p-3 text-center">Vol</th><th class="p-3 text-right">Harga Satuan</th><th class="p-3 text-right rounded-tr-lg">Subtotal</th></tr></thead><tbody id="print-table-body"></tbody><tfoot class="font-black text-green-900 text-lg"><tr><td colspan="4" class="p-4 text-right border-t-2 border-gray-200">TOTAL ESTIMASI BIAYA</td><td class="p-4 text-right border-t-2 border-gray-200 bg-green-50" id="print-grand-total"></td></tr></tfoot></table>
                    <div class="mt-20 text-right font-black"><p contenteditable="true" spellcheck="false" class="mb-20 opacity-60 text-gray-800 text-sm outline-none hover:bg-gray-50 focus:bg-green-50 rounded inline-block px-2 transition-colors cursor-text">Hormat Kami,</p><br><p contenteditable="true" spellcheck="false" class="underline text-gray-800 text-lg outline-none hover:bg-gray-50 focus:bg-green-50 rounded inline-block px-2 transition-colors cursor-text">Manajemen Mitra Rizki</p></div>
                </div>
            </div>