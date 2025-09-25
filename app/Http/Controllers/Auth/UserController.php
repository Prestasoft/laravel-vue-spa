<?php

namespace App\Http\Controllers\Auth;

use App\Models\User;
use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\Rule;

class UserController extends Controller
{
    /**
     * Get authenticated user.
     */
    public function current(Request $request)
    {
        return response()->json($request->user());
    }

    public function index(Request $request)
    {
        try {
            $authUser = auth()->user();
            $perPage = $request->input('per_page', 10);
            $search = $request->input('search');

            $query = User::query();

            // Los candidatos solo ven sus propios coordinadores
            if ($authUser->isCandidato()) {
                $query->where('candidato_id', $authUser->id)
                      ->where('type', User::TYPE_COORDINADOR);
            }

            $users = $query->when($search, function ($query) use ($search) {
                return $query->where('name', 'like', "%$search%")
                            ->orWhere('email', 'like', "%$search%");
            })
            ->withCount('votantes')
            ->orderBy('created_at', 'desc')
            ->paginate($perPage);

            return response()->json($users);
        } catch (\Exception $e) {
            \Log::error('Error fetching users: ' . $e->getMessage());
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }

    public function store(Request $request)
    {
        $authUser = auth()->user();

        // Los candidatos solo pueden crear coordinadores
        if ($authUser->isCandidato() && $request->type != 3) {
            return response()->json(['error' => 'Los candidatos solo pueden crear coordinadores'], 403);
        }

        $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'cedula' => 'nullable|string|max:11|unique:users',
            'password' => 'required|string|min:8|confirmed',
            'type' => 'required|in:1,2,3,4',
        ]);

        $userData = [
            'name' => $request->name,
            'email' => $request->email,
            'cedula' => $request->cedula,
            'password' => Hash::make($request->password),
            'type' => $request->type,
        ];

        // Si es un candidato creando un coordinador, asignar el candidato_id
        if ($authUser->isCandidato() && $request->type == 3) {
            $userData['candidato_id'] = $authUser->id;
        }

        $user = User::create($userData);

        return response()->json($user, 201);
    }

    public function show(User $user)
    {
        return response()->json($user);
    }

    public function update(Request $request, User $user)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'email' => [
                'required',
                'string',
                'email',
                'max:255',
                Rule::unique('users')->ignore($user->id),
            ],
            'type' => 'required|in:1,2,3,4',
        ]);

        $user->update([
            'name' => $request->name,
            'email' => $request->email,
            'type' => $request->type,
        ]);

        return response()->json($user);
    }

    public function destroy(User $user)
    {
        $user->delete();
        return response()->json(null, 204);
    }

    public function changePassword(Request $request, User $user)
    {
        $request->validate([
            'password' => 'required|string|min:8|confirmed',
        ]);

        $user->update([
            'password' => Hash::make($request->password),
        ]);

        return response()->json(['message' => 'Password changed successfully']);
    }

    /**
     * Actualizar permisos de usuario
     */
    public function updatePermissions(Request $request, User $user)
    {
        $request->validate([
            'permissions' => 'required|array',
            'permissions.can_view_votantes' => 'boolean',
            'permissions.can_add_votantes' => 'boolean',
            'permissions.can_edit_votantes' => 'boolean',
            'permissions.can_delete_votantes' => 'boolean',
            'permissions.can_view_users' => 'boolean',
            'permissions.can_add_users' => 'boolean',
            'permissions.can_edit_users' => 'boolean',
            'permissions.can_delete_users' => 'boolean',
            'permissions.can_view_reports' => 'boolean',
            'permissions.can_export_data' => 'boolean',
            'permissions.can_view_all_votantes' => 'boolean',
            'permissions.can_manage_coordinadores' => 'boolean',
        ]);

        // Solo administradores pueden cambiar permisos
        if (!auth()->user()->isAdmin()) {
            return response()->json(['error' => 'No autorizado'], 403);
        }

        $user->update($request->permissions);

        return response()->json([
            'message' => 'Permisos actualizados exitosamente',
            'user' => $user
        ]);
    }

    /**
     * Buscar datos del padrón por cédula
     */
    public function searchByCedula(Request $request)
    {
        try {
            $request->validate([
                'cedula' => 'required|string|max:11'
            ]);

            // Verificar si ya existe un usuario con esta cédula
            $existingUser = User::where('cedula', $request->cedula)->first();
            if ($existingUser) {
                return response()->json([
                    'error' => 'Ya existe un usuario con esta cédula',
                    'user' => $existingUser
                ], 422);
            }

            // Buscar en el padrón usando DB connection explícito
            $padron = \DB::connection('sqlsrv_db1')
                ->table('Padron')
                ->where('Cedula', $request->cedula)
                ->first();

            if (!$padron) {
                return response()->json(['error' => 'Cédula no encontrada en el padrón'], 404);
            }

            // Buscar foto
            $foto = null;
            try {
                $foto = \DB::connection('sqlsrv_db2')
                    ->table('FOTOS_PRM_PRM')
                    ->where('Cedula', $request->cedula)
                    ->first();
            } catch (\Exception $e) {
                // Si hay error con la foto, continuar sin ella
                \Log::warning('Error al buscar foto para cédula ' . $request->cedula . ': ' . $e->getMessage());
            }

            $nombreCompleto = trim(
                ($padron->Nombres ?? $padron->nombres ?? '') . ' ' .
                ($padron->Apellido1 ?? $padron->apellido1 ?? '') . ' ' .
                ($padron->Apellido2 ?? $padron->apellido2 ?? '')
            );

            return response()->json([
                'padron' => [
                    'cedula' => $padron->Cedula,
                    'nombres' => $padron->Nombres ?? $padron->nombres ?? '',
                    'apellido1' => $padron->Apellido1 ?? $padron->apellido1 ?? '',
                    'apellido2' => $padron->Apellido2 ?? $padron->apellido2 ?? '',
                    'nombre_completo' => $nombreCompleto,
                    'sexo' => $padron->Sexo ?? $padron->sexo ?? '',
                    'fecha_nacimiento' => $padron->FechaNacimiento ?? null
                ],
                'has_photo' => !is_null($foto)
            ]);
        } catch (\Exception $e) {
            \Log::error('Error en searchByCedula: ' . $e->getMessage());
            \Log::error('Stack trace: ' . $e->getTraceAsString());
            return response()->json([
                'error' => 'Error al buscar la cédula: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Obtener foto del usuario
     */
    public function getPhoto(User $user)
    {
        if (!$user->cedula) {
            return response()->json(['error' => 'Usuario sin cédula'], 404);
        }

        $fotoData = $user->getFotoFromPadron();

        if (!$fotoData) {
            // Retornar imagen por defecto
            return redirect($user->getPhotoUrlAttribute());
        }

        // Decodificar y retornar la imagen
        $imageData = base64_decode($fotoData);
        return response($imageData, 200)
            ->header('Content-Type', 'image/jpeg')
            ->header('Cache-Control', 'public, max-age=3600');
    }

    /**
     * Obtener foto temporal por cédula (para preview antes de guardar)
     */
    public function getPhotoTemp($cedula)
    {
        try {
            $foto = \DB::connection('sqlsrv_db2')
                ->table('FOTOS_PRM_PRM')
                ->where('Cedula', $cedula)
                ->first();

            if (!$foto || !$foto->Imagen) {
                // Retornar imagen por defecto
                $defaultImage = 'https://ui-avatars.com/api/?name=User&size=200';
                return redirect($defaultImage);
            }

            // La imagen ya está en base64 en la DB, necesitamos procesarla correctamente
            // Verificar si es binario o ya está en base64
            $imageData = $foto->Imagen;

            // Si los datos parecen ser base64, decodificar
            if (is_string($imageData)) {
                // Intentar decodificar si parece ser base64
                $decoded = @base64_decode($imageData, true);
                if ($decoded !== false) {
                    $imageData = $decoded;
                }
            }

            // Si imageData es binario raw, usarlo directamente
            // Si no, intentar una vez más la decodificación
            if (!$imageData) {
                $defaultImage = 'https://ui-avatars.com/api/?name=User&size=200';
                return redirect($defaultImage);
            }

            return response($imageData, 200)
                ->header('Content-Type', 'image/jpeg')
                ->header('Cache-Control', 'public, max-age=3600');
        } catch (\Exception $e) {
            \Log::error('Error getting temp photo for cedula ' . $cedula . ': ' . $e->getMessage());
            $defaultImage = 'https://ui-avatars.com/api/?name=User&size=200';
            return redirect($defaultImage);
        }
    }
}
