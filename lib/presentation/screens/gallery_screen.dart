import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import '../../data/models/foto.dart';
import '../../data/repositories/foto_repository.dart';
import '../../core/constants/app_constants.dart';
import 'detalle_foto_screen.dart';

/// Pantalla principal de galería de fotos
/// Muestra fotos en grid con filtros por categoría
class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final FotoRepository _fotoRepository = FotoRepository();
  final ImagePicker _imagePicker = ImagePicker();
  
  List<Foto> _fotos = [];
  List<String> _categorias = [];
  String? _filtroCategoria;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// Carga fotos y categorías desde la base de datos
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      // Cargar fotos visibles en galería
      final fotos = _filtroCategoria == null
          ? await _fotoRepository.getVisiblesEnGaleria()
          : await _fotoRepository.getVisiblesByCategoria(_filtroCategoria);
      
      // Cargar categorías disponibles
      final categorias = await _fotoRepository.getCategorias();
      
      setState(() {
        _fotos = fotos;
        _categorias = categorias;
        _isLoading = false;
      });
      
      print('📸 Galería cargada: ${_fotos.length} fotos, ${_categorias.length} categorías');
    } catch (e) {
      print('❌ Error cargando galería: $e');
      setState(() => _isLoading = false);
    }
  }

  /// Muestra diálogo para seleccionar origen de foto
  Future<void> _mostrarOpcionesFoto() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppConstants.accentColor),
              title: const Text('Tomar foto con la cámara'),
              onTap: () {
                Navigator.pop(context);
                _tomarFoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppConstants.accentColor),
              title: const Text('Seleccionar de la galería'),
              onTap: () {
                Navigator.pop(context);
                _tomarFoto(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel),
              title: const Text('Cancelar'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  /// Captura o selecciona una foto
  Future<void> _tomarFoto(ImageSource source) async {
    try {
      // Solicitar permisos según la fuente
      bool permisoConcedido = false;
      if (source == ImageSource.camera) {
        final status = await Permission.camera.request();
        permisoConcedido = status.isGranted;
        if (!permisoConcedido) {
          _mostrarMensajePermiso('Se requiere permiso de cámara');
          return;
        }
      } else {
        final status = await Permission.photos.request();
        permisoConcedido = status.isGranted;
        if (!permisoConcedido) {
          _mostrarMensajePermiso('Se requiere permiso para acceder a fotos');
          return;
        }
      }

      // Capturar/seleccionar imagen
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image == null) {
        print('📸 Usuario canceló la selección de foto');
        return;
      }

      // Guardar foto en almacenamiento local
      final rutaGuardada = await _guardarFotoLocal(image);
      
      // Mostrar diálogo para agregar información de la foto
      if (mounted) {
        _mostrarDialogoNuevaFoto(rutaGuardada);
      }
    } catch (e) {
      print('❌ Error capturando foto: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al capturar foto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Guarda la foto en el almacenamiento local de la app
  Future<String> _guardarFotoLocal(XFile image) async {
    // Obtener directorio de documentos de la app
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String fotosDir = path.join(appDocDir.path, 'fotos');
    
    // Crear directorio de fotos si no existe
    final Directory fotosDirPath = Directory(fotosDir);
    if (!await fotosDirPath.exists()) {
      await fotosDirPath.create(recursive: true);
    }

    // Generar nombre único para la foto
    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final String extension = path.extension(image.path);
    final String nombreArchivo = 'foto_$timestamp$extension';
    final String rutaDestino = path.join(fotosDir, nombreArchivo);

    // Copiar archivo a la ubicación permanente
    final File archivoOriginal = File(image.path);
    await archivoOriginal.copy(rutaDestino);

    print('💾 Foto guardada en: $rutaDestino');
    return rutaDestino;
  }

  /// Muestra diálogo para agregar información de la nueva foto
  void _mostrarDialogoNuevaFoto(String rutaArchivo) {
    final TextEditingController descripcionController = TextEditingController();
    String? categoriaSeleccionada;
    String tipoSeleccionado = Foto.tipoCatalogo;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Nueva Foto'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Descripción
                TextField(
                  controller: descripcionController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    hintText: 'Ej: Torta de cumpleaños con temática princesas',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                
                // Tipo
                DropdownButtonFormField<String>(
                  value: tipoSeleccionado,
                  decoration: const InputDecoration(
                    labelText: 'Tipo',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(value: Foto.tipoCatalogo, child: const Text('Catálogo')),
                    DropdownMenuItem(value: Foto.tipoProductoFinal, child: const Text('Producto Final')),
                    DropdownMenuItem(value: Foto.tipoProceso, child: const Text('Proceso')),
                    DropdownMenuItem(value: Foto.tipoReferencia, child: const Text('Referencia')),
                    DropdownMenuItem(value: Foto.tipoOtro, child: const Text('Otro')),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      tipoSeleccionado = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                
                // Categoría
                DropdownButtonFormField<String>(
                  value: categoriaSeleccionada,
                  decoration: const InputDecoration(
                    labelText: 'Categoría (opcional)',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Sin categoría')),
                    ..._categorias.map((cat) => DropdownMenuItem(
                      value: cat,
                      child: Text(cat),
                    )),
                    const DropdownMenuItem(value: '_nueva', child: Text('+ Nueva categoría')),
                  ],
                  onChanged: (value) {
                    if (value == '_nueva') {
                      _mostrarDialogoNuevaCategoria((nuevaCategoria) {
                        setDialogState(() {
                          categoriaSeleccionada = nuevaCategoria;
                        });
                      });
                    } else {
                      setDialogState(() {
                        categoriaSeleccionada = value;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Eliminar foto guardada si cancela
                File(rutaArchivo).deleteSync();
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.pop(context);
                await _guardarFotoEnDB(
                  rutaArchivo,
                  descripcionController.text,
                  tipoSeleccionado,
                  categoriaSeleccionada,
                );
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  /// Muestra diálogo para crear nueva categoría
  void _mostrarDialogoNuevaCategoria(Function(String) onCreated) {
    final TextEditingController controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva Categoría'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nombre de la categoría',
            hintText: 'Ej: Tortas, Bocaditos, Decoraciones',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final nuevaCategoria = controller.text.trim();
              if (nuevaCategoria.isNotEmpty) {
                Navigator.pop(context);
                onCreated(nuevaCategoria);
              }
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  /// Guarda la foto en la base de datos
  Future<void> _guardarFotoEnDB(
    String rutaArchivo,
    String descripcion,
    String tipo,
    String? categoria,
  ) async {
    try {
      final foto = Foto(
        rutaArchivo: rutaArchivo,
        descripcion: descripcion.isEmpty ? null : descripcion,
        tipo: tipo,
        categoria: categoria,
        fechaCreacion: DateTime.now(),
        visibleEnGaleria: true,
        pedidoId: null, // Sin pedido asociado
      );

      await _fotoRepository.insert(foto);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Foto guardada en la galería'),
            backgroundColor: Colors.green,
          ),
        );
      }
      
      // Recargar galería
      _loadData();
    } catch (e) {
      print('❌ Error guardando foto en DB: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error guardando foto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Muestra mensaje cuando se niegan permisos
  void _mostrarMensajePermiso(String mensaje) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permiso requerido'),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Configuración'),
          ),
        ],
      ),
    );
  }

  /// Muestra diálogo para seleccionar filtro de categoría
  void _mostrarFiltroCategoria() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtrar por categoría'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Todas las fotos'),
                leading: Radio<String?>(
                  value: null,
                  groupValue: _filtroCategoria,
                  onChanged: (value) {
                    setState(() => _filtroCategoria = value);
                    Navigator.pop(context);
                    _loadData();
                  },
                ),
                onTap: () {
                  setState(() => _filtroCategoria = null);
                  Navigator.pop(context);
                  _loadData();
                },
              ),
              ..._categorias.map((categoria) => ListTile(
                title: Text(categoria),
                leading: Radio<String?>(
                  value: categoria,
                  groupValue: _filtroCategoria,
                  onChanged: (value) {
                    setState(() => _filtroCategoria = value);
                    Navigator.pop(context);
                    _loadData();
                  },
                ),
                onTap: () {
                  setState(() => _filtroCategoria = categoria);
                  Navigator.pop(context);
                  _loadData();
                },
              )),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.navGallery),
        actions: [
          // Botón de filtro por categoría
          if (_categorias.isNotEmpty)
            IconButton(
              icon: Icon(
                Icons.filter_list,
                color: _filtroCategoria != null ? AppConstants.accentColor : null,
              ),
              onPressed: _mostrarFiltroCategoria,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _fotos.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: Column(
                    children: [
                      // Chip de filtro activo
                      if (_filtroCategoria != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(8.0),
                          color: AppConstants.primaryColor.withOpacity(0.1),
                          child: Wrap(
                            spacing: 8.0,
                            children: [
                              Chip(
                                label: Text(_filtroCategoria!),
                                deleteIcon: const Icon(Icons.close, size: 18),
                                onDeleted: () {
                                  setState(() => _filtroCategoria = null);
                                  _loadData();
                                },
                              ),
                            ],
                          ),
                        ),
                      
                      // Grid de fotos
                      Expanded(
                        child: GridView.builder(
                          padding: const EdgeInsets.all(8.0),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1.0,
                            crossAxisSpacing: 8.0,
                            mainAxisSpacing: 8.0,
                          ),
                          itemCount: _fotos.length,
                          itemBuilder: (context, index) {
                            final foto = _fotos[index];
                            return _buildFotoCard(foto);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _mostrarOpcionesFoto,
        icon: const Icon(Icons.add_a_photo),
        label: const Text('Agregar'),
      ),
    );
  }

  /// Construye el estado vacío cuando no hay fotos
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 100,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No hay fotos en la galería',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Toca el botón "Agregar" para capturar\no seleccionar fotos',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Construye una tarjeta de foto en el grid
  Widget _buildFotoCard(Foto foto) {
    final file = File(foto.rutaArchivo);
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetalleFotoScreen(
              foto: foto,
              onFotoActualizada: _loadData,
            ),
          ),
        );
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 2,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Imagen
            file.existsSync()
                ? Image.file(
                    file,
                    fit: BoxFit.cover,
                  )
                : Container(
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.broken_image,
                      size: 48,
                      color: Colors.grey,
                    ),
                  ),
            
            // Overlay con información
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (foto.descripcion != null && foto.descripcion!.isNotEmpty)
                      Text(
                        foto.descripcion!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (foto.categoria != null)
                      Text(
                        foto.categoria!,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
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
}
