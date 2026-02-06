import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/cliente.dart';
import '../../data/models/familiar.dart';
import '../../data/models/pedido.dart';
import '../../data/repositories/cliente_repository.dart';
import '../../data/repositories/familiar_repository.dart';
import '../../data/repositories/pedido_repository.dart';
import 'formulario_cliente_screen.dart';
import 'detalle_pedido_screen.dart';
import 'nuevo_pedido_screen.dart';

/// Pantalla de detalle de cliente
class DetalleClienteScreen extends StatefulWidget {
  final int clienteId;

  const DetalleClienteScreen({super.key, required this.clienteId});

  @override
  State<DetalleClienteScreen> createState() => _DetalleClienteScreenState();
}

class _DetalleClienteScreenState extends State<DetalleClienteScreen> {
  final ClienteRepository _clienteRepository = ClienteRepository();
  final FamiliarRepository _familiarRepository = FamiliarRepository();
  final PedidoRepository _pedidoRepository = PedidoRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Cliente'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _navigateToEdit(),
            tooltip: 'Editar cliente',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmDelete(),
            tooltip: 'Eliminar cliente',
          ),
        ],
      ),
      body: FutureBuilder<Cliente?>(
        future: _clienteRepository.getById(widget.clienteId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Text('Error al cargar cliente: ${snapshot.error}'),
            );
          }

          final cliente = snapshot.data!;

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
                  _buildClienteInfo(cliente),
                  const SizedBox(height: 24),
                  _buildFamiliares(cliente),
                  const SizedBox(height: 24),
                  _buildPedidosRecientes(cliente),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createOrder(),
        icon: const Icon(Icons.add_shopping_cart),
        label: const Text('Crear Pedido'),
      ),
    );
  }

  Widget _buildClienteInfo(Cliente cliente) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Text(
                    cliente.nombre[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cliente.nombre,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Cliente desde ${dateFormat.format(cliente.fechaRegistro)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            if (cliente.telefono != null)
              _InfoRow(
                icon: Icons.phone,
                label: 'Teléfono',
                value: cliente.telefono!,
              ),
            if (cliente.email != null)
              _InfoRow(
                icon: Icons.email,
                label: 'Email',
                value: cliente.email!,
              ),
            if (cliente.direccion != null)
              _InfoRow(
                icon: Icons.location_on,
                label: 'Dirección',
                value: cliente.direccion!,
              ),
            if (cliente.notas != null && cliente.notas!.isNotEmpty)
              _InfoRow(
                icon: Icons.note,
                label: 'Notas',
                value: cliente.notas!,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFamiliares(Cliente cliente) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Familiares',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: () => _addFamiliar(cliente),
              icon: const Icon(Icons.add),
              label: const Text('Agregar'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        FutureBuilder<List<Familiar>>(
          future: _familiarRepository.getByCliente(cliente.id!),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final familiares = snapshot.data ?? [];

            if (familiares.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      'No hay familiares registrados',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ),
              );
            }

            return Column(
              children: familiares.map((familiar) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.purple[100],
                      child: Icon(
                        Icons.person,
                        color: Colors.purple[700],
                      ),
                    ),
                    title: Text(familiar.nombre),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (familiar.parentesco != null)
                          Text('Parentesco: ${familiar.parentesco}'),
                        if (familiar.fechaNacimiento != null)
                          Text(
                            'Cumpleaños: ${DateFormat('dd/MM/yyyy').format(familiar.fechaNacimiento!)}',
                          ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: () => _editFamiliar(cliente, familiar),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 20),
                          onPressed: () => _deleteFamiliar(familiar),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPedidosRecientes(Cliente cliente) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pedidos Recientes',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        FutureBuilder<List<Pedido>>(
          future: _pedidoRepository.getByCliente(cliente.id!),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final pedidos = snapshot.data ?? [];
            final recentOrders = pedidos.take(5).toList();

            if (recentOrders.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      'No hay pedidos registrados',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ),
              );
            }

            return Column(
              children: [
                ...recentOrders.map((pedido) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getEstadoColor(pedido.estado),
                        child: const Icon(
                          Icons.shopping_bag,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        'Entrega: ${DateFormat('dd/MM/yyyy').format(pedido.fechaEntrega)}',
                      ),
                      subtitle: Text(
                        'Estado: ${_getEstadoLabel(pedido.estado)} - \$${pedido.precioTotal.toStringAsFixed(2)}',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _viewPedido(pedido),
                    ),
                  );
                }).toList(),
                if (pedidos.length > 5)
                  TextButton(
                    onPressed: () {
                      // TODO: Navigate to all orders screen
                    },
                    child: Text('Ver todos los ${pedidos.length} pedidos'),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  void _navigateToEdit() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormularioClienteScreen(
          clienteId: widget.clienteId,
        ),
      ),
    );
    setState(() {}); // Refresh after edit
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Cliente'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar este cliente? '
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              await _clienteRepository.delete(widget.clienteId);
              if (mounted) {
                Navigator.pop(context); // Go back to list
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cliente eliminado')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _addFamiliar(Cliente cliente) {
    _showFamiliarDialog(cliente, null);
  }

  void _editFamiliar(Cliente cliente, Familiar familiar) {
    _showFamiliarDialog(cliente, familiar);
  }

  void _deleteFamiliar(Familiar familiar) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Familiar'),
        content: Text(
          '¿Eliminar a ${familiar.nombre}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _familiarRepository.delete(familiar.id!);
              setState(() {});
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Familiar eliminado')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showFamiliarDialog(Cliente cliente, Familiar? familiar) {
    final isEditing = familiar != null;
    final nombreController = TextEditingController(text: familiar?.nombre ?? '');
    final parentescoController = TextEditingController(text: familiar?.parentesco ?? '');
    final notasController = TextEditingController(text: familiar?.notas ?? '');
    DateTime? selectedDate = familiar?.fechaNacimiento;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(isEditing ? 'Editar Familiar' : 'Agregar Familiar'),
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
                    controller: parentescoController,
                    decoration: const InputDecoration(
                      labelText: 'Parentesco (hijo/a, esposo/a, etc.)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate ?? DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setDialogState(() {
                          selectedDate = date;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Fecha de Nacimiento',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        selectedDate != null
                            ? DateFormat('dd/MM/yyyy').format(selectedDate!)
                            : 'Seleccionar fecha',
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: notasController,
                    decoration: const InputDecoration(
                      labelText: 'Notas',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () async {
                  final nombre = nombreController.text.trim();
                  if (nombre.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('El nombre es requerido')),
                    );
                    return;
                  }

                  final newFamiliar = Familiar(
                    id: familiar?.id,
                    clienteId: cliente.id!,
                    nombre: nombre,
                    parentesco: parentescoController.text.trim().isNotEmpty
                        ? parentescoController.text.trim()
                        : null,
                    fechaNacimiento: selectedDate,
                    notas: notasController.text.trim().isNotEmpty
                        ? notasController.text.trim()
                        : null,
                  );

                  if (isEditing) {
                    await _familiarRepository.update(newFamiliar, familiar.id!);
                  } else {
                    await _familiarRepository.insert(newFamiliar);
                  }

                  if (mounted) {
                    Navigator.pop(context);
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isEditing
                              ? 'Familiar actualizado'
                              : 'Familiar agregado',
                        ),
                      ),
                    );
                  }
                },
                child: const Text('Guardar'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _createOrder() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NuevoPedidoScreen(),
      ),
    );
  }

  void _viewPedido(Pedido pedido) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetallePedidoScreen(pedidoId: pedido.id!),
      ),
    );
  }

  Color _getEstadoColor(String estado) {
    switch (estado) {
      case 'pendiente':
        return Colors.orange;
      case 'confirmado':
        return Colors.blue;
      case 'en_proceso':
        return Colors.purple;
      case 'completado':
        return Colors.green;
      case 'cancelado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getEstadoLabel(String estado) {
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
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
