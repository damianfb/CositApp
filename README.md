# 🍰 Cositas de la Abuela - CositApp

![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)
![Platform](https://img.shields.io/badge/platform-Android-green.svg)
![License](https://img.shields.io/badge/license-MIT-orange.svg)

## 📝 Descripción

**Cositas de la Abuela** es una aplicación móvil para la gestión de pedidos de pastelería artesanal. La app permite a los usuarios gestionar pedidos, visualizar un calendario de entregas, mantener una galería de fotos de productos, recibir notificaciones de recordatorios, y realizar backup de datos.

Esta es la **ETAPA 5** completada: Notificaciones locales, automatización de cumpleaños, backup/restore de datos y personalización con logo.

## ✨ Características Actuales (Etapa 5 - COMPLETADA)

### 🔔 Notificaciones Locales (NUEVA)
- ✅ **Recordatorios de entrega** configurables (X días antes, hora configurable)
- ✅ **Recordatorios de preparación** para iniciar elaboración de pedidos
- ✅ **Notificaciones de cumpleaños** con días de anticipación
- ✅ **Resumen mensual de cumpleaños** automático
- ✅ **Seguimiento post-venta** para pedir reseñas
- ✅ **Configuración personalizada** por tipo de notificación
- ✅ **Compatible con Android 13+ y One UI**

### 🎂 Automatización de Cumpleaños (NUEVA)
- ✅ **Lista de cumpleaños del mes** con contador de días
- ✅ **Próximos cumpleaños** (hasta 60 días)
- ✅ **Acciones rápidas**: llamar, enviar WhatsApp, crear pedido
- ✅ **Notificaciones automáticas** programables
- ✅ **Integración con clientes y familiares**

### 💾 Backup y Restore (NUEVA)
- ✅ **Exportar base de datos** completa a archivo comprimido
- ✅ **Formato JSON con compresión gzip**
- ✅ **Importar desde archivo** con confirmación
- ✅ **Verificación de integridad** del backup
- ✅ **Compartir backups** vía WhatsApp, email, etc.
- ✅ **Información detallada** de cada backup (fecha, registros)
- ✅ **Gestión de backups** (listar, eliminar, restaurar)

### 🎨 Personalización (NUEVA)
- ✅ **Logo oficial** en el icono de la app (launcher icon)
- ✅ **Logo en la interfaz** (AppBar de pantalla principal)
- ✅ **Branding coherente** en toda la aplicación

### Gestión de Pedidos (Etapa 3)
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

### ✅ Etapa 4: Galería de Fotos - COMPLETADA
- Captura de fotos con la cámara
- Gestión de galería
- Asociación de fotos con pedidos
- Compartir fotos en redes sociales

### ✅ Etapa 5: Notificaciones, Backup y Extras - COMPLETADA
- Notificaciones locales configurables
- Automatización de cumpleaños
- Backup y restore de datos
- Logo personalizado de la app
- Acciones rápidas (llamar, WhatsApp)

## 📦 Dependencias

### Dependencias de Producción

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.6              # Iconos iOS
  sqflite: ^2.3.0                      # Base de datos SQLite
  path: ^1.8.3                         # Utilidades de path
  path_provider: ^2.1.0                # Acceso a directorios del sistema
  intl: 0.20.2                         # Formateo de fechas y números
  table_calendar: ^3.0.9               # Widget de calendario
  image_picker: ^1.0.7                 # Captura de fotos
  share_plus: ^7.2.1                   # Compartir archivos
  permission_handler: ^11.2.0          # Permisos del sistema
  flutter_local_notifications: ^17.0.0 # Notificaciones locales
  timezone: ^0.9.2                     # Zonas horarias
  file_picker: ^8.0.0+1                # Selector de archivos
  archive: ^3.4.10                     # Compresión de archivos
  url_launcher: ^6.2.4                 # Abrir URLs
  flutter_localizations:               # Localización en español
    sdk: flutter
```

### Dependencias de Desarrollo

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0              # Análisis estático de código
  flutter_launcher_icons: ^0.13.1    # Generación de iconos
```

## 📱 Pantallas Implementadas (20 pantallas)

### Dashboard y Pedidos
1. **HomeScreen** - Dashboard con resúmenes y lista de pedidos (con logo)
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

### Galería y Fotos
13. **GalleryScreen** - Galería de fotos con filtros
14. **DetalleFotoScreen** - Detalle y edición de fotos

### Notificaciones y Backup (ETAPA 5)
15. **NotificationSettingsScreen** - Configuración de notificaciones
16. **BirthdaysScreen** - Lista de cumpleaños con acciones rápidas
17. **BackupRestoreScreen** - Gestión de backups

### Configuración
18. **SettingsScreen** - Menú de configuración principal
19. **CatalogoScreen** - Submenu de productos y catálogo
20. **ClientesScreen** - Submenu de gestión de clientes

## 🔔 Guía de Uso: Notificaciones

### Configurar Notificaciones

1. Ir a **Configuración → Notificaciones**
2. Activar/desactivar cada tipo de notificación:
   - **Entrega**: Días antes de la entrega
   - **Preparación**: Días antes de iniciar preparación
   - **Cumpleaños**: Días antes del cumpleaños
   - **Post-Venta**: Días después de la entrega
3. Ajustar días de anticipación y hora
4. Guardar configuración

### Probar Notificaciones

- Usar el botón **"Probar"** en la pantalla de configuración
- Las notificaciones aparecerán según permisos del sistema
- En Android 13+, los permisos se solicitan automáticamente

### Ver Cumpleaños

1. Ir a **Configuración → Cumpleaños**
2. Alternar entre "Este Mes" y "Próximos 60 días"
3. Ver días hasta cada cumpleaños
4. Usar acciones rápidas:
   - **Llamar**: Abre el marcador telefónico
   - **WhatsApp**: Envía mensaje personalizado
   - **Pedido**: Crea nuevo pedido

### Programar Recordatorios de Cumpleaños

1. Ir a **Configuración → Notificaciones**
2. Scroll hasta **"Recordatorios de Cumpleaños"**
3. Tap en **"Programar cumpleaños"**
4. Se programarán automáticamente según configuración

## 💾 Guía de Uso: Backup y Restore

### Crear Backup

1. Ir a **Configuración → Backup y Restore**
2. Tap en **"Crear Backup"**
3. Se generará un archivo `.cositbackup` comprimido
4. Opción de compartir vía WhatsApp, email, etc.

### Restaurar Backup

⚠️ **ADVERTENCIA**: Restaurar un backup reemplaza TODOS los datos actuales.

1. Ir a **Configuración → Backup y Restore**
2. Opción 1: Tap en backup existente → "Restaurar"
3. Opción 2: Tap **"Restaurar desde Archivo"** → Seleccionar archivo
4. Confirmar la acción
5. Esperar a que termine la restauración
6. Se recomienda reiniciar la app

### Compartir Backup

1. En la lista de backups, tap en el menú (⋮)
2. Seleccionar **"Compartir"**
3. Elegir aplicación para compartir
4. El backup se puede guardar en Drive, enviarse por email, etc.

### Ver Información del Backup

1. En la lista de backups, tap en el menú (⋮)
2. Seleccionar **"Ver información"**
3. Ver fecha, versión y cantidad de registros por tabla

### Eliminar Backups Antiguos

1. En la lista de backups, tap en el menú (⋮)
2. Seleccionar **"Eliminar"**
3. Confirmar la acción

## 🎨 Personalización: Icono de la App

### Generar Iconos de Launcher

El proyecto está configurado para usar el logo oficial desde `assets/images/cositasdelaabuela.png`:

```yaml
flutter_launcher_icons:
  android: true
  ios: false
  image_path: "assets/images/cositasdelaabuela.png"
  min_sdk_android: 24
  adaptive_icon_background: "#F8BBD9"
  adaptive_icon_foreground: "assets/images/cositasdelaabuela.png"
```

Para generar los iconos:

```bash
flutter pub run flutter_launcher_icons
```

Esto creará todos los iconos necesarios para Android en diferentes resoluciones.

### Logo en la Interfaz

El logo se muestra en:
- **AppBar del Home**: Esquina superior izquierda junto al nombre
- **Launcher Icon**: Icono de la aplicación en el dispositivo

**Nota**: El archivo de logo se encuentra en `assets/images/cositasdelaabuela.png` (una copia también existe en `lib/data/resources/` para referencia).

## 📦 Generar y Compartir el APK

### Generar el APK de Release

Para generar el archivo APK que puedes instalar en cualquier dispositivo Android:

1. Abre una terminal en la raíz del proyecto
2. Ejecuta el comando de build:

```bash
flutter build apk --release
```

3. El APK generado se encontrará en:
```
build/app/outputs/flutter-apk/app-release.apk
```

### Compartir el APK

Una vez generado el APK, puedes compartirlo de varias formas:

#### Opción 1: WhatsApp
1. Abre WhatsApp en tu dispositivo
2. Selecciona el contacto con quien quieres compartir
3. Toca el ícono de adjuntar (📎)
4. Selecciona "Documento" o "Archivo"
5. Navega hasta `build/app/outputs/flutter-apk/`
6. Selecciona `app-release.apk` y envía

#### Opción 2: Email
1. Abre tu cliente de email
2. Crea un nuevo mensaje
3. Adjunta el archivo `app-release.apk`
4. Envía el email

#### Opción 3: Google Drive / Cloud
1. Sube el archivo `app-release.apk` a Google Drive, Dropbox u otro servicio de almacenamiento en la nube
2. Comparte el enlace de descarga con quien necesite el APK

### Instalar en Dispositivos Android (Samsung A32)

Para instalar el APK en un dispositivo Samsung A32 u otro dispositivo Android:

1. **Habilita la instalación desde fuentes desconocidas**:
   - Ve a **Configuración** → **Seguridad y privacidad**
   - Busca **Instalar aplicaciones desconocidas**
   - Selecciona la aplicación desde la que instalarás (por ejemplo: Chrome, Archivos, WhatsApp)
   - Activa **Permitir desde esta fuente**

2. **Descarga o transfiere el APK**:
   - Descarga el APK desde el link compartido, o
   - Transfiere el archivo desde tu computadora al dispositivo (vía cable USB, Bluetooth, etc.)

3. **Instala la aplicación**:
   - Abre el administrador de archivos en tu dispositivo
   - Navega hasta la carpeta de **Descargas** (o donde hayas guardado el APK)
   - Toca el archivo `app-release.apk`
   - Sigue las instrucciones en pantalla para completar la instalación

4. **Abre la aplicación**:
   - Una vez instalada, busca "CositApp" o "Cositas de la Abuela" en tu lista de aplicaciones
   - Toca el ícono para abrir la app

#### ⚠️ Notas Importantes

- **Permisos**: La primera vez que abras la app, es posible que solicite permisos (cámara, almacenamiento, notificaciones). Acepta los permisos para que la app funcione correctamente.
- **Actualizaciones**: Para actualizar la app a una nueva versión, repite el proceso de instalación con el nuevo APK. La app existente será reemplazada manteniendo tus datos.
- **Seguridad**: Solo instala APKs de fuentes confiables. Si generas el APK tú mismo desde el código fuente, puedes estar seguro de su origen.

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