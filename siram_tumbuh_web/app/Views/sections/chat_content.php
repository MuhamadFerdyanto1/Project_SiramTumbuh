<div id="chat-content" class="hidden flex-col p-6 space-y-6">
    <div class="flex justify-between items-end">
        <div>
            <h2 class="text-3xl font-black text-green-900 leading-tight">Chat Konsultasi</h2>
            <p class="text-sm text-green-600 font-bold uppercase tracking-widest mt-1">Interaksi Customer & AI Bot</p>
        </div>
    </div>

    <div class="grid grid-cols-12 gap-6 h-[calc(100vh-250px)]">
        <!-- Chat List -->
        <div class="col-span-4 bg-white rounded-3xl border shadow-sm flex flex-col overflow-hidden">
            <div class="p-4 border-b bg-gray-50">
                <input type="text" placeholder="Cari customer..." class="w-full px-4 py-2 rounded-xl border-none bg-white text-sm focus:ring-2 focus:ring-green-500 shadow-sm">
            </div>
            <div class="flex-1 overflow-y-auto" id="chat-list">
                <!-- Chat list items will be injected here -->
                <div class="p-8 text-center text-gray-400 italic text-sm">Memuat percakapan...</div>
            </div>
        </div>

        <!-- Chat Window -->
        <div class="col-span-8 bg-white rounded-3xl border shadow-sm flex flex-col overflow-hidden">
            <div id="chat-window-header" class="p-4 border-b bg-white flex justify-between items-center hidden">
                <div class="flex items-center">
                    <div class="w-10 h-10 bg-green-100 text-green-600 rounded-full flex items-center justify-center font-black mr-3 shadow-sm">U</div>
                    <div>
                        <h3 id="active-chat-name" class="font-bold text-gray-800">Customer Name</h3>
                        <p class="text-[10px] text-green-500 font-bold uppercase tracking-wider">Online</p>
                    </div>
                </div>
            </div>

            <div id="chat-messages" class="flex-1 overflow-y-auto p-6 space-y-4 bg-gray-50/50">
                <div class="h-full flex flex-col items-center justify-center text-gray-400 space-y-4">
                    <i data-lucide="message-square" class="w-16 h-16 opacity-20"></i>
                    <p class="font-bold italic">Pilih percakapan untuk memulai</p>
                </div>
            </div>

            <div id="chat-input-container" class="p-4 border-t bg-white hidden">
                <div class="flex space-x-2">
                    <input type="text" id="chat-input" placeholder="Ketik balasan..." class="flex-1 px-4 py-3 rounded-2xl border-none bg-gray-100 text-sm focus:ring-2 focus:ring-green-500">
                    <button id="btn-send-chat" class="bg-green-600 text-white px-6 py-3 rounded-2xl font-black text-sm hover:bg-green-700 transition shadow-lg shadow-green-200">Kirim</button>
                </div>
            </div>
        </div>
    </div>
</div>
