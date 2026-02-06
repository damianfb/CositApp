import 'package:flutter_test/flutter_test.dart';
import 'package:cositapp/data/models/cliente.dart';
import 'package:cositapp/data/models/producto.dart';
import 'package:cositapp/data/models/bizcochuelo.dart';
import 'package:cositapp/data/models/relleno.dart';
import 'package:cositapp/data/models/pedido.dart';

void main() {
  group('Database Models Tests', () {
    test('Cliente model should serialize and deserialize correctly', () {
      // Crear un cliente
      final cliente = Cliente(
        id: 1,
        nombre: 'María González',
        telefono: '1234567890',
        email: 'maria@example.com',
        direccion: 'Calle Falsa 123',
        fechaRegistro: DateTime(2024, 1, 1),
        activo: true,
      );

      // Convertir a Map
      final map = cliente.toMap();
      expect(map['nombre'], equals('María González'));
      expect(map['telefono'], equals('1234567890'));
      expect(map['activo'], equals(1));

      // Convertir de Map
      final clienteFromMap = Cliente.fromMap(map);
      expect(clienteFromMap.nombre, equals(cliente.nombre));
      expect(clienteFromMap.telefono, equals(cliente.telefono));
      expect(clienteFromMap.activo, equals(cliente.activo));
    });

    test('Producto model should serialize and deserialize correctly', () {
      final producto = Producto(
        id: 1,
        nombre: 'Torta Clásica',
        descripcion: 'Torta tradicional para 8-10 personas',
        precioBase: 5000.0,
        categoria: 'torta',
        activo: true,
      );

      final map = producto.toMap();
      expect(map['nombre'], equals('Torta Clásica'));
      expect(map['precio_base'], equals(5000.0));
      expect(map['categoria'], equals('torta'));

      final productoFromMap = Producto.fromMap(map);
      expect(productoFromMap.nombre, equals(producto.nombre));
      expect(productoFromMap.precioBase, equals(producto.precioBase));
    });

    test('Bizcochuelo model should serialize and deserialize correctly', () {
      final bizcochuelo = Bizcochuelo(
        id: 1,
        nombre: 'Vainilla',
        descripcion: 'Bizcochuelo clásico de vainilla',
        activo: true,
      );

      final map = bizcochuelo.toMap();
      expect(map['nombre'], equals('Vainilla'));
      expect(map['activo'], equals(1));

      final bizcochueloFromMap = Bizcochuelo.fromMap(map);
      expect(bizcochueloFromMap.nombre, equals(bizcochuelo.nombre));
      expect(bizcochueloFromMap.activo, equals(bizcochuelo.activo));
    });

    test('Relleno model should serialize and deserialize correctly', () {
      final relleno = Relleno(
        id: 1,
        nombre: 'DDL con merengues',
        descripcion: 'Dulce de leche con merengues italianos',
        activo: true,
      );

      final map = relleno.toMap();
      expect(map['nombre'], equals('DDL con merengues'));

      final rellenoFromMap = Relleno.fromMap(map);
      expect(rellenoFromMap.nombre, equals(relleno.nombre));
    });

    test('Pedido model should serialize and deserialize correctly', () {
      final pedido = Pedido(
        id: 1,
        clienteId: 1,
        fechaPedido: DateTime(2024, 1, 1),
        fechaEntrega: DateTime(2024, 1, 10),
        estado: 'pendiente',
        precioTotal: 5000.0,
        senia: 1000.0,
      );

      final map = pedido.toMap();
      expect(map['cliente_id'], equals(1));
      expect(map['estado'], equals('pendiente'));
      expect(map['precio_total'], equals(5000.0));
      expect(map['senia'], equals(1000.0));

      final pedidoFromMap = Pedido.fromMap(map);
      expect(pedidoFromMap.clienteId, equals(pedido.clienteId));
      expect(pedidoFromMap.estado, equals(pedido.estado));
      expect(pedidoFromMap.precioTotal, equals(pedido.precioTotal));
    });

    test('Cliente copyWith should work correctly', () {
      final cliente = Cliente(
        nombre: 'Juan Pérez',
        fechaRegistro: DateTime.now(),
      );

      final clienteModificado = cliente.copyWith(
        telefono: '0987654321',
        email: 'juan@example.com',
      );

      expect(clienteModificado.nombre, equals('Juan Pérez'));
      expect(clienteModificado.telefono, equals('0987654321'));
      expect(clienteModificado.email, equals('juan@example.com'));
    });

    test('Producto toString should return formatted string', () {
      final producto = Producto(
        id: 1,
        nombre: 'Torta Grande',
        precioBase: 8000.0,
        categoria: 'torta',
      );

      final str = producto.toString();
      expect(str, contains('Torta Grande'));
      expect(str, contains('8000.0'));
      expect(str, contains('torta'));
    });
  });
}
