<?php

namespace App\Controllers\Api;

use CodeIgniter\RESTful\ResourceController;
use App\Models\MaterialRequestModel;
use App\Models\InventoryModel;

class MaterialRequests extends ResourceController
{
    protected $modelName = 'App\Models\MaterialRequestModel';
    protected $format    = 'json';

    public function __construct()
    {
        $this->materialModel = new MaterialRequestModel();
        $this->inventoryModel = new InventoryModel();
    }

    public function index()
    {
        // Get material requests for current worker
        $workerId = $this->request->getHeaderLine('X-Worker-ID');
        
        if (!$workerId) {
            return $this->fail('Worker ID harus disediakan di header X-Worker-ID', 400);
        }

        $status = $this->request->getGet('status'); // Filter by status if provided

        $query = $this->materialModel->where('worker_id', $workerId);
        
        if ($status) {
            $query->where('status', $status);
        }

        $requests = $query->orderBy('requested_date', 'DESC')->findAll();

        return $this->respond($requests);
    }

    public function show($id = null)
    {
        $request = $this->materialModel->find($id);
        if (!$request) {
            return $this->failNotFound('Permintaan material tidak ditemukan');
        }

        return $this->respond($request);
    }

    public function create()
    {
        $data = $this->request->getJSON(true) ?? $this->request->getPost();

        // Validate worker_id
        if (!isset($data['worker_id'])) {
            return $this->fail('worker_id harus disediakan', 400);
        }

        // Validate items
        if (!isset($data['items']) || !is_array($data['items']) || empty($data['items'])) {
            return $this->fail('Items harus disediakan (minimal 1 item)', 400);
        }

        // Default values
        $data['requested_date'] = $data['requested_date'] ?? date('Y-m-d');
        $data['status'] = 'pending';

        // Validate each item has required fields
        foreach ($data['items'] as $item) {
            if (!isset($item['catalog_id']) || !isset($item['quantity_used'])) {
                return $this->fail('Setiap item harus memiliki catalog_id dan quantity_used', 400);
            }
        }

        if ($this->materialModel->insert($data)) {
            return $this->respondCreated(
                ['id' => $this->materialModel->getInsertID()],
                'Permintaan material berhasil dibuat'
            );
        }

        return $this->fail($this->materialModel->errors());
    }

    public function update($id = null)
    {
        $request = $this->materialModel->find($id);
        if (!$request) {
            return $this->failNotFound('Permintaan material tidak ditemukan');
        }

        $data = $this->request->getJSON(true) ?? $this->request->getRawInput();

        if ($this->materialModel->update($id, $data)) {
            return $this->respond($data, 200, 'Permintaan material berhasil diupdate');
        }

        return $this->fail($this->materialModel->errors());
    }

    public function delete($id = null)
    {
        $request = $this->materialModel->find($id);
        if (!$request) {
            return $this->failNotFound('Permintaan material tidak ditemukan');
        }

        // Only allow deletion if pending
        if ($request['status'] !== 'pending') {
            return $this->fail('Hanya permintaan dengan status pending yang bisa dihapus', 400);
        }

        if ($this->materialModel->delete($id)) {
            return $this->respondDeleted(['id' => $id], 'Permintaan material berhasil dihapus');
        }

        return $this->fail($this->materialModel->errors());
    }

    /**
     * Approve material request and reduce inventory
     * POST /api/material-requests/{id}/approve
     */
    public function approve($id = null)
    {
        $request = $this->materialModel->find($id);
        if (!$request) {
            return $this->failNotFound('Permintaan material tidak ditemukan');
        }

        if ($request['status'] !== 'pending') {
            return $this->fail('Hanya permintaan pending yang bisa di-approve', 400);
        }

        $approveData = $this->request->getJSON(true) ?? $this->request->getPost();
        $approveData['status'] = 'approved';
        $approveData['approved_by'] = $approveData['approved_by'] ?? null;

        // Reduce inventory for each item in request
        if (is_array($request['items'])) {
            foreach ($request['items'] as $item) {
                if (isset($item['catalog_id'])) {
                    // Reduce inventory quantity (optional: implement logic)
                    // This depends on how you want to manage inventory deduction
                }
            }
        }

        if ($this->materialModel->update($id, $approveData)) {
            return $this->respond(null, 200, 'Permintaan material berhasil di-approve');
        }

        return $this->fail($this->materialModel->errors());
    }

    /**
     * Reject material request
     * POST /api/material-requests/{id}/reject
     */
    public function reject($id = null)
    {
        $request = $this->materialModel->find($id);
        if (!$request) {
            return $this->failNotFound('Permintaan material tidak ditemukan');
        }

        if ($request['status'] !== 'pending') {
            return $this->fail('Hanya permintaan pending yang bisa di-reject', 400);
        }

        $rejectData = $this->request->getJSON(true) ?? $this->request->getPost();
        $rejectData['status'] = 'rejected';

        if ($this->materialModel->update($id, $rejectData)) {
            return $this->respond(null, 200, 'Permintaan material berhasil di-reject');
        }

        return $this->fail($this->materialModel->errors());
    }
}
