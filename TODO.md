# 📝 TODO - Roadmap de Desarrollo

Este documento contiene el plan de desarrollo para las próximas etapas del proyecto.

## ✅ ETAPA 1: Proyecto Base Flutter - COMPLETADA

- [x] Estructura de carpetas
- [x] Configuración de pubspec.yaml
- [x] Core (constants y theme)
- [x] Navegación con Bottom Nav Bar
- [x] Pantallas placeholder
- [x] Configuración Android
- [x] Documentación completa
- [x] Tests básicos

---

## 📅 ETAPA 2: Base de Datos Local (SQLite)

**Objetivo**: Implementar persistencia local de datos con SQLite

### Tareas

**Dependencias**
- [ ] Añadir sqflite: ^2.3.0
- [ ] Añadir path: ^1.8.3
- [ ] Añadir path_provider: ^2.1.0

**Modelo de Datos**
- [ ] Crear `lib/domain/entities/order.dart`
  - [ ] id (String)
  - [ ] clientName (String)
  - [ ] productType (String)
  - [ ] quantity (int)
  - [ ] deliveryDate (DateTime)
  - [ ] notes (String?)
  - [ ] price (double)
  - [ ] status (enum: pending, confirmed, completed)
  - [ ] createdAt (DateTime)
  
**Base de Datos**
- [ ] Crear `lib/data/database/database_helper.dart`
  - [ ] initDatabase()
  - [ ] createTables()
  - [ ] CRUD methods
  
**Repository**
- [ ] Crear `lib/domain/repositories/order_repository.dart` (interface)
- [ ] Crear `lib/data/repositories/order_repository_impl.dart`
  - [ ] createOrder()
  - [ ] getOrders()
  - [ ] getOrderById()
  - [ ] updateOrder()
  - [ ] deleteOrder()
  - [ ] getOrdersByDate()
  
**UI - Home Screen**
- [ ] Mostrar lista de pedidos recientes
- [ ] Card widget para cada pedido
- [ ] Acción de editar/eliminar
- [ ] EmptyState cuando no hay pedidos

**UI - Nuevo Pedido**
- [ ] Formulario completo
  - [ ] TextField para nombre del cliente
  - [ ] Dropdown para tipo de producto
  - [ ] Number input para cantidad
  - [ ] DatePicker para fecha de entrega
  - [ ] TextField para notas
  - [ ] TextField para precio
- [ ] Validación de formulario
- [ ] Guardar en base de datos
- [ ] Mensaje de confirmación

**Tests**
- [ ] Unit tests para OrderRepository
- [ ] Widget tests para formulario
- [ ] Integration tests para CRUD

---

## 📆 ETAPA 3: Calendario de Pedidos

**Objetivo**: Visualizar pedidos en un calendario interactivo

### Tareas

**Dependencias**
- [ ] Añadir table_calendar: ^3.0.9

**UI - Calendar Screen**
- [ ] Integrar TableCalendar widget
- [ ] Marcar días con pedidos
- [ ] Mostrar lista de pedidos del día seleccionado
- [ ] Vista de mes/semana/día

**Notificaciones**
- [ ] Añadir flutter_local_notifications
- [ ] Programar notificaciones para días de entrega
- [ ] Configurar permisos en Android
- [ ] Botón para activar/desactivar recordatorios

**Tests**
- [ ] Tests de calendario
- [ ] Tests de notificaciones

---

## 📸 ETAPA 4: Galería de Fotos

**Objetivo**: Capturar y gestionar fotos de productos

### Tareas

**Dependencias**
- [ ] Añadir image_picker: ^1.0.0
- [ ] Añadir photo_view: ^0.14.0

**Modelo de Datos**
- [ ] Crear `lib/domain/entities/product_photo.dart`
  - [ ] id
  - [ ] orderId (FK)
  - [ ] photoPath
  - [ ] caption
  - [ ] createdAt

**Base de Datos**
- [ ] Tabla para product_photos
- [ ] Relación con orders

**UI - Gallery Screen**
- [ ] Grid de fotos
- [ ] Botón FAB para agregar foto
- [ ] Visor de foto en pantalla completa
- [ ] Asociar foto con pedido

**Cámara**
- [ ] Integrar image_picker
- [ ] Capturar foto desde cámara
- [ ] Seleccionar desde galería
- [ ] Comprimir y guardar imagen

**Tests**
- [ ] Tests de galería
- [ ] Tests de captura de fotos

---

## 🚀 ETAPA 5: Funcionalidades Avanzadas

**Objetivo**: Añadir exportación, estadísticas y opciones avanzadas

### Tareas

**Exportación de Datos**
- [ ] Añadir pdf: ^3.10.0
- [ ] Añadir csv: ^5.1.0
- [ ] Generar reporte PDF de pedidos
- [ ] Exportar a CSV
- [ ] Compartir archivos

**Estadísticas**
- [ ] Crear `lib/presentation/screens/statistics_screen.dart`
- [ ] Gráficos con fl_chart
- [ ] Pedidos por mes
- [ ] Ingresos totales
- [ ] Productos más vendidos

**Settings Screen**
- [ ] Configuración de la app
  - [ ] Activar/desactivar notificaciones
  - [ ] Configurar recordatorios
  - [ ] Tema claro/oscuro
  - [ ] Idioma (español/inglés)
- [ ] Backup/Restore de base de datos
- [ ] Limpiar cache
- [ ] Acerca de la app

**Sincronización en la Nube (Opcional)**
- [ ] Firebase Authentication
- [ ] Firebase Firestore
- [ ] Sincronizar pedidos
- [ ] Backup automático

**Tests**
- [ ] Tests de exportación
- [ ] Tests de estadísticas
- [ ] Tests E2E completos

---

## 🎯 Mejoras Futuras

**Optimizaciones**
- [ ] Provider/Riverpod para gestión de estado
- [ ] Lazy loading de listas
- [ ] Caché de imágenes
- [ ] Optimización de rendimiento

**Características Adicionales**
- [ ] Multi-idioma completo (i18n)
- [ ] Tema oscuro
- [ ] Búsqueda de pedidos
- [ ] Filtros avanzados
- [ ] Recordatorios personalizados
- [ ] Widget de escritorio
- [ ] Integración con WhatsApp
- [ ] Plantillas de mensajes

**Calidad**
- [ ] Aumentar cobertura de tests a >80%
- [ ] Documentación de API
- [ ] CI/CD con GitHub Actions
- [ ] Análisis de código estático mejorado

---

## 📌 Notas de Desarrollo

### Convenciones
- Usar inglés para código, español para UI
- Seguir Clean Architecture
- Escribir tests para cada feature
- Documentar funciones públicas
- Commits descriptivos

### Prioridades
1. Funcionalidad básica
2. Experiencia de usuario
3. Tests
4. Documentación
5. Optimizaciones

---

**Última actualización**: 2024-02-06
**Etapa actual**: 1 de 5 (Completada)
**Próxima etapa**: 2 - Base de Datos Local
