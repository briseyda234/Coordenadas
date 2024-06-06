import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Definición de la clase StatefulWidget llamada Coordenadas
class Coordenadas extends StatefulWidget {
  const Coordenadas({super.key}); // Constructor con una clave opcional

  @override
  _CoordenadasState createState() => _CoordenadasState();
}


class _CoordenadasState extends State<Coordenadas> {
  List<String> ubicaciones = []; // Lista para almacenar las ubicaciones

  // Método initState para inicializar el estado del widget
  @override
  void initState() {
    super.initState();
    _cargarUbicaciones(); // Carga ubicaciones desde SharedPreferences al iniciar
  }

  // Método para determinar la posición actual del dispositivo
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verifica si los servicios de ubicación están habilitados
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'Location services are disabled.';
    }

    // Verifica y solicita permisos de ubicación
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Location permissions are denied.';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw 'Location permissions are permanently denied, we cannot request permissions.';
    }

    // Obtiene la posición actual del dispositivo
    return await Geolocator.getCurrentPosition();
  }

  // Método para cargar ubicaciones guardadas desde SharedPreferences
  Future<void> _cargarUbicaciones() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? ubicacionesGuardadas = prefs.getStringList('ubicaciones');
    setState(() {
      if (ubicacionesGuardadas != null) {
        ubicaciones = ubicacionesGuardadas; // Actualiza la lista de ubicaciones con las guardadas
      }
    });
  }

  // Método para guardar la ubicación actual en SharedPreferences
  Future<void> _guardarUbicacion(Position position) async {
    final prefs = await SharedPreferences.getInstance();
    final ubicacion = 'Latitud:${position.latitude}, Longitud:${position.longitude}';
    setState(() {
      ubicaciones.insert(0, ubicacion); // Añade la nueva ubicación al inicio de la lista
    });
    await prefs.setStringList('ubicaciones', ubicaciones); // Guarda la lista actualizada en SharedPreferences
  }

  // Construye la interfaz de usuario del widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text("Tracking", style: TextStyle(color: Colors.white)),
        ),
        backgroundColor: const Color.fromARGB(255, 58, 156, 61),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                try {
                  final position = await _determinePosition(); // Obtiene la posición actual
                  await _guardarUbicacion(position); // Guarda la posición actual
                  //print('Latitude: ${position.latitude}, Longitude: ${position.longitude}');
                } catch (e) {
                  //print(e);
                }
              },
              child: const Text('Obtener ubicación'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: ubicaciones.length, // Número de elementos en la lista
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(ubicaciones[index]), // Muestra cada ubicación en un ListTile
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
