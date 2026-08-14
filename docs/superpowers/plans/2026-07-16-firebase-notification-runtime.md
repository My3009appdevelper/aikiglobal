# Firebase Notification Runtime Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Registrar la instalacion Android autenticada en `notification_devices`, mantener actualizado su token FCM y volver a comprobar permiso y token cuando la app regresa al primer plano.

**Architecture:** Un cliente Firebase recopila FID, token, permiso y version sin conocer Supabase. Un runtime serializa los registros y los entrega al `NotificationDevicesController` offline-first existente. `AppDataContainer` enlaza el runtime al perfil actual y `AppDataScope` solo reenvia el evento de reanudacion de la app.

**Tech Stack:** Flutter, Firebase Core, Firebase Messaging, Firebase Installations, Package Info Plus, Drift, Supabase y `flutter_test`.

## Global Constraints

- Configurar Firebase solo para Android en esta fase.
- No inicializar Firebase en web, iOS, macOS, Windows o Linux hasta generar opciones para esas plataformas.
- No mostrar loaders ni dialogs propios para solicitar notificaciones; Android presenta el permiso del sistema.
- No guardar ni imprimir el token FCM completo en logs.
- No agregar migraciones ni modificar el schema de Supabase.
- Preservar el cierre de sesion que desactiva el dispositivo antes de cerrar Supabase.

---

### Task 1: Contrato y runtime testeable

**Files:**
- Create: `lib/core/notifications/notification_device_registration.dart`
- Create: `lib/core/notifications/notification_device_runtime.dart`
- Test: `test/core/notifications/notification_device_runtime_test.dart`

**Interfaces:**
- `NotificationDeviceRegistrationClient.loadRegistration({required bool requestPermission, String? fcmTokenOverride})` devuelve FID, token, plataforma, permiso, version y fecha UTC.
- `NotificationDeviceRuntime.activateProfile`, `refreshCurrentProfile`, `clearProfile` y `dispose` administran el ciclo de vida.

- [ ] Escribir pruebas que activen un perfil, comprueben que el primer registro solicita permiso y verifiquen los campos guardados mediante el controller real con Drift en memoria.
- [ ] Ejecutar `flutter test test/core/notifications/notification_device_runtime_test.dart` y confirmar que falla porque el runtime no existe.
- [ ] Implementar una cola serial para impedir dos altas simultaneas y descartar resultados de un perfil que ya no esta activo.
- [ ] Probar que `onTokenRefresh` actualiza la misma fila sin volver a solicitar permiso y que `refreshCurrentProfile` vuelve a consultar el estado actual.
- [ ] Ejecutar nuevamente el test y confirmar que pasa.

### Task 2: Adaptador Firebase Android

**Files:**
- Create: `lib/core/notifications/firebase_notification_device_client.dart`
- Create: `lib/core/notifications/firebase_notification_support.dart`
- Test: `test/core/notifications/firebase_notification_device_client_test.dart`

**Interfaces:**
- `FirebaseNotificationDeviceClient` usa `FirebaseInstallations.instance.getId()`, `FirebaseMessaging.instance` y `PackageInfo.fromPlatform()`.
- `supportsFirebaseNotificationRuntime({required bool isWeb, required TargetPlatform platform})` solo devuelve `true` para Android no web.

- [ ] Escribir pruebas fallidas para el mapeo de `AuthorizationStatus` a `authorized`, `denied`, `not_determined` y `provisional`, el formato `version+build` y el guard de plataforma.
- [ ] Implementar el cliente usando `requestPermission` en la primera alta, `getNotificationSettings` en refrescos y `getToken` salvo que llegue un token renovado.
- [ ] Ejecutar el test del adaptador y confirmar que pasa.

### Task 3: Cableado con sesion y ciclo de vida

**Files:**
- Modify: `lib/main.dart`
- Modify: `lib/core/data/providers/app_data_container.dart`
- Modify: `lib/core/data/providers/app_data_scope.dart`
- Modify: `lib/core/data/providers/notification_devices_controller.dart`

**Interfaces:**
- `AppDataContainer.create` recibe opcionalmente un `NotificationDeviceRegistrationClient` y expone el runtime nullable.
- `NotificationDevicesController.watchForProfile(..., {bool pullRemote = true})` permite que el runtime haga primero un pull remoto antes del alta inicial.

- [ ] Inicializar Firebase y crear el cliente solo cuando la plataforma soportada sea Android.
- [ ] Al cargar un perfil: observar sus dispositivos, traer la fila remota previa y luego registrar la instalacion actual.
- [ ] Al quitar el perfil: invalidar operaciones pendientes y limpiar el controller.
- [ ] Al reanudar la app: refrescar permiso y token sin volver a mostrar el prompt.
- [ ] Al disponer el contenedor: cancelar las suscripciones del runtime antes de disponer el controller.

### Task 4: Verificacion y prueba real

**Files:**
- Verify: archivos anteriores y configuracion Android Firebase.

- [ ] Ejecutar `dart format` en los archivos tocados.
- [ ] Ejecutar los tests de runtime junto con los tests existentes de `notification_devices` y logout.
- [ ] Ejecutar analisis estatico focalizado y `:app:processDebugGoogleServices`.
- [ ] Intentar compilacion Android y reportar por separado cualquier error ajeno a Firebase.
- [ ] En un dispositivo fisico, iniciar sesion, aceptar permiso y confirmar en Supabase una fila activa con `platform = 'android'`, `permission_status = 'authorized'` y token no nulo.
