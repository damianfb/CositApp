import 'package:flutter/material.dart';
import '../../data/repositories/producto_repository.dart';
import 'productos_screen.dart';
import 'bizcochuelos_screen.dart';
import 'rellenos_screen.dart';
import 'tematicas_screen.dart';

/// Pantalla principal de gestión de catálogo
/// Muestra un menú con acceso a productos, bizcochuelos, rellenos y temáticas
class CatalogoScreen extends StatefulWidget {
  const CatalogoScreen({super.key});

  @override
  State<CatalogoScreen> createState() => _CatalogoScreenState();
}

class _CatalogoScreenState extends State<CatalogoScreen> {
  final ProductoRepository _productoRepo = ProductoRepository();
  final BizcochueloRepository _bizcochueloRepo = BizcochueloRepository();
  final RellenoRepository _rellenoRepo = RellenoRepository();
  final TematicaRepository _tematicaRepo = TematicaRepository();

  int _productosCount = 0;
  int _bizcochuelosCount = 0;
  int _rellenosCount = 0;
  int _tematicasCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCounts();
  }

  Future<void> _loadCounts() async {
    setState(() => _isLoading = true);
    try {
      final productos = await _productoRepo.getAll();
      final bizcochuelos = await _bizcochueloRepo.getAll();
      final rellenos = await _rellenoRepo.getAll();
      final tematicas = await _tematicaRepo.getAll();

      setState(() {
        _productosCount = productos.length;
        _bizcochuelosCount = bizcochuelos.length;
        _rellenosCount = rellenos.length;
        _tematicasCount = tematicas.length;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar datos: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Catálogo'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadCounts,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildCatalogCard(
                    context,
                    title: 'Productos',
                    subtitle: 'Gestionar productos del catálogo',
                    icon: Icons.cake,
                    count: _productosCount,
                    color: Colors.pink,
                    onTap: () => _navigateToScreen(const ProductosScreen()),
                  ),
                  const SizedBox(height: 16),
                  _buildCatalogCard(
                    context,
                    title: 'Bizcochuelos',
                    subtitle: 'Tipos de bizcochuelo disponibles',
                    icon: Icons.cake_outlined,
                    count: _bizcochuelosCount,
                    color: Colors.orange,
                    onTap: () => _navigateToScreen(const BizcochuelosScreen()),
                  ),
                  const SizedBox(height: 16),
                  _buildCatalogCard(
                    context,
                    title: 'Rellenos',
                    subtitle: 'Tipos de relleno disponibles',
                    icon: Icons.layers,
                    count: _rellenosCount,
                    color: Colors.purple,
                    onTap: () => _navigateToScreen(const RellenosScreen()),
                  ),
                  const SizedBox(height: 16),
                  _buildCatalogCard(
                    context,
                    title: 'Temáticas',
                    subtitle: 'Temáticas de decoración',
                    icon: Icons.palette,
                    count: _tematicasCount,
                    color: Colors.teal,
                    onTap: () => _navigateToScreen(const TematicasScreen()),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildCatalogCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required int count,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Text(
                    count.toString(),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                  ),
                  Text(
                    'items',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _navigateToScreen(Widget screen) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
    _loadCounts(); // Refresh counts when returning
  }
}
