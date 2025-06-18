import 'package:flutter/material.dart';
import 'package:agrocuy/core/widgets/app_bar_menu.dart';
import 'package:agrocuy/core/widgets/drawer/user_drawer_breeder.dart';
import 'package:agrocuy/core/widgets/drawer/user_drawer_advisor.dart';

class HomeScreen extends StatelessWidget {
  final int userId;
  final String fullname;
  final String username;
  final String photoUrl;
  final String role; // NUEVO

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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE3B3),
      appBar: const appBarMenu(title: 'AgroCuy'),
      drawer: role == 'ROLE_BREEDER'
          ? UserDrawerBreeder(
              fullname: fullname,
              username: username.split('@').first,
              photoUrl: photoUrl,
            )
          : UserDrawerAdvisor(
              fullname: fullname,
              username: username.split('@').first,
              photoUrl: photoUrl,
              advisorId: userId),
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
                          '¡Hola, ${fullname.split(' ').first}!',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          role == 'ROLE_BREEDER'
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
                        photoUrl,
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
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final publications = [
                    {
                      'id': 1,
                      'title': 'Cuidados básicos del cuy',
                      'description':
                          'Aprende los cuidados esenciales para mantener a tus cuyes saludables y felices. Incluye tips de alimentación, higiene y manejo.',
                      'imageUrl':
                          'https://images.unsplash.com/photo-1589952283406-b53173a8ab6d?w=400',
                      'author': 'Claudia23',
                      'date': '2025-06-15',
                      'category': 'Tips'
                    },
                    {
                      'id': 2,
                      'title': 'Receta nutritiva para cuyes',
                      'description':
                          'Deliciosa receta balanceada que aporta todos los nutrientes necesarios para el crecimiento óptimo de tus cuyes.',
                      'imageUrl':
                          'https://images.unsplash.com/photo-1559181567-c3190ca9959b?w=400',
                      'author': 'Tilin001',
                      'date': '2025-06-14',
                      'category': 'Receta'
                    },
                    {
                      'id': 3,
                      'title': 'Técnicas de reproducción',
                      'description':
                          'Guía completa sobre las mejores prácticas para la reproducción exitosa de cuyes en tu granja.',
                      'imageUrl':
                          'https://images.unsplash.com/photo-1558618047-3c8c76ca7d13?w=400',
                      'author': 'EstebanQuito',
                      'date': '2025-06-13',
                      'category': 'Tips'
                    },
                    {
                      'id': 4,
                      'title': 'Alimentación balanceada',
                      'description':
                          'Conoce los alimentos ideales y las proporciones correctas para una dieta equilibrada de tus cuyes.',
                      'imageUrl':
                          'https://images.unsplash.com/photo-1516467508483-a7212febe31a?w=400',
                      'author': 'ElCarlitosTV',
                      'date': '2025-06-12',
                      'category': 'Nutrición'
                    },
                    {
                      'id': 5,
                      'title': 'Prevención de enfermedades',
                      'description':
                          'Medidas preventivas esenciales para evitar las enfermedades más comunes en la crianza de cuyes.',
                      'imageUrl':
                          'https://images.unsplash.com/photo-1601758228041-f3b2795255f1?w=400',
                      'author': 'ElzaPayo',
                      'date': '2025-06-11',
                      'category': 'Salud'
                    },
                    {
                      'id': 6,
                      'title': 'Manejo del galpón',
                      'description':
                          'Consejos para optimizar el espacio y las condiciones de tu galpón para el bienestar de los cuyes.',
                      'imageUrl':
                          'https://images.unsplash.com/photo-1504595403659-9088ce801e29?w=400',
                      'author': 'TaniaCavia',
                      'date': '2025-06-10',
                      'category': 'Tips'
                    },
                  ];
                  final publication = publications[index];

                  return _buildPublicationCard(context, publication);
                },
                childCount: 6,
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

  Widget _buildPublicationCard(
      BuildContext context, Map<String, dynamic> publication) {
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
              flex: 3,
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
                    publication['imageUrl'],
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
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          publication['title'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFF2C2C2C),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(publication['category']),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            publication['category'],
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Autor
                    Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: const Color(0xFF8B4513).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person,
                            size: 12,
                            color: Color(0xFF8B4513),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            publication['author'],
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
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

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Tips':
        return const Color(0xFF2196F3);
      case 'Receta':
        return const Color(0xFFFF9800);
      case 'Salud':
        return const Color(0xFF4CAF50);
      case 'Nutrición':
        return const Color(0xFF9C27B0);
      default:
        return const Color(0xFF8B4513);
    }
  }

  void _showPublicationDetail(
      BuildContext context, Map<String, dynamic> publication) {
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
                    publication['imageUrl'],
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
                            publication['title'],
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
                            color: _getCategoryColor(publication['category']),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            publication['category'],
                            style: const TextStyle(
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
                      publication['description'],
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
                                  publication['author'],
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
                                _formatDate(publication['date']),
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
