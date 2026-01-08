import 'package:carsigo/core/supabase_client.dart';
import 'package:carsigo/drivers/driver_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DriverService {
  /// Tabla de perfiles de conductores en Supabase.
  final String _driverProfileTable = 'drivers';

  /// Obtiene el perfil de un conductor usando su ID de usuario de autenticación.
  ///
  /// Devuelve un objeto [Driver] si se encuentra, o `null` si no existe.
  Future<Driver?> getDriverProfile(String userId) async {
    try {
      final response = await supabase
          .from(_driverProfileTable)
          .select()
          .eq('user_id', userId)
          .single();

      return Driver.fromMap(response);
    } on PostgrestException catch (e) {
      // Si no se encuentra el perfil, Supabase lanza una excepción.
      // Puedes manejar diferentes errores aquí, ej. e.code == 'PGRST116' (not found)
      print('Error al obtener perfil de conductor: ${e.message}');
      return null;
    }
  }

  /// Crea un nuevo perfil de conductor.
  ///
  /// Esto normalmente se llamaría después de que un usuario se registra y completa
  /// un formulario para convertirse en conductor.
  Future<void> createDriverProfile(Driver driver) async {
    try {
      await supabase.from(_driverProfileTable).insert(driver.toMap());
    } catch (e) {
      print('Error al crear el perfil de conductor: $e');
      rethrow;
    }
  }

  /// Actualiza el estado de un conductor (online, offline, etc.).
  Future<void> updateDriverStatus(String driverId, DriverStatus status) async {
    try {
      await supabase.from(_driverProfileTable).update({
        'status': status.name,
      }).eq('id', driverId);
    } catch (e) {
      print('Error al actualizar el estado del conductor: $e');
      rethrow;
    }
  }
}
