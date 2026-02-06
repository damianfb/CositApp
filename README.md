# 🍰 Cositas de la Abuela - CositApp

![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)
![Platform](https://img.shields.io/badge/platform-Android-green.svg)
![License](https://img.shields.io/badge/license-MIT-orange.svg)

## 📝 Descripción

**Cositas de la Abuela** es una aplicación móvil para la gestión de pedidos de pastelería artesanal. La app permite a los usuarios gestionar pedidos, visualizar un calendario de entregas, mantener una galería de fotos de productos, y más.

Esta es la **ETAPA 1** del proyecto: Proyecto Base Flutter con estructura de navegación y diseño visual.

## ✨ Características Actuales (Etapa 1)

- ✅ Proyecto Flutter funcional
- ✅ Navegación con Bottom Navigation Bar (5 tabs)
- ✅ Pantallas placeholder:
  - 🏠 Inicio
  - 📅 Calendario
  - ➕ Nuevo Pedido
  - 📸 Galería
  - ⚙️ Configuración
- ✅ Tema visual personalizado (colores cálidos/pastel)
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
│   └── presentation/
│       ├── screens/
│       │   ├── home_screen.dart           # Pantalla de inicio
│       │   ├── calendar_screen.dart       # Pantalla de calendario
│       │   ├── gallery_screen.dart        # Pantalla de galería
│       │   └── settings_screen.dart       # Pantalla de configuración
│       └── widgets/
│           └── bottom_nav_bar.dart        # Bottom Navigation Bar
├── android/                               # Configuración Android
├── test/                                  # Tests unitarios
├── pubspec.yaml                          # Dependencias
└── README.md                             # Este archivo
```

## 🗺️ Roadmap - 5 Etapas

### ✅ Etapa 1: Proyecto Base Flutter (COMPLETADA)
- Estructura de carpetas
- Navegación básica
- Tema visual

### ⏳ Etapa 2: Base de Datos Local (SQLite)
- Modelo de datos para pedidos
- CRUD de pedidos
- Persistencia local

### ⏳ Etapa 3: Calendario de Pedidos
- Integración de calendario
- Visualización de pedidos por fecha
- Notificaciones de recordatorio

### ⏳ Etapa 4: Galería de Fotos
- Captura de fotos con la cámara
- Gestión de galería
- Asociación de fotos con pedidos

### ⏳ Etapa 5: Funcionalidades Avanzadas
- Exportación de datos (CSV/PDF)
- Sincronización en la nube (opcional)
- Estadísticas y reportes

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