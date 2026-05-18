<?php

namespace App\Controllers\Api;

use CodeIgniter\RESTful\ResourceController;

class Upload extends ResourceController
{
    public function index()
    {
        $file = $this->request->getFile('file');
        
        if (!$file) {
            return $this->fail('Tidak ada file yang diunggah', 400);
        }

        if (!$file->isValid()) {
            return $this->fail($file->getErrorString(), 400);
        }

        // Generate a random unique name
        $newName = $file->getRandomName();

        // Move the file to public/uploads
        // Ensure the directory exists
        if (!is_dir(FCPATH . 'uploads')) {
            mkdir(FCPATH . 'uploads', 0777, true);
        }

        if ($file->move(FCPATH . 'uploads', $newName)) {
            // Return the API URL so it goes through CORS filter
            return $this->respond([
                'status'  => 200,
                'message' => 'File berhasil diunggah',
                'url'     => '/api/uploads/' . $newName,
                'type'    => $file->getClientMimeType()
            ], 200);
        } else {
            return $this->fail('Gagal memindahkan file', 500);
        }
    }

    public function serve($filename)
    {
        $path = FCPATH . 'uploads/' . $filename;
        if (!file_exists($path)) {
            $this->response->setContentType('image/png');
            $this->response->setBody(base64_decode('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII='));
            $this->response->setHeader('Access-Control-Allow-Origin', '*');
            return $this->response;
        }

        $mime = mime_content_type($path);
        
        $this->response->setContentType($mime);
        $this->response->setBody(file_get_contents($path));
        $this->response->setHeader('Access-Control-Allow-Origin', '*');
        $this->response->setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS');
        $this->response->setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');
        $this->response->setHeader('Cross-Origin-Resource-Policy', 'cross-origin');
        return $this->response;
    }
}
