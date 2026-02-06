import 'package:flutter/material.dart';
import '../../data/models/bizcochuelo.dart';
import '../../data/repositories/producto_repository.dart';

/// Pantalla de gestión de bizcochuelos
class BizcochuelosScreen extends StatefulWidget {
  const BizcochuelosScreen({super.key});

  @override
  State<BizcochuelosScreen> createState() => _BizcochuelosScreenState();
}

class _BizcochuelosScreenState extends State<BizcochuelosScreen> {
  final BizcochueloRepository _repository = BizcochueloRepository();
  List<Bizcochuelo> _bizcochuelos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBizcochuelos();
  }

  Future<void> _loadBizcochuelos() async {
    setState(() => _isLoading = true);
    try {
      final bizcochuelos = await _repository.getAll();
      setState(() {
        _bizcochuelos = bizcochuelos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar bizcochuelos: $e')),
        );
      }
    }
  }

  Future<void> _deleteBizcochuelo(Bizcochuelo bizcochuelo) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Desea eliminar "${bizcochuelo.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && bizcochuelo.id != null) {
      try {
        await _repository.delete(bizcochuelo.id!);
        _loadBizcochuelos();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bizcochuelo eliminado')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al eliminar: $e')),
          );
        }
      }
    }
  }

  void _showBizcochueloForm([Bizcochuelo? bizcochuelo]) {
    showDialog(
      context: context,
      builder: (context) => _BizcochueloFormDialog(
        bizcochuelo: bizcochuelo,
        onSave: (savedBizcochuelo) {
          _loadBizcochuelos();
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bizcochuelos'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _bizcochuelos.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cake_outlined,
                          size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No hay bizcochuelos',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Toca el botón + para agregar uno',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadBizcochuelos,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _bizcochuelos.length,
                    itemBuilder: (context, index) {
                      final bizcochuelo = _bizcochuelos[index];
                      return Dismissible(
                        key: Key('bizcochuelo_${bizcochuelo.id}'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 16),
                          color: Colors.red,
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (direction) async {
                          return await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Confirmar eliminación'),
                              content: Text(
                                  '¿Desea eliminar "${bizcochuelo.nombre}"?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Eliminar',
                                      style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                        },
                        onDismissed: (direction) async {
                          if (bizcochuelo.id != null) {
                            await _repository.delete(bizcochuelo.id!);
                            _loadBizcochuelos();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Bizcochuelo eliminado')),
                              );
                            }
                          }
                        },
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            onTap: () => _showBizcochueloForm(bizcochuelo),
                            onLongPress: () => _deleteBizcochuelo(bizcochuelo),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                bizcochuelo.nombre,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: bizcochuelo.activo
                                                    ? Colors.green[100]
                                                    : Colors.grey[300],
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                bizcochuelo.activo
                                                    ? 'Activo'
                                                    : 'Inactivo',
                                                style: TextStyle(
                                                  color: bizcochuelo.activo
                                                      ? Colors.green[900]
                                                      : Colors.grey[700],
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (bizcochuelo.descripcion?.isNotEmpty ==
                                            true) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            bizcochuelo.descripcion!,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  color: Colors.grey[600],
                                                ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right,
                                      color: Colors.grey),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showBizcochueloForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _BizcochueloFormDialog extends StatefulWidget {
  final Bizcochuelo? bizcochuelo;
  final Function(Bizcochuelo) onSave;

  const _BizcochueloFormDialog({
    this.bizcochuelo,
    required this.onSave,
  });

  @override
  State<_BizcochueloFormDialog> createState() => _BizcochueloFormDialogState();
}

class _BizcochueloFormDialogState extends State<_BizcochueloFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final BizcochueloRepository _repository = BizcochueloRepository();

  bool _activo = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.bizcochuelo != null) {
      _nombreController.text = widget.bizcochuelo!.nombre;
      _descripcionController.text = widget.bizcochuelo!.descripcion ?? '';
      _activo = widget.bizcochuelo!.activo;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _saveBizcochuelo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final bizcochuelo = Bizcochuelo(
        id: widget.bizcochuelo?.id,
        nombre: _nombreController.text.trim(),
        descripcion: _descripcionController.text.trim().isEmpty
            ? null
            : _descripcionController.text.trim(),
        activo: _activo,
      );

      if (widget.bizcochuelo == null) {
        await _repository.insert(bizcochuelo);
      } else {
        await _repository.update(bizcochuelo);
      }

      widget.onSave(bizcochuelo);
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.bizcochuelo == null
          ? 'Nuevo Bizcochuelo'
          : 'Editar Bizcochuelo'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El nombre es requerido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('Activo'),
                value: _activo,
                onChanged: (value) => setState(() => _activo = value ?? true),
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _saveBizcochuelo,
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Guardar'),
        ),
      ],
    );
  }
}
