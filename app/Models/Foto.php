<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Foto extends Model
{
    use HasFactory;

    protected $connection = 'sqlsrv_db2';
    protected $table = 'FOTOS_PRM_PRM';
}