import 'package:flutter/material.dart';
import 'package:agrocuy/core/widgets/app_bar_menu.dart';
import 'package:agrocuy/core/widgets/drawer/user_drawer_breeder.dart';
import 'package:agrocuy/core/widgets/drawer/user_drawer_advisor.dart';
import 'package:agrocuy/infrastructure/services/publication_service.dart';
import 'package:agrocuy/infrastructure/services/session_service.dart';

class HomeScreen extends StatefulWidget {
  final int userId;
  final String fullname;
  final String username;
  final String photoUrl;
  final String role;

  const HomeScreen({
    super.key,
    required this.userId,
    required this.username,
    required this.fullname,
    required this.photoUrl,
    required this.role,
    required breederId,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Publication> publications = [];
  bool isLoading = true;
  String? errorMessage;
  final PublicationService _publicationService = PublicationService();
  final SessionService _sessionService = SessionService();

  @override
  void initState() {
    super.initState();
    _initializeAndLoadData();
  }

  Future<void> _initializeAndLoadData() async {
    try {
      // Asegurar que SessionService esté inicializado
      await _sessionService.init();
      await _loadPublications();
    } catch (e) {
      setState(() {
        errorMessage = 'Error al inicializar la aplicación: $e';
        isLoading = false;
      });
      print('Error initializing: $e');
    }
  }

  Future<void> _loadPublications() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      // Verificar si el usuario está autenticado
      if (!_publicationService.isAuthenticated()) {
        setState(() {
          errorMessage =
              'No hay token de autenticación. Por favor, inicia sesión nuevamente.';
          isLoading = false;
        });
        return;
      }

      // Debug: mostrar el token actual (opcional, solo para desarrollo)
      final currentToken = _publicationService.getCurrentToken();
      print('Current token: ${currentToken.substring(0, 20)}...');

      final loadedPublications =
          await _publicationService.getPublicationsWithRetry();

      setState(() {
        publications = loadedPublications;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        // Verificar si es un error de autenticación
        if (e.toString().contains('401')) {
          errorMessage =
              'Error de autenticación. El token ha expirado o es inválido.';
        } else if (e.toString().contains('403')) {
          errorMessage = 'No tienes permisos para ver las publicaciones.';
        } else if (e.toString().contains('500')) {
          errorMessage = 'Error del servidor. Intenta más tarde.';
        } else if (e.toString().contains('Connection') ||
            e.toString().contains('SocketException')) {
          errorMessage =
              'Error de conexión. Verifica tu internet y que el servidor esté disponible.';
        } else {
          errorMessage = 'Error: ${e.toString().replaceAll('Exception: ', '')}';
        }
        isLoading = false;
      });
      print('Error loading publications: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE3B3),
      appBar: const appBarMenu(title: 'AgroCuy'),
      drawer: widget.role == 'ROLE_BREEDER'
          ? UserDrawerBreeder(
              fullname: widget.fullname,
              username: widget.username.split('@').first,
              photoUrl: widget.photoUrl,
            )
          : UserDrawerAdvisor(
              fullname: widget.fullname,
              username: widget.username.split('@').first,
              photoUrl: widget.photoUrl,
              advisorId: widget.userId),
      body: CustomScrollView(
        slivers: [
          // Header de bienvenida
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B4513), Color(0xFFD2691E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '¡Hola, ${widget.fullname.split(' ').first}!',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.role == 'ROLE_BREEDER'
                              ? 'Gestiona tu granja de cuyes'
                              : 'Brinda asesoría especializada',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.network(
                        widget.photoUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.white,
                            child: const Icon(
                              Icons.person,
                              color: Color(0xFF8B4513),
                              size: 30,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Sección de categorías
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Categorías',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8B4513),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildCategoryCard(
                          'Tips & Consejos',
                          Icons.lightbulb_outline,
                          const Color(0xFFE6F3FF),
                          const Color(0xFF2196F3),
                          () => print('Tips seleccionado'),
                        ),
                        const SizedBox(width: 12),
                        _buildCategoryCard(
                          'Recetas',
                          Icons.restaurant_menu,
                          const Color(0xFFFFF3E0),
                          const Color(0xFFFF9800),
                          () => print('Recetas seleccionadas'),
                        ),
                        const SizedBox(width: 12),
                        _buildCategoryCard(
                          'Salud',
                          Icons.local_hospital_outlined,
                          const Color(0xFFE8F5E8),
                          const Color(0xFF4CAF50),
                          () => print('Salud seleccionada'),
                        ),
                        const SizedBox(width: 12),
                        _buildCategoryCard(
                          'Nutrición',
                          Icons.eco_outlined,
                          const Color(0xFFF3E5F5),
                          const Color(0xFF9C27B0),
                          () => print('Nutrición seleccionada'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // Sección de contenido destacado
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Contenido Destacado',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8B4513),
                    ),
                  ),
                  TextButton(
                    onPressed: () => print('Ver todo'),
                    child: const Text(
                      'Ver todo',
                      style: TextStyle(
                        color: Color(0xFF8B4513),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Grid de contenido
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: isLoading
                ? const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: CircularProgressIndicator(
                          color: Color(0xFF8B4513),
                        ),
                      ),
                    ),
                  )
                : errorMessage != null
                    ? SliverToBoxAdapter(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          margin: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border:
                                Border.all(color: Colors.red.withOpacity(0.3)),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Colors.red[700],
                                size: 48,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Error al cargar publicaciones',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red[700],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                errorMessage!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.red[600],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                onPressed: _loadPublications,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Reintentar'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red[700],
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : publications.isEmpty
                        ? SliverToBoxAdapter(
                            child: Container(
                              padding: const EdgeInsets.all(40),
                              margin: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color:
                                    const Color(0xFF8B4513).withOpacity(0.05),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color:
                                      const Color(0xFF8B4513).withOpacity(0.2),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.article_outlined,
                                    size: 64,
                                    color: const Color(0xFF8B4513)
                                        .withOpacity(0.5),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Aún no hay publicaciones',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF8B4513)
                                          .withOpacity(0.8),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Las publicaciones de los asesores aparecerán aquí',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: const Color(0xFF8B4513)
                                          .withOpacity(0.6),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton.icon(
                                    onPressed: _loadPublications,
                                    icon: const Icon(Icons.refresh),
                                    label: const Text('Actualizar'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF8B4513),
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : SliverGrid(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: 0.8,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final publication = publications[index];
                                return _buildPublicationCard(
                                    context, publication);
                              },
                              childCount: publications.length,
                            ),
                          ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(String title, IconData icon, Color backgroundColor,
      Color iconColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: iconColor,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPublicationCard(BuildContext context, Publication publication) {
    return GestureDetector(
      onTap: () => _showPublicationDetail(context, publication),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen de la publicación
            Expanded(
              flex: 5,
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: Image.network(
                    publication.image.isNotEmpty
                        ? publication.image
                        : 'https://images.unsplash.com/photo-1589952283406-b53173a8ab6d?w=400',
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFF8B4513).withOpacity(0.1),
                        child: const Center(
                          child: Icon(
                            Icons.image_outlined,
                            color: Color(0xFF8B4513),
                            size: 40,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            // Información de la publicación
            Container(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    publication.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF2C2C2C),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(
                              0xFF8B4513), // Color genérico para todas las publicaciones
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Publicación',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      // Información del asesor
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: const Color(0xFF8B4513).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.person,
                                size: 10,
                                color: Color(0xFF8B4513),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                'Asesor #${publication.advisorId}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPublicationDetail(BuildContext context, Publication publication) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Handle del modal
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Imagen principal
            Expanded(
              flex: 2,
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    publication.image.isNotEmpty
                        ? publication.image
                        : 'https://images.unsplash.com/photo-1589952283406-b53173a8ab6d?w=400',
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFF8B4513).withOpacity(0.1),
                        child: const Center(
                          child: Icon(
                            Icons.image_outlined,
                            color: Color(0xFF8B4513),
                            size: 60,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // Contenido de la publicación
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título y categoría
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            publication.title,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C2C2C),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8B4513),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Publicación',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Descripción
                    Text(
                      publication.description,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),

                    const Spacer(),

                    // Información del autor y fecha
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B4513).withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFF8B4513).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person,
                              color: Color(0xFF8B4513),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Publicado por',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  'Asesor #${publication.advisorId}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF8B4513),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatDate(publication.date.toIso8601String()),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final months = [
        'Ene',
        'Feb',
        'Mar',
        'Abr',
        'May',
        'Jun',
        'Jul',
        'Ago',
        'Sep',
        'Oct',
        'Nov',
        'Dic'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}
