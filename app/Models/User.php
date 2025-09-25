<?php

namespace App\Models;

use App\Notifications\ResetPassword;
use App\Notifications\VerifyEmail;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
// use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Notifications\Notifiable;
use Tymon\JWTAuth\Contracts\JWTSubject;

class User extends Authenticatable implements JWTSubject //, MustVerifyEmail
{
    use Notifiable,
        HasFactory;

    protected $connection = 'sqlsrv_db1';
    protected $table = 'users';

    /**
     * The attributes that are mass assignable.
     *
     * @var array
     */
    protected $fillable = [
        'name', 'email', 'cedula', 'password', 'type', 'candidato_id',
        'can_view_votantes', 'can_add_votantes', 'can_edit_votantes', 'can_delete_votantes',
        'can_view_users', 'can_add_users', 'can_edit_users', 'can_delete_users',
        'can_view_reports', 'can_export_data', 'can_view_all_votantes', 'can_manage_coordinadores'
    ];

    /**
     * The attributes that should be hidden for arrays.
     *
     * @var array
     */
    protected $hidden = [
        'password',
        'remember_token',
    ];

    /**
     * The attributes that should be cast to native types.
     *
     * @var array
     */
    protected $casts = [
        'email_verified_at' => 'datetime',
        'can_view_votantes' => 'boolean',
        'can_add_votantes' => 'boolean',
        'can_edit_votantes' => 'boolean',
        'can_delete_votantes' => 'boolean',
        'can_view_users' => 'boolean',
        'can_add_users' => 'boolean',
        'can_edit_users' => 'boolean',
        'can_delete_users' => 'boolean',
        'can_view_reports' => 'boolean',
        'can_export_data' => 'boolean',
        'can_view_all_votantes' => 'boolean',
        'can_manage_coordinadores' => 'boolean',
    ];

    /**
     * The accessors to append to the model's array form.
     *
     * @var array
     */
    protected $appends = [
        'photo_url',
    ];

    const TYPE_ADMIN = 1;
    const TYPE_GUEST = 2;
    const TYPE_COORDINADOR = 3;
    const TYPE_CANDIDATO = 4;

    public function isAdmin()
    {
        return $this->type == self::TYPE_ADMIN || $this->type == '1';
    }

    public function isCoordinador()
    {
        return $this->type == self::TYPE_COORDINADOR || $this->type == '3';
    }

    // Mantener método legacy para compatibilidad
    public function isDirigente()
    {
        return $this->isCoordinador();
    }

    public function isGuest()
    {
        return $this->type == self::TYPE_GUEST || $this->type == '2';
    }

    public function isCandidato()
    {
        return $this->type == self::TYPE_CANDIDATO || $this->type == '4';
    }

    public function getTypeNameAttribute()
    {
        switch($this->type) {
            case self::TYPE_ADMIN:
                return 'Administrador';
            case self::TYPE_COORDINADOR:
                return 'Coordinador';
            case self::TYPE_GUEST:
                return 'Invitado';
            case self::TYPE_CANDIDATO:
                return 'Candidato';
            default:
                return 'Usuario';
        }
    }

    /**
     * Get the profile photo URL attribute.
     *
     * @return string
     */
    public function getPhotoUrlAttribute()
    {
        // Si tiene cédula, usar foto del padrón
        if ($this->cedula) {
            return '/api/users/photo/' . $this->id;
        }

        return vsprintf('https://www.gravatar.com/avatar/%s.jpg?s=200&d=%s', [
            md5(strtolower($this->email)),
            $this->name ? urlencode("https://ui-avatars.com/api/$this->name") : 'mp',
        ]);
    }

    /**
     * Obtener foto desde el padrón
     */
    public function getFotoFromPadron()
    {
        if (!$this->cedula) return null;

        $foto = \DB::connection('sqlsrv_db2')
            ->table('FOTOS_PRM_PRM')
            ->where('Cedula', $this->cedula)
            ->first();

        return $foto ? $foto->Imagen : null;
    }

    /**
     * Get the oauth providers.
     *
     * @return \Illuminate\Database\Eloquent\Relations\HasMany
     */
    public function oauthProviders()
    {
        return $this->hasMany(OAuthProvider::class);
    }

    /**
     * Get the votantes for the dirigente.
     *
     * @return \Illuminate\Database\Eloquent\Relations\HasMany
     */
    public function votantes()
    {
        return $this->hasMany(Votante::class, 'dirigente_id');
    }

    /**
     * Relación con coordinadores (para candidatos)
     */
    public function coordinadores()
    {
        return $this->hasMany(User::class, 'candidato_id')
            ->where('type', self::TYPE_COORDINADOR);
    }

    // Mantener método legacy para compatibilidad
    public function dirigentes()
    {
        return $this->coordinadores();
    }

    /**
     * Relación con candidato (para coordinadores)
     */
    public function candidato()
    {
        return $this->belongsTo(User::class, 'candidato_id')
            ->where('type', self::TYPE_CANDIDATO);
    }

    /**
     * Send the password reset notification.
     *
     * @param  string  $token
     * @return void
     */
    public function sendPasswordResetNotification($token)
    {
        $this->notify(new ResetPassword($token));
    }

    /**
     * Send the email verification notification.
     *
     * @return void
     */
    public function sendEmailVerificationNotification()
    {
        $this->notify(new VerifyEmail);
    }

    /**
     * @return int
     */
    public function getJWTIdentifier()
    {
        return $this->getKey();
    }

    /**
     * @return array
     */
    public function getJWTCustomClaims()
    {
        return [];
    }
}
