# 🚀 Guía de Inicio Rápido - Cositas de la Abuela

Esta guía te ayudará a poner en marcha el proyecto en 5 minutos.

## ⚡ Configuración Rápida

### 1. Prerrequisitos

Asegúrate de tener instalado:
- ✅ Flutter SDK 3.0+
- ✅ Android Studio o VS Code
- ✅ JDK 8+
- ✅ Git

### 2. Instalación

```bash
# Clonar el repositorio
git clone https://github.com/damianfb/CositApp.git
cd CositApp

# Configurar Flutter SDK en Android
# Edita android/local.properties y añade:
# flutter.sdk=/ruta/a/tu/flutter/sdk

# Instalar dependencias
flutter pub get

# Verificar configuración
flutter doctor
```

### 3. Ejecutar

```bash
# Conectar dispositivo Samsung A32 o iniciar emulador

# Verificar dispositivos
flutter devices

# Ejecutar app
flutter run
```

## 📱 Emulador Android 13

Si no tienes un dispositivo físico:

1. Abre Android Studio
2. Tools > AVD Manager
3. Create Virtual Device
4. Selecciona un dispositivo (ej: Pixel 5)
5. Selecciona "Tiramisu" (API 33 - Android 13)
6. Click "Finish"
7. Inicia el emulador

## 🔧 Solución de Problemas

### Error: "flutter.sdk not set"
Edita `android/local.properties`:
```properties
flutter.sdk=/ruta/completa/a/flutter
```

### Error: "Android licenses not accepted"
```bash
flutter doctor --android-licenses
```

### Error: "SDK version not found"
```bash
flutter upgrade
flutter clean
flutter pub get
```

## 📋 Verificación

La app debe:
1. ✅ Compilar sin errores
2. ✅ Mostrar pantalla de inicio "Cositas de la Abuela"
3. ✅ Permitir navegar entre 5 tabs
4. ✅ Mostrar diálogo al presionar botón "Nuevo"

## 🎯 Próximos Pasos

Una vez que la app funcione:
1. Explora las diferentes pantallas
2. Revisa el código en `lib/`
3. Personaliza el tema en `lib/core/theme/app_theme.dart`
4. Prepárate para la Etapa 2: Base de datos SQLite

## 📚 Recursos

- [Documentación Flutter](https://flutter.dev/docs)
- [Widgets Catalog](https://flutter.dev/docs/development/ui/widgets)
- [Pub.dev](https://pub.dev) - Paquetes de Dart/Flutter

---

¿Problemas? Abre un issue en GitHub.
