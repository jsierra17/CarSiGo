import 'package:carsigo/core/supabase_client.dart';
import 'package:carsigo/drivers/driver_model.dart';
import 'package:carsigo/drivers/driver_service.dart';
import 'package:carsigo/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class CreateDriverProfilePage extends StatefulWidget {
  const CreateDriverProfilePage({super.key});

  @override
  State<CreateDriverProfilePage> createState() => _CreateDriverProfilePageState();
}

class _CreateDriverProfilePageState extends State<CreateDriverProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _idNumberController = TextEditingController(); // Controller para la identificación
  final _vehicleModelController = TextEditingController();
  final _licensePlateController = TextEditingController();
  final _driverService = DriverService();

  bool _isLoading = false;

  Future<void> _createProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final user = supabase.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Usuario no autenticado.')),
      );
      setState(() => _isLoading = false);
      return;
    }

    try {
      final newDriver = Driver(
        id: const Uuid().v4(),
        userId: user.id,
        fullName: _fullNameController.text,
        idNumber: _idNumberController.text, // Añadido el nuevo campo
        vehicleModel: _vehicleModelController.text,
        licensePlate: _licensePlateController.text,
        status: DriverStatus.offline,
        createdAt: DateTime.now(),
      );
      await _driverService.createDriverProfile(newDriver);

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomePage()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al crear perfil: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _idNumberController.dispose();
    _vehicleModelController.dispose();
    _licensePlateController.dispose();
    super.dispose();
  }

  Widget _buildDocumentUploadTile(String title, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title),
      trailing: const Icon(Icons.upload_file, color: Colors.grey),
      onTap: () { /* TODO: Implementar lógica para subir archivo */ },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Conviértete en Conductor')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  Text("Información Personal", style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  TextFormField(controller: _fullNameController, decoration: const InputDecoration(labelText: 'Nombre Completo'), validator: (v) => v!.isEmpty ? 'Campo requerido' : null),
                  const SizedBox(height: 12),
                  TextFormField(controller: _idNumberController, decoration: const InputDecoration(labelText: 'Cédula o Identificación'), validator: (v) => v!.isEmpty ? 'Campo requerido' : null),
                  const SizedBox(height: 24),
                  Text("Información del Vehículo", style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  TextFormField(controller: _vehicleModelController, decoration: const InputDecoration(labelText: 'Modelo del Vehículo'), validator: (v) => v!.isEmpty ? 'Campo requerido' : null),
                  const SizedBox(height: 12),
                  TextFormField(controller: _licensePlateController, decoration: const InputDecoration(labelText: 'Matrícula del Vehículo'), validator: (v) => v!.isEmpty ? 'Campo requerido' : null),
                  const SizedBox(height: 24),
                  Text("Documentos", style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  _buildDocumentUploadTile('Foto de Cédula (Frontal)', Icons.credit_card),
                  _buildDocumentUploadTile('Foto de Cédula (Trasera)', Icons.credit_card),
                  _buildDocumentUploadTile('Licencia de Conducir', Icons.drive_eta),
                  _buildDocumentUploadTile('Tarjeta de Propiedad', Icons.description),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _createProfile,
                    child: const Text('Enviar Solicitud'),
                  ),
                ],
              ),
            ),
    );
  }
}
