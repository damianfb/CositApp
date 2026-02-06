import 'package:sqflite/sqflite.dart';
import '../models/pedido.dart';
import '../models/pedido_detalle.dart';
import '../models/detalle_relleno.dart';
import 'base_repository.dart';

/// Repositorio para gestión de Pedidos
/// Proporciona operaciones CRUD y consultas específicas para pedidos
class PedidoRepository extends BaseRepository<Pedido> {
  @override
  String get tableName => 'pedido';

  @override
  Pedido fromMap(Map<String, dynamic> map) => Pedido.fromMap(map);

  @override
  Map<String, dynamic> toMap(Pedido item) => item.toMap();

  /// Obtiene pedidos por cliente
  Future<List<Pedido>> getByCliente(int clienteId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'cliente_id = ?',
      whereArgs: [clienteId],
      orderBy: 'fecha_entrega DESC',
    );
    return List.generate(maps.length, (i) => fromMap(maps[i]));
  }

  /// Obtiene pedidos por estado
  Future<List<Pedido>> getByEstado(String estado) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'estado = ?',
      whereArgs: [estado],
      orderBy: 'fecha_entrega ASC',
    );
    return List.generate(maps.length, (i) => fromMap(maps[i]));
  }

  /// Obtiene pedidos por rango de fechas de entrega
  Future<List<Pedido>> getByDateRange(DateTime inicio, DateTime fin) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'fecha_entrega BETWEEN ? AND ?',
      whereArgs: [inicio.toIso8601String(), fin.toIso8601String()],
      orderBy: 'fecha_entrega ASC',
    );
    return List.generate(maps.length, (i) => fromMap(maps[i]));
  }

  /// Obtiene pedidos recientes (últimos N pedidos)
  Future<List<Pedido>> getRecent({int limit = 10}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      orderBy: 'fecha_pedido DESC',
      limit: limit,
    );
    return List.generate(maps.length, (i) => fromMap(maps[i]));
  }

  /// Obtiene pedidos pendientes ordenados por fecha de entrega
  Future<List<Pedido>> getPendientes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'estado IN (?, ?)',
      whereArgs: ['pendiente', 'confirmado'],
      orderBy: 'fecha_entrega ASC',
    );
    return List.generate(maps.length, (i) => fromMap(maps[i]));
  }

  /// Calcula el total de ingresos en un rango de fechas
  Future<double> getTotalIngresos(DateTime inicio, DateTime fin) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(precio_total) as total FROM $tableName WHERE fecha_entrega BETWEEN ? AND ? AND estado = ?',
      [inicio.toIso8601String(), fin.toIso8601String(), 'completado'],
    );
    
    final total = result.first['total'];
    return total != null ? (total as num).toDouble() : 0.0;
  }
}

/// Repositorio para gestión de Detalles de Pedido
class PedidoDetalleRepository extends BaseRepository<PedidoDetalle> {
  @override
  String get tableName => 'pedido_detalle';

  @override
  PedidoDetalle fromMap(Map<String, dynamic> map) => PedidoDetalle.fromMap(map);

  @override
  Map<String, dynamic> toMap(PedidoDetalle item) => item.toMap();

  /// Obtiene todos los detalles de un pedido
  Future<List<PedidoDetalle>> getByPedido(int pedidoId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'pedido_id = ?',
      whereArgs: [pedidoId],
    );
    return List.generate(maps.length, (i) => fromMap(maps[i]));
  }
}

/// Repositorio para gestión de Detalles de Relleno
class DetalleRellenoRepository extends BaseRepository<DetalleRelleno> {
  @override
  String get tableName => 'detalle_relleno';

  @override
  DetalleRelleno fromMap(Map<String, dynamic> map) => DetalleRelleno.fromMap(map);

  @override
  Map<String, dynamic> toMap(DetalleRelleno item) => item.toMap();

  /// Obtiene todos los rellenos de un detalle de pedido
  Future<List<DetalleRelleno>> getByPedidoDetalle(int pedidoDetalleId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'pedido_detalle_id = ?',
      whereArgs: [pedidoDetalleId],
      orderBy: 'capa ASC',
    );
    return List.generate(maps.length, (i) => fromMap(maps[i]));
  }
}
