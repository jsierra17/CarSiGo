import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../presentation/providers/auth_provider.dart';
import '../router/app_router.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => AppRouter.goToEditProfile(context),
            tooltip: 'Editar Perfil',
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (authProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = authProvider.user;
          if (user == null) {
            return const Center(child: Text('No se encontró información del usuario'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Header
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Profile Image
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          child: user.hasProfileImage
                              ? ClipOval(
                                  child: Image.network(
                                    user.fotoPerfilUrl!,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        Icons.person,
                                        size: 50,
                                        color: Colors.white,
                                      );
                                    },
                                  ),
                                )
                              : Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.white,
                                ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Name and Email
                        Text(
                          user.name,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        // User Type and Status
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Chip(
                              label: Text(_getUserTypeText(user.tipoUsuario)),
                              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                              labelStyle: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Chip(
                              label: Text(_getAccountStatusText(user.estadoCuenta)),
                              backgroundColor: _getAccountStatusColor(user.estadoCuenta).withOpacity(0.1),
                              labelStyle: TextStyle(
                                color: _getAccountStatusColor(user.estadoCuenta),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Personal Information
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Información Personal',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow(
                          context,
                          icon: Icons.phone,
                          label: 'Teléfono',
                          value: user.telefono,
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          context,
                          icon: Icons.location_city,
                          label: 'Ciudad',
                          value: user.ciudad,
                        ),
                        if (user.departamento != null) ...[
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            context,
                            icon: Icons.map,
                            label: 'Departamento',
                            value: user.departamento!,
                          ),
                        ],
                        if (user.numeroDocumento != null) ...[
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            context,
                            icon: Icons.badge,
                            label: 'Documento',
                            value: user.numeroDocumento!,
                          ),
                        ],
                        if (user.fechaNacimiento != null) ...[
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            context,
                            icon: Icons.cake,
                            label: 'Fecha de Nacimiento',
                            value: user.fechaNacimiento!,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Account Settings
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(
                          Icons.edit,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        title: const Text('Editar Perfil'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () => AppRouter.goToEditProfile(context),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: Icon(
                          Icons.lock,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        title: const Text('Cambiar Contraseña'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () => AppRouter.goToChangePassword(context),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: Icon(
                          Icons.location_on,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        title: const Text('Mis Ubicaciones'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () => AppRouter.goToSavedLocations(context),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: Icon(
                          Icons.history,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        title: const Text('Historial de Viajes'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () => AppRouter.goToTripHistory(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Support
                Card(
                  child: ListTile(
                    leading: Icon(
                      Icons.support_agent,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: const Text('Soporte'),
                    subtitle: const Text('¿Necesitas ayuda? Contáctanos'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => AppRouter.goToSupport(context),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Logout
                Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.logout,
                      color: Colors.red,
                    ),
                    title: const Text(
                      'Cerrar Sesión',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () => _showLogoutDialog(context),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 20,
        ),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  String _getUserTypeText(String tipoUsuario) {
    switch (tipoUsuario) {
      case 'pasajero':
        return 'Pasajero';
      case 'conductor':
        return 'Conductor';
      case 'admin':
        return 'Administrador';
      case 'soporte':
        return 'Soporte';
      default:
        return tipoUsuario;
    }
  }

  String _getAccountStatusText(String estadoCuenta) {
    switch (estadoCuenta) {
      case 'activa':
        return 'Activa';
      case 'suspendida':
        return 'Suspendida';
      case 'verificacion':
        return 'En Verificación';
      default:
        return estadoCuenta;
    }
  }

  Color _getAccountStatusColor(String estadoCuenta) {
    switch (estadoCuenta) {
      case 'activa':
        return Colors.green;
      case 'suspendida':
        return Colors.red;
      case 'verificacion':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await context.read<AuthProvider>().logout();
              AppRouter.replaceWithLogin(context);
            },
            child: const Text(
              'Cerrar Sesión',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
