import 'package:flutter/material.dart';
import 'package:agrocuy/core/widgets/app_bar_menu.dart';
import 'package:agrocuy/core/widgets/drawer/user_drawer_breeder.dart';
import 'package:agrocuy/core/widgets/drawer/user_drawer_advisor.dart';

class ConfigurationScreen extends StatefulWidget {
  final int userId;
  final String fullname;
  final String username;
  final String photoUrl;
  final String role;

  const ConfigurationScreen({
    super.key,
    required this.userId,
    required this.username,
    required this.fullname,
    required this.photoUrl,
    required this.role,
  });

  @override
  State<ConfigurationScreen> createState() => _ConfigurationScreenState();
}

class _ConfigurationScreenState extends State<ConfigurationScreen> {
  // Configuraciones de la aplicación
  bool _notificacionesPush = true;
  bool _notificacionesEmail = false;
  bool _recordatoriosCitas = true;
  bool _alertasVacunacion = true;
  bool _sincronizacionAutomatica = true;
  bool _modoOscuro = false;
  bool _guardarDatosLocalmente = true;
  bool _usarMetricasAvanzadas = false;

  String _unidadPeso = 'kg';
  String _formatoFecha = 'dd/mm/yyyy';
  String _idioma = 'español';
  String _moneda = 'USD';
  int _frecuenciaSincronizacion = 30; // minutos

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE3B3),
      appBar: const appBarMenu(title: 'Configuración'),
      drawer: widget.role == 'ROLE_BREEDER'
          ? UserDrawerBreeder(
              fullname: widget.fullname,
              username: widget.username.split('@').first,
              photoUrl: widget.photoUrl,
              userId: widget.userId,
              role: widget.role,
            )
          : UserDrawerAdvisor(
              fullname: widget.fullname,
              username: widget.username.split('@').first,
              photoUrl: widget.photoUrl,
              advisorId: widget.userId,
            ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B4513), Color(0xFFD2691E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ajustes de la Aplicación',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Personaliza tu experiencia en AgroCuy',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Notificaciones
            _buildSectionCard(
              title: 'Notificaciones',
              icon: Icons.notifications,
              children: [
                _buildSwitchTile(
                  title: 'Notificaciones Push',
                  subtitle: 'Recibe alertas en tu dispositivo',
                  value: _notificacionesPush,
                  onChanged: (value) =>
                      setState(() => _notificacionesPush = value),
                ),
                _buildSwitchTile(
                  title: 'Notificaciones por Email',
                  subtitle: 'Recibe resúmenes por correo electrónico',
                  value: _notificacionesEmail,
                  onChanged: (value) =>
                      setState(() => _notificacionesEmail = value),
                ),
                _buildSwitchTile(
                  title: 'Recordatorios de Citas',
                  subtitle: 'Alertas 24 horas antes de cada cita',
                  value: _recordatoriosCitas,
                  onChanged: (value) =>
                      setState(() => _recordatoriosCitas = value),
                ),
                _buildSwitchTile(
                  title: 'Alertas de Vacunación',
                  subtitle: 'Notificaciones para vacunas de cuyes',
                  value: _alertasVacunacion,
                  onChanged: (value) =>
                      setState(() => _alertasVacunacion = value),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Datos y Sincronización
            _buildSectionCard(
              title: 'Datos y Sincronización',
              icon: Icons.sync,
              children: [
                _buildSwitchTile(
                  title: 'Sincronización Automática',
                  subtitle: 'Mantén tus datos actualizados',
                  value: _sincronizacionAutomatica,
                  onChanged: (value) =>
                      setState(() => _sincronizacionAutomatica = value),
                ),
                _buildSwitchTile(
                  title: 'Guardar Datos Localmente',
                  subtitle: 'Acceso sin conexión a internet',
                  value: _guardarDatosLocalmente,
                  onChanged: (value) =>
                      setState(() => _guardarDatosLocalmente = value),
                ),
                _buildDropdownTile(
                  title: 'Frecuencia de Sincronización',
                  subtitle: 'Cada $_frecuenciaSincronizacion minutos',
                  value: _frecuenciaSincronizacion.toString(),
                  items: const ['15', '30', '60', '120'],
                  onChanged: (value) => setState(
                      () => _frecuenciaSincronizacion = int.parse(value!)),
                  suffixLabels: const ['15 min', '30 min', '1 hora', '2 horas'],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Unidades y Formato
            _buildSectionCard(
              title: 'Unidades y Formato',
              icon: Icons.straighten,
              children: [
                _buildDropdownTile(
                  title: 'Unidad de Peso',
                  subtitle: 'Para registro de cuyes',
                  value: _unidadPeso,
                  items: const ['kg', 'lb', 'g'],
                  onChanged: (value) => setState(() => _unidadPeso = value!),
                  suffixLabels: const ['Kilogramos', 'Libras', 'Gramos'],
                ),
                _buildDropdownTile(
                  title: 'Formato de Fecha',
                  subtitle: 'Cómo se muestran las fechas',
                  value: _formatoFecha,
                  items: const ['dd/mm/yyyy', 'mm/dd/yyyy', 'yyyy-mm-dd'],
                  onChanged: (value) => setState(() => _formatoFecha = value!),
                ),
                _buildDropdownTile(
                  title: 'Moneda',
                  subtitle: 'Para gastos y recursos',
                  value: _moneda,
                  items: const ['USD', 'EUR', 'PEN', 'COP'],
                  onChanged: (value) => setState(() => _moneda = value!),
                  suffixLabels: const [
                    'Dólar USD',
                    'Euro',
                    'Sol Peruano',
                    'Peso Colombiano'
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Apariencia
            _buildSectionCard(
              title: 'Apariencia',
              icon: Icons.palette,
              children: [
                _buildSwitchTile(
                  title: 'Modo Oscuro',
                  subtitle: 'Tema oscuro para la aplicación',
                  value: _modoOscuro,
                  onChanged: (value) => setState(() => _modoOscuro = value),
                ),
                _buildDropdownTile(
                  title: 'Idioma',
                  subtitle: 'Idioma de la interfaz',
                  value: _idioma,
                  items: const ['español', 'english', 'português'],
                  onChanged: (value) => setState(() => _idioma = value!),
                  suffixLabels: const ['Español', 'English', 'Português'],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Funciones Avanzadas
            _buildSectionCard(
              title: 'Funciones Avanzadas',
              icon: Icons.settings_applications,
              children: [
                _buildSwitchTile(
                  title: 'Métricas Avanzadas',
                  subtitle: 'Análisis detallado de rendimiento',
                  value: _usarMetricasAvanzadas,
                  onChanged: (value) =>
                      setState(() => _usarMetricasAvanzadas = value),
                ),
                _buildActionTile(
                  title: 'Exportar Datos',
                  subtitle: 'Descargar información de la granja',
                  icon: Icons.download,
                  onTap: () => _showExportDialog(),
                ),
                _buildActionTile(
                  title: 'Copia de Seguridad',
                  subtitle: 'Respaldar toda la información',
                  icon: Icons.backup,
                  onTap: () => _showBackupDialog(),
                ),
                _buildActionTile(
                  title: 'Restablecer Configuración',
                  subtitle: 'Volver a valores predeterminados',
                  icon: Icons.restore,
                  onTap: () => _showResetDialog(),
                  isDestructive: true,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Información
            _buildSectionCard(
              title: 'Información',
              icon: Icons.info,
              children: [
                _buildInfoTile(
                  title: 'Versión de la App',
                  subtitle: '1.2.3 (Build 456)',
                ),
                _buildActionTile(
                  title: 'Términos y Condiciones',
                  subtitle: 'Políticas de uso de AgroCuy',
                  icon: Icons.description,
                  onTap: () => _showTermsDialog(),
                ),
                _buildActionTile(
                  title: 'Soporte Técnico',
                  subtitle: 'Contáctanos para ayuda',
                  icon: Icons.support_agent,
                  onTap: () => _showSupportDialog(),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Botón de guardar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _saveSettings(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B4513),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Guardar Configuración',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B4513).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFF8B4513),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8B4513),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF8B4513),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownTile({
    required String title,
    required String subtitle,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    List<String>? suffixLabels,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final label = suffixLabels != null ? suffixLabels[index] : item;

              return DropdownMenuItem(
                value: item,
                child: Text(label),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(
                icon,
                color: isDestructive ? Colors.red : const Color(0xFF8B4513),
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isDestructive ? Colors.red : null,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _saveSettings() {
    // Aquí implementarías la lógica para guardar las configuraciones
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Configuración guardada exitosamente'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exportar Datos'),
        content: const Text(
            '¿Qué datos deseas exportar?\n\n• Información de jaulas\n• Datos de cuyes\n• Historial de citas\n• Gastos y recursos'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Implementar exportación
            },
            child: const Text('Exportar'),
          ),
        ],
      ),
    );
  }

  void _showBackupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Copia de Seguridad'),
        content: const Text(
            'Se creará una copia de seguridad de todos tus datos en la nube.\n\n¿Continuar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Implementar backup
            },
            child: const Text('Crear Backup'),
          ),
        ],
      ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restablecer Configuración'),
        content: const Text(
            'Esto restaurará todos los ajustes a sus valores predeterminados.\n\n¿Estás seguro?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _resetToDefaults();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Restablecer'),
          ),
        ],
      ),
    );
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Términos y Condiciones'),
        content: const SingleChildScrollView(
          child: Text(
              'Aquí irían los términos y condiciones completos de AgroCuy...\n\n(Contenido por implementar)'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showSupportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Soporte Técnico'),
        content: const Text(
            '¿Necesitas ayuda?\n\nContacta con nuestro equipo:\n\n📧 soporte@agrocuy.com\n📱 +51 999 888 777\n💬 Chat en línea: 24/7'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Abrir chat o email
            },
            child: const Text('Contactar'),
          ),
        ],
      ),
    );
  }

  void _resetToDefaults() {
    setState(() {
      _notificacionesPush = true;
      _notificacionesEmail = false;
      _recordatoriosCitas = true;
      _alertasVacunacion = true;
      _sincronizacionAutomatica = true;
      _modoOscuro = false;
      _guardarDatosLocalmente = true;
      _usarMetricasAvanzadas = false;
      _unidadPeso = 'kg';
      _formatoFecha = 'dd/mm/yyyy';
      _idioma = 'español';
      _moneda = 'USD';
      _frecuenciaSincronizacion = 30;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Configuración restablecida a valores predeterminados'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}
