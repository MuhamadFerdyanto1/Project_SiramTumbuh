<?php

namespace App\Controllers\Api;

use CodeIgniter\RESTful\ResourceController;

class Projects extends ResourceController
{
    protected $modelName = 'App\Models\ProjectModel';
    protected $format    = 'json';

    public function __construct()
    {
        $this->model = new \App\Models\ProjectModel();
    }

    public function index()
    {
        // Filter by klien_email if provided (for customer Flutter app)
        $email = $this->request->getGet('email');
        if ($email) {
            $data = $this->model->where('klien_email', strtolower(trim($email)))->findAll();
            return $this->respond($data);
        }
        return $this->respond($this->model->findAll());
    }

    public function show($id = null)
    {
        $data = $this->model->find($id);
        if ($data) {
            return $this->respond($data);
        }
        return $this->failNotFound('Data tidak ditemukan');
    }

    public function create()
    {
        $data = $this->request->getJSON(true) ?? $this->request->getPost();
        
        // Normalize email to lowercase
        if (!empty($data['klien_email'])) {
            $data['klien_email'] = strtolower(trim($data['klien_email']));
        }

        // Map 'pending' or empty status to 'Menunggu Survei' for consistency with admin workflow
        if (empty($data['status']) || strtolower($data['status']) === 'pending') {
            $data['status'] = 'Menunggu Survei';
        }

        if ($this->model->insert($data)) {
            $data['id'] = $this->model->getInsertID();
            return $this->respondCreated($data, 'Data berhasil disimpan');
        }
        return $this->fail($this->model->errors());
    }

    public function update($id = null)
    {
        $data = $this->request->getJSON(true) ?? $this->request->getRawInput();
        if (!empty($data['klien_email'])) {
            $data['klien_email'] = strtolower(trim($data['klien_email']));
        }
        if ($this->model->update($id, $data)) {
            return $this->respond($data, 200, 'Data berhasil diupdate');
        }
        return $this->fail($this->model->errors());
    }

    public function delete($id = null)
    {
        if ($this->model->delete($id)) {
            return $this->respondDeleted(['id' => $id], 'Data berhasil dihapus');
        }
        return $this->failNotFound('Data tidak ditemukan');
    }
}
