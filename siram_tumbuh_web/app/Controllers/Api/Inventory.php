<?php

namespace App\Controllers\Api;

use CodeIgniter\RESTful\ResourceController;

class Inventory extends ResourceController
{
    protected $modelName = 'App\Models\InventoryModel';
    protected $format    = 'json';

    public function index()
    {
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
        if ($this->model->insert($data)) {
            $data['id'] = $this->model->getInsertID();
            return $this->respondCreated($data, 'Data berhasil disimpan');
        }
        return $this->fail($this->model->errors());
    }

    public function update($id = null)
    {
        $data = $this->request->getJSON(true) ?? $this->request->getRawInput();
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
