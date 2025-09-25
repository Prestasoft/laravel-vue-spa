<?php

namespace App\Http\Controllers;

use App\Models\Votante;
use App\Models\GestionVotante;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class VotanteController extends Controller
{
    public function index(Request $request)
    {
        $user = auth()->user();
        $query = Votante::with(['gestiones' => function($q) {
            $q->orderBy('fecha', 'desc')->limit(1);
        }, 'dirigente:id,name,email']);

        // Aplicar filtros según el tipo de usuario
        if ($user->isAdmin()) {
            // Admin puede ver todos y filtrar por dirigente específico
            if ($request->has('dirigente_id') && $request->dirigente_id !== '') {
                if ($request->dirigente_id === 'null') {
                    // Mostrar votantes sin dirigente asignado
                    $query->whereNull('dirigente_id');
                } else {
                    $query->delDirigente($request->dirigente_id);
                }
            }
        } elseif ($user->isCandidato()) {
            // Candidatos ven sus propios votantes y los de sus coordinadores
            $coordinadoresIds = User::where('candidato_id', $user->id)
                                 ->where('type', User::TYPE_COORDINADOR)
                                 ->pluck('id')
                                 ->toArray();

            // Incluir también los votantes del candidato mismo
            $coordinadoresIds[] = $user->id;

            $query->whereIn('dirigente_id', $coordinadoresIds);
        } elseif ($user->isCoordinador()) {
            // Coordinadores solo ven sus votantes
            $query->delDirigente($user->id);
        } else {
            // Invitados no ven votantes
            $query->whereRaw('1 = 0');
        }

        if ($request->has('colegio_id')) {
            $query->porColegio($request->colegio_id);
        }

        if ($request->has('mesa')) {
            $query->porMesa($request->mesa);
        }

        if ($request->has('search')) {
            $search = $request->search;
            $query->where(function($q) use ($search) {
                $q->where('cedula', 'LIKE', "%$search%")
                  ->orWhere('telefono', 'LIKE', "%$search%");
            });
        }

        if ($request->has('activo')) {
            $query->where('activo', $request->activo);
        } else {
            $query->activos();
        }

        $orderBy = $request->get('order_by', 'fecha_registro');
        $orderDir = $request->get('order_dir', 'desc');
        $query->orderBy($orderBy, $orderDir);

        $votantes = $query->paginate($request->get('per_page', 20));

        // Limpiar datos para evitar problemas de codificación
        $votantes->getCollection()->transform(function ($votante) {
            // No incluir foto_data automáticamente para evitar problemas de encoding
            return $votante;
        });

        return response()->json($votantes);
    }

    public function store(Request $request)
    {
        $request->validate([
            'cedula' => 'required|string|max:11',
            'colegio_id' => 'nullable|integer',
            'mesa' => 'nullable|string|max:10',
            'telefono' => 'nullable|string|max:20',
            'direccion' => 'nullable|string',
            'latitud' => 'nullable|numeric|between:-90,90',
            'longitud' => 'nullable|numeric|between:-180,180',
            'direccion_gps' => 'nullable|string',
            'observaciones' => 'nullable|string'
        ]);

        $user = auth()->user();

        $existente = Votante::where('cedula', $request->cedula)
            ->where('dirigente_id', $user->id)
            ->first();

        if ($existente) {
            return response()->json([
                'message' => 'Este votante ya está en tu lista'
            ], 422);
        }

        $padron = DB::connection('sqlsrv_db1')
            ->table('Padron')
            ->where('Cedula', $request->cedula)
            ->first();

        if (!$padron) {
            return response()->json([
                'message' => 'Cédula no encontrada en el padrón'
            ], 404);
        }

        $data = [
            'cedula' => $request->cedula,
            'dirigente_id' => $user->id,
            'colegio_id' => $request->colegio_id,
            'mesa' => $request->mesa,
            'telefono' => $request->telefono,
            'direccion' => $request->direccion,
            'observaciones' => $request->observaciones,
            'fecha_registro' => Carbon::now()
        ];

        // Agregar datos GPS si están presentes
        if ($request->latitud && $request->longitud) {
            $data['latitud'] = $request->latitud;
            $data['longitud'] = $request->longitud;
            $data['direccion_gps'] = $request->direccion_gps;
            $data['gps_capturado_en'] = Carbon::now();
        }

        $votante = Votante::create($data);

        return response()->json([
            'message' => 'Votante agregado exitosamente',
            'votante' => $votante->load('gestiones')
        ], 201);
    }

    public function show($id)
    {
        $user = auth()->user();

        $votante = Votante::with('gestiones.dirigente')
            ->when(!$user->isAdmin(), function($q) use ($user) {
                $q->delDirigente($user->id);
            })
            ->findOrFail($id);

        return response()->json($votante);
    }

    public function update(Request $request, $id)
    {
        $request->validate([
            'colegio_id' => 'nullable|integer',
            'mesa' => 'nullable|string|max:10',
            'telefono' => 'nullable|string|max:20',
            'direccion' => 'nullable|string',
            'latitud' => 'nullable|numeric|between:-90,90',
            'longitud' => 'nullable|numeric|between:-180,180',
            'direccion_gps' => 'nullable|string',
            'observaciones' => 'nullable|string',
            'activo' => 'boolean'
        ]);

        $user = auth()->user();

        // Aplicar filtros según el tipo de usuario
        if ($user->isAdmin()) {
            $votante = Votante::findOrFail($id);
        } elseif ($user->isCandidato()) {
            // Candidatos pueden editar votantes suyos y de sus coordinadores
            $coordinadoresIds = User::where('candidato_id', $user->id)
                                 ->where('type', User::TYPE_COORDINADOR)
                                 ->pluck('id')
                                 ->toArray();
            $coordinadoresIds[] = $user->id;

            $votante = Votante::whereIn('dirigente_id', $coordinadoresIds)
                              ->findOrFail($id);
        } elseif ($user->isCoordinador()) {
            $votante = Votante::delDirigente($user->id)->findOrFail($id);
        } else {
            return response()->json(['message' => 'No autorizado'], 403);
        }

        $dataToUpdate = $request->only([
            'colegio_id', 'mesa', 'telefono',
            'direccion', 'observaciones', 'activo'
        ]);

        // Actualizar GPS si se proporcionan coordenadas
        if ($request->has('latitud') && $request->has('longitud')) {
            $dataToUpdate['latitud'] = $request->latitud;
            $dataToUpdate['longitud'] = $request->longitud;
            $dataToUpdate['direccion_gps'] = $request->direccion_gps;
            $dataToUpdate['gps_capturado_en'] = Carbon::now();
        }

        $votante->update($dataToUpdate);

        return response()->json([
            'message' => 'Votante actualizado exitosamente',
            'votante' => $votante
        ]);
    }

    public function destroy($id)
    {
        $user = auth()->user();

        // Aplicar filtros según el tipo de usuario
        if ($user->isAdmin()) {
            $votante = Votante::findOrFail($id);
        } elseif ($user->isCandidato()) {
            // Candidatos pueden eliminar votantes suyos y de sus coordinadores
            $coordinadoresIds = User::where('candidato_id', $user->id)
                                 ->where('type', User::TYPE_COORDINADOR)
                                 ->pluck('id')
                                 ->toArray();
            $coordinadoresIds[] = $user->id;

            $votante = Votante::whereIn('dirigente_id', $coordinadoresIds)
                              ->findOrFail($id);
        } elseif ($user->isCoordinador()) {
            $votante = Votante::delDirigente($user->id)->findOrFail($id);
        } else {
            return response()->json(['message' => 'No autorizado'], 403);
        }

        $votante->delete();

        return response()->json([
            'message' => 'Votante eliminado exitosamente'
        ]);
    }

    public function buscar($cedula)
    {
        $padron = DB::connection('sqlsrv_db1')
            ->table('Padron as p')
            ->leftJoin('Nacionalidad as nac', 'p.IdNacionalidad', '=', 'nac.ID')
            ->leftJoin('Sexo as sex', 'p.IdSexo', '=', 'sex.IdSexo')
            ->leftJoin('EstadoCivil as ec', 'p.IdEstadoCivil', '=', 'ec.Id')
            ->leftJoin('Colegio as co', 'p.IdColegio', '=', 'co.IDColegio')
            ->leftJoin('Municipio as mu', 'p.IdMunicipio', '=', 'mu.ID')
            ->leftJoin('Provincia as pro', 'mu.IDProvincia', '=', 'pro.ID')
            ->where('p.Cedula', $cedula)
            ->select([
                'p.*',
                'nac.Descripcion as nacionalidad',
                'sex.Descripcion as sexo',
                'ec.Descripcion as estado_civil',
                'co.Descripcion as colegio',
                'co.IDColegio as colegio_id',
                'p.CodigoColegio as mesa', // Agregamos el CodigoColegio como mesa
                'mu.Descripcion as municipio',
                'pro.Descripcion as provincia',
            ])
            ->first();

        if (!$padron) {
            return response()->json([
                'message' => 'Cédula no encontrada en el padrón'
            ], 404);
        }

        $user = auth()->user();

        // Verificar si el usuario actual ya tiene este votante
        $yaRegistrado = Votante::where('cedula', $cedula)
            ->where('dirigente_id', $user->id)
            ->exists();

        // Verificar si otro usuario ya tiene este votante registrado
        $registradoPorOtro = Votante::where('cedula', $cedula)
            ->where('dirigente_id', '!=', $user->id)
            ->with('dirigente:id,name,type')
            ->first();

        $responseData = [
            'padron' => $padron,
            'ya_registrado' => $yaRegistrado
        ];

        if ($registradoPorOtro) {
            $tipoUsuario = $registradoPorOtro->dirigente->type == 4 ? 'Candidato' :
                          ($registradoPorOtro->dirigente->type == 3 ? 'Coordinador' : 'Usuario');

            $responseData['registrado_por_otro'] = [
                'existe' => true,
                'usuario' => $registradoPorOtro->dirigente->name,
                'tipo' => $tipoUsuario,
                'fecha_registro' => $registradoPorOtro->fecha_registro
            ];
        } else {
            $responseData['registrado_por_otro'] = ['existe' => false];
        }

        return response()->json($responseData);
    }

    public function estadisticas(Request $request)
    {
        $user = auth()->user();
        $query = Votante::query();

        if (!$user->isAdmin()) {
            $query->delDirigente($user->id);
        }

        $total = $query->count();
        $activos = (clone $query)->activos()->count();

        $porColegio = (clone $query)->activos()
            ->select('colegio_id', DB::raw('count(*) as total'))
            ->groupBy('colegio_id')
            ->get()
            ->map(function($item) {
                $colegio = DB::connection('sqlsrv_db1')
                    ->table('Colegio')
                    ->where('IDColegio', $item->colegio_id)
                    ->value('Descripcion');

                return [
                    'colegio_id' => $item->colegio_id,
                    'colegio' => $colegio,
                    'total' => $item->total
                ];
            });

        $porMesa = (clone $query)->activos()
            ->whereNotNull('mesa')
            ->select('mesa', DB::raw('count(*) as total'))
            ->groupBy('mesa')
            ->get();

        $ultimosDias = (clone $query)
            ->where('fecha_registro', '>=', Carbon::now()->subDays(30))
            ->select(DB::raw('CAST(fecha_registro AS DATE) as fecha'), DB::raw('count(*) as total'))
            ->groupBy(DB::raw('CAST(fecha_registro AS DATE)'))
            ->orderBy('fecha')
            ->get();

        return response()->json([
            'total' => $total,
            'activos' => $activos,
            'inactivos' => $total - $activos,
            'por_colegio' => $porColegio,
            'por_mesa' => $porMesa,
            'ultimos_30_dias' => $ultimosDias
        ]);
    }

    public function dirigentes()
    {
        $user = auth()->user();

        if ($user->isAdmin()) {
            // Admin ve todos los coordinadores
            $coordinadores = User::where('type', User::TYPE_COORDINADOR)
                ->withCount('votantes')
                ->select('id', 'name', 'email')
                ->orderBy('name')
                ->get();
        } elseif ($user->isCandidato()) {
            // Candidato ve solo sus coordinadores
            $coordinadores = User::where('type', User::TYPE_COORDINADOR)
                ->where('candidato_id', $user->id)
                ->withCount('votantes')
                ->select('id', 'name', 'email')
                ->orderBy('name')
                ->get();
        } else {
            return response()->json(['message' => 'No autorizado'], 403);
        }

        return response()->json($coordinadores);
    }

    public function obtenerFoto($cedula)
    {
        try {
            $foto = DB::connection('sqlsrv_db2')
                ->table('FOTOS_PRM_PRM')
                ->where('Cedula', $cedula)
                ->select('Imagen')
                ->first();

            if ($foto && $foto->Imagen) {
                // Asegurar que la imagen esté correctamente codificada
                $imagenBase64 = base64_encode($foto->Imagen);

                return response()->json([
                    'success' => true,
                    'imagen' => $imagenBase64
                ]);
            }

            return response()->json([
                'success' => false,
                'message' => 'Foto no encontrada'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error al obtener foto'
            ]);
        }
    }

    public function agregarGestion(Request $request, $id)
    {
        $request->validate([
            'tipo_gestion' => 'required|string|in:llamada,visita,mensaje,otro',
            'nota' => 'nullable|string'
        ]);

        $user = auth()->user();

        $votante = Votante::when(!$user->isAdmin(), function($q) use ($user) {
            $q->delDirigente($user->id);
        })->findOrFail($id);

        $gestion = GestionVotante::create([
            'votante_id' => $votante->id,
            'dirigente_id' => $user->id,
            'tipo_gestion' => $request->tipo_gestion,
            'nota' => $request->nota,
            'fecha' => Carbon::now()
        ]);

        return response()->json([
            'message' => 'Gestión agregada exitosamente',
            'gestion' => $gestion
        ], 201);
    }

    public function obtenerParaMapa(Request $request)
    {
        $user = auth()->user();
        $query = Votante::with('dirigente:id,name,type')
            ->whereNotNull('latitud')
            ->whereNotNull('longitud');

        // Aplicar filtros según el tipo de usuario
        if ($user->isAdmin()) {
            // Admin puede ver todos y filtrar por dirigente específico
            if ($request->has('dirigente_id') && $request->dirigente_id !== '') {
                $query->where('dirigente_id', $request->dirigente_id);
            }
        } elseif ($user->isCandidato()) {
            // Candidatos ven sus propios votantes y los de sus coordinadores
            $coordinadoresIds = User::where('candidato_id', $user->id)
                                 ->where('type', User::TYPE_COORDINADOR)
                                 ->pluck('id')
                                 ->toArray();

            // Incluir también los votantes del candidato mismo
            $coordinadoresIds[] = $user->id;

            $query->whereIn('dirigente_id', $coordinadoresIds);

            // Permitir filtro por coordinador específico
            if ($request->has('dirigente_id') && $request->dirigente_id !== '') {
                $query->where('dirigente_id', $request->dirigente_id);
            }
        } elseif ($user->isCoordinador()) {
            // Coordinadores solo ven sus votantes
            $query->where('dirigente_id', $user->id);
        } else {
            // Invitados no ven votantes
            $query->whereRaw('1 = 0');
        }

        // Filtros adicionales
        if ($request->has('colegio_id') && $request->colegio_id !== '') {
            $query->where('colegio_id', $request->colegio_id);
        }

        $query->activos();

        $votantes = $query->get();

        // Preparar datos para el mapa
        $votantesData = $votantes->map(function($votante) {
            $padron = $votante->padron_data;

            // Obtener foto
            $foto = null;
            try {
                $fotoData = DB::connection('sqlsrv_db2')
                    ->table('FOTOS_PRM_PRM')
                    ->where('Cedula', $votante->cedula)
                    ->select('Imagen')
                    ->first();

                if ($fotoData && $fotoData->Imagen) {
                    $foto = base64_encode($fotoData->Imagen);
                }
            } catch (\Exception $e) {
                // Silenciar error
            }

            return [
                'id' => $votante->id,
                'cedula' => $votante->cedula,
                'nombre_completo' => $padron ? trim("{$padron->nombres} {$padron->apellido1} {$padron->apellido2}") : 'Sin nombre',
                'telefono' => $votante->telefono,
                'latitud' => $votante->latitud,
                'longitud' => $votante->longitud,
                'direccion' => $votante->direccion,
                'direccion_gps' => $votante->direccion_gps,
                'colegio_id' => $votante->colegio_id,
                'colegio_nombre' => $votante->colegio_nombre,
                'mesa' => $votante->mesa,
                'observaciones' => $votante->observaciones,
                'fecha_registro' => $votante->fecha_registro,
                'gps_capturado_en' => $votante->gps_capturado_en,
                'dirigente_id' => $votante->dirigente_id,
                'dirigente_nombre' => $votante->dirigente ? $votante->dirigente->name : 'Sin asignar',
                'dirigente_tipo' => $votante->dirigente ? $votante->dirigente->type : null,
                'foto_base64' => $foto
            ];
        });

        // Contar totales
        $totalQuery = Votante::query();

        if ($user->isAdmin()) {
            // Admin ve todos
        } elseif ($user->isCandidato()) {
            $coordinadoresIds = User::where('candidato_id', $user->id)
                                 ->where('type', User::TYPE_COORDINADOR)
                                 ->pluck('id')
                                 ->toArray();
            $coordinadoresIds[] = $user->id;
            $totalQuery->whereIn('dirigente_id', $coordinadoresIds);
        } elseif ($user->isCoordinador()) {
            $totalQuery->where('dirigente_id', $user->id);
        }

        $totalVotantes = $totalQuery->activos()->count();
        $conGps = $totalQuery->whereNotNull('latitud')->whereNotNull('longitud')->count();

        return response()->json([
            'votantes' => $votantesData,
            'total' => $totalVotantes,
            'con_gps' => $conGps
        ]);
    }

    public function exportar(Request $request)
    {
        $user = auth()->user();
        $formato = $request->get('formato', 'excel');

        $votantes = Votante::with('gestiones')
            ->when(!$user->isAdmin(), function($q) use ($user) {
                $q->delDirigente($user->id);
            })
            ->activos()
            ->get();

        if ($formato === 'json') {
            return response()->json($votantes);
        }

        $csv = "Cédula,Nombres,Apellidos,Teléfono,Colegio,Mesa,Dirección,Observaciones\n";

        foreach ($votantes as $votante) {
            $padron = $votante->padron_data;
            $csv .= sprintf(
                "%s,%s,%s,%s,%s,%s,%s,%s\n",
                $votante->cedula,
                $padron->nombres ?? '',
                ($padron->apellido1 ?? '') . ' ' . ($padron->apellido2 ?? ''),
                $votante->telefono ?? '',
                $votante->colegio_nombre ?? '',
                $votante->mesa ?? '',
                $votante->direccion ?? '',
                $votante->observaciones ?? ''
            );
        }

        return response($csv, 200, [
            'Content-Type' => 'text/csv',
            'Content-Disposition' => 'attachment; filename="votantes.csv"'
        ]);
    }
}