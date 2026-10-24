<?php
// views.php
function renderApp($seccion, $datos = [], $mensaje = null) {
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0">
    <title>INTACTUS App</title>
    <link rel="stylesheet" href="css/estilo.css">
</head>
<body>

    <header class="header">
        <span class="brand">INTACTUS</span>
        <span class="user"><?php echo htmlspecialchars($datos['user']['full_name'] ?? 'Usuario'); ?></span>
    </header>

    <div class="container">
        <?php if ($mensaje): ?>
            <div class="alert"><?php echo $mensaje; ?></div>
        <?php endif; ?>

        <?php if ($seccion == 'inicio'): ?>
            <!-- PANTALLA: DASHBOARD / GLUCOSA -->
            <div class="card text-center">
                <h3>Glucosa Actual</h3>
                <?php if ($datos['glucosa']): ?>
                    <h1 class="value"><?php echo number_format($datos['glucosa']['glucose_value_mg_dl'], 0); ?> <small>mg/dL</small></h1>
                    <span class="badge status-<?php echo $datos['glucosa']['range_status']; ?>">
                        <?php echo $datos['glucosa']['range_status']; ?>
                    </span>
                <?php else: ?>
                    <h1 class="value">-- <small>mg/dL</small></h1>
                    <p>Sin lecturas registradas</p>
                <?php endif; ?>
            </div>

            <div class="card">
                <h4>Pulsera Conectada</h4>
                <p>Batería: <?php echo $datos['device']['battery_level'] ?? '0'; ?>% | Estado: <strong><?php echo $datos['device']['connection_status'] ?? 'DESCONECTADO'; ?></strong></p>
            </div>

        <?php elseif ($seccion == 'contactos'): ?>
            <!-- PANTALLA: CONTACTOS SOS -->
            <div class="card">
                <h3>Registrar Contacto de Emergencia</h3>
                <form action="index.php?seccion=contactos" method="POST">
                    <input type="hidden" name="accion" value="guardar_contacto">
                    <input type="text" name="nombre" placeholder="Nombre completo" required>
                    <input type="tel" name="telefono" placeholder="Número de teléfono" required>
                    <select name="relacion">
                        <option value="Family">Familiar</option>
                        <option value="Physician">Médico</option>
                        <option value="Friend">Amigo / Tutor</option>
                    </select>
                    <button type="submit" class="btn">Guardar Contacto</button>
                </form>
            </div>

        <?php elseif ($seccion == 'sos'): ?>
            <!-- PANTALLA: BOTÓN DE PÁNICO -->
            <div class="card text-center">
                <h3>Botón de Auxilio SOS</h3>
                <p>Presiona el botón para enviar una alerta inmediata a tu red de apoyo.</p>
                <form action="index.php?seccion=sos" method="POST">
                    <input type="hidden" name="accion" value="enviar_sos">
                    <button type="submit" class="btn-sos">S.O.S</button>
                </form>
            </div>
        <?php endif; ?>
    </div>

    <!-- NAVEGACIÓN INFERIOR -->
    <nav class="bottom-nav">
        <a href="index.php?seccion=inicio" class="<?php echo $seccion == 'inicio' ? 'active' : ''; ?>">📊 Glucosa</a>
        <a href="index.php?seccion=contactos" class="<?php echo $seccion == 'contactos' ? 'active' : ''; ?>">👥 Contactos</a>
        <a href="index.php?seccion=sos" class="<?php echo $seccion == 'sos' ? 'active' : ''; ?>">🚨 S.O.S</a>
    </nav>

</body>
</html>
<?php
}
?>