import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/cliente.dart';
import '../../data/models/producto.dart';
import '../../data/models/bizcochuelo.dart';
import '../../data/models/relleno.dart';
import '../../data/models/tematica.dart';
import '../../data/models/pedido.dart';
import '../../data/models/pedido_detalle.dart';
import '../../data/models/detalle_relleno.dart';
import '../../data/repositories/cliente_repository.dart';
import '../../data/repositories/producto_repository.dart';
import '../../data/repositories/pedido_repository.dart';

/// Item de producto agregado al pedido
class ProductoItem {
  final Producto producto;
  int cantidad;
  Bizcochuelo? bizcochuelo;
  Tematica? tematica;
  List<Relleno> rellenos;
  String? observaciones;

  ProductoItem({
    required this.producto,
    this.cantidad = 1,
    this.bizcochuelo,
    this.tematica,
    this.rellenos = const [],
    this.observaciones,
  });

  double get subtotal => producto.precioBase * cantidad;
}

/// Pantalla de creación de nuevo pedido con wizard de 4 pasos
class NuevoPedidoScreen extends StatefulWidget {
  const NuevoPedidoScreen({super.key});

  @override
  State<NuevoPedidoScreen> createState() => _NuevoPedidoScreenState();
}

class _NuevoPedidoScreenState extends State<NuevoPedidoScreen> {
  int _currentStep = 0;
  
  // Repositorios
  final ClienteRepository _clienteRepository = ClienteRepository();
  final ProductoRepository _productoRepository = ProductoRepository();
  final BizcochueloRepository _bizcochueloRepository = BizcochueloRepository();
  final RellenoRepository _rellenoRepository = RellenoRepository();
  final TematicaRepository _tematicaRepository = TematicaRepository();
  final PedidoRepository _pedidoRepository = PedidoRepository();
  final PedidoDetalleRepository _pedidoDetalleRepository = PedidoDetalleRepository();
  final DetalleRellenoRepository _detalleRellenoRepository = DetalleRellenoRepository();

  // Datos del pedido
  Cliente? _selectedCliente;
  final List<ProductoItem> _productosAgregados = [];
  DateTime? _fechaEntrega;
  double? _precioTotal;
  double? _senia;
  String? _observaciones;

  // Controllers
  final TextEditingController _searchClienteController = TextEditingController();
  final TextEditingController _observacionesController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  final TextEditingController _seniaController = TextEditingController();

  @override
  void dispose() {
    _searchClienteController.dispose();
    _observacionesController.dispose();
    _precioController.dispose();
    _seniaController.dispose();
    super.dispose();
  }

  bool get _canProceed {
    switch (_currentStep) {
      case 0:
        return _selectedCliente != null;
      case 1:
        return _productosAgregados.isNotEmpty;
      case 2:
        return _fechaEntrega != null && _precioTotal != null;
      default:
        return true;
    }
  }

  double get _totalCalculado {
    return _productosAgregados.fold(0.0, (sum, item) => sum + item.subtotal);
  }

  void _nextStep() {
    if (_currentStep < 3 && _canProceed) {
      setState(() {
        _currentStep++;
        if (_currentStep == 2) {
          _precioTotal = _totalCalculado;
          _precioController.text = _precioTotal!.toStringAsFixed(2);
        }
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  Future<void> _guardarPedido() async {
    if (_selectedCliente == null || _fechaEntrega == null || _precioTotal == null) {
      return;
    }

    try {
      // Crear el pedido principal
      final pedido = Pedido(
        clienteId: _selectedCliente!.id!,
        fechaPedido: DateTime.now(),
        fechaEntrega: _fechaEntrega!,
        estado: 'pendiente',
        precioTotal: _precioTotal!,
        senia: _senia,
        observaciones: _observaciones,
      );

      final pedidoId = await _pedidoRepository.insert(pedido);

      // Crear los detalles del pedido
      for (final item in _productosAgregados) {
        final detalle = PedidoDetalle(
          pedidoId: pedidoId,
          productoId: item.producto.id!,
          bizcochueloId: item.bizcochuelo?.id,
          tematicaId: item.tematica?.id,
          cantidad: item.cantidad,
          precioUnitario: item.producto.precioBase,
          subtotal: item.subtotal,
          observaciones: item.observaciones,
        );

        final detalleId = await _pedidoDetalleRepository.insert(detalle);

        // Crear los rellenos para este detalle
        for (int i = 0; i < item.rellenos.length; i++) {
          final detalleRelleno = DetalleRelleno(
            pedidoDetalleId: detalleId,
            rellenoId: item.rellenos[i].id!,
            capa: i + 1,
          );
          await _detalleRellenoRepository.insert(detalleRelleno);
        }
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Pedido creado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar pedido: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Pedido'),
        elevation: 2,
      ),
      body: Column(
        children: [
          // Stepper indicator
          _buildStepIndicator(),
          
          // Step content
          Expanded(
            child: IndexedStack(
              index: _currentStep,
              children: [
                _buildStep1Cliente(),
                _buildStep2Productos(),
                _buildStep3FechasPrecios(),
                _buildStep4Confirmacion(),
              ],
            ),
          ),

          // Navigation buttons
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStepItem(0, 'Cliente', Icons.person),
          _buildStepDivider(),
          _buildStepItem(1, 'Productos', Icons.cake),
          _buildStepDivider(),
          _buildStepItem(2, 'Fechas', Icons.calendar_today),
          _buildStepDivider(),
          _buildStepItem(3, 'Confirmar', Icons.check_circle),
        ],
      ),
    );
  }

  Widget _buildStepItem(int step, String label, IconData icon) {
    final isActive = _currentStep == step;
    final isCompleted = _currentStep > step;
    
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted
                  ? Colors.green
                  : isActive
                      ? Theme.of(context).primaryColor
                      : Colors.grey[300],
            ),
            child: Icon(
              isCompleted ? Icons.check : icon,
              color: isActive || isCompleted ? Colors.white : Colors.grey[600],
              size: 20,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive
                  ? Theme.of(context).primaryColor
                  : Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStepDivider() {
    return Container(
      width: 20,
      height: 2,
      color: Colors.grey[300],
      margin: const EdgeInsets.only(bottom: 20),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _previousStep,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Anterior'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _canProceed
                  ? (_currentStep < 3 ? _nextStep : _guardarPedido)
                  : null,
              icon: Icon(_currentStep < 3 ? Icons.arrow_forward : Icons.save),
              label: Text(_currentStep < 3 ? 'Siguiente' : 'Guardar Pedido'),
            ),
          ),
        ],
      ),
    );
  }

  // ========== PASO 1: CLIENTE ==========
  Widget _buildStep1Cliente() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Seleccionar Cliente',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Busca un cliente existente o crea uno nuevo',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),

          // Buscador de clientes
          TextField(
            controller: _searchClienteController,
            decoration: InputDecoration(
              hintText: 'Buscar cliente por nombre...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              suffixIcon: _searchClienteController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _searchClienteController.clear();
                        });
                      },
                    )
                  : null,
            ),
            onChanged: (value) => setState(() {}),
          ),
          const SizedBox(height: 16),

          // Botón crear nuevo cliente
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showNewClienteDialog(),
              icon: const Icon(Icons.person_add),
              label: const Text('Crear Nuevo Cliente'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Cliente seleccionado
          if (_selectedCliente != null) ...[
            Card(
              elevation: 3,
              color: Colors.green[50],
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Icon(Icons.check, color: Colors.white),
                ),
                title: Text(
                  _selectedCliente!.nombre,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(_selectedCliente!.telefono ?? 'Sin teléfono'),
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => _selectedCliente = null),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Lista de clientes
          const Text(
            'Clientes Recientes',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          
          FutureBuilder<List<Cliente>>(
            future: _searchClienteController.text.isEmpty
                ? _clienteRepository.getRecent(limit: 20)
                : _clienteRepository.searchByName(_searchClienteController.text),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                      child: Text('No se encontraron clientes'),
                    ),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final cliente = snapshot.data![index];
                  final isSelected = _selectedCliente?.id == cliente.id;
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    color: isSelected ? Colors.blue[50] : null,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isSelected ? Colors.blue : Colors.grey,
                        child: Text(
                          cliente.nombre[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        cliente.nombre,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      subtitle: Text(cliente.telefono ?? 'Sin teléfono'),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle, color: Colors.blue)
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedCliente = cliente;
                        });
                      },
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  // ========== PASO 2: PRODUCTOS ==========
  Widget _buildStep2Productos() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Agregar Productos',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Selecciona los productos y configura sus detalles',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),

                // Productos agregados
                if (_productosAgregados.isNotEmpty) ...[
                  const Text(
                    'Productos Agregados',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ..._productosAgregados.asMap().entries.map((entry) {
                    return _buildProductoCard(entry.key, entry.value);
                  }).toList(),
                  const SizedBox(height: 16),
                  Card(
                    color: Colors.blue[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '\$${_totalCalculado.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Botón agregar producto
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showAddProductoDialog(),
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar Producto'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductoCard(int index, ProductoItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.producto.nombre,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () => _editProductoItem(index),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                  onPressed: () {
                    setState(() {
                      _productosAgregados.removeAt(index);
                    });
                  },
                ),
              ],
            ),
            const Divider(),
            _buildDetailRow('Cantidad', '${item.cantidad}'),
            if (item.bizcochuelo != null)
              _buildDetailRow('Bizcochuelo', item.bizcochuelo!.nombre),
            if (item.tematica != null)
              _buildDetailRow('Temática', item.tematica!.nombre),
            if (item.rellenos.isNotEmpty)
              _buildDetailRow(
                'Rellenos',
                item.rellenos.map((r) => r.nombre).join(', '),
              ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Subtotal:',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                Text(
                  '\$${item.subtotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  // ========== PASO 3: FECHAS Y PRECIOS ==========
  Widget _buildStep3FechasPrecios() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Fechas y Precios',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Configura la fecha de entrega y ajusta el precio',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),

          // Fecha de entrega
          Card(
            child: ListTile(
              leading: const Icon(Icons.calendar_today, color: Colors.blue),
              title: const Text('Fecha de Entrega *'),
              subtitle: Text(
                _fechaEntrega != null
                    ? DateFormat('dd/MM/yyyy').format(_fechaEntrega!)
                    : 'Seleccionar fecha',
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _fechaEntrega ?? DateTime.now().add(const Duration(days: 1)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  locale: const Locale('es', 'ES'),
                );
                if (date != null) {
                  setState(() {
                    _fechaEntrega = date;
                  });
                }
              },
            ),
          ),
          const SizedBox(height: 16),

          // Precio total
          TextField(
            controller: _precioController,
            decoration: InputDecoration(
              labelText: 'Precio Total *',
              prefixText: '\$ ',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              helperText: 'Calculado: \$${_totalCalculado.toStringAsFixed(2)}',
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              _precioTotal = double.tryParse(value);
            },
          ),
          const SizedBox(height: 16),

          // Seña
          TextField(
            controller: _seniaController,
            decoration: InputDecoration(
              labelText: 'Seña/Adelanto (opcional)',
              prefixText: '\$ ',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              helperText: 'Monto adelantado por el cliente',
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              _senia = value.isEmpty ? null : double.tryParse(value);
            },
          ),
          const SizedBox(height: 16),

          // Observaciones
          TextField(
            controller: _observacionesController,
            decoration: InputDecoration(
              labelText: 'Observaciones (opcional)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              helperText: 'Notas adicionales sobre el pedido',
            ),
            maxLines: 4,
            onChanged: (value) {
              _observaciones = value.isEmpty ? null : value;
            },
          ),
        ],
      ),
    );
  }

  // ========== PASO 4: CONFIRMACIÓN ==========
  Widget _buildStep4Confirmacion() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Confirmar Pedido',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Revisa todos los detalles antes de guardar',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),

          // Cliente
          _buildSummarySection(
            'Cliente',
            Icons.person,
            Colors.blue,
            [
              _buildSummaryRow('Nombre', _selectedCliente?.nombre ?? ''),
              if (_selectedCliente?.telefono != null)
                _buildSummaryRow('Teléfono', _selectedCliente!.telefono!),
              if (_selectedCliente?.email != null)
                _buildSummaryRow('Email', _selectedCliente!.email!),
            ],
          ),
          const SizedBox(height: 16),

          // Productos
          _buildSummarySection(
            'Productos (${_productosAgregados.length})',
            Icons.cake,
            Colors.orange,
            _productosAgregados.map((item) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• ${item.producto.nombre} x${item.cantidad}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (item.bizcochuelo != null)
                    Text('  Bizcochuelo: ${item.bizcochuelo!.nombre}'),
                  if (item.tematica != null)
                    Text('  Temática: ${item.tematica!.nombre}'),
                  if (item.rellenos.isNotEmpty)
                    Text('  Rellenos: ${item.rellenos.map((r) => r.nombre).join(", ")}'),
                  Text('  Subtotal: \$${item.subtotal.toStringAsFixed(2)}'),
                  const SizedBox(height: 8),
                ],
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Fechas y Precios
          _buildSummarySection(
            'Detalles del Pedido',
            Icons.attach_money,
            Colors.green,
            [
              _buildSummaryRow(
                'Fecha de Entrega',
                _fechaEntrega != null
                    ? DateFormat('dd/MM/yyyy').format(_fechaEntrega!)
                    : '',
              ),
              _buildSummaryRow(
                'Precio Total',
                '\$${_precioTotal?.toStringAsFixed(2) ?? "0.00"}',
              ),
              if (_senia != null)
                _buildSummaryRow(
                  'Seña',
                  '\$${_senia!.toStringAsFixed(2)}',
                ),
              if (_senia != null)
                _buildSummaryRow(
                  'Saldo Pendiente',
                  '\$${((_precioTotal ?? 0) - _senia!).toStringAsFixed(2)}',
                ),
              if (_observaciones != null && _observaciones!.isNotEmpty)
                _buildSummaryRow('Observaciones', _observaciones!),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection(
    String title,
    IconData icon,
    Color color,
    List<Widget> children,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ========== DIÁLOGOS ==========

  void _showNewClienteDialog() {
    final nombreController = TextEditingController();
    final telefonoController = TextEditingController();
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nuevo Cliente'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: telefonoController,
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nombreController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('El nombre es requerido')),
                );
                return;
              }

              final cliente = Cliente(
                nombre: nombreController.text,
                telefono: telefonoController.text.isEmpty ? null : telefonoController.text,
                email: emailController.text.isEmpty ? null : emailController.text,
                fechaRegistro: DateTime.now(),
              );

              try {
                await _clienteRepository.insert(cliente);
                final clientes = await _clienteRepository.searchByName(nombreController.text);
                if (clientes.isNotEmpty) {
                  setState(() {
                    _selectedCliente = clientes.first;
                  });
                }
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cliente creado exitosamente'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  void _showAddProductoDialog() async {
    final productos = await _productoRepository.getActive();
    if (!mounted) return;

    final producto = await showDialog<Producto>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleccionar Producto'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: productos.length,
            itemBuilder: (context, index) {
              final prod = productos[index];
              return ListTile(
                title: Text(prod.nombre),
                subtitle: Text('\$${prod.precioBase.toStringAsFixed(2)}'),
                trailing: Text(prod.categoria ?? ''),
                onTap: () => Navigator.of(context).pop(prod),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );

    if (producto != null) {
      _showConfigureProductoDialog(producto);
    }
  }

  void _showConfigureProductoDialog(Producto producto, [int? editIndex]) async {
    final bizcochuelos = await _bizcochueloRepository.getActive();
    final tematicas = await _tematicaRepository.getActive();
    final rellenos = await _rellenoRepository.getActive();

    if (!mounted) return;

    // Si estamos editando, usar valores existentes
    final existingItem = editIndex != null ? _productosAgregados[editIndex] : null;
    
    int cantidad = existingItem?.cantidad ?? 1;
    Bizcochuelo? selectedBizcochuelo = existingItem?.bizcochuelo;
    Tematica? selectedTematica = existingItem?.tematica;
    List<Relleno> selectedRellenos = List.from(existingItem?.rellenos ?? []);
    String? observaciones = existingItem?.observaciones;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(editIndex != null ? 'Editar Producto' : 'Configurar Producto'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  producto.nombre,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '\$${producto.precioBase.toStringAsFixed(2)} c/u',
                  style: const TextStyle(color: Colors.grey),
                ),
                const Divider(height: 24),

                // Cantidad
                Row(
                  children: [
                    const Text('Cantidad:', style: TextStyle(fontSize: 16)),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: cantidad > 1
                          ? () => setDialogState(() => cantidad--)
                          : null,
                    ),
                    Text(
                      '$cantidad',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () => setDialogState(() => cantidad++),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Bizcochuelo
                const Text('Bizcochuelo:', style: TextStyle(fontSize: 14)),
                const SizedBox(height: 8),
                DropdownButtonFormField<Bizcochuelo>(
                  value: selectedBizcochuelo,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  hint: const Text('Seleccionar'),
                  items: bizcochuelos.map((biz) {
                    return DropdownMenuItem(
                      value: biz,
                      child: Text(biz.nombre),
                    );
                  }).toList(),
                  onChanged: (value) => setDialogState(() => selectedBizcochuelo = value),
                ),
                const SizedBox(height: 16),

                // Temática
                const Text('Temática:', style: TextStyle(fontSize: 14)),
                const SizedBox(height: 8),
                DropdownButtonFormField<Tematica>(
                  value: selectedTematica,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  hint: const Text('Seleccionar'),
                  items: tematicas.map((tem) {
                    return DropdownMenuItem(
                      value: tem,
                      child: Text(tem.nombre),
                    );
                  }).toList(),
                  onChanged: (value) => setDialogState(() => selectedTematica = value),
                ),
                const SizedBox(height: 16),

                // Rellenos
                const Text('Rellenos (capas):', style: TextStyle(fontSize: 14)),
                const SizedBox(height: 8),
                ...rellenos.map((relleno) {
                  final isSelected = selectedRellenos.contains(relleno);
                  return CheckboxListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(relleno.nombre, style: const TextStyle(fontSize: 13)),
                    value: isSelected,
                    onChanged: (checked) {
                      setDialogState(() {
                        if (checked == true) {
                          selectedRellenos.add(relleno);
                        } else {
                          selectedRellenos.remove(relleno);
                        }
                      });
                    },
                  );
                }).toList(),
                const SizedBox(height: 16),

                // Subtotal
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Subtotal:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '\$${(producto.precioBase * cantidad).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final item = ProductoItem(
                  producto: producto,
                  cantidad: cantidad,
                  bizcochuelo: selectedBizcochuelo,
                  tematica: selectedTematica,
                  rellenos: selectedRellenos,
                  observaciones: observaciones,
                );

                setState(() {
                  if (editIndex != null) {
                    _productosAgregados[editIndex] = item;
                  } else {
                    _productosAgregados.add(item);
                  }
                });

                Navigator.of(context).pop();
              },
              child: Text(editIndex != null ? 'Guardar' : 'Agregar'),
            ),
          ],
        ),
      ),
    );
  }

  void _editProductoItem(int index) {
    final item = _productosAgregados[index];
    _showConfigureProductoDialog(item.producto, index);
  }
}
