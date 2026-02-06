# 🏗️ Arquitectura del Proyecto

## Visión General

Este proyecto sigue una arquitectura limpia simplificada, separando las responsabilidades en capas bien definidas.

## 📁 Estructura de Carpetas

```
CositApp/
├── lib/
│   ├── main.dart                    # Entry point
│   ├── app.dart                     # MaterialApp setup
│   │
│   ├── core/                        # Núcleo de la aplicación
│   │   ├── constants/               # Constantes globales
│   │   │   └── app_constants.dart   # Colores, textos, etc.
│   │   └── theme/                   # Tema visual
│   │       └── app_theme.dart       # ThemeData personalizado
│   │
│   └── presentation/                # Capa de presentación (UI)
│       ├── screens/                 # Pantallas completas
│       │   ├── home_screen.dart
│       │   ├── calendar_screen.dart
│       │   ├── gallery_screen.dart
│       │   └── settings_screen.dart
│       └── widgets/                 # Widgets reutilizables
│           └── bottom_nav_bar.dart
│
├── android/                         # Configuración Android
│   ├── app/
│   │   ├── build.gradle            # Build config
│   │   └── src/main/
│   │       ├── AndroidManifest.xml # Manifest
│   │       └── kotlin/             # Código nativo
│   └── gradle/                     # Gradle wrapper
│
└── test/                           # Tests
    └── widget_test.dart            # Tests de widgets
```

## 📐 Capas de la Arquitectura

### 1. **Core** - Núcleo de la Aplicación

**Responsabilidad**: Elementos compartidos y configuración global

- `constants/`: Valores constantes usados en toda la app
  - Colores
  - Textos estáticos
  - Configuraciones
  
- `theme/`: Configuración visual
  - ThemeData
  - Estilos de botones, cards, inputs
  - Tipografía

**Principios**:
- ✅ Inmutable
- ✅ Sin dependencias externas
- ✅ Fácilmente testeable

### 2. **Presentation** - Capa de Presentación

**Responsabilidad**: UI y experiencia de usuario

- `screens/`: Pantallas completas de la aplicación
  - Cada screen es una página independiente
  - Usa widgets y lógica de presentación
  
- `widgets/`: Componentes reutilizables
  - Bottom navigation bar
  - Custom buttons, cards, etc.

**Principios**:
- ✅ Widgets declarativos
- ✅ Separación de lógica y UI
- ✅ Reutilización de componentes

### 3. **Domain** (Futura - Etapa 2)

En etapas futuras se añadirá:
- `entities/`: Modelos de datos
- `repositories/`: Interfaces de datos
- `use_cases/`: Lógica de negocio

### 4. **Data** (Futura - Etapa 2)

En etapas futuras se añadirá:
- `models/`: Modelos de base de datos
- `data_sources/`: SQLite, APIs
- `repositories/`: Implementaciones

## 🎨 Convenciones de Diseño

### Colores

```dart
// Definidos en app_constants.dart
primaryColor: #F8BBD9    // Rosa pastel
secondaryColor: #FFF8E1  // Crema
accentColor: #EC407A     // Rosa intenso
textColor: #5D4037       // Marrón oscuro
```

### Tipografía

- **Display**: Para títulos grandes (32-24px)
- **Headline**: Para títulos de sección (20px)
- **Title**: Para títulos de cards (18-16px)
- **Body**: Para texto general (16-14px)

### Espaciado

- **Small**: 8px
- **Medium**: 16px
- **Large**: 24px
- **XLarge**: 32px

## 🔄 Flujo de Navegación

```
main.dart
    ↓
app.dart (MaterialApp)
    ↓
BottomNavBar (Stateful)
    ↓
    ├── HomeScreen
    ├── CalendarScreen
    ├── (New Dialog)
    ├── GalleryScreen
    └── SettingsScreen
```

## 🧪 Testing

### Estrategia de Testing

1. **Unit Tests**: Lógica de negocio (Etapa 2+)
2. **Widget Tests**: Componentes UI (Actual)
3. **Integration Tests**: Flujos completos (Etapa 3+)

### Cobertura Actual

- ✅ Tests de navegación
- ✅ Tests de widgets básicos
- ✅ Verificación de construcción de UI

## 📱 Plataforma Android

### Configuración

- **minSdkVersion**: 24 (Android 7.0)
  - Soporta ~93% de dispositivos Android
  
- **targetSdkVersion**: 33 (Android 13)
  - Optimizado para dispositivos recientes
  
- **compileSdkVersion**: 34
  - Usa las últimas APIs de Android

### Permisos

Preparados para futuras funcionalidades:
- 📷 CAMERA - Fotos de productos
- 📁 STORAGE - Guardar galería
- 🔔 POST_NOTIFICATIONS - Recordatorios

## 🚀 Escalabilidad

El proyecto está preparado para crecer:

### Etapa 2 - Base de Datos
```
lib/
├── domain/
│   ├── entities/
│   └── repositories/
└── data/
    ├── models/
    ├── data_sources/
    └── repositories/
```

### Etapa 3 - Estado Global
```
lib/
├── application/
│   ├── providers/
│   └── state/
```

### Etapa 4 - Servicios
```
lib/
├── infrastructure/
│   ├── services/
│   └── adapters/
```

## 🎯 Principios SOLID

1. **Single Responsibility**: Cada clase tiene una responsabilidad
2. **Open/Closed**: Abierto a extensión, cerrado a modificación
3. **Liskov Substitution**: Subclases sustituibles
4. **Interface Segregation**: Interfaces específicas
5. **Dependency Inversion**: Depender de abstracciones

## 📚 Referencias

- [Flutter Architecture](https://flutter.dev/docs/development/data-and-backend/state-mgmt/options)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter Best Practices](https://flutter.dev/docs/development/data-and-backend/state-mgmt/intro)

---

Última actualización: Etapa 1 - Proyecto Base
