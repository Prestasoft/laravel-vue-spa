<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ColegioController extends Controller
{
    public function index()
    {
        $colegios = DB::connection('sqlsrv_db1')
            ->table('Colegio')
            ->select('IDColegio as id', 'Descripcion as nombre', 'Direccion as direccion')
            ->orderBy('Descripcion')
            ->get();

        return response()->json($colegios);
    }

    public function mesas($colegioId)
    {
        $mesas = DB::connection('sqlsrv_db1')
            ->table('mesas_electorales')
            ->where('colegio_id', $colegioId)
            ->orderBy('numero_mesa')
            ->get();

        return response()->json($mesas);
    }
}