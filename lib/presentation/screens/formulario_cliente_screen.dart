import 'package:flutter/material.dart';
import '../../data/models/cliente.dart';
import '../../data/repositories/cliente_repository.dart';

/// Pantalla de formulario para crear/editar cliente
class FormularioClienteScreen extends StatefulWidget {
  final int? clienteId;

  const FormularioClienteScreen({super.key, this.clienteId});

  @override
  State<FormularioClienteScreen> createState() => _FormularioClienteScreenState();
}

class _FormularioClienteScreenState extends State<FormularioClienteScreen> {
  final _formKey = GlobalKey<FormState>();
  final ClienteRepository _clienteRepository = ClienteRepository();
  
  final _nombreController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _emailController = TextEditingController();
  final _direccionController = TextEditingController();
  final _notasController = TextEditingController();
  
  bool _isLoading = false;
  bool _isEditing = false;
  Cliente? _cliente;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.clienteId != null;
    if (_isEditing) {
      _loadCliente();
    }
  }

  Future<void> _loadCliente() async {
    setState(() => _isLoading = true);
    
    try {
      final cliente = await _clienteRepository.getById(widget.clienteId!);
      if (cliente != null) {
        _cliente = cliente;
        _nombreController.text = cliente.nombre;
        _telefonoController.text = cliente.telefono ?? '';
        _emailController.text = cliente.email ?? '';
        _direccionController.text = cliente.direccion ?? '';
        _notasController.text = cliente.notas ?? '';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar cliente: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    _direccionController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Cliente' : 'Nuevo Cliente'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Información del Cliente',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _nombreController,
                              decoration: const InputDecoration(
                                labelText: 'Nombre *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.person),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'El nombre es requerido';
                                }
                                return null;
                              },
                              textCapitalization: TextCapitalization.words,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _telefonoController,
                              decoration: const InputDecoration(
                                labelText: 'Teléfono',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.phone),
                              ),
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.email),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value != null && value.trim().isNotEmpty) {
                                  final emailRegex = RegExp(
                                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                  );
                                  if (!emailRegex.hasMatch(value.trim())) {
                                    return 'Email inválido';
                                  }
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _direccionController,
                              decoration: const InputDecoration(
                                labelText: 'Dirección',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.location_on),
                                alignLabelWithHint: true,
                              ),
                              maxLines: 3,
                              textCapitalization: TextCapitalization.sentences,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _notasController,
                              decoration: const InputDecoration(
                                labelText: 'Notas',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.note),
                                alignLabelWithHint: true,
                                hintText: 'Preferencias, alergias, etc.',
                              ),
                              maxLines: 4,
                              textCapitalization: TextCapitalization.sentences,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('Cancelar'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _saveCliente,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('Guardar'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _saveCliente() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final nombre = _nombreController.text.trim();
      final telefono = _telefonoController.text.trim();
      final email = _emailController.text.trim();
      final direccion = _direccionController.text.trim();
      final notas = _notasController.text.trim();

      final cliente = Cliente(
        id: _cliente?.id,
        nombre: nombre,
        telefono: telefono.isNotEmpty ? telefono : null,
        email: email.isNotEmpty ? email : null,
        direccion: direccion.isNotEmpty ? direccion : null,
        notas: notas.isNotEmpty ? notas : null,
        fechaRegistro: _cliente?.fechaRegistro ?? DateTime.now(),
        activo: _cliente?.activo ?? true,
      );

      if (_isEditing) {
        await _clienteRepository.update(cliente, widget.clienteId!);
      } else {
        await _clienteRepository.insert(cliente);
      }

      if (mounted) {
        Navigator.pop(context, true); // Return true to indicate success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? 'Cliente actualizado correctamente'
                  : 'Cliente creado correctamente',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar cliente: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
