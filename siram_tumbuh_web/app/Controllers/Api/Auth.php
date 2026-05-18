<?php

namespace App\Controllers\Api;

use CodeIgniter\RESTful\ResourceController;
use App\Models\UserModel;

class Auth extends ResourceController
{
    protected $format = 'json';

    public function __construct()
    {
        $this->userModel = new UserModel();
    }

    public function login()
    {
        $request = $this->request->getJSON(true) ?? $this->request->getPost();

        // Validate input
        if (empty($request['email']) || empty($request['password'])) {
            return $this->fail('Email dan password harus diisi', 400);
        }

        // Find user by email
        $user = $this->userModel->where('email', strtolower(trim($request['email'])))->first();

        if (!$user) {
            return $this->fail('Email atau password salah', 401);
        }

        // Check status
        if ($user['status'] !== 'active') {
            return $this->fail('Akun Anda tidak aktif. Hubungi admin.', 401);
        }

        // Verify password
        if (!password_verify($request['password'], $user['password_hash'])) {
            return $this->fail('Email atau password salah', 401);
        }

        // Generate simple token (in production use JWT)
        $token = hash('sha256', $user['id'] . time() . random_bytes(16));

        // Return user data with token (store token in client-side for subsequent requests)
        unset($user['password_hash']);

        return $this->respond([
            'user'  => $user,
            'token' => $token
        ], 200, 'Login berhasil');
    }

    public function logout()
    {
        // In production with JWT, you might want to blacklist the token
        return $this->respond(null, 200, 'Logout berhasil');
    }

    public function register_worker()
    {
        $request = $this->request->getJSON(true) ?? $this->request->getPost();

        if (empty($request['email']) || empty($request['password']) || empty($request['name']) || empty($request['phone'])) {
            return $this->fail('Semua data wajib diisi', 400);
        }

        $existing = $this->userModel->where('email', strtolower(trim($request['email'])))->first();
        if ($existing) {
            // Update if exists but let's just update password
            $this->userModel->update($existing['id'], [
                'password_hash' => password_hash($request['password'], PASSWORD_DEFAULT),
                'name' => $request['name'],
                'phone' => $request['phone']
            ]);
            return $this->respond(['message' => 'Worker diperbarui']);
        }

        $data = [
            'name' => $request['name'],
            'email' => strtolower(trim($request['email'])),
            'phone' => $request['phone'],
            'role' => 'worker',
            'password_hash' => password_hash($request['password'], PASSWORD_DEFAULT),
            'status' => 'active'
        ];

        if ($this->userModel->insert($data)) {
            return $this->respondCreated(['message' => 'Worker berhasil didaftarkan']);
        }
        return $this->fail('Gagal mendaftar worker', 500);
    }
}
