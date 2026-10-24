<?php
// models.php

function getDB() {
    $host = '127.0.0.1';
    $dbname = 'intactus_db';
    $username = 'root';
    $password = '';

    try {
        $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8mb4", $username, $password, [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
        ]);
        return $pdo;
    } catch (PDOException $e) {
        die("Error de conexión: " . $e->getMessage());
    }
}

// 1. Obtener datos del usuario
function getUserData($user_id) {
    $stmt = getDB()->prepare("SELECT * FROM users WHERE id = :id");
    $stmt->execute([':id' => $user_id]);
    return $stmt->fetch();
}

// 2. Obtener última lectura de glucosa
function getLatestGlucose($user_id) {
    $stmt = getDB()->prepare("SELECT * FROM glucose_readings WHERE user_id = :id ORDER BY reading_timestamp DESC LIMIT 1");
    $stmt->execute([':id' => $user_id]);
    return $stmt->fetch();
}

// 3. Obtener estado de la pulsera
function getDeviceStatus($user_id) {
    $stmt = getDB()->prepare("SELECT * FROM devices WHERE user_id = :id LIMIT 1");
    $stmt->execute([':id' => $user_id]);
    return $stmt->fetch();
}

// 4. Guardar contacto de emergencia
function saveContact($user_id, $name, $phone, $relationship) {
    $stmt = getDB()->prepare("INSERT INTO emergency_contacts (user_id, name, phone_number, relationship) VALUES (:user_id, :name, :phone, :rel)");
    return $stmt->execute([':user_id' => $user_id, ':name' => $name, ':phone' => $phone, ':rel' => $relationship]);
}

// 5. Guardar alerta SOS
function triggerSOS($user_id) {
    $stmt = getDB()->prepare("INSERT INTO sos_alerts (user_id, event_type, dispatch_status) VALUES (:user_id, 'MANUAL_PANIC_BUTTON', 'SENT')");
    return $stmt->execute([':user_id' => $user_id]);
}
?>