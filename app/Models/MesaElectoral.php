<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class MesaElectoral extends Model
{
    use HasFactory;

    protected $connection = 'sqlsrv_db1';
    protected $table = 'mesas_electorales';

    protected $fillable = [
        'codigo',
        'colegio_id',
        'numero_mesa',
        'ubicacion'
    ];

    protected $appends = ['colegio_nombre'];

    public function votantes()
    {
        return $this->hasMany(Votante::class, 'mesa', 'codigo');
    }

    public function getColegioNombreAttribute()
    {
        $colegio = \DB::connection('sqlsrv_db1')
            ->table('Colegio')
            ->where('IDColegio', $this->colegio_id)
            ->value('Descripcion');

        return $colegio;
    }
}