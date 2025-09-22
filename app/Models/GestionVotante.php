<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class GestionVotante extends Model
{
    use HasFactory;

    protected $connection = 'sqlsrv_db1';
    protected $table = 'gestiones_votantes';

    public $timestamps = false;

    protected $fillable = [
        'votante_id',
        'dirigente_id',
        'tipo_gestion',
        'nota',
        'fecha'
    ];

    protected $casts = [
        'fecha' => 'datetime',
    ];

    public function votante()
    {
        return $this->belongsTo(Votante::class, 'votante_id');
    }

    public function dirigente()
    {
        return $this->belongsTo(User::class, 'dirigente_id');
    }
}