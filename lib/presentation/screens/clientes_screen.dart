import 'package:flutter/material.dart';
import '../../data/models/cliente.dart';
import '../../data/repositories/cliente_repository.dart';
import '../../data/repositories/familiar_repository.dart';
import '../../data/repositories/pedido_repository.dart';
import 'detalle_cliente_screen.dart';
import 'formulario_cliente_screen.dart';

/// Pantalla de listado de clientes
class ClientesScreen extends StatefulWidget {
  const ClientesScreen({super.key});

  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  final ClienteRepository _clienteRepository = ClienteRepository();
  final FamiliarRepository _familiarRepository = FamiliarRepository();
  final PedidoRepository _pedidoRepository = PedidoRepository();
  
  String _searchQuery = '';
  String _sortOrder = 'name'; // 'name' or 'recent'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              setState(() {
                _sortOrder = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'name',
                child: Text('Ordenar por nombre'),
              ),
              const PopupMenuItem(
                value: 'recent',
                child: Text('Ordenar por recientes'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar cliente...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          
          // Lista de clientes
          Expanded(
            child: FutureBuilder<List<Cliente>>(
              future: _loadClientes(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                final clientes = snapshot.data ?? [];

                if (clientes.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'No hay clientes registrados'
                              : 'No se encontraron clientes',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchQuery.isEmpty
                              ? 'Toca el botón + para agregar un cliente'
                              : 'Intenta con otra búsqueda',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: clientes.length,
                  itemBuilder: (context, index) {
                    final cliente = clientes[index];
                    return _ClienteCard(
                      cliente: cliente,
                      familiarRepository: _familiarRepository,
                      pedidoRepository: _pedidoRepository,
                      onTap: () => _navigateToDetalle(cliente),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToFormulario,
        child: const Icon(Icons.add),
        tooltip: 'Agregar cliente',
      ),
    );
  }

  Future<List<Cliente>> _loadClientes() async {
    List<Cliente> clientes;
    
    if (_sortOrder == 'recent') {
      clientes = await _clienteRepository.getRecent(limit: 100);
    } else {
      clientes = await _clienteRepository.getActive();
    }

    // Aplicar filtro de búsqueda
    if (_searchQuery.isNotEmpty) {
      clientes = clientes.where((cliente) {
        return cliente.nombre.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    return clientes;
  }

  void _navigateToDetalle(Cliente cliente) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetalleClienteScreen(clienteId: cliente.id!),
      ),
    );
    setState(() {}); // Refresh list after returning
  }

  void _navigateToFormulario() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FormularioClienteScreen(),
      ),
    );
    setState(() {}); // Refresh list after returning
  }
}

/// Card de cliente en la lista
class _ClienteCard extends StatelessWidget {
  final Cliente cliente;
  final FamiliarRepository familiarRepository;
  final PedidoRepository pedidoRepository;
  final VoidCallback onTap;

  const _ClienteCard({
    required this.cliente,
    required this.familiarRepository,
    required this.pedidoRepository,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(
                      cliente.nombre[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                cliente.nombre,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            FutureBuilder<int>(
                              future: familiarRepository.countByCliente(cliente.id!),
                              builder: (context, snapshot) {
                                final count = snapshot.data ?? 0;
                                if (count > 0) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.purple[50],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.people,
                                          size: 14,
                                          color: Colors.purple[700],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '$count',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.purple[700],
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        if (cliente.telefono != null)
                          Row(
                            children: [
                              Icon(
                                Icons.phone,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                cliente.telefono!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        if (cliente.email != null)
                          Row(
                            children: [
                              Icon(
                                Icons.email,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  cliente.email!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              FutureBuilder<List<dynamic>>(
                future: Future.wait([
                  pedidoRepository.getByCliente(cliente.id!),
                ]),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final pedidos = snapshot.data![0] as List;
                    final numOrders = pedidos.length;
                    
                    return Row(
                      children: [
                        Icon(
                          Icons.shopping_bag_outlined,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$numOrders ${numOrders == 1 ? 'pedido' : 'pedidos'}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
