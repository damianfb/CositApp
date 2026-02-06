import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../../data/models/pedido.dart';
import '../../data/models/pedido_detalle.dart';
import '../../data/models/cliente.dart';
import '../../data/models/producto.dart';
import '../../data/models/bizcochuelo.dart';
import '../../data/models/tematica.dart';
import '../../data/models/relleno.dart';
import '../../data/models/detalle_relleno.dart';
import '../../data/models/foto.dart';
import '../../data/repositories/pedido_repository.dart';
import '../../data/repositories/cliente_repository.dart';
import '../../data/repositories/producto_repository.dart';
import '../../data/repositories/foto_repository.dart';
import 'detalle_foto_screen.dart';

class _DetalleData {
  final Pedido pedido;
  final Cliente cliente;
  final List<_ProductoCompleto> productos;

  _DetalleData({
    required this.pedido,
    required this.cliente,
    required this.productos,
  });
}

class _ProductoCompleto {
  final PedidoDetalle detalle;
  final Producto producto;
  final Bizcochuelo? bizcochuelo;
  final Tematica? tematica;
  final List<Relleno> rellenos;

  _ProductoCompleto({
    required this.detalle,
    required this.producto,
    this.bizcochuelo,
    this.tematica,
    required this.rellenos,
  });
}

class DetallePedidoScreen extends StatefulWidget {
  final int pedidoId;

  const DetallePedidoScreen({
    super.key,
    required this.pedidoId,
  });

  @override
  State<DetallePedidoScreen> createState() => _DetallePedidoScreenState();
}

class _DetallePedidoScreenState extends State<DetallePedidoScreen> {
  final PedidoRepository _pedidoRepository = PedidoRepository();
  final ClienteRepository _clienteRepository = ClienteRepository();
  final ProductoRepository _productoRepository = ProductoRepository();
  final PedidoDetalleRepository _detalleRepository = PedidoDetalleRepository();
  final DetalleRellenoRepository _rellenoRepository = DetalleRellenoRepository();
  final FotoRepository _fotoRepository = FotoRepository();
  final ImagePicker _imagePicker = ImagePicker();

  // Checklist postventa
  final Map<String, bool> _checklistPostventa = {
    'Producto entregado': false,
    'Cliente satisfecho': false,
    'Foto tomada': false,
    'Feedback recibido': false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Pedido'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Función de editar próximamente'),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Función de compartir próximamente'),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: FutureBuilder<_DetalleData>(
        future: _loadDetalleData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          final data = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOrderInfoCard(data),
                  const SizedBox(height: 16),
                  _buildClientCard(data.cliente),
                  const SizedBox(height: 16),
                  _buildProductsSection(data.productos),
                  const SizedBox(height: 16),
                  _buildPaymentSection(data.pedido),
                  const SizedBox(height: 16),
                  _buildStatusSection(data.pedido),
                  const SizedBox(height: 16),
                  _buildPhotosSection(data.pedido),
                  if (data.pedido.estado == 'completado') ...[
                    const SizedBox(height: 16),
                    _buildPostventaSection(),
                  ],
                  if (data.pedido.observaciones?.isNotEmpty ?? false) ...[
                    const SizedBox(height: 16),
                    _buildObservacionesCard(data.pedido.observaciones!),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<_DetalleData> _loadDetalleData() async {
    final pedido = await _pedidoRepository.getById(widget.pedidoId);
    if (pedido == null) {
      throw Exception('Pedido no encontrado');
    }

    final cliente = await _clienteRepository.getById(pedido.clienteId);
    if (cliente == null) {
      throw Exception('Cliente no encontrado');
    }

    final detalles = await _detalleRepository.getByPedido(widget.pedidoId);
    final productos = <_ProductoCompleto>[];

    for (final detalle in detalles) {
      final producto = await _productoRepository.getById(detalle.productoId);
      if (producto == null) continue;

      Bizcochuelo? bizcochuelo;
      if (detalle.bizcochueloId != null) {
        bizcochuelo = await _productoRepository.getBizcochueloById(detalle.bizcochueloId!);
      }

      Tematica? tematica;
      if (detalle.tematicaId != null) {
        tematica = await _productoRepository.getTematicaById(detalle.tematicaId!);
      }

      final detalleRellenos = await _rellenoRepository.getByPedidoDetalle(detalle.id!);
      final rellenos = <Relleno>[];
      for (final dr in detalleRellenos) {
        final relleno = await _productoRepository.getRellenoById(dr.rellenoId);
        if (relleno != null) {
          rellenos.add(relleno);
        }
      }

      productos.add(_ProductoCompleto(
        detalle: detalle,
        producto: producto,
        bizcochuelo: bizcochuelo,
        tematica: tematica,
        rellenos: rellenos,
      ));
    }

    return _DetalleData(
      pedido: pedido,
      cliente: cliente,
      productos: productos,
    );
  }

  Widget _buildOrderInfoCard(_DetalleData data) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pedido #${data.pedido.id}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildStatusBadge(data.pedido.estado),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow(Icons.calendar_today, 'Fecha de Pedido',
                dateFormat.format(data.pedido.fechaPedido)),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.event, 'Fecha de Entrega',
                dateFormat.format(data.pedido.fechaEntrega)),
            if (data.pedido.fechaCompletado != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow(Icons.check_circle, 'Fecha Completado',
                  dateFormat.format(data.pedido.fechaCompletado!)),
            ],
            const SizedBox(height: 8),
            _buildInfoRow(Icons.attach_money, 'Total',
                '\$${data.pedido.precioTotal.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }

  Widget _buildClientCard(Cliente cliente) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ver detalle de ${cliente.nombre}'),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.person, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Cliente',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
              const Divider(height: 16),
              Text(
                cliente.nombre,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (cliente.telefono != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.phone, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(cliente.telefono!),
                  ],
                ),
              ],
              if (cliente.email != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.email, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(cliente.email!),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductsSection(List<_ProductoCompleto> productos) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Productos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 16),
            if (productos.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No hay productos en este pedido'),
                ),
              )
            else
              ...productos.map((p) => _buildProductCard(p)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(_ProductoCompleto productoCompleto) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${productoCompleto.detalle.cantidad}x',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      productoCompleto.producto.nombre,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (productoCompleto.detalle.tamanio != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Tamaño: ${productoCompleto.detalle.tamanio}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Text(
                '\$${productoCompleto.detalle.subtotal.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          if (productoCompleto.bizcochuelo != null) ...[
            const SizedBox(height: 8),
            _buildDetailRow('Bizcochuelo', productoCompleto.bizcochuelo!.nombre),
          ],
          if (productoCompleto.tematica != null) ...[
            const SizedBox(height: 4),
            _buildDetailRow('Temática', productoCompleto.tematica!.nombre),
          ],
          if (productoCompleto.rellenos.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text(
              'Rellenos:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            ...productoCompleto.rellenos.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(left: 8, top: 2),
                child: Row(
                  children: [
                    Text(
                      '• Capa ${entry.key + 1}:',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      entry.value.nombre,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
          if (productoCompleto.detalle.observaciones != null &&
              productoCompleto.detalle.observaciones!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.amber[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.note, size: 16, color: Colors.amber[800]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      productoCompleto.detalle.observaciones!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildPaymentSection(Pedido pedido) {
    final saldoPendiente = pedido.precioTotal - (pedido.senia ?? 0);
    final isPaid = saldoPendiente <= 0;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.payment, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Pagos',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 16),
            _buildPaymentRow('Total', pedido.precioTotal, Colors.black),
            const SizedBox(height: 8),
            _buildPaymentRow('Seña', pedido.senia ?? 0, Colors.blue),
            const SizedBox(height: 8),
            _buildPaymentRow('Saldo Pendiente', saldoPendiente,
                isPaid ? Colors.green : Colors.red),
            if (isPaid) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[300]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green[700], size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Pagado completamente',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (!isPaid) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showAddPaymentDialog(pedido),
                  icon: const Icon(Icons.add),
                  label: const Text('Registrar Pago'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentRow(String label, double amount, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusSection(Pedido pedido) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.timeline, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Estado del Pedido',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatusBadge(pedido.estado, large: true),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showChangeStatusDialog(pedido),
                icon: const Icon(Icons.edit),
                label: const Text('Cambiar Estado'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostventaSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.checklist, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Checklist Postventa',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 16),
            ..._checklistPostventa.entries.map((entry) {
              return CheckboxListTile(
                title: Text(entry.key),
                value: entry.value,
                onChanged: (bool? value) {
                  setState(() {
                    _checklistPostventa[entry.key] = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotosSection(Pedido pedido) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.photo_library, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Fotos del Pedido',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.add_a_photo),
                  onPressed: () => _agregarFoto(pedido),
                  tooltip: 'Agregar foto',
                ),
              ],
            ),
            const Divider(height: 16),
            FutureBuilder<List<Foto>>(
              future: _fotoRepository.getByPedido(pedido.id!),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final fotos = snapshot.data!;
                if (fotos.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Icon(Icons.photo_library_outlined, 
                            size: 48, 
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No hay fotos asociadas a este pedido',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: fotos.length,
                    itemBuilder: (context, index) {
                      final foto = fotos[index];
                      return _buildFotoThumbnail(foto);
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFotoThumbnail(Foto foto) {
    final file = File(foto.rutaArchivo);
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetalleFotoScreen(
              foto: foto,
              onFotoActualizada: () => setState(() {}),
            ),
          ),
        );
      },
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 8),
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: file.existsSync()
              ? Image.file(
                  file,
                  fit: BoxFit.cover,
                )
              : Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
        ),
      ),
    );
  }

  Future<void> _agregarFoto(Pedido pedido) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Tomar foto con la cámara'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Seleccionar de la galería'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
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

    if (source == null) return;

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image == null) return;

      // Guardar foto
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String fotosDir = path.join(appDocDir.path, 'fotos');
      final Directory fotosDirPath = Directory(fotosDir);
      if (!await fotosDirPath.exists()) {
        await fotosDirPath.create(recursive: true);
      }

      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String extension = path.extension(image.path);
      final String nombreArchivo = 'foto_$timestamp$extension';
      final String rutaDestino = path.join(fotosDir, nombreArchivo);

      final File archivoOriginal = File(image.path);
      await archivoOriginal.copy(rutaDestino);

      // Guardar en base de datos
      final foto = Foto(
        pedidoId: pedido.id!,
        rutaArchivo: rutaDestino,
        tipo: 'producto_final',
        fechaCreacion: DateTime.now(),
        visibleEnGaleria: true,
      );

      await _fotoRepository.insert(foto);

      setState(() {});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Foto agregada al pedido'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('❌ Error agregando foto: $e');
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

  Widget _buildObservacionesCard(String observaciones) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.notes, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Observaciones',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 16),
            Text(
              observaciones,
              style: const TextStyle(fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String estado, {bool large = false}) {
    Color color;
    String text;

    switch (estado) {
      case 'pendiente':
        color = Colors.orange;
        text = 'Pendiente';
        break;
      case 'confirmado':
        color = Colors.blue;
        text = 'Confirmado';
        break;
      case 'en_proceso':
        color = Colors.purple;
        text = 'En Proceso';
        break;
      case 'completado':
        color = Colors.green;
        text = 'Completado';
        break;
      case 'cancelado':
        color = Colors.red;
        text = 'Cancelado';
        break;
      default:
        color = Colors.grey;
        text = estado;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 16 : 12,
        vertical: large ? 12 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(large ? 8 : 12),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: large ? 16 : 12,
        ),
      ),
    );
  }

  String _getStatusLabel(String estado) {
    switch (estado) {
      case 'pendiente':
        return 'Pendiente';
      case 'confirmado':
        return 'Confirmado';
      case 'en_proceso':
        return 'En Proceso';
      case 'completado':
        return 'Completado';
      case 'cancelado':
        return 'Cancelado';
      default:
        return estado;
    }
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  void _showChangeStatusDialog(Pedido pedido) {
    final estados = [
      {'value': 'pendiente', 'label': 'Pendiente'},
      {'value': 'confirmado', 'label': 'Confirmado'},
      {'value': 'en_proceso', 'label': 'En Proceso'},
      {'value': 'completado', 'label': 'Completado'},
      {'value': 'cancelado', 'label': 'Cancelado'},
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cambiar Estado'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: estados.map((estado) {
              return ListTile(
                title: Text(estado['label']!),
                leading: Radio<String>(
                  value: estado['value']!,
                  groupValue: pedido.estado,
                  onChanged: (String? value) {
                    Navigator.of(context).pop();
                    if (value != null) {
                      _changeStatus(pedido, value);
                    }
                  },
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _changeStatus(pedido, estado['value']!);
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _changeStatus(Pedido pedido, String nuevoEstado) async {
    final estadoLabel = _getStatusLabel(nuevoEstado);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar cambio'),
          content: Text('¿Cambiar estado del pedido a "$estadoLabel"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        final updatedPedido = pedido.copyWith(
          estado: nuevoEstado,
          fechaCompletado:
              nuevoEstado == 'completado' ? DateTime.now() : pedido.fechaCompletado,
        );
        await _pedidoRepository.update(updatedPedido, pedido.id!);
        setState(() {});
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Estado actualizado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al actualizar estado: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showAddPaymentDialog(Pedido pedido) {
    final controller = TextEditingController();
    final saldoPendiente = pedido.precioTotal - (pedido.senia ?? 0);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Registrar Pago'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Saldo pendiente: \$${saldoPendiente.toStringAsFixed(2)}'),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Monto a pagar',
                  prefixText: '\$',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final monto = double.tryParse(controller.text);
                if (monto == null || monto <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Ingrese un monto válido'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                Navigator.of(context).pop();
                _addPayment(pedido, monto);
              },
              child: const Text('Registrar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addPayment(Pedido pedido, double monto) async {
    try {
      final nuevaSenia = (pedido.senia ?? 0) + monto;
      final updatedPedido = pedido.copyWith(senia: nuevaSenia);
      await _pedidoRepository.update(updatedPedido, pedido.id!);
      setState(() {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pago de \$${monto.toStringAsFixed(2)} registrado'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al registrar pago: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar Pedido'),
          content: const Text(
            '¿Está seguro que desea eliminar este pedido? Esta acción no se puede deshacer.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _deletePedido();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deletePedido() async {
    try {
      await _pedidoRepository.delete(widget.pedidoId);
      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pedido eliminado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar pedido: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
