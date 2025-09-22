<?php
// Archivo de prueba para verificar la configuración de la API

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// Simular respuesta de login para pruebas
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $input = json_decode(file_get_contents('php://input'), true);

    // Usuario de prueba
    if ($input['email'] === 'admin@test.com' && $input['password'] === 'password') {
        echo json_encode([
            'access_token' => 'test_token_' . uniqid(),
            'user' => [
                'id' => 1,
                'name' => 'Admin Test',
                'email' => 'admin@test.com',
                'type' => 1
            ]
        ]);
    } else {
        http_response_code(401);
        echo json_encode(['message' => 'Credenciales incorrectas']);
    }
} else {
    echo json_encode([
        'status' => 'API Test Working',
        'method' => $_SERVER['REQUEST_METHOD'],
        'time' => date('Y-m-d H:i:s')
    ]);
}
?>