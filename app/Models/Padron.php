<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Padron extends Model
{
    protected $connection = 'sqlsrv_db1';
    protected $table = 'Padron';
}