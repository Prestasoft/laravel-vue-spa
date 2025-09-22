<?php

use App\Http\Controllers\Auth\ForgotPasswordController;
use App\Http\Controllers\Auth\LoginController;
use App\Http\Controllers\Auth\OAuthController;
use App\Http\Controllers\Auth\RegisterController;
use App\Http\Controllers\Auth\ResetPasswordController;
use App\Http\Controllers\Auth\UserController;
use App\Http\Controllers\Auth\VerificationController;
use App\Http\Controllers\Settings\PasswordController;
use App\Http\Controllers\Settings\ProfileController;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\PadronController;
use App\Http\Controllers\LogController;
use App\Http\Controllers\VotanteController;
use App\Http\Controllers\ColegioController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| is assigned the "api" middleware group. Enjoy building your API!
|
*/

Route::group(['middleware' => 'auth:api'], function () {
    Route::post('logout', [LoginController::class, 'logout']);

    Route::get('user', [UserController::class, 'current']);

    Route::patch('settings/profile', [ProfileController::class, 'update']);
    Route::patch('settings/password', [PasswordController::class, 'update']);
    Route::get('/search', [PadronController::class, 'search']);

    Route::get('users', [UserController::class, 'index']);
    Route::post('users', [UserController::class, 'store']);
    Route::get('users/{user}', [UserController::class, 'show']);
    Route::put('users/{user}', [UserController::class, 'update']);
    Route::delete('users/{user}', [UserController::class, 'destroy']);
    Route::post('users/{user}/change-password', [UserController::class, 'changePassword']);

    Route::get('search-logs', [LogController::class, 'index']);

    // Votantes routes
    Route::get('votantes', [VotanteController::class, 'index']);
    Route::post('votantes', [VotanteController::class, 'store']);
    Route::get('votantes/buscar/{cedula}', [VotanteController::class, 'buscar']);
    Route::get('votantes/estadisticas', [VotanteController::class, 'estadisticas']);
    Route::get('votantes/exportar', [VotanteController::class, 'exportar']);
    Route::get('votantes/{id}', [VotanteController::class, 'show']);
    Route::put('votantes/{id}', [VotanteController::class, 'update']);
    Route::delete('votantes/{id}', [VotanteController::class, 'destroy']);
    Route::post('votantes/{id}/gestiones', [VotanteController::class, 'agregarGestion']);

    // Colegios routes
    Route::get('colegios', [ColegioController::class, 'index']);
    Route::get('colegios/{id}/mesas', [ColegioController::class, 'mesas']);
});

Route::group(['middleware' => 'guest:api'], function () {
    Route::post('login', [LoginController::class, 'login']);
    Route::post('register', [RegisterController::class, 'register']);

    Route::post('password/email', [ForgotPasswordController::class, 'sendResetLinkEmail']);
    Route::post('password/reset', [ResetPasswordController::class, 'reset']);

    Route::post('email/verify/{user}', [VerificationController::class, 'verify'])->name('verification.verify');
    Route::post('email/resend', [VerificationController::class, 'resend']);

    Route::post('oauth/{driver}', [OAuthController::class, 'redirect']);
    Route::get('oauth/{driver}/callback', [OAuthController::class, 'handleCallback'])->name('oauth.callback');

    Route::post('/dni/image', [PadronController::class, 'dniPhoto']);
    Route::post('/search/cedula', [PadronController::class, 'search']);
});
