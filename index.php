<?php
// index.php
require_once 'models.php';
require_once 'views.php';

// Simulamos que el usuario está en sesión
$user_id = 'a1b2c3d4-e5f6-7890-abcd-1234567890ab'; 

$seccion = $_GET['seccion'] ?? 'inicio';
$mensaje = null;

// Procesar formularios enviando POST
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $accion = $_POST['accion'] ?? '';

    if ($accion === 'guardar_contacto') {
        if (saveContact($user_id, $_POST['nombre'], $_POST['telefono'], $_POST['relacion'])) {
            $mensaje = "¡Contacto registrado con éxito!";
        }
    } elseif ($accion === 'enviar_sos') {
        if (triggerSOS($user_id)) {
            $mensaje = "¡Alerta SOS enviada a la base de datos!";
        }
    }
}

// Cargar los datos necesarios para la vista según la sección
$datos = [
    'user'    => getUserData($user_id),
    'glucosa' => getLatestGlucose($user_id),
    'device'  => getDeviceStatus($user_id)
];

// Imprimir la vista
renderApp($seccion, $datos, $mensaje);
?>