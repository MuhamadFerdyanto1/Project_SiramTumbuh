<?php

namespace App\Controllers\Api;

use CodeIgniter\RESTful\ResourceController;
use App\Models\AttendanceModel;

class Attendance extends ResourceController
{
    protected $format = 'json';

    public function __construct()
    {
        $this->attendanceModel = new AttendanceModel();
    }

    public function index()
    {
        // Get attendance history for worker
        $workerId = $this->request->getHeaderLine('X-Worker-ID');
        
        if (!$workerId) {
            return $this->fail('Worker ID harus disediakan di header X-Worker-ID', 400);
        }

        // Get last 30 days of attendance
        $thirtyDaysAgo = date('Y-m-d', strtotime('-30 days'));
        $attendance = $this->attendanceModel
            ->where('worker_id', $workerId)
            ->where('DATE(clock_in_time) >=', $thirtyDaysAgo)
            ->orderBy('clock_in_time', 'DESC')
            ->findAll();

        return $this->respond($attendance);
    }

    /**
     * Clock-in: Record arrival time, location, and photo
     * POST /api/attendance/clock-in
     */
    public function clockIn()
    {
        $request = $this->request->getJSON(true) ?? $this->request->getPost();

        // Validate required fields
        if (!isset($request['worker_id'])) {
            return $this->fail('worker_id harus disediakan', 400);
        }

        if (!isset($request['clock_in_location'])) {
            return $this->fail('Lokasi GPS harus disediakan', 400);
        }

        // Prepare data
        $data = [
            'worker_id'         => $request['worker_id'],
            'clock_in_time'     => date('Y-m-d H:i:s'),
            'clock_in_location' => $request['clock_in_location'], // Already JSON
            'clock_in_photo'    => $request['clock_in_photo'] ?? null,
            'status'            => 'clock_in'
        ];

        // Check if already clocked in today (not yet clocked out)
        $today = date('Y-m-d');
        $alreadyClocked = $this->attendanceModel
            ->where('worker_id', $request['worker_id'])
            ->where("DATE(clock_in_time) = '$today'")
            ->where('status', 'clock_in')
            ->first();

        if ($alreadyClocked) {
            return $this->fail('Anda sudah melakukan clock-in hari ini. Silakan clock-out terlebih dahulu.', 400);
        }

        if ($this->attendanceModel->insert($data)) {
            return $this->respondCreated(
                ['id' => $this->attendanceModel->getInsertID()],
                'Clock-in berhasil'
            );
        }

        return $this->fail($this->attendanceModel->errors());
    }

    /**
     * Clock-out: Record departure time, location, and photo
     * POST /api/attendance/clock-out
     */
    public function clockOut()
    {
        $request = $this->request->getJSON(true) ?? $this->request->getPost();

        // Validate required fields
        if (!isset($request['worker_id'])) {
            return $this->fail('worker_id harus disediakan', 400);
        }

        if (!isset($request['clock_out_location'])) {
            return $this->fail('Lokasi GPS harus disediakan', 400);
        }

        $today = date('Y-m-d');
        
        // Find today's clock-in record (not yet clocked out)
        $clockInRecord = $this->attendanceModel
            ->where('worker_id', $request['worker_id'])
            ->where("DATE(clock_in_time) = '$today'")
            ->where('status', 'clock_in')
            ->first();

        if (!$clockInRecord) {
            return $this->fail('Tidak ada clock-in untuk hari ini. Lakukan clock-in terlebih dahulu.', 400);
        }

        // Update record with clock-out data
        $updateData = [
            'clock_out_time'     => date('Y-m-d H:i:s'),
            'clock_out_location' => $request['clock_out_location'],
            'clock_out_photo'    => $request['clock_out_photo'] ?? null,
            'status'             => 'clocked_out'
        ];

        if ($this->attendanceModel->update($clockInRecord['id'], $updateData)) {
            return $this->respond(
                ['id' => $clockInRecord['id']],
                200,
                'Clock-out berhasil'
            );
        }

        return $this->fail($this->attendanceModel->errors());
    }

    /**
     * Get today's attendance status (current clock-in/out state)
     * GET /api/attendance/today
     */
    public function getToday()
    {
        $workerId = $this->request->getHeaderLine('X-Worker-ID');
        
        if (!$workerId) {
            return $this->fail('Worker ID harus disediakan di header X-Worker-ID', 400);
        }

        $today = date('Y-m-d');
        $todayAttendance = $this->attendanceModel
            ->where('worker_id', $workerId)
            ->where("DATE(clock_in_time) = '$today'")
            ->first();

        if (!$todayAttendance) {
            return $this->respond(null, 200, 'Belum ada attendance untuk hari ini');
        }

        return $this->respond($todayAttendance);
    }
}
