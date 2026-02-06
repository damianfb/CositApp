import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/services/birthday_service.dart';
import 'nuevo_pedido_screen.dart';

/// Pantalla para mostrar cumpleaños del mes y próximos
class BirthdaysScreen extends StatefulWidget {
  const BirthdaysScreen({super.key});

  @override
  State<BirthdaysScreen> createState() => _BirthdaysScreenState();
}

class _BirthdaysScreenState extends State<BirthdaysScreen> {
  final _birthdayService = BirthdayService();
  
  List<BirthdayInfo> _birthdays = [];
  bool _loading = true;
  bool _showThisMonth = true;

  @override
  void initState() {
    super.initState();
    _loadBirthdays();
  }

  Future<void> _loadBirthdays() async {
    setState(() {
      _loading = true;
    });

    try {
      final birthdays = _showThisMonth
          ? await _birthdayService.getBirthdaysThisMonth()
          : await _birthdayService.getUpcomingBirthdays(days: 60);

      setState(() {
        _birthdays = birthdays;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Error al cargar cumpleaños: $e');
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _makePhoneCall(String phone) async {
    final url = Uri.parse('tel:$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se puede realizar la llamada'),
          ),
        );
      }
    }
  }

  Future<void> _sendWhatsApp(BirthdayInfo birthday) async {
    if (birthday.telefono == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay teléfono registrado'),
        ),
      );
      return;
    }

    final message = _birthdayService.getBirthdayMessage(birthday);
    final whatsappUrl = _birthdayService.getWhatsAppUrl(
      birthday.telefono!,
      message,
    );

    final url = Uri.parse(whatsappUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se puede abrir WhatsApp'),
          ),
        );
      }
    }
  }

  void _createNewOrder(BirthdayInfo birthday) {
    // Navegar a la pantalla de nuevo pedido
    // Idealmente pre-seleccionando el cliente
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NuevoPedidoScreen(),
      ),
    );
  }

  Widget _buildBirthdayCard(BirthdayInfo birthday) {
    final dateFormat = DateFormat('dd MMM', 'es');
    final daysUntil = birthday.diasHastaCumpleanos;
    
    Color accentColor;
    String daysText;
    
    if (daysUntil == 0) {
      accentColor = Colors.red;
      daysText = 'HOY';
    } else if (daysUntil == 1) {
      accentColor = Colors.orange;
      daysText = 'MAÑANA';
    } else if (daysUntil <= 7) {
      accentColor = Colors.amber;
      daysText = 'En $daysUntil días';
    } else {
      accentColor = Colors.grey;
      daysText = 'En $daysUntil días';
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: accentColor,
              child: Text(
                birthday.fechaNacimiento.day.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              birthday.nombre,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (birthday.clienteNombre != null)
                  Text('Cliente: ${birthday.clienteNombre}'),
                Text(
                  '${dateFormat.format(birthday.fechaNacimiento)} - Cumple ${birthday.edadQueCumple} años',
                ),
              ],
            ),
            trailing: Chip(
              label: Text(
                daysText,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              backgroundColor: accentColor.withOpacity(0.2),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Botón de llamada
                if (birthday.telefono != null)
                  TextButton.icon(
                    onPressed: () => _makePhoneCall(birthday.telefono!),
                    icon: const Icon(Icons.phone, size: 20),
                    label: const Text('Llamar'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.green,
                    ),
                  )
                else
                  TextButton.icon(
                    onPressed: null,
                    icon: const Icon(Icons.phone_disabled, size: 20),
                    label: const Text('Sin teléfono'),
                  ),

                // Botón de WhatsApp
                if (birthday.telefono != null)
                  TextButton.icon(
                    onPressed: () => _sendWhatsApp(birthday),
                    icon: const Icon(Icons.chat, size: 20),
                    label: const Text('WhatsApp'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.teal,
                    ),
                  ),

                // Botón de nuevo pedido
                TextButton.icon(
                  onPressed: () => _createNewOrder(birthday),
                  icon: const Icon(Icons.add_shopping_cart, size: 20),
                  label: const Text('Pedido'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.pink,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎂 Cumpleaños'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
            onPressed: _loadBirthdays,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SegmentedButton<bool>(
              selected: {_showThisMonth},
              onSelectionChanged: (Set<bool> newSelection) {
                setState(() {
                  _showThisMonth = newSelection.first;
                });
                _loadBirthdays();
              },
              segments: const [
                ButtonSegment<bool>(
                  value: true,
                  label: Text('Este Mes'),
                  icon: Icon(Icons.calendar_today),
                ),
                ButtonSegment<bool>(
                  value: false,
                  label: Text('Próximos 60 días'),
                  icon: Icon(Icons.calendar_month),
                ),
              ],
            ),
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _birthdays.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.cake_outlined,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _showThisMonth
                            ? 'No hay cumpleaños este mes'
                            : 'No hay cumpleaños próximos',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Agrega fechas de nacimiento a los familiares',
                        style: TextStyle(
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadBirthdays,
                  child: ListView.builder(
                    itemCount: _birthdays.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        // Header con resumen
                        return Card(
                          margin: const EdgeInsets.all(16),
                          color: Colors.purple[50],
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.celebration,
                                  size: 40,
                                  color: Colors.purple,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _showThisMonth
                                            ? 'Cumpleaños de ${DateFormat.MMMM('es').format(DateTime.now())}'
                                            : 'Próximos cumpleaños',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${_birthdays.length} ${_birthdays.length == 1 ? "cumpleaños" : "cumpleaños"}',
                                        style: TextStyle(
                                          color: Colors.grey[700],
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
                      
                      return _buildBirthdayCard(_birthdays[index - 1]);
                    },
                  ),
                ),
    );
  }
}
