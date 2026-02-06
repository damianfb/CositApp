# 📸 Guía Rápida - Galería de Fotos

## 🚀 Inicio Rápido

### Para Usuarios

#### Agregar una Foto
1. Abrir app → Tab "Galería" (icono cámara)
2. Tap botón flotante "Agregar"
3. Elegir: Cámara o Galería
4. Tomar/seleccionar foto
5. Completar formulario
6. Tap "Guardar"

#### Ver Fotos
- **Grid**: Vista principal con todas las fotos
- **Tap en foto**: Ver detalle completo
- **Pull down**: Refrescar galería

#### Filtrar por Categoría
1. Tap icono filtro (esquina superior derecha)
2. Seleccionar categoría deseada
3. Tap "X" en chip para quitar filtro

#### Compartir Foto
1. Abrir foto en detalle
2. Tap icono "Compartir"
3. Elegir app (WhatsApp, Instagram, etc.)

#### Agregar Foto a Pedido
**Opción A - Desde Galería:**
1. Abrir foto en detalle
2. Tap "Asociar con pedido"
3. Seleccionar pedido de la lista

**Opción B - Desde Pedido:**
1. Abrir detalle de pedido
2. En sección "Fotos del Pedido"
3. Tap botón "+"
4. Tomar/seleccionar foto
5. ¡Listo! Se asocia automáticamente

---

## 🛠️ Para Desarrolladores

### Estructura del Código

```
lib/
├── data/
│   ├── models/
│   │   └── foto.dart                 # Modelo con constantes
│   ├── repositories/
│   │   └── foto_repository.dart      # CRUD + consultas especializadas
│   └── database/
│       └── database_helper.dart      # Migración v1→v2
└── presentation/
    └── screens/
        ├── gallery_screen.dart       # Galería principal
        ├── detalle_foto_screen.dart  # Detalle de foto
        └── detalle_pedido_screen.dart # Integración con pedidos
```

### Modelo de Datos

```dart
class Foto {
  static const String tipoProductoFinal = 'producto_final';
  static const String tipoProceso = 'proceso';
  static const String tipoReferencia = 'referencia';
  static const String tipoCatalogo = 'catalogo';
  static const String tipoOtro = 'otro';

  int? id;
  int? pedidoId;              // Opcional (nullable)
  String rutaArchivo;         // Path local
  String? descripcion;
  String tipo;                // Usar constantes
  DateTime fechaCreacion;
  bool visibleEnGaleria;      // true = visible
  String? categoria;          // Opcional
}
```

### Métodos del Repository

```dart
// Básicos
getAll()
getById(int id)
insert(Foto foto)
update(Foto foto, int id)
delete(int id)

// Especializados
getByPedido(int pedidoId)
getByTipo(String tipo)
getByCategoria(String categoria)
getVisiblesEnGaleria()
getVisiblesByCategoria(String? categoria)
getFotosCatalogo()
getCategorias()
countByCategoria()
deleteByPedido(int pedidoId)
updateVisibilidad(int id, bool visible)
searchByDescripcion(String query)
getTotalCount()
getVisiblesCount()
```

### Uso Básico

```dart
// Crear repositorio
final fotoRepo = FotoRepository();

// Obtener fotos visibles
final fotos = await fotoRepo.getVisiblesEnGaleria();

// Obtener fotos de un pedido
final fotosPedido = await fotoRepo.getByPedido(pedidoId);

// Filtrar por categoría
final fotasTortas = await fotoRepo.getByCategoria('Tortas');

// Insertar foto
final foto = Foto(
  rutaArchivo: '/path/to/photo.jpg',
  tipo: Foto.tipoProductoFinal,
  fechaCreacion: DateTime.now(),
  visibleEnGaleria: true,
  pedidoId: 123, // opcional
);
await fotoRepo.insert(foto);

// Actualizar visibilidad
await fotoRepo.updateVisibilidad(fotoId, false);
```

### Captura de Fotos

```dart
// Importar
import 'package:image_picker/image_picker.dart';

// Usar
final picker = ImagePicker();
final XFile? image = await picker.pickImage(
  source: ImageSource.camera, // o ImageSource.gallery
  maxWidth: 1920,
  maxHeight: 1920,
  imageQuality: 85,
);
```

### Permisos

```dart
// Importar
import 'package:permission_handler/permission_handler.dart';

// Solicitar permiso
final status = await Permission.camera.request();
if (status.isGranted) {
  // Capturar foto
} else {
  // Mostrar mensaje o abrir configuración
  openAppSettings();
}
```

### Compartir

```dart
// Importar
import 'package:share_plus/share_plus.dart';

// Compartir
await Share.shareXFiles(
  [XFile('/path/to/photo.jpg')],
  text: 'Mi foto de torta',
);
```

---

## 📋 Checklist de Integración

### Si vas a agregar fotos a tu feature:

- [ ] Importar `foto_repository.dart`
- [ ] Crear instancia de `FotoRepository`
- [ ] Usar constantes de tipo: `Foto.tipoProductoFinal`, etc.
- [ ] Validar existencia de archivo antes de mostrar
- [ ] Manejar caso de archivo no encontrado
- [ ] Actualizar UI después de cambios
- [ ] Considerar permisos si captura directa

### Si vas a mostrar fotos:

- [ ] Usar `Image.file()` para mostrar
- [ ] Envolver en `File.existsSync()` check
- [ ] Mostrar placeholder si no existe
- [ ] Agregar tap handler para navegación
- [ ] Considerar usar Hero animation

### Si vas a eliminar entidades con fotos:

- [ ] Usar `deleteByPedido()` para limpiar
- [ ] O confiar en CASCADE DELETE de FK
- [ ] Considerar eliminar archivos físicos también

---

## 🎨 UI Components

### Grid de Fotos

```dart
GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    childAspectRatio: 1.0,
    crossAxisSpacing: 8.0,
    mainAxisSpacing: 8.0,
  ),
  itemCount: fotos.length,
  itemBuilder: (context, index) {
    return FotoCard(foto: fotos[index]);
  },
)
```

### Card de Foto

```dart
Card(
  clipBehavior: Clip.antiAlias,
  child: Stack(
    children: [
      Image.file(file, fit: BoxFit.cover),
      Positioned(
        bottom: 0,
        child: Container(
          // Overlay con gradiente
        ),
      ),
    ],
  ),
)
```

---

## 🔍 Debugging

### Logs Importantes

```dart
print('📸 Galería cargada: ${fotos.length} fotos');
print('💾 Foto guardada en: $rutaDestino');
print('❌ Error cargando galería: $e');
```

### Comandos Útiles

```bash
# Ver archivos de fotos
adb shell run-as com.cositasdelaabuela.app ls -la /data/data/com.cositasdelaabuela.app/app_flutter/fotos/

# Ver contenido de DB
adb shell run-as com.cositasdelaabuela.app sqlite3 /data/data/com.cositasdelaabuela.app/databases/cositapp.db "SELECT * FROM foto;"
```

---

## ❓ FAQ

**P: ¿Dónde se guardan las fotos?**  
R: En `{appDocuments}/fotos/` - directorio privado de la app.

**P: ¿Las fotos persisten al desinstalar?**  
R: No, se eliminan con la app. Implementar backup en ETAPA 5.

**P: ¿Cuántas fotos puede tener?**  
R: Sin límite técnico, pero considerar espacio en dispositivo.

**P: ¿Se pueden editar las fotos?**  
R: Solo metadatos (descripción, categoría). Edición de imagen en ETAPA 5.

**P: ¿Cómo desasociar una foto de un pedido?**  
R: Editar foto y seleccionar "Sin pedido" o usar `update()` con `pedidoId: null`.

**P: ¿Qué pasa si elimino un pedido?**  
R: Las fotos se eliminan automáticamente (CASCADE DELETE).

**P: ¿Puedo buscar fotos?**  
R: Sí, usar `searchByDescripcion(query)` del repository.

---

## 🚀 Próximas Mejoras (ETAPA 5)

- [ ] Backup y exportación de fotos
- [ ] Sincronización en la nube
- [ ] Edición de fotos (crop, filtros)
- [ ] Búsqueda avanzada con tags
- [ ] Estadísticas de galería
- [ ] Exportar catálogo a PDF

---

**¿Dudas?** Revisa `ETAPA4_COMPLETADA.md` para documentación completa.
