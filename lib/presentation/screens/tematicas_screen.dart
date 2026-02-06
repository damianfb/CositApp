import 'package:flutter/material.dart';
import '../../data/models/tematica.dart';
import '../../data/repositories/producto_repository.dart';

/// Pantalla de gestión de temáticas
class TematicasScreen extends StatefulWidget {
  const TematicasScreen({super.key});

  @override
  State<TematicasScreen> createState() => _TematicasScreenState();
}

class _TematicasScreenState extends State<TematicasScreen> {
  final TematicaRepository _repository = TematicaRepository();
  List<Tematica> _tematicas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTematicas();
  }

  Future<void> _loadTematicas() async {
    setState(() => _isLoading = true);
    try {
      final tematicas = await _repository.getAll();
      setState(() {
        _tematicas = tematicas;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar temáticas: $e')),
        );
      }
    }
  }

  Future<void> _deleteTematica(Tematica tematica) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Desea eliminar "${tematica.nombre}"?'),
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

    if (confirmed == true && tematica.id != null) {
      try {
        await _repository.delete(tematica.id!);
        _loadTematicas();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Temática eliminada')),
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

  void _showTematicaForm([Tematica? tematica]) {
    showDialog(
      context: context,
      builder: (context) => _TematicaFormDialog(
        tematica: tematica,
        onSave: (savedTematica) {
          _loadTematicas();
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Temáticas'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tematicas.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.palette, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No hay temáticas',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Toca el botón + para agregar una',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadTematicas,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _tematicas.length,
                    itemBuilder: (context, index) {
                      final tematica = _tematicas[index];
                      return Dismissible(
                        key: Key('tematica_${tematica.id}'),
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
                                  '¿Desea eliminar "${tematica.nombre}"?'),
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
                          if (tematica.id != null) {
                            await _repository.delete(tematica.id!);
                            _loadTematicas();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Temática eliminada')),
                              );
                            }
                          }
                        },
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            onTap: () => _showTematicaForm(tematica),
                            onLongPress: () => _deleteTematica(tematica),
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
                                                tematica.nombre,
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
                                                color: tematica.activo
                                                    ? Colors.green[100]
                                                    : Colors.grey[300],
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                tematica.activo
                                                    ? 'Activo'
                                                    : 'Inactivo',
                                                style: TextStyle(
                                                  color: tematica.activo
                                                      ? Colors.green[900]
                                                      : Colors.grey[700],
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (tematica.descripcion?.isNotEmpty ==
                                            true) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            tematica.descripcion!,
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
        onPressed: () => _showTematicaForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _TematicaFormDialog extends StatefulWidget {
  final Tematica? tematica;
  final Function(Tematica) onSave;

  const _TematicaFormDialog({
    this.tematica,
    required this.onSave,
  });

  @override
  State<_TematicaFormDialog> createState() => _TematicaFormDialogState();
}

class _TematicaFormDialogState extends State<_TematicaFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final TematicaRepository _repository = TematicaRepository();

  bool _activo = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.tematica != null) {
      _nombreController.text = widget.tematica!.nombre;
      _descripcionController.text = widget.tematica!.descripcion ?? '';
      _activo = widget.tematica!.activo;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _saveTematica() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final tematica = Tematica(
        id: widget.tematica?.id,
        nombre: _nombreController.text.trim(),
        descripcion: _descripcionController.text.trim().isEmpty
            ? null
            : _descripcionController.text.trim(),
        activo: _activo,
      );

      if (widget.tematica == null) {
        await _repository.insert(tematica);
      } else {
        await _repository.update(tematica);
      }

      widget.onSave(tematica);
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
      title: Text(widget.tematica == null ? 'Nueva Temática' : 'Editar Temática'),
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
          onPressed: _isSaving ? null : _saveTematica,
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
