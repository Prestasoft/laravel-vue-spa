<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Votante extends Model
{
    use HasFactory;

    protected $connection = 'sqlsrv_db1';
    protected $table = 'votantes';

    public $timestamps = false;

    protected $fillable = [
        'cedula',
        'dirigente_id',
        'colegio_id',
        'mesa',
        'telefono',
        'direccion',
        'observaciones',
        'fecha_registro',
        'activo'
    ];

    protected $casts = [
        'activo' => 'boolean',
        'fecha_registro' => 'datetime',
    ];

    protected $appends = ['padron_data', 'colegio_nombre'];

    public function dirigente()
    {
        return $this->belongsTo(User::class, 'dirigente_id');
    }

    public function gestiones()
    {
        return $this->hasMany(GestionVotante::class, 'votante_id');
    }

    public function getPadronDataAttribute()
    {
        $padron = \DB::connection('sqlsrv_db1')
            ->table('Padron as p')
            ->leftJoin('Nacionalidad as nac', 'p.IdNacionalidad', '=', 'nac.ID')
            ->leftJoin('Sexo as sex', 'p.IdSexo', '=', 'sex.IdSexo')
            ->leftJoin('EstadoCivil as ec', 'p.IdEstadoCivil', '=', 'ec.Id')
            ->where('p.Cedula', $this->cedula)
            ->select([
                'p.Cedula',
                'p.Nombres',
                'p.Apellido1',
                'p.Apellido2',
                'p.FechaNacimiento',
                'p.LugarNacimiento',
                'nac.Descripcion as nacionalidad',
                'sex.Descripcion as sexo',
                'ec.Descripcion as estado_civil',
            ])
            ->first();

        return $padron;
    }

    public function getColegioNombreAttribute()
    {
        if (!$this->colegio_id) return null;

        $colegio = \DB::connection('sqlsrv_db1')
            ->table('Colegio')
            ->where('IDColegio', $this->colegio_id)
            ->value('Descripcion');

        return $colegio;
    }

    public function scopeDelDirigente($query, $dirigenteId)
    {
        return $query->where('dirigente_id', $dirigenteId);
    }

    public function scopeActivos($query)
    {
        return $query->where('activo', true);
    }

    public function scopePorColegio($query, $colegioId)
    {
        return $query->where('colegio_id', $colegioId);
    }

    public function scopePorMesa($query, $mesa)
    {
        return $query->where('mesa', $mesa);
    }
}