# Diseño de `notification_devices`

## Objetivo

Agregar el dominio `notification_devices` siguiendo literalmente la arquitectura offline-first existente de Aiki: tabla Drift, DAO, modelo, mappers, servicio remoto Supabase, servicio de sincronización por perfil, controller y registro en `AppDataContainer`/`AppDataScope`.

La tabla representa instalaciones capaces de recibir notificaciones push. No guarda preferencias temáticas del usuario ni historial de notificaciones; esas responsabilidades corresponderán posteriormente a `notification_preferences` y `notifications_inbox`.

## Alcance

Esta fase implementará:

- Persistencia local Drift en plataformas no web.
- Persistencia remota Supabase y sincronización por perfil.
- Registro o actualización de una instalación con datos proporcionados por el runtime de Firebase.
- Actualización del token o del permiso de una instalación existente.
- Desactivación de la instalación actual antes de cerrar la sesión de Supabase.
- Limpieza del estado observado cuando no exista un perfil autenticado.
- SQL manual para crear tabla, restricciones, índices, trigger `updated_at` y políticas RLS.

Esta fase no inicializará Firebase ni generará archivos como `google-services.json`, `GoogleService-Info.plist` o configuración web. La obtención automática de `installation_id` y `fcm_token` se conectará cuando exista un proyecto Firebase configurado. No se generarán identificadores o tokens simulados.

## Campos

| Campo | Tipo | Nulabilidad | Responsabilidad |
| --- | --- | --- | --- |
| `uuid_notification_device` | `uuid` / texto local | No | Identificador primario de la asociación perfil-instalación. |
| `uuid_profile` | `uuid` / texto local | No | Perfil propietario del registro. |
| `installation_id` | `text` | No | Firebase Installation ID de la instalación. No representa el teléfono físico. |
| `fcm_token` | `text` | Sí | Dirección FCM actual. Puede no existir antes de autorizar o completar el registro. |
| `platform` | `text` | No | Plataforma normalizada: `android`, `ios` o `web`. |
| `permission_status` | `text` | No | Estado normalizado: `authorized`, `denied`, `not_determined` o `provisional`. |
| `app_version` | `text` | Sí | Versión y build instalados, por ejemplo `1.0.0+1`. |
| `is_active` | `boolean` | No | Indica si la asociación continúa vigente para envíos técnicos. No es una preferencia del usuario. |
| `registration_refreshed_at` | `timestamptz` | Sí | Última vez que la aplicación confirmó y subió el registro de Firebase. |
| `created_at` | `timestamptz` | No | Creación del registro. |
| `updated_at` | `timestamptz` | No | Última modificación funcional. |
| `deleted_at` | `timestamptz` | Sí | Retiro lógico definitivo. |
| `synced_at` | `timestamptz` | Sí | Marca local de sincronización con el remoto. |

## Reglas e invariantes

- Un perfil puede tener varias instalaciones activas.
- Una instalación sólo puede estar activa para un perfil a la vez.
- El mismo perfil tendrá como máximo un registro no eliminado por `installation_id`.
- Un `fcm_token` no identifica el registro y puede cambiar.
- Sólo se consideran enviables los registros con `is_active = true`, `deleted_at is null`, `fcm_token is not null` y permiso `authorized` o `provisional`.
- `is_active = false` conserva historial y permite reactivar la misma asociación.
- `deleted_at` representa retiro lógico definitivo y no se utilizará para un cierre de sesión normal.
- `registration_refreshed_at` se actualizará cada vez que la app confirme el registro al servidor, aunque el token recibido sea igual al anterior.
- No se usará esta tabla para afirmar que un usuario está conectado o que leyó una notificación.

Supabase tendrá una restricción única `(uuid_profile, installation_id)` y dos índices únicos parciales: una sola asociación activa por `installation_id` y un solo registro activo por `fcm_token` no nulo. La desactivación de la cuenta anterior debe ocurrir antes de registrar la misma instalación para otra cuenta.

## Arquitectura de archivos

- `lib/core/data/local/tables/notification_devices_table.dart`: definición Drift y valores permitidos.
- `lib/core/data/local/daos/notification_devices_dao.dart`: consultas por perfil/instalación, watchers, upsert, actualización, desactivación y sync pendiente.
- `lib/core/data/models/app_notification_device.dart`: modelo inmutable de aplicación y getters `canReceivePush`/`hasPendingSync`.
- `lib/core/data/remote/services/notification_devices_remote_service.dart`: consultas y actualizaciones Supabase por perfil/instalación.
- `lib/core/data/sync/notification_devices_sync_service.dart`: réplica de `UserContentStatesSyncService`, con operaciones limitadas al perfil autenticado.
- `lib/core/data/providers/notification_devices_controller.dart`: estado observado, registro, refresh, desactivación y coordinación local/remota.
- `lib/core/data/sync/sync_mappers.dart`: conversiones local-remoto, remoto-Drift y remoto-app.
- `lib/core/data/remote/supabase_tables.dart`: constante `notificationDevices`.
- `lib/core/data/local/app_database.dart`: registro de tabla y aumento de versión de schema.
- `lib/core/data/providers/app_data_container.dart`: construcción de DAO, service, sync y controller; reacción a cambios del perfil.
- `lib/core/data/providers/app_data_scope.dart`: acceso central al controller.

No se creará un provider aislado o un segundo contenedor de dependencias; se reutilizarán los centralizados actuales.

## Flujo de datos

### Inicio de sesión

1. `CurrentProfileController` obtiene el perfil autenticado.
2. `AppDataContainer` activa `NotificationDevicesController.watchForProfile(uuidProfile)`.
3. El controller sincroniza únicamente los registros visibles para ese perfil.
4. Cuando el runtime Firebase entregue instalación, token, plataforma, permiso y versión, se llama `registerCurrentInstallation`.
5. El controller reutiliza la fila `(uuid_profile, installation_id)` o crea una nueva, la marca activa, limpia `deleted_at`, actualiza `registration_refreshed_at` y sincroniza.

### Renovación de registro

El futuro listener de Firebase llamará al controller con el token o permiso actualizado. La modificación conservará el UUID de la fila, actualizará `updated_at`, dejará `synced_at = null` en Drift y sincronizará con Supabase.

### Cierre de sesión

1. Antes de `Supabase.auth.signOut`, se ejecuta un callback asíncrono de cierre.
2. El controller marca `is_active = false` para la instalación actual y confirma el cambio remoto.
3. Sólo después se cierra la sesión de Supabase, porque posteriormente RLS ya no permitiría modificar la fila del perfil anterior.
4. El controller cancela watchers y limpia su estado en memoria.

Si existe un token activo y la desactivación remota falla, el cierre de sesión se abortará y el error se propagará. Esto evita dejar una ruta de notificación activa para una cuenta que ya no está abierta. Cuando Firebase esté configurado, la eliminación del token local podrá agregarse como una segunda garantía, pero no sustituirá la desactivación remota.

## Web y funcionamiento sin Drift

El proyecto no crea `AppDatabase` en web. El controller seguirá el patrón actual: usará DAO/sync cuando estén disponibles y recurrirá al servicio remoto directo cuando sean nulos. Los mismos métodos públicos funcionarán en ambos caminos.

## RLS y seguridad

- Un usuario autenticado podrá leer, insertar y actualizar sólo filas cuyo `uuid_profile` corresponda a su fila en `profiles.auth_user_id = auth.uid()`.
- Los administradores podrán consultar y administrar todas las filas mediante `public.is_admin()`.
- No se otorgará acceso a usuarios anónimos.
- El cliente no realizará borrado físico como parte del flujo normal.
- Las funciones backend de envío usarán posteriormente credenciales de servidor y nunca expondrán esas credenciales en Flutter.
- La interfaz administrativa no mostrará el token FCM completo por defecto, porque funciona como identificador técnico sensible.

## Manejo de errores

- Las validaciones rechazarán UUID de perfil, instalación o plataforma vacíos.
- `platform` y `permission_status` se validarán contra listas centralizadas.
- Un permiso sin token podrá persistirse; el registro simplemente no será enviable.
- Errores temporales de red mantendrán el registro local pendiente siguiendo `BaseSync`.
- Durante logout, un error al confirmar la desactivación remota impedirá cerrar la sesión si el registro todavía tiene un token activo.
- Errores de permisos/RLS se propagarán al controller y quedarán disponibles en `error`.
- La respuesta futura `UNREGISTERED` de FCM deberá marcar `is_active = false`; esto se implementará en la fase del backend de envíos.

## Pruebas

- DAO: consulta por perfil/instalación, unicidad lógica, watcher, registros pendientes y desactivación.
- Mappers: nulabilidad de token/versión/fechas y conservación de auditoría.
- Sync: sólo sube y descarga filas del perfil solicitado.
- Controller: crea, reutiliza, refresca y desactiva una instalación; soporta camino remoto sin DAO.
- Sesión: la desactivación se ejecuta antes del cierre remoto y el estado se limpia después.
- Base completa: generación Drift, `flutter analyze` y suite de pruebas existente.

## Entrega SQL

El SQL se entregará como comandos manuales para el editor de Supabase. No se agregará un archivo de migración al repositorio. Incluirá tabla, foreign key con `profiles`, checks, índices, trigger `set_updated_at`, RLS y políticas idempotentes.
