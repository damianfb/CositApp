import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../screens/home_screen.dart';
import '../screens/calendar_screen.dart';
import '../screens/gallery_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/nuevo_pedido_screen.dart';

/// Widget de navegación inferior con 5 tabs
class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _currentIndex = 0;

  // Lista de pantallas
  final List<Widget> _screens = const [
    HomeScreen(),
    CalendarScreen(),
    HomeScreen(), // Placeholder para "Nuevo" (botón central)
    GalleryScreen(),
    SettingsScreen(),
  ];

  void _onTabTapped(int index) {
    // Si se presiona el botón central (índice 2), mostrar diálogo o acción
    if (index == 2) {
      _showNewItemDialog();
      return;
    }
    setState(() {
      _currentIndex = index;
    });
  }

  void _showNewItemDialog() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const NuevoPedidoScreen(),
      ),
    ).then((_) {
      // Refrescar la pantalla actual después de crear un pedido
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: AppConstants.navHome,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: AppConstants.navCalendar,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle, size: 36),
            label: AppConstants.navNew,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_library),
            label: AppConstants.navGallery,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: AppConstants.navSettings,
          ),
        ],
      ),
      // Botón flotante para acción "Nuevo" (opcional, visual adicional)
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: _showNewItemDialog,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
