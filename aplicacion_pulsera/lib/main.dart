import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const GlucoseApp());
}

class GlucoseApp extends StatelessWidget {
  const GlucoseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Glucómetro No Invasivo',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
        brightness: Brightness.dark,
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // VALORES MOCK DE PRUEBA
  double _currentGlucose = 108.0;
  double _maxGlucoseToday = 145.0;
  double _minGlucoseToday = 82.0;
  bool _isConnected = true;
  int _batteryLevel = 88;
  Timer? _simulationTimer;
  bool _isAutoSimulating = false;

  @override
  void dispose() {
    _simulationTimer?.cancel();
    super.dispose();
  }

  void _toggleAutoSimulation() {
    setState(() {
      _isAutoSimulating = !_isAutoSimulating;
    });

    if (_isAutoSimulating) {
      _simulationTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
        setState(() {
          _currentGlucose += (timer.tick % 2 == 0 ? 3.0 : -2.0);
          if (_currentGlucose > _maxGlucoseToday) _maxGlucoseToday = _currentGlucose;
          if (_currentGlucose < _minGlucoseToday) _minGlucoseToday = _currentGlucose;
        });
      });
    } else {
      _simulationTimer?.cancel();
    }
  }

  Color _getGlucoseColor(double value) {
    if (value < 70) return Colors.red;
    if (value > 180) return Colors.orange;
    return Colors.green;
  }

  String _getGlucoseStatusText(double value) {
    if (value < 70) return 'Hipoglucemia';
    if (value > 180) return 'Hiperglucemia';
    return 'En Rango Normal';
  }

  @override
  Widget build(BuildContext context) {
    final glucoseColor = _getGlucoseColor(_currentGlucose);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Glucómetro No Invasivo'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              children: [
                Icon(
                  _isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
                  color: _isConnected ? Colors.blue : Colors.red,
                ),
                const SizedBox(width: 6),
                Text('$_batteryLevel%'),
                const SizedBox(width: 2),
                Icon(
                  _batteryLevel > 20 ? Icons.battery_full : Icons.battery_alert,
                  size: 18,
                  color: _batteryLevel > 20 ? Colors.green : Colors.red,
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, // <-- CORREGIDO AQUÍ
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Glucosa Actual',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: glucoseColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.trending_flat, color: glucoseColor, size: 18),
                              const SizedBox(width: 4),
                              Text(
                                _getGlucoseStatusText(_currentGlucose),
                                style: TextStyle(
                                  color: glucoseColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline, // <-- CORREGIDO AQUÍ
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          _currentGlucose.toStringAsFixed(0),
                          style: TextStyle(
                            fontSize: 64,
                            fontWeight: FontWeight.bold,
                            color: _isConnected ? glucoseColor : Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'mg/dL',
                          style: TextStyle(fontSize: 20, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _isConnected
                          ? 'Sincronizado vía BLE • Modo Prueba'
                          : 'Pulsera Desconectada',
                      style: TextStyle(
                        fontSize: 12,
                        color: _isConnected ? Colors.grey : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    title: 'Máximo Hoy',
                    value: '${_maxGlucoseToday.toStringAsFixed(0)} mg/dL',
                    icon: Icons.arrow_upward,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    title: 'Mínimo Hoy',
                    value: '${_minGlucoseToday.toStringAsFixed(0)} mg/dL',
                    icon: Icons.arrow_downward,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => _showEmergencyDialog(context),
                icon: const Icon(Icons.warning_amber_rounded),
                label: const Text(
                  'ENVIAR ALERTA SOS DE PRUEBA',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 24),

            ExpansionTile(
              initiallyExpanded: true,
              title: const Text(
                '🛠️ Panel de Simulación (Mock Controls)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.teal),
              ),
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Simular Estados de Glucosa:',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          ActionChip(
                            label: const Text('Bajo (58 mg/dL)'),
                            backgroundColor: Colors.red.shade100,
                            onPressed: () => setState(() => _currentGlucose = 58.0),
                          ),
                          ActionChip(
                            label: const Text('Normal (110 mg/dL)'),
                            backgroundColor: Colors.green.shade100,
                            onPressed: () => setState(() => _currentGlucose = 110.0),
                          ),
                          ActionChip(
                            label: const Text('Alto (210 mg/dL)'),
                            backgroundColor: Colors.orange.shade100,
                            onPressed: () => setState(() => _currentGlucose = 210.0),
                          ),
                        ],
                      ),
                      const Divider(),
                      SwitchListTile(
                        title: const Text('Estado Conexión BLE', style: TextStyle(fontSize: 13)),
                        value: _isConnected,
                        onChanged: (val) => setState(() => _isConnected = val),
                      ),
                      SwitchListTile(
                        title: const Text('Simular flujo continuo en tiempo real', style: TextStyle(fontSize: 13)),
                        subtitle: const Text('Varía el valor cada 3 segundos', style: TextStyle(fontSize: 11)),
                        value: _isAutoSimulating,
                        onChanged: (val) => _toggleAutoSimulation(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEmergencyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Activar Alerta de Emergencia?'),
        content: Text(
          'Se enviaría un mensaje SMS a tus contactos registrados con el valor actual de glucosa ($_currentGlucose mg/dL) y tu ubicación GPS.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Alerta de prueba enviada correctamente.')),
              );
            },
            child: const Text('Enviar Alerta', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // <-- CORREGIDO AQUÍ
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 4),
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}