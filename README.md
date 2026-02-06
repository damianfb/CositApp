# 🍰 Cositas de la Abuela - CositApp

![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)
![Platform](https://img.shields.io/badge/platform-Android-green.svg)
![License](https://img.shields.io/badge/license-MIT-orange.svg)

## 📝 Descripción

**Cositas de la Abuela** es una aplicación móvil para la gestión de pedidos de pastelería artesanal. La app permite a los usuarios gestionar pedidos, visualizar un calendario de entregas, mantener una galería de fotos de productos, y más.

Esta es la **ETAPA 3** completada: Sistema completo de gestión de pedidos con dashboard, calendario, CRUD de clientes y catálogo.

## ✨ Características Actuales (Etapa 3 - COMPLETADA)

### Gestión de Pedidos
- ✅ **Dashboard funcional** con resumen de pedidos del día y próximos 7 días
- ✅ **Wizard multi-paso** para crear pedidos (cliente, productos, fechas, confirmación)
- ✅ **Detalle completo** de pedidos con cambio de estado y gestión de pagos
- ✅ **Calendario mensual** con marcadores de entregas y vista por día
- ✅ **Checklist post-venta** para pedidos completados

### Gestión de Clientes
- ✅ **Lista de clientes** con búsqueda y ordenamiento
- ✅ **Detalle de cliente** con historial de pedidos
- ✅ **CRUD de familiares** con fechas de cumpleaños
- ✅ **Formulario de cliente** con validación

### Gestión de Catálogo
- ✅ **CRUD de productos** (nombre, precio, categoría)
- ✅ **CRUD de bizcochuelos** (tipos de bizcocho)
- ✅ **CRUD de rellenos** (rellenos por capa)
- ✅ **CRUD de temáticas** (decoraciones)

### Base de Datos (Etapa 2)
- ✅ SQLite con 12 tablas relacionadas
- ✅ Repositorios con CRUD completo
- ✅ Datos seed iniciales
- ✅ Sistema de migraciones

### UI/UX
- ✅ Navegación con Bottom Navigation Bar (5 tabs)
- ✅ Tema visual personalizado (colores cálidos/pastel)
- ✅ Textos en español
- ✅ Material Design 3
- ✅ Compatibilidad con Android 13 (Samsung A32)

## 🎨 Diseño Visual

El tema de la app utiliza una paleta de colores cálidos y acogedores:

- **Color Primario**: Rosa pastel (#F8BBD9)
- **Color Secundario**: Crema (#FFF8E1)
- **Color de Acento**: Rosa intenso (#EC407A)
- **Fondo**: Blanco/crema claro
- **Textos**: Marrón oscuro (#5D4037)

## 📱 Compatibilidad

- **Dispositivo objetivo**: Samsung A32
- **Sistema Operativo**: Android 13 (API 33) con One UI 5.1
- **minSdkVersion**: 24 (Android 7.0)
- **targetSdkVersion**: 33 (Android 13)
- **compileSdkVersion**: 34

## 🚀 Requisitos Previos

Antes de comenzar, asegúrate de tener instalado:

1. **Flutter SDK** (3.0 o superior)
   - Descarga: https://flutter.dev/docs/get-started/install
   
2. **Android Studio** o **VS Code** con extensiones de Flutter

3. **Android SDK** (API 33 y 34)

4. **Java JDK** (versión 8 o superior)

5. **Dispositivo físico** (Samsung A32) o **emulador Android 13**

## 📦 Instalación

### 1. Clonar el repositorio

```bash
git clone https://github.com/damianfb/CositApp.git
cd CositApp
```

### 2. Instalar dependencias

```bash
flutter pub get
```

### 3. Verificar instalación de Flutter

```bash
flutter doctor
```

Asegúrate de que todos los checks estén en verde (✓).

### 4. Configurar dispositivo

**Opción A: Dispositivo físico (Samsung A32)**

1. Habilita las opciones de desarrollador en tu Samsung A32
2. Activa la depuración USB
3. Conecta el dispositivo por USB
4. Verifica la conexión: `flutter devices`

**Opción B: Emulador Android**

1. Abre Android Studio
2. Ve a Tools > AVD Manager
3. Crea un nuevo dispositivo virtual con Android 13 (API 33)
4. Inicia el emulador
5. Verifica la conexión: `flutter devices`

## 🏃‍♀️ Ejecutar la Aplicación

### Modo Debug

```bash
flutter run
```

### Modo Release (APK)

```bash
flutter build apk --release
```

El APK generado estará en: `build/app/outputs/flutter-apk/app-release.apk`

### Instalar en dispositivo

```bash
flutter install
```

## 📁 Estructura del Proyecto

```
CositApp/
├── lib/
│   ├── main.dart                          # Punto de entrada
│   ├── app.dart                           # MaterialApp configurado
│   ├── core/
│   │   ├── constants/
│   │   │   └── app_constants.dart         # Constantes de la app
│   │   └── theme/
│   │       └── app_theme.dart             # Tema personalizado
│   ├── data/                              # Capa de datos
│   │   ├── database/
│   │   │   └── database_helper.dart       # Helper de SQLite
│   │   ├── models/                        # 12 modelos de datos
│   │   │   ├── cliente.dart
│   │   │   ├── familiar.dart
│   │   │   ├── producto.dart
│   │   │   ├── bizcochuelo.dart
│   │   │   ├── relleno.dart
│   │   │   ├── tematica.dart
│   │   │   ├── pedido.dart
│   │   │   ├── pedido_detalle.dart
│   │   │   ├── detalle_relleno.dart
│   │   │   ├── recordatorio.dart
│   │   │   ├── tarea_postventa.dart
│   │   │   └── foto.dart
│   │   └── repositories/                  # Repositorios CRUD
│   │       ├── base_repository.dart
│   │       ├── cliente_repository.dart
│   │       ├── familiar_repository.dart   # 🆕 ETAPA 3
│   │       ├── producto_repository.dart
│   │       └── pedido_repository.dart
│   └── presentation/
│       ├── screens/
│       │   ├── home_screen.dart           # 🔄 Dashboard completo
│       │   ├── calendar_screen.dart       # 🔄 Calendario funcional
│       │   ├── nuevo_pedido_screen.dart   # 🆕 Wizard pedidos
│       │   ├── detalle_pedido_screen.dart # 🆕 Detalle pedido
│       │   ├── clientes_screen.dart       # 🆕 Lista clientes
│       │   ├── detalle_cliente_screen.dart # 🆕 Detalle cliente
│       │   ├── formulario_cliente_screen.dart # 🆕 Form cliente
│       │   ├── catalogo_screen.dart       # 🆕 Menú catálogo
│       │   ├── productos_screen.dart      # 🆕 CRUD productos
│       │   ├── bizcochuelos_screen.dart   # 🆕 CRUD bizcochuelos
│       │   ├── rellenos_screen.dart       # 🆕 CRUD rellenos
│       │   ├── tematicas_screen.dart      # 🆕 CRUD temáticas
│       │   ├── gallery_screen.dart        # Pantalla de galería
│       │   └── settings_screen.dart       # 🔄 Config con menús
│       └── widgets/
│           └── bottom_nav_bar.dart        # Bottom Navigation Bar
├── android/                               # Configuración Android
├── test/                                  # Tests unitarios
├── pubspec.yaml                          # Dependencias
├── ETAPA2_COMPLETADA.md                  # Documentación Etapa 2
├── ETAPA3_COMPLETADA.md                  # 🆕 Documentación Etapa 3
└── README.md                             # Este archivo
```

## 🗺️ Roadmap - 5 Etapas

### ✅ Etapa 1: Proyecto Base Flutter (COMPLETADA)
- Estructura de carpetas
- Navegación básica
- Tema visual

### ✅ Etapa 2: Base de Datos Local (SQLite) - COMPLETADA
- 12 modelos de datos implementados
- Base de datos SQLite con sqflite
- Repositorios con CRUD completo
- Datos seed iniciales
- Migraciones preparadas

### ✅ Etapa 3: Gestión de Pedidos (Core) - COMPLETADA
- Dashboard con resúmenes y lista de pedidos
- Wizard multi-paso para crear pedidos
- Detalle de pedido con cambio de estado y pagos
- Calendario mensual con marcadores
- Gestión completa de clientes y familiares
- CRUD de catálogo (productos, bizcochuelos, rellenos, temáticas)
- 13 pantallas funcionales nuevas

### ⏳ Etapa 4: Galería de Fotos y Recordatorios
- Captura de fotos con la cámara
- Gestión de galería
- Asociación de fotos con pedidos
- Notificaciones de recordatorios

### ⏳ Etapa 5: Funcionalidades Avanzadas
- Exportación de datos (CSV/PDF)
- Sincronización en la nube (opcional)
- Estadísticas y reportes

## 📦 Dependencias

### Dependencias de Producción

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.6      # Iconos iOS
  sqflite: ^2.3.0              # Base de datos SQLite
  path: ^1.8.3                 # Utilidades de path
  path_provider: ^2.1.0        # Acceso a directorios del sistema
  intl: ^0.19.0                # Formateo de fechas y números
  table_calendar: ^3.0.9       # Widget de calendario
  flutter_localizations:        # Localización en español
    sdk: flutter
```

### Dependencias de Desarrollo

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0        # Análisis estático de código
```

## 📱 Pantallas Implementadas (14 pantallas)

### Dashboard y Pedidos
1. **HomeScreen** - Dashboard con resúmenes y lista de pedidos
2. **NuevoPedidoScreen** - Wizard multi-paso para crear pedidos
3. **DetallePedidoScreen** - Detalle completo con gestión de estado y pagos
4. **CalendarScreen** - Calendario mensual con marcadores de entregas

### Gestión de Clientes
5. **ClientesScreen** - Lista de clientes con búsqueda y ordenamiento
6. **DetalleClienteScreen** - Detalle de cliente con familiares e historial
7. **FormularioClienteScreen** - Formulario para crear/editar clientes

### Gestión de Catálogo
8. **CatalogoScreen** - Menú principal del catálogo
9. **ProductosScreen** - CRUD de productos con precios
10. **BizcochuelosScreen** - CRUD de tipos de bizcochuelo
11. **RellenosScreen** - CRUD de tipos de relleno
12. **TematicasScreen** - CRUD de temáticas de decoración

### Otras Pantallas
13. **GalleryScreen** - Galería de fotos (placeholder)
14. **SettingsScreen** - Configuración y menús de gestión

## 🗄️ Base de Datos

### Estructura de la Base de Datos

La aplicación utiliza **SQLite** a través del paquete `sqflite` para persistencia local. La base de datos se crea automáticamente al iniciar la app por primera vez.

### Modelos de Datos (12 entidades)

1. **Cliente**: Información de clientes del negocio
2. **Familiar**: Familiares de clientes (para recordatorios de cumpleaños)
3. **Producto**: Catálogo de productos (tortas, bocaditos, etc.)
4. **Bizcochuelo**: Tipos de bizcochuelo disponibles
5. **Relleno**: Tipos de relleno disponibles
6. **Temática**: Temáticas de decoración
7. **Pedido**: Pedidos realizados por clientes
8. **PedidoDetalle**: Detalles de productos en cada pedido
9. **DetalleRelleno**: Rellenos seleccionados por capa
10. **Recordatorio**: Recordatorios para eventos importantes
11. **TareaPostventa**: Tareas de seguimiento post-entrega
12. **Foto**: Fotos asociadas a pedidos

### Datos Iniciales (Seeds)

Al crear la base de datos, se insertan datos de prueba:

- **3 Bizcochuelos**: Vainilla, Chocolate, Combinado
- **6 Rellenos**: DDL con merengues, DDL chip chocolate, DDL nueces, Mousse chocolate, Crema pastelera, Chantilly con frutas
- **5 Temáticas**: Princesas, Superhéroes, Flores, Cumpleaños Clásico, Personalizada
- **3 Productos**: Torta Clásica, Torta Grande, Bocaditos

### Uso de Repositorios

Todos los repositorios heredan de `BaseRepository` que proporciona operaciones CRUD básicas:

```dart
// Ejemplo: Usar el repositorio de clientes
final clienteRepo = ClienteRepository();

// Crear un nuevo cliente
final nuevoCliente = Cliente(
  nombre: 'María González',
  telefono: '1234567890',
  email: 'maria@example.com',
  fechaRegistro: DateTime.now(),
);
await clienteRepo.insert(nuevoCliente);

// Obtener todos los clientes
final clientes = await clienteRepo.getAll();

// Buscar cliente por nombre
final resultados = await clienteRepo.searchByName('María');

// Actualizar cliente
final clienteActualizado = nuevoCliente.copyWith(telefono: '0987654321');
await clienteRepo.update(clienteActualizado, nuevoCliente.id!);

// Eliminar cliente
await clienteRepo.delete(nuevoCliente.id!);
```

### Extender los Modelos

Para agregar nuevos campos a un modelo existente:

1. **Actualizar el modelo** (`lib/data/models/[modelo].dart`):
   ```dart
   class Cliente {
     final String? nuevocampo;
     // ... agregar en constructor, toMap, fromMap, copyWith
   }
   ```

2. **Crear migración** en `database_helper.dart`:
   ```dart
   Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
     if (oldVersion < 2) {
       await db.execute('ALTER TABLE cliente ADD COLUMN nuevo_campo TEXT');
     }
   }
   ```

3. **Incrementar versión** de la base de datos:
   ```dart
   return await openDatabase(
     path,
     version: 2, // Incrementar versión
     onCreate: _createDB,
     onUpgrade: _upgradeDB,
   );
   ```

### Para Crear un Nuevo Modelo

1. Crear archivo en `lib/data/models/nuevo_modelo.dart`
2. Implementar clase con métodos `toMap()`, `fromMap()`, y `copyWith()`
3. Agregar tabla en `database_helper.dart` método `_createDB`
4. Crear repositorio en `lib/data/repositories/nuevo_modelo_repository.dart`
5. Extender de `BaseRepository<NuevoModelo>`

## 🧪 Testing

Para ejecutar los tests:

```bash
flutter test
```

Para ejecutar tests con cobertura:

```bash
flutter test --coverage
```

## 🛠️ Desarrollo

### Comandos útiles

```bash
# Analizar código
flutter analyze

# Formatear código
flutter format .

# Limpiar build
flutter clean

# Ver dispositivos conectados
flutter devices

# Ver logs en tiempo real
flutter logs
```

### Convenciones de Código

- **Idioma**: Variables y funciones en inglés, textos de UI en español
- **Formato**: Usar `flutter format` antes de cada commit
- **Comentarios**: Documentar clases y funciones públicas

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo `LICENSE` para más detalles.

## 👥 Contribución

Las contribuciones son bienvenidas. Por favor:

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📞 Contacto

Proyecto: [https://github.com/damianfb/CositApp](https://github.com/damianfb/CositApp)

---

Hecho con ❤️ para las abuelas pasteleras