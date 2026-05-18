<?php

namespace App\Database\Migrations;

use CodeIgniter\Database\Migration;

class AddTimelineToProjects extends Migration
{
    public function up()
    {
        $this->forge->addColumn('projects', [
            'timeline' => [
                'type' => 'JSON',
                'null' => true,
                'after' => 'progress'
            ],
        ]);
    }

    public function down()
    {
        $this->forge->dropColumn('projects', 'timeline');
    }
}
