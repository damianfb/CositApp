import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/models/foto.dart';
import '../../data/repositories/foto_repository.dart';
import '../../data/repositories/pedido_repository.dart';
import '../../data/models/pedido.dart';
import '../../core/constants/app_constants.dart';

/// Pantalla de detalle de una foto
/// Muestra la foto en tamaño completo con opciones de editar, compartir y eliminar
class DetalleFotoScreen extends StatefulWidget {
  final Foto foto;
  final VoidCallback onFotoActualizada;

  const DetalleFotoScreen({
    super.key,
    required this.foto,
    required this.onFotoActualizada,
  });

  @override
  State<DetalleFotoScreen> createState() => _DetalleFotoScreenState();
}

class _DetalleFotoScreenState extends State<DetalleFotoScreen> {
  final FotoRepository _fotoRepository = FotoRepository();
  final PedidoRepository _pedidoRepository = PedidoRepository();
  late Foto _foto;

  @override
  void initState() {
    super.initState();
    _foto = widget.foto;
  }

  /// Comparte la foto
  Future<void> _compartirFoto() async {
    try {
      final file = File(_foto.rutaArchivo);
      if (!file.existsSync()) {
        throw Exception('El archivo de imagen no existe');
      }

      // Crear mensaje para compartir
      String mensaje = 'Cositas de la Abuela 🧁';
      if (_foto.descripcion != null && _foto.descripcion!.isNotEmpty) {
        mensaje = _foto.descripcion!;
      }

      await Share.shareXFiles(
        [XFile(file.path)],
        text: mensaje,
      );

      print('📤 Foto compartida exitosamente');
    } catch (e) {
      print('❌ Error compartiendo foto: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al compartir: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Muestra diálogo para editar información de la foto
  Future<void> _editarFoto() async {
    final TextEditingController descripcionController = 
        TextEditingController(text: _foto.descripcion);
    String tipoSeleccionado = _foto.tipo;
    String? categoriaSeleccionada = _foto.categoria;
    bool visibleSeleccionada = _foto.visibleEnGaleria;

    // Cargar categorías existentes
    final categorias = await _fotoRepository.getCategorias();

    if (!mounted) return;

    final resultado = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Editar Foto'),
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
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
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
                    labelText: 'Categoría',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Sin categoría')),
                    ...categorias.map((cat) => DropdownMenuItem(
                      value: cat,
                      child: Text(cat),
                    )),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      categoriaSeleccionada = value;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Visible en galería
                SwitchListTile(
                  title: const Text('Visible en galería'),
                  subtitle: const Text('Mostrar esta foto en la galería pública'),
                  value: visibleSeleccionada,
                  onChanged: (value) {
                    setDialogState(() {
                      visibleSeleccionada = value;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, {
                  'descripcion': descripcionController.text,
                  'tipo': tipoSeleccionado,
                  'categoria': categoriaSeleccionada,
                  'visible': visibleSeleccionada,
                });
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );

    if (resultado != null) {
      await _guardarCambios(resultado);
    }
  }

  /// Guarda los cambios de la foto en la base de datos
  Future<void> _guardarCambios(Map<String, dynamic> cambios) async {
    try {
      final fotoActualizada = _foto.copyWith(
        descripcion: cambios['descripcion'],
        tipo: cambios['tipo'],
        categoria: cambios['categoria'],
        visibleEnGaleria: cambios['visible'],
      );

      await _fotoRepository.update(fotoActualizada, _foto.id!);

      setState(() {
        _foto = fotoActualizada;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Foto actualizada'),
            backgroundColor: Colors.green,
          ),
        );
      }

      widget.onFotoActualizada();
    } catch (e) {
      print('❌ Error actualizando foto: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Muestra diálogo para asociar foto con un pedido
  Future<void> _asociarConPedido() async {
    try {
      // Cargar pedidos recientes con información de cliente
      final pedidos = await _pedidoRepository.getAll();
      
      if (!mounted) return;

      if (pedidos.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No hay pedidos disponibles'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Cargar información de clientes para cada pedido
      final pedidosConCliente = <Map<String, dynamic>>[];
      for (final pedido in pedidos) {
        final cliente = await _pedidoRepository.getClienteByPedido(pedido.id!);
        pedidosConCliente.add({
          'pedido': pedido,
          'cliente': cliente,
        });
      }

      if (!mounted) return;

      // Mostrar diálogo de selección
      final pedidoSeleccionado = await showDialog<Pedido>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Asociar con pedido'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: pedidosConCliente.length,
              itemBuilder: (context, index) {
                final item = pedidosConCliente[index];
                final pedido = item['pedido'] as Pedido;
                final cliente = item['cliente'] as Cliente?;
                
                return ListTile(
                  title: Text('Pedido #${pedido.id}'),
                  subtitle: Text(
                    '${cliente?.nombre ?? "Cliente ID: ${pedido.clienteId}"}\n'
                    'Entrega: ${pedido.fechaEntrega.toString().substring(0, 10)}',
                  ),
                  trailing: Chip(
                    label: Text(pedido.estado),
                    backgroundColor: _getEstadoColor(pedido.estado),
                  ),
                  onTap: () => Navigator.pop(context, pedido),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      );

      if (pedidoSeleccionado != null) {
        final fotoActualizada = _foto.copyWith(pedidoId: pedidoSeleccionado.id);
        await _fotoRepository.update(fotoActualizada, _foto.id!);
        
        setState(() {
          _foto = fotoActualizada;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Foto asociada al pedido #${pedidoSeleccionado.id}'),
              backgroundColor: Colors.green,
            ),
          );
        }

        widget.onFotoActualizada();
      }
    } catch (e) {
      print('❌ Error asociando foto con pedido: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Elimina la foto
  Future<void> _eliminarFoto() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar foto'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar esta foto?\n\n'
          'Esta acción no se puede deshacer.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        // Eliminar archivo físico
        final file = File(_foto.rutaArchivo);
        if (file.existsSync()) {
          await file.delete();
        }

        // Eliminar de la base de datos
        await _fotoRepository.delete(_foto.id!);

        widget.onFotoActualizada();

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Foto eliminada'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        print('❌ Error eliminando foto: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Color _getEstadoColor(String estado) {
    switch (estado) {
      case 'pendiente':
        return Colors.orange.shade100;
      case 'confirmado':
        return Colors.blue.shade100;
      case 'en_proceso':
        return Colors.purple.shade100;
      case 'completado':
        return Colors.green.shade100;
      case 'cancelado':
        return Colors.red.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  @override
  Widget build(BuildContext context) {
    final file = File(_foto.rutaArchivo);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Foto'),
        actions: [
          // Compartir
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _compartirFoto,
            tooltip: 'Compartir',
          ),
          // Editar
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editarFoto,
            tooltip: 'Editar',
          ),
          // Eliminar
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _eliminarFoto,
            tooltip: 'Eliminar',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Imagen en tamaño completo
            Hero(
              tag: 'foto_${_foto.id}',
              child: file.existsSync()
                  ? Image.file(
                      file,
                      fit: BoxFit.contain,
                    )
                  : Container(
                      height: 300,
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(
                          Icons.broken_image,
                          size: 100,
                          color: Colors.grey,
                        ),
                      ),
                    ),
            ),

            // Información de la foto
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Descripción
                  if (_foto.descripcion != null && _foto.descripcion!.isNotEmpty) ...[
                    Text(
                      'Descripción',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppConstants.textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _foto.descripcion!,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const Divider(height: 32),
                  ],

                  // Detalles en chips
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: [
                      if (_foto.categoria != null)
                        Chip(
                          avatar: const Icon(Icons.category, size: 18),
                          label: Text(_foto.categoria!),
                          backgroundColor: AppConstants.primaryColor.withOpacity(0.3),
                        ),
                      Chip(
                        avatar: const Icon(Icons.label, size: 18),
                        label: Text(_foto.tipo.replaceAll('_', ' ')),
                        backgroundColor: AppConstants.secondaryColor,
                      ),
                      Chip(
                        avatar: Icon(
                          _foto.visibleEnGaleria ? Icons.visibility : Icons.visibility_off,
                          size: 18,
                        ),
                        label: Text(_foto.visibleEnGaleria ? 'Visible' : 'Oculta'),
                        backgroundColor: _foto.visibleEnGaleria 
                            ? Colors.green.shade100 
                            : Colors.grey.shade300,
                      ),
                      if (_foto.pedidoId != null)
                        Chip(
                          avatar: const Icon(Icons.shopping_bag, size: 18),
                          label: Text('Pedido #${_foto.pedidoId}'),
                          backgroundColor: Colors.blue.shade100,
                        ),
                    ],
                  ),
                  const Divider(height: 32),

                  // Fecha
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        'Creada: ${_foto.fechaCreacion.toString().substring(0, 16)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Botón para asociar con pedido
                  if (_foto.pedidoId == null)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _asociarConPedido,
                        icon: const Icon(Icons.link),
                        label: const Text('Asociar con pedido'),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
