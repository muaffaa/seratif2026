<?php
// backend/index.php – Simple URL router

declare(strict_types=1);

ini_set('display_errors', '0');
error_reporting(E_ALL);

$uri    = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$method = $_SERVER['REQUEST_METHOD'];

// Determine allowed origin
$allowed_origins = [
    'http://localhost:5173',
    'http://localhost:3000',
    'http://localhost:8000',
    'http://localhost:8080',
    getenv('APP_URL') ?: 'https://seratif2026-production.up.railway.app',
];

$origin = $_SERVER['HTTP_ORIGIN'] ?? '';
$allowed_origin = in_array($origin, $allowed_origins, true) ? $origin : $allowed_origins[4];

// CORS headers
header('Access-Control-Allow-Origin: ' . $allowed_origin);
header('Access-Control-Allow-Credentials: true');
header('Access-Control-Allow-Headers: Content-Type');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');

// CORS preflight
if ($method === 'OPTIONS') {
    http_response_code(204);
    exit;
}

// Static file serving for uploads
if ($method === 'GET' && preg_match('#^/uploads/payments/[a-f0-9\-\.]+\.(jpg|jpeg|png|gif|webp)$#i', $uri)) {
    $projectRoot = realpath(__DIR__ . '/..');
    $requested = $projectRoot ? realpath($projectRoot . $uri) : false;
    $uploadsRoot = $projectRoot . '/uploads/payments/';
    if ($requested && str_starts_with($requested, $uploadsRoot) && is_file($requested)) {
        $file_path = $requested;
        $ext = strtolower(pathinfo($file_path, PATHINFO_EXTENSION));
        $mime_types = [
            'jpg'  => 'image/jpeg',
            'jpeg' => 'image/jpeg',
            'png'  => 'image/png',
            'gif'  => 'image/gif',
            'webp' => 'image/webp',
        ];
        header('Content-Type: ' . ($mime_types[$ext] ?? 'application/octet-stream'));
        header('Access-Control-Allow-Origin: ' . $allowed_origin);
        header('Access-Control-Allow-Credentials: true');
        header('Cache-Control: max-age=86400');
        readfile($file_path);
        exit;
    }
    http_response_code(404);
    exit;
}

$routes = [
    'POST' => [
        '/auth/register'    => __DIR__ . '/auth/register.php',
        '/auth/login'       => __DIR__ . '/auth/login.php',
        '/auth/logout'      => __DIR__ . '/auth/logout.php',
        '/upload-payment'   => __DIR__ . '/api/upload_payment.php',
        '/admin/login'      => __DIR__ . '/admin/login.php',
        '/admin/approve'    => __DIR__ . '/admin/payments.php',
    ],
    'GET' => [
        '/user/status'      => __DIR__ . '/api/user_status.php',
        '/admin/payments'   => __DIR__ . '/admin/payments.php',
    ],
];

// Dynamic route: GET /ticket/{uuid}
if ($method === 'GET' && preg_match('#^/ticket/[0-9a-f\-]+$#i', $uri)) {
    require __DIR__ . '/api/ticket.php';
    exit;
}

// Dynamic route: GET /validate/{uuid} – PUBLIC validation endpoint
if ($method === 'GET' && preg_match('#^/validate/[0-9a-f\-]+$#i', $uri)) {
    require __DIR__ . '/api/validate.php';
    exit;
}

if (isset($routes[$method][$uri])) {
    require $routes[$method][$uri];
    exit;
}

// 404
header('Content-Type: application/json');
http_response_code(404);
echo json_encode(['success' => false, 'message' => 'Endpoint not found.']);
