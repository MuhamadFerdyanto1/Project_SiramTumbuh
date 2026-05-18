<?php

namespace App\Controllers\Api;

use CodeIgniter\RESTful\ResourceController;
use App\Models\AssignmentModel;
use App\Models\ProgressUpdateModel;
use App\Models\ProjectModel;

class Assignments extends ResourceController
{
    protected $modelName = 'App\Models\AssignmentModel';
    protected $format    = 'json';

    public function __construct()
    {
        $this->assignmentModel = new AssignmentModel();
        $this->progressModel = new ProgressUpdateModel();
        $this->projectModel = new ProjectModel();
    }

    public function index()
    {
        // Get assignments for current worker (filtered by Authorization header)
        $workerId = $this->request->getHeaderLine('X-Worker-ID');
        
        if (!$workerId) {
            return $this->fail('Worker ID harus disediakan di header X-Worker-ID', 400);
        }

        // Get assignments with project details
        $assignments = $this->assignmentModel
            ->where('worker_id', $workerId)
            ->findAll();

        // Enrich with project data
        foreach ($assignments as &$assignment) {
            $project = $this->projectModel->find($assignment['project_id']);
            $assignment['project'] = $project;
            
            // Get latest progress
            $latestProgress = $this->progressModel
                ->where('assignment_id', $assignment['id'])
                ->orderBy('created_at', 'DESC')
                ->first();
            $assignment['latest_progress'] = $latestProgress;
        }

        return $this->respond($assignments);
    }

    public function show($id = null)
    {
        $assignment = $this->assignmentModel->find($id);
        if (!$assignment) {
            return $this->failNotFound('Penugasan tidak ditemukan');
        }

        // Enrich with project and progress updates
        $assignment['project'] = $this->projectModel->find($assignment['project_id']);
        $assignment['progress_history'] = $this->progressModel
            ->where('assignment_id', $id)
            ->orderBy('created_at', 'DESC')
            ->findAll();

        return $this->respond($assignment);
    }

    public function create()
    {
        $data = $this->request->getJSON(true) ?? $this->request->getPost();

        if ($this->assignmentModel->insert($data)) {
            $data['id'] = $this->assignmentModel->getInsertID();
            return $this->respondCreated($data, 'Penugasan berhasil dibuat');
        }

        return $this->fail($this->assignmentModel->errors());
    }

    public function update($id = null)
    {
        $data = $this->request->getJSON(true) ?? $this->request->getRawInput();

        if ($this->assignmentModel->update($id, $data)) {
            return $this->respond($data, 200, 'Penugasan berhasil diupdate');
        }

        return $this->fail($this->assignmentModel->errors());
    }

    public function delete($id = null)
    {
        if ($this->assignmentModel->delete($id)) {
            return $this->respondDeleted(['id' => $id], 'Penugasan berhasil dihapus');
        }

        return $this->failNotFound('Penugasan tidak ditemukan');
    }

    /**
     * Submit progress update for assignment
     * POST /api/assignments/{id}/progress
     */
    public function submitProgress($id = null)
    {
        // Verify assignment exists
        $assignment = $this->assignmentModel->find($id);
        if (!$assignment) {
            return $this->failNotFound('Penugasan tidak ditemukan');
        }

        $data = $this->request->getJSON(true) ?? $this->request->getPost();

        // Validate required fields
        if (!isset($data['progress_percentage'])) {
            return $this->fail('progress_percentage harus disediakan', 400);
        }

        // Validate percentage range
        if ($data['progress_percentage'] < 0 || $data['progress_percentage'] > 100) {
            return $this->fail('Progress harus antara 0-100', 400);
        }

        // Add assignment_id
        $data['assignment_id'] = $id;

        // Insert progress update
        if ($this->progressModel->insert($data)) {
            // Update assignment status if progress = 100
            if ($data['progress_percentage'] == 100) {
                $this->assignmentModel->update($id, ['status' => 'completed']);
            } else if ($data['progress_percentage'] > 0) {
                $this->assignmentModel->update($id, ['status' => 'in_progress']);
            }

            return $this->respondCreated(
                ['id' => $this->progressModel->getInsertID(), 'assignment_id' => $id],
                'Progress berhasil diperbarui'
            );
        }

        return $this->fail($this->progressModel->errors());
    }

    /**
     * Get all progress updates for specific assignment
     * GET /api/assignments/{id}/progress
     */
    public function getProgress($id = null)
    {
        $assignment = $this->assignmentModel->find($id);
        if (!$assignment) {
            return $this->failNotFound('Penugasan tidak ditemukan');
        }

        $progressUpdates = $this->progressModel
            ->where('assignment_id', $id)
            ->orderBy('created_at', 'DESC')
            ->findAll();

        return $this->respond($progressUpdates);
    }
}
