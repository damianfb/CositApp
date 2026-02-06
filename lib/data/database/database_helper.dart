import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Helper para gestión de la base de datos SQLite
/// Maneja la creación, migración y acceso a la base de datos local
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  /// Obtiene la instancia de la base de datos
  /// Si no existe, la crea
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('cositapp.db');
    return _database!;
  }

  /// Inicializa la base de datos
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2, // Incrementada versión para migración de foto
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  /// Crea todas las tablas de la base de datos
  Future<void> _createDB(Database db, int version) async {
    // Tabla CLIENTE
    await db.execute('''
      CREATE TABLE cliente (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        telefono TEXT,
        email TEXT,
        direccion TEXT,
        notas TEXT,
        fecha_registro TEXT NOT NULL,
        activo INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // Tabla FAMILIAR
    await db.execute('''
      CREATE TABLE familiar (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cliente_id INTEGER NOT NULL,
        nombre TEXT NOT NULL,
        fecha_nacimiento TEXT,
        parentesco TEXT,
        notas TEXT,
        FOREIGN KEY (cliente_id) REFERENCES cliente (id) ON DELETE CASCADE
      )
    ''');

    // Tabla BIZCOCHUELO
    await db.execute('''
      CREATE TABLE bizcochuelo (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        descripcion TEXT,
        activo INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // Tabla RELLENO
    await db.execute('''
      CREATE TABLE relleno (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        descripcion TEXT,
        activo INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // Tabla TEMATICA
    await db.execute('''
      CREATE TABLE tematica (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        descripcion TEXT,
        activo INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // Tabla PRODUCTO
    await db.execute('''
      CREATE TABLE producto (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        descripcion TEXT,
        precio_base REAL NOT NULL,
        categoria TEXT,
        activo INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // Tabla PEDIDO
    await db.execute('''
      CREATE TABLE pedido (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cliente_id INTEGER NOT NULL,
        fecha_pedido TEXT NOT NULL,
        fecha_entrega TEXT NOT NULL,
        estado TEXT NOT NULL DEFAULT 'pendiente',
        precio_total REAL NOT NULL,
        senia REAL,
        observaciones TEXT,
        fecha_completado TEXT,
        FOREIGN KEY (cliente_id) REFERENCES cliente (id) ON DELETE CASCADE
      )
    ''');

    // Tabla PEDIDO_DETALLE
    await db.execute('''
      CREATE TABLE pedido_detalle (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        pedido_id INTEGER NOT NULL,
        producto_id INTEGER NOT NULL,
        bizcochuelo_id INTEGER,
        tematica_id INTEGER,
        cantidad INTEGER NOT NULL,
        precio_unitario REAL NOT NULL,
        subtotal REAL NOT NULL,
        tamanio TEXT,
        observaciones TEXT,
        FOREIGN KEY (pedido_id) REFERENCES pedido (id) ON DELETE CASCADE,
        FOREIGN KEY (producto_id) REFERENCES producto (id),
        FOREIGN KEY (bizcochuelo_id) REFERENCES bizcochuelo (id),
        FOREIGN KEY (tematica_id) REFERENCES tematica (id)
      )
    ''');

    // Tabla DETALLE_RELLENO
    await db.execute('''
      CREATE TABLE detalle_relleno (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        pedido_detalle_id INTEGER NOT NULL,
        relleno_id INTEGER NOT NULL,
        capa INTEGER NOT NULL DEFAULT 1,
        observaciones TEXT,
        FOREIGN KEY (pedido_detalle_id) REFERENCES pedido_detalle (id) ON DELETE CASCADE,
        FOREIGN KEY (relleno_id) REFERENCES relleno (id)
      )
    ''');

    // Tabla RECORDATORIO
    await db.execute('''
      CREATE TABLE recordatorio (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cliente_id INTEGER,
        familiar_id INTEGER,
        titulo TEXT NOT NULL,
        descripcion TEXT,
        fecha_evento TEXT NOT NULL,
        dias_anticipacion INTEGER NOT NULL DEFAULT 7,
        activo INTEGER NOT NULL DEFAULT 1,
        fecha_recordatorio TEXT,
        FOREIGN KEY (cliente_id) REFERENCES cliente (id) ON DELETE CASCADE,
        FOREIGN KEY (familiar_id) REFERENCES familiar (id) ON DELETE CASCADE
      )
    ''');

    // Tabla TAREA_POSTVENTA
    await db.execute('''
      CREATE TABLE tarea_postventa (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        pedido_id INTEGER NOT NULL,
        titulo TEXT NOT NULL,
        descripcion TEXT,
        fecha_limite TEXT NOT NULL,
        estado TEXT NOT NULL DEFAULT 'pendiente',
        fecha_completado TEXT,
        resultado TEXT,
        FOREIGN KEY (pedido_id) REFERENCES pedido (id) ON DELETE CASCADE
      )
    ''');

    // Tabla FOTO
    await db.execute('''
      CREATE TABLE foto (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        pedido_id INTEGER,
        ruta_archivo TEXT NOT NULL,
        descripcion TEXT,
        tipo TEXT NOT NULL DEFAULT 'producto_final',
        fecha_creacion TEXT NOT NULL,
        visible_en_galeria INTEGER NOT NULL DEFAULT 1,
        categoria TEXT,
        FOREIGN KEY (pedido_id) REFERENCES pedido (id) ON DELETE CASCADE
      )
    ''');

    // Índices para mejorar el rendimiento
    await db.execute('CREATE INDEX idx_cliente_nombre ON cliente(nombre)');
    await db.execute('CREATE INDEX idx_pedido_cliente ON pedido(cliente_id)');
    await db.execute('CREATE INDEX idx_pedido_fecha_entrega ON pedido(fecha_entrega)');
    await db.execute('CREATE INDEX idx_pedido_estado ON pedido(estado)');
    await db.execute('CREATE INDEX idx_familiar_cliente ON familiar(cliente_id)');

    // Insertar datos seed (datos iniciales de prueba)
    await _insertSeedData(db);
  }

  /// Inserta datos de prueba iniciales
  Future<void> _insertSeedData(Database db) async {
    // BIZCOCHUELOS - 3 tipos básicos
    await db.insert('bizcochuelo', {
      'nombre': 'Vainilla',
      'descripcion': 'Bizcochuelo clásico de vainilla, suave y esponjoso',
      'activo': 1,
    });
    await db.insert('bizcochuelo', {
      'nombre': 'Chocolate',
      'descripcion': 'Bizcochuelo de chocolate intenso y húmedo',
      'activo': 1,
    });
    await db.insert('bizcochuelo', {
      'nombre': 'Combinado',
      'descripcion': 'Capas alternadas de vainilla y chocolate',
      'activo': 1,
    });

    // RELLENOS - 6 opciones
    await db.insert('relleno', {
      'nombre': 'DDL con merengues',
      'descripcion': 'Dulce de leche con merengues italianos',
      'activo': 1,
    });
    await db.insert('relleno', {
      'nombre': 'DDL chip chocolate',
      'descripcion': 'Dulce de leche con chips de chocolate',
      'activo': 1,
    });
    await db.insert('relleno', {
      'nombre': 'DDL nueces',
      'descripcion': 'Dulce de leche con nueces picadas',
      'activo': 1,
    });
    await db.insert('relleno', {
      'nombre': 'Mousse chocolate',
      'descripcion': 'Mousse de chocolate belga suave y cremoso',
      'activo': 1,
    });
    await db.insert('relleno', {
      'nombre': 'Crema pastelera',
      'descripcion': 'Crema pastelera tradicional con vainilla',
      'activo': 1,
    });
    await db.insert('relleno', {
      'nombre': 'Chantilly con frutas',
      'descripcion': 'Crema chantilly con frutas frescas de estación',
      'activo': 1,
    });

    // TEMÁTICAS - 5 ejemplos
    await db.insert('tematica', {
      'nombre': 'Princesas',
      'descripcion': 'Decoración con temática de princesas Disney',
      'activo': 1,
    });
    await db.insert('tematica', {
      'nombre': 'Superhéroes',
      'descripcion': 'Decoración de superhéroes Marvel y DC',
      'activo': 1,
    });
    await db.insert('tematica', {
      'nombre': 'Flores',
      'descripcion': 'Decoración floral elegante con rosas y margaritas',
      'activo': 1,
    });
    await db.insert('tematica', {
      'nombre': 'Cumpleaños Clásico',
      'descripcion': 'Decoración tradicional de cumpleaños con velas y mensajes',
      'activo': 1,
    });
    await db.insert('tematica', {
      'nombre': 'Personalizada',
      'descripcion': 'Temática personalizada según preferencias del cliente',
      'activo': 1,
    });

    // PRODUCTOS - 3 productos básicos
    await db.insert('producto', {
      'nombre': 'Torta Clásica',
      'descripcion': 'Torta tradicional para 8-10 personas',
      'precio_base': 5000.0,
      'categoria': 'torta',
      'activo': 1,
    });
    await db.insert('producto', {
      'nombre': 'Torta Grande',
      'descripcion': 'Torta grande para 15-20 personas',
      'precio_base': 8000.0,
      'categoria': 'torta',
      'activo': 1,
    });
    await db.insert('producto', {
      'nombre': 'Bocaditos',
      'descripcion': 'Bocaditos dulces surtidos (por docena)',
      'precio_base': 1500.0,
      'categoria': 'bocadito',
      'activo': 1,
    });

    print('✅ Datos seed insertados correctamente:');
    print('   - 3 Bizcochuelos');
    print('   - 6 Rellenos');
    print('   - 5 Temáticas');
    print('   - 3 Productos');
  }

  /// Maneja las migraciones de versiones de la base de datos
  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    print('🔄 Migrando base de datos de v$oldVersion a v$newVersion');
    
    // Migración de v1 a v2: Agregar campos a tabla foto
    if (oldVersion < 2) {
      print('   📸 Actualizando tabla foto...');
      
      // SQLite no soporta ALTER COLUMN, necesitamos recrear la tabla
      await db.execute('''
        CREATE TABLE foto_new (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          pedido_id INTEGER,
          ruta_archivo TEXT NOT NULL,
          descripcion TEXT,
          tipo TEXT NOT NULL DEFAULT 'producto_final',
          fecha_creacion TEXT NOT NULL,
          visible_en_galeria INTEGER NOT NULL DEFAULT 1,
          categoria TEXT,
          FOREIGN KEY (pedido_id) REFERENCES pedido (id) ON DELETE CASCADE
        )
      ''');
      
      // Copiar datos existentes
      // NOTA: Todas las fotos existentes se marcan como visibles (visible_en_galeria=1)
      // y sin categoría (categoria=NULL) por defecto. Esto asume que las fotos
      // previas deben ser visibles en la galería pública.
      await db.execute('''
        INSERT INTO foto_new (id, pedido_id, ruta_archivo, descripcion, tipo, fecha_creacion, visible_en_galeria, categoria)
        SELECT id, pedido_id, ruta_archivo, descripcion, tipo, fecha_creacion, 1, NULL
        FROM foto
      ''');
      
      // Eliminar tabla vieja y renombrar la nueva
      await db.execute('DROP TABLE foto');
      await db.execute('ALTER TABLE foto_new RENAME TO foto');
      
      print('   ✅ Tabla foto actualizada con éxito');
    }
    
    print('✅ Migración completada');
  }

  /// Cierra la conexión a la base de datos
  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  /// Elimina la base de datos (útil para testing o reset)
  Future<void> deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'cositapp.db');
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}
