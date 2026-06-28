# Content Media Design

## Objetivo

Agregar soporte para varios archivos de media por cada contenido administrable. Un `content_item` conserva la ficha editorial y cada archivo reproducible vive en `content_media`.

## Alcance

La primera version soporta tres tipos de archivo:

- `video`: clases, sesiones o lecciones en video.
- `audio`: notas de voz, podcasts, meditaciones guiadas o explicaciones.
- `ambient_sound`: sonidos ambientales.

Los borradores pueden guardarse sin media. Para publicar, el contenido debe tener al menos un registro `content_media` activo asociado.

## Contrato Remoto

La tabla remota sera aplicada manualmente en Supabase y no se generara migracion desde la app:

```sql
create table if not exists public.content_media (
  uuid_content_media uuid primary key default gen_random_uuid(),
  uuid_content_item uuid not null references public.content_items(uuid_content_item) on delete cascade,
  type text not null,
  title text,
  storage_path text not null,
  duration_seconds integer check (duration_seconds is null or duration_seconds >= 0),
  sort_order integer not null default 0,
  status text not null default 'draft',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  synced_at timestamptz
);
```

La app debe mapear los nombres remotos tal como estan: `type`, `title`, `storage_path`, `duration_seconds`, `sort_order`, `status`.

## Arquitectura

Se agrega una capa paralela a `content_items` siguiendo los patrones existentes:

- Modelo: `AppContentMedia`.
- Drift: `ContentMediaTable`.
- DAO: `ContentMediaDao`.
- Remoto: `ContentMediaRemoteService`.
- Sync: `ContentMediaSyncService`.
- Estado: `ContentMediaController`.
- Composicion: `AppDataContainer` crea dao, service, sync y controller.
- Acceso UI: `AppDataScope.contentMedia(context)`.
- Mappers: funciones en `sync_mappers.dart`.

`ContentItemsController` conserva la responsabilidad de guardar metadata editorial y portada. `ContentMediaController` administra lista, subida, reemplazo, borrado logico y sincronizacion de archivos media.

## Storage

Se reutiliza el bucket `content`.

Rutas propuestas:

```text
<uuid_content_item>/media/<uuid_content_media>/<timestamp>.<ext>
```

La portada se mantiene separada en la ruta existente de `cover`. La media usa `storage_path` y no debe mezclarse con `cover_path_supabase`.

Para archivos grandes, la implementacion inicial puede usar el upload disponible en `supabase_flutter`; si aparecen fallos por tamano o estabilidad, se debe evolucionar a upload resumible. La documentacion actual de Supabase recomienda TUS para archivos mayores a 6 MB.

## UI Admin

`AdminContentFormPage` agrega una seccion "Archivos del contenido":

- Lista de archivos ya asociados al contenido.
- Boton para agregar archivo.
- Campos por archivo: tipo, titulo, duracion opcional y orden.
- Acciones: editar metadata, quitar archivo, reordenar.

El boton `Guardar borrador` sigue permitido sin archivos. El boton `Publicar` debe bloquearse si no hay al menos un archivo media activo. El mensaje visible debe indicar que se necesita agregar al menos un archivo antes de publicar.

Como `image_picker` no cubre bien audio/video, se agregara un picker de archivos apropiado para seleccionar `video`, `audio` y sonidos ambientales.

## Lectura y Reproduccion

`ContentDetailPage` y `LessonPlayerPage` deben poder consultar los archivos media del contenido seleccionado.

La primera version puede mostrar el primer archivo activo ordenado como media principal. Para cursos o contenidos con multiples archivos, la app debe conservar el orden por `sort_order` y mostrar titulos propios por archivo.

La reproduccion real de audio/video puede implementarse despues de la persistencia si se necesita partir el trabajo. El contrato de datos debe quedar listo para ambos tipos.

## Sincronizacion Local

La tabla local mantiene `media_path_local` como cache opcional, equivalente al manejo de portadas. La sincronizacion usa `updated_at`, `deleted_at` y `synced_at` siguiendo `BaseSync`.

Los archivos binarios no viajan por la tabla. La tabla sincroniza metadata y rutas; Storage guarda los bytes.

## Seguridad

Las politicas RLS de `content_media` deben seguir el mismo modelo de `content_items`:

- Usuarios anonimos/autenticados leen solo media de contenidos publicados y no eliminados.
- Admins gestionan todos los registros.
- Storage debe permitir operaciones de admin sobre bucket `content` y lectura controlada mediante signed URLs.

La app no debe usar `service_role` ni llaves secretas en cliente.

## Validacion

Antes de implementar contra Supabase se debe confirmar que la tabla `content_media` ya existe o que el usuario aplico el SQL. La app debe tolerar que el remoto no este listo mostrando error de sync, sin romper guardado local donde aplique.

Validaciones minimas:

- No publicar sin media activa.
- No subir archivo sin titulo.
- No subir archivo sin tipo valido.
- No guardar metadata media sin `storage_path`.
- No mezclar portada con media reproducible.
