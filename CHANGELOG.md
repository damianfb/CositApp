# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-02-06

### Added - ETAPA 1: Proyecto Base Flutter

#### Estructura del Proyecto
- ✅ Estructura de carpetas siguiendo arquitectura limpia
- ✅ Configuración de pubspec.yaml con dependencias básicas
- ✅ Configuración de análisis estático (analysis_options.yaml)
- ✅ Archivo .gitignore para Flutter

#### Core
- ✅ `app_constants.dart`: Constantes de la aplicación (colores, textos, etc.)
- ✅ `app_theme.dart`: Tema personalizado con colores cálidos/pastel
  - Color primario: Rosa pastel (#F8BBD9)
  - Color secundario: Crema (#FFF8E1)
  - Color de acento: Rosa intenso (#EC407A)
  - Tipografía consistente
  - Estilos para botones, cards, inputs

#### Aplicación
- ✅ `main.dart`: Punto de entrada de la aplicación
- ✅ `app.dart`: MaterialApp con configuración de tema

#### Presentación
- ✅ `bottom_nav_bar.dart`: Barra de navegación inferior con 5 tabs
  - 🏠 Inicio
  - 📅 Calendario
  - ➕ Nuevo (botón central con diálogo)
  - 📸 Galería
  - ⚙️ Configuración
- ✅ `home_screen.dart`: Pantalla de inicio (placeholder)
- ✅ `calendar_screen.dart`: Pantalla de calendario (placeholder)
- ✅ `gallery_screen.dart`: Pantalla de galería (placeholder)
- ✅ `settings_screen.dart`: Pantalla de configuración (placeholder)

#### Configuración Android
- ✅ `build.gradle`: Configuración de compilación
  - compileSdkVersion: 34
  - minSdkVersion: 24
  - targetSdkVersion: 33
- ✅ `AndroidManifest.xml`: Manifiesto con permisos
  - Nombre: "Cositas de la Abuela"
  - Permisos: Cámara, Almacenamiento, Notificaciones
- ✅ `MainActivity.kt`: Actividad principal en Kotlin
- ✅ Recursos Android (estilos, launcher)

#### Testing
- ✅ Tests básicos de widgets
- ✅ Verificación de navegación entre pantallas

#### Documentación
- ✅ README.md completo con:
  - Descripción del proyecto
  - Instrucciones de instalación
  - Estructura del proyecto
  - Roadmap de 5 etapas
  - Comandos útiles
- ✅ LICENSE (MIT)
- ✅ CHANGELOG.md

### Compatibilidad
- **Dispositivo objetivo**: Samsung A32
- **Sistema Operativo**: Android 13 (API 33) con One UI 5.1
- **Android mínimo**: Android 7.0 (API 24)

### Próximos Pasos (Etapa 2)
- Base de datos local con SQLite
- Modelo de datos para pedidos
- CRUD de pedidos
- Persistencia local
