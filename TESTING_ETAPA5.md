# 🧪 Guía de Testing - ETAPA 5

## Prerrequisitos

- Dispositivo físico Samsung A32 con Android 13 o emulador equivalente
- Flutter SDK instalado y configurado
- App compilada y ejecutándose

## 1. Testing de Notificaciones

### Prueba 1: Configuración Básica
1. Abrir la app
2. Ir a **Configuración** (tab de Settings)
3. Tap en **"Notificaciones"**
4. Verificar que se carga la pantalla sin errores
5. Verificar contador de notificaciones pendientes

**Resultado esperado**: Pantalla carga correctamente con estado inicial

### Prueba 2: Notificación de Prueba
1. En pantalla de Notificaciones
2. Tap en botón **"Probar"**
3. Verificar que aparece notificación del sistema
4. Verificar que el título es "Prueba de Notificación"

**Resultado esperado**: Notificación aparece en el área de notificaciones de Android

### Prueba 3: Configurar Recordatorio de Entrega
1. En pantalla de Notificaciones
2. Activar toggle **"Recordatorios de Entrega"**
3. Cambiar días de anticipación a **2 días**
4. Cambiar hora a **10:00**
5. Tap en icono de **guardar** (arriba derecha)
6. Verificar SnackBar de confirmación

**Resultado esperado**: Configuración guardada correctamente

### Prueba 4: Verificar Permisos (Android 13+)
1. Al iniciar la app por primera vez
2. Verificar que aparece diálogo de permisos de notificaciones
3. Aceptar permisos
4. Verificar en Configuración → Notificaciones que aparece "Permisos concedidos"

**Resultado esperado**: Permisos solicitados y concedidos correctamente

## 2. Testing de Cumpleaños

### Prueba 5: Ver Cumpleaños del Mes
1. Ir a **Configuración**
2. Tap en **"Cumpleaños"**
3. Verificar filtro "Este Mes" está seleccionado
4. Ver lista de cumpleaños (puede estar vacía si no hay datos)

**Resultado esperado**: Pantalla carga sin errores

### Prueba 6: Agregar Cumpleaños de Prueba
1. Ir a **Configuración → Gestión de Clientes**
2. Seleccionar un cliente existente
3. Agregar un familiar con fecha de nacimiento en el mes actual
4. Volver a **Configuración → Cumpleaños**
5. Verificar que aparece el familiar agregado

**Resultado esperado**: Cumpleaños aparece en la lista con días correctos

### Prueba 7: Acciones Rápidas
1. En lista de cumpleaños, tap en un cumpleaños con teléfono
2. Verificar que botones **Llamar**, **WhatsApp**, **Pedido** están habilitados
3. Tap en **Llamar** - debe abrir marcador telefónico
4. Volver y tap en **WhatsApp** - debe abrir WhatsApp con mensaje pre-cargado

**Resultado esperado**: Botones funcionan y abren apps correctamente

### Prueba 8: Filtro de Próximos 60 Días
1. En pantalla de Cumpleaños
2. Cambiar a filtro **"Próximos 60 días"**
3. Verificar que lista se actualiza
4. Verificar ordenamiento por días hasta cumpleaños

**Resultado esperado**: Lista muestra cumpleaños hasta 60 días en el futuro

## 3. Testing de Backup y Restore

### Prueba 9: Crear Backup
1. Ir a **Configuración → Backup y Restore**
2. Tap en **"Crear Backup"**
3. Esperar mensaje de confirmación
4. Verificar que aparece opción de compartir
5. Seleccionar **"No"** por ahora
6. Verificar que backup aparece en la lista

**Resultado esperado**: Backup creado y visible en lista con fecha y tamaño

### Prueba 10: Ver Información de Backup
1. En lista de backups, tap en menú (⋮) de un backup
2. Seleccionar **"Ver información"**
3. Verificar que muestra:
   - Fecha de exportación
   - Versión
   - Conteo de registros por tabla
   - Total de registros

**Resultado esperado**: Diálogo muestra información correcta del backup

### Prueba 11: Compartir Backup
1. En lista de backups, tap en menú (⋮)
2. Seleccionar **"Compartir"**
3. Verificar que abre share sheet de Android
4. Seleccionar WhatsApp o email
5. Verificar que archivo se adjunta correctamente

**Resultado esperado**: Backup se comparte exitosamente

### Prueba 12: Restaurar Backup (⚠️ DESTRUCTIVO)
**ADVERTENCIA**: Esta prueba eliminará todos los datos actuales

1. Crear un backup primero
2. Agregar algunos datos de prueba (cliente, producto, etc)
3. Crear otro backup con los datos nuevos
4. En lista de backups, tap en menú (⋮) del primer backup
5. Seleccionar **"Restaurar"**
6. Leer advertencia y confirmar
7. Esperar proceso de restauración
8. Verificar que datos vuelven al estado del primer backup

**Resultado esperado**: Datos se restauran correctamente al estado anterior

### Prueba 13: Importar Backup desde Archivo
1. Compartir un backup previamente (enviar por WhatsApp a otro dispositivo o guardar)
2. En otra instalación o después de reinstalar, tap **"Restaurar desde Archivo"**
3. Seleccionar archivo .cositbackup
4. Confirmar restauración
5. Verificar que datos se importan correctamente

**Resultado esperado**: Backup externo se importa exitosamente

## 4. Testing de Logo

### Prueba 14: Logo en UI
1. Abrir la app
2. Ver pantalla de inicio (Home)
3. Verificar que logo aparece en AppBar (esquina superior izquierda)
4. Logo debe ser cuadrado de 40x40px con bordes redondeados

**Resultado esperado**: Logo visible y bien formateado

### Prueba 15: Generar Launcher Icon
**Nota**: Requiere ejecutar comando en terminal

```bash
cd /ruta/al/proyecto
flutter pub run flutter_launcher_icons
```

1. Ejecutar comando
2. Verificar salida sin errores
3. Compilar app: `flutter build apk`
4. Instalar en dispositivo
5. Verificar icono en launcher de Android

**Resultado esperado**: Icono personalizado visible en launcher

## 5. Testing de Integración

### Prueba 16: Flujo Completo - Pedido con Notificaciones
1. Crear un nuevo pedido para mañana
2. Ir a **Configuración → Notificaciones**
3. Verificar que hay notificación pendiente (contador aumentó)
4. Esperar hasta la hora configurada (o cambiar hora del sistema para testing)
5. Verificar que notificación aparece

**Resultado esperado**: Notificación se dispara en el momento correcto

### Prueba 17: Flujo Completo - Backup con Datos
1. Agregar varios clientes, productos, pedidos
2. Agregar fotos a algunos pedidos
3. Crear backup
4. Verificar tamaño del archivo (debe ser significativo)
5. Ver información - verificar conteos correctos
6. Restaurar backup
7. Verificar que todos los datos persisten incluyendo fotos

**Resultado esperado**: Todos los datos se respaldan y restauran correctamente

### Prueba 18: Flujo Completo - Cumpleaños con Pedido
1. Ver lista de cumpleaños próximos
2. Seleccionar uno en los próximos 3 días
3. Tap en botón **"Pedido"**
4. Crear pedido para ese cumpleaños
5. Configurar entrega para el día del cumpleaños
6. Guardar pedido
7. Ir a calendario - verificar que pedido está en fecha correcta

**Resultado esperado**: Flujo completo de remarketing por cumpleaños funciona

## 6. Testing de Errores

### Prueba 19: Permisos Denegados
1. Ir a Settings → Apps → CositApp → Permissions
2. Denegar permiso de notificaciones
3. Abrir app → Configuración → Notificaciones
4. Tap en **"Probar"**
5. Verificar que muestra mensaje de error apropiado

**Resultado esperado**: App maneja permisos denegados gracefully

### Prueba 20: Backup Corrupto
1. Crear un backup válido
2. Ubicar archivo .cositbackup
3. Editar con editor de texto (corromper JSON)
4. Intentar restaurar
5. Verificar que muestra error y no corrompe BD actual

**Resultado esperado**: Validación detecta backup inválido

### Prueba 21: Sin Datos para Backup
1. Hacer reset completo de la app (desinstalar y reinstalar)
2. Sin agregar datos, intentar crear backup
3. Verificar que backup se crea (solo con datos seed)
4. Ver información - debe mostrar solo datos iniciales

**Resultado esperado**: Backup funciona incluso con BD vacía

## 7. Testing de Performance

### Prueba 22: Backup Grande
1. Agregar muchos datos:
   - 50+ clientes
   - 100+ pedidos
   - 50+ fotos
2. Crear backup
3. Medir tiempo de creación
4. Verificar tamaño de archivo comprimido

**Resultado esperado**: Backup completa en tiempo razonable (< 10 segundos)

### Prueba 23: Restauración Grande
1. Usar backup del test anterior
2. Restaurar backup
3. Medir tiempo de restauración
4. Verificar que todos los datos están presentes

**Resultado esperado**: Restauración completa en tiempo razonable (< 30 segundos)

### Prueba 24: Muchas Notificaciones
1. Crear 20+ pedidos para los próximos días
2. Configurar notificaciones
3. Ir a Configuración → Notificaciones
4. Verificar contador de pendientes
5. Usar botón "Cancelar Todas"
6. Verificar que contador vuelve a 0

**Resultado esperado**: Sistema maneja múltiples notificaciones eficientemente

## ✅ Checklist de Testing Completo

- [ ] Todas las 24 pruebas ejecutadas
- [ ] Notificaciones funcionan en Android 13
- [ ] Cumpleaños listados correctamente
- [ ] Backup/restore preserva todos los datos
- [ ] Logo visible en UI y launcher
- [ ] Permisos manejados correctamente
- [ ] Sin crashes o errores inesperados
- [ ] Performance aceptable con datos reales
- [ ] Mensajes de error claros y útiles
- [ ] UI responsiva y fluida

## 📝 Notas de Testing

Documentar aquí cualquier problema encontrado:

```
Fecha: ___________
Tester: ___________
Dispositivo: Samsung A32 Android 13

Problemas encontrados:
- 
- 
- 

Notas adicionales:
- 
```

## 🐛 Reporte de Bugs

Si encuentras bugs durante el testing, reportar con este formato:

```markdown
### Bug #X: [Título descriptivo]

**Pasos para reproducir:**
1. 
2. 
3. 

**Resultado esperado:**
[Lo que debería pasar]

**Resultado actual:**
[Lo que pasó]

**Prioridad:** Alta/Media/Baja
**Pantalla:** [Nombre de la pantalla]
**Logs:** [Copiar logs relevantes]
```

---

**Última actualización:** 2026-02-06  
**Versión de la app:** 1.0.0+1  
**Etapa:** 5
