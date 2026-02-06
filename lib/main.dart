import 'package:flutter/material.dart';
import 'app.dart';
import 'data/database/database_helper.dart';
import 'data/repositories/cliente_repository.dart';
import 'data/repositories/producto_repository.dart';
import 'data/repositories/pedido_repository.dart';

/// Punto de entrada de la aplicación
void main() async {
  // Asegurar que Flutter está inicializado
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar la base de datos
  await _initializeDatabase();
  
  // Ejecutar la aplicación
  runApp(const App());
}

/// Inicializa la base de datos y muestra datos de verificación
Future<void> _initializeDatabase() async {
  try {
    print('\n🔧 Inicializando base de datos...');
    
    // Obtener instancia de la base de datos (esto crea la BD si no existe)
    final db = await DatabaseHelper.instance.database;
    print('✅ Base de datos inicializada correctamente');
    
    // Verificar datos seed - Repositorios
    final productoRepo = ProductoRepository();
    final bizcochueloRepo = BizcochueloRepository();
    final rellenoRepo = RellenoRepository();
    final tematicaRepo = TematicaRepository();
    
    // Obtener y mostrar datos de prueba
    print('\n📊 Datos iniciales en la base de datos:');
    
    // Bizcochuelos
    final bizcochuelos = await bizcochueloRepo.getAll();
    print('\n🍰 Bizcochuelos (${bizcochuelos.length}):');
    for (var b in bizcochuelos) {
      print('   - ${b.nombre}: ${b.descripcion}');
    }
    
    // Rellenos
    final rellenos = await rellenoRepo.getAll();
    print('\n🎂 Rellenos (${rellenos.length}):');
    for (var r in rellenos) {
      print('   - ${r.nombre}: ${r.descripcion}');
    }
    
    // Temáticas
    final tematicas = await tematicaRepo.getAll();
    print('\n🎨 Temáticas (${tematicas.length}):');
    for (var t in tematicas) {
      print('   - ${t.nombre}: ${t.descripcion}');
    }
    
    // Productos
    final productos = await productoRepo.getAll();
    print('\n📦 Productos (${productos.length}):');
    for (var p in productos) {
      print('   - ${p.nombre}: \$${p.precioBase} (${p.categoria})');
    }
    
    print('\n✅ Base de datos lista para usar');
    print('━' * 50);
    
  } catch (e) {
    print('❌ Error al inicializar base de datos: $e');
  }
}
