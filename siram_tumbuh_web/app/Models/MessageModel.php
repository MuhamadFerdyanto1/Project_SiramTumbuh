<?php

namespace App\Models;

use CodeIgniter\Model;

class MessageModel extends Model
{
    protected $table            = 'messages';
    protected $primaryKey       = 'id';
    protected $useAutoIncrement = true;
    protected $returnType       = 'array';
    protected $useSoftDeletes   = false;
    protected $protectFields    = true;
    protected $allowedFields    = [
        'project_id', 
        'customer_name', 
        'sender_role', 
        'message', 
        'is_read'
    ];

    protected $useTimestamps = true;
    protected $createdField  = 'created_at';
    protected $updatedField  = 'updated_at';

    public function getUnreadCount()
    {
        return $this->where('is_read', 0)
                    ->where('sender_role', 'customer')
                    ->countAllResults();
    }
}
