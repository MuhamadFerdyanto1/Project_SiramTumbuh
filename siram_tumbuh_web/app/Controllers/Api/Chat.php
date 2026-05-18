<?php

namespace App\Controllers\Api;

use App\Controllers\BaseController;
use App\Models\MessageModel;
use CodeIgniter\API\ResponseTrait;

class Chat extends BaseController
{
    use ResponseTrait;

    public function index()
    {
        $model = new MessageModel();
        $projectId = $this->request->getVar('project_id');
        $customerName = $this->request->getVar('customer_name');
        
        if ($projectId) {
            $model->where('project_id', $projectId);
        }
        
        if ($customerName) {
            $model->where('customer_name', $customerName);
        }
        
        $messages = $model->orderBy('id', 'ASC')->findAll();

        return $this->respond($messages);
    }

    public function send()
    {
        $model = new MessageModel();
        
        $data = [
            'project_id'    => $this->request->getVar('project_id'),
            'customer_name' => $this->request->getVar('customer_name'),
            'sender_role'   => $this->request->getVar('sender_role'),
            'message'       => $this->request->getVar('message'),
            'is_read'       => $this->request->getVar('sender_role') === 'admin' ? 1 : 0,
        ];

        if ($model->insert($data)) {
            return $this->respondCreated(['status' => 'success', 'message' => 'Message sent']);
        }

        return $this->fail('Failed to send message');
    }

    public function unreadCount()
    {
        $model = new MessageModel();
        return $this->respond(['count' => $model->getUnreadCount()]);
    }

    public function markAsRead()
    {
        $model = new MessageModel();
        $projectId = $this->request->getVar('project_id');
        $customerName = $this->request->getVar('customer_name');
        
        if ($projectId) {
            $model->where('project_id', $projectId);
        }
        
        if ($customerName) {
            $model->where('customer_name', $customerName);
        }
        
        $model->where('sender_role', 'customer')
              ->set(['is_read' => 1])
              ->update();

        return $this->respond(['status' => 'success']);
    }
}
