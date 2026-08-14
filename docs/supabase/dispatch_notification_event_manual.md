# Despliegue manual de `dispatch-notification-event`

La función requiere un proyecto Supabase ya creado y un proyecto Firebase con
Firebase Cloud Messaging habilitado. No guardes una llave de cuenta de servicio
ni su JSON dentro de este repositorio.

## 1. Crear la cuenta de servicio de Firebase

1. En Google Cloud Console abre el proyecto que usa la app Firebase.
2. Habilita **Firebase Cloud Messaging API** si todavía no está habilitada.
3. En **IAM y administración > Cuentas de servicio**, crea una cuenta dedicada
   para esta función.
4. Asigna únicamente el rol **Firebase Cloud Messaging API Admin** en el
   proyecto destino.
5. En **Claves**, genera una clave nueva de tipo JSON y guárdala temporalmente
   fuera de `C:\Apps\aikiglobal`.

La función sólo usa `project_id`, `client_email` y `private_key`. No cambies el
nombre del archivo a `service-account.json` ni lo muevas al repositorio.

## 2. Crear el env local ignorado

Ejecuta lo siguiente en PowerShell desde `C:\Apps\aikiglobal`. El script rechaza
un JSON ubicado dentro del repositorio y no imprime la llave privada.

```powershell
$repo = (Resolve-Path '.').Path
$serviceAccountPath = Read-Host 'Ruta absoluta del JSON de cuenta de servicio'
$serviceAccountFile = (Resolve-Path -LiteralPath $serviceAccountPath).Path

if ($serviceAccountFile.StartsWith($repo, [System.StringComparison]::OrdinalIgnoreCase)) {
  throw 'El JSON de cuenta de servicio debe estar fuera del repositorio.'
}

$envFile = Join-Path $repo 'supabase\functions\.env.local'

try {
  $serviceAccount = Get-Content -Raw -LiteralPath $serviceAccountFile | ConvertFrom-Json
  $privateKeyEscaped = $serviceAccount.private_key -replace "`r?`n", '\n'
  $envLines = @(
    "FIREBASE_PROJECT_ID=$($serviceAccount.project_id)"
    "FIREBASE_CLIENT_EMAIL=$($serviceAccount.client_email)"
    "FIREBASE_PRIVATE_KEY=`"$privateKeyEscaped`""
  )

  [System.IO.File]::WriteAllLines(
    $envFile,
    $envLines,
    [System.Text.UTF8Encoding]::new($false)
  )

  git check-ignore -v -- .\supabase\functions\.env.local
} finally {
  Remove-Variable serviceAccount, privateKeyEscaped, envLines -ErrorAction SilentlyContinue
}
```

`git check-ignore` debe mostrar una regla de `.gitignore`. Si no muestra nada,
detente y no ejecutes `git add` ni `supabase secrets set` hasta corregirlo.

## 3. Iniciar sesión y vincular Supabase

No escribas un `project-ref` de ejemplo en scripts o documentación ejecutable.
Léelo desde **Supabase Dashboard > Project Settings > General > Reference ID** y
proporciónalo de forma interactiva:

```powershell
supabase login
$projectRef = Read-Host 'Supabase project ref'
supabase link --project-ref $projectRef
```

Confirma en la salida de `supabase link` que el proyecto corresponde al entorno
correcto antes de continuar.

## 4. Registrar secretos y desplegar

Supabase proporciona `SUPABASE_URL`, `SUPABASE_ANON_KEY` y
`SUPABASE_SERVICE_ROLE_KEY` a la Edge Function. El env local sólo debe contener
las tres variables `FIREBASE_*`.

```powershell
supabase secrets set --env-file .\supabase\functions\.env.local
supabase functions deploy dispatch-notification-event
```

No uses `--no-verify-jwt`. La función además valida el JWT con el cliente anon y
confirma que el perfil sea administrador, activo y no eliminado antes de crear
el cliente service-role.

## 5. Validación manual

Obtén un JWT real de una sesión administrativa y evita dejarlo en el historial
de PowerShell. Puedes ingresarlo como valor seguro y mantenerlo sólo en memoria:

```powershell
$jwtSecure = Read-Host 'JWT del administrador' -AsSecureString

try {
  $jwt = [System.Net.NetworkCredential]::new('', $jwtSecure).Password
  $eventUuid = Read-Host 'uuid_notification_event manual y activo'
  $functionUrl = "https://$projectRef.supabase.co/functions/v1/dispatch-notification-event"

  $headers = @{
    Authorization = "Bearer $jwt"
    apikey = Read-Host 'Supabase anon key'
  }

  $previewBody = @{
    mode = 'preview'
    uuid_notification_event = $eventUuid
  } | ConvertTo-Json

  Invoke-RestMethod -Method Post -Uri $functionUrl -Headers $headers `
    -ContentType 'application/json' -Body $previewBody
} finally {
  Remove-Variable jwt, jwtSecure, headers, previewBody -ErrorAction SilentlyContinue
}
```

Comprueba que la respuesta incluya `uuid_notification_event`, `title`, `body`,
`category`, `audience_type`, `action_type`, `action_payload`,
`target_profile_count` y `target_device_count`. Ejecuta `mode = 'send'` sólo con
un evento de prueba y confirma después en Supabase:

- un único `notification_dispatches.idempotency_key = manual:<uuid>`;
- un inbox por perfil objetivo;
- conteos y estado terminal del dispatch;
- evento `completed` para `completed` o `partial`, o todavía `active` para
  `failed` sin éxitos.

Una nueva invocación nunca reenvía un dispatch `processing`: si tiene menos de
10 minutos devuelve `reused`; si supera ese límite intenta cerrarlo como
`partial` con resultado incierto y reconciliar el evento a `completed`.

Para validar el destino FCM, incluye un dispositivo elegible que tenga
`installation_id` y confirma que la solicitud use ese valor como `message.fid`.
`message.token = fcm_token` sólo es el fallback cuando `installation_id` está
ausente. Si FCM devuelve `UNREGISTERED` para un fallback, la desactivación
compara tanto el token como la ausencia o valor vacío original de
`installation_id`; un FID registrado después del envío impide desactivar esa
fila. Repite una invocación sobre un dispatch terminal para confirmar que el
evento se reconcilie a `completed` sin crear otro envío.

El envío reclama el dispatch con un CAS `pending -> processing` antes de crear
inbox o programar FCM. Dos invocaciones concurrentes deben producir un solo
procesamiento; la perdedora devuelve `reused` con estado `processing`.

Las pruebas automatizadas del repositorio validan el contrato de las cadenas
PostgREST mediante dobles en memoria; no levantan Supabase ni demuestran la
integración con PostgREST o FCM reales. La prueba manual de esta sección queda
pendiente en cada proyecto desplegado y debe ejecutarse antes de habilitar
envíos manuales en producción.

## 6. Prueba opcional de preview desplegado

`deployed_preview_integration_test.ts` está ignorada por defecto y la matriz
local no hace requests a un proyecto. Para ejecutarla deliberadamente contra la
función ya desplegada, usa un evento manual activo y una sesión administrativa:

```powershell
$jwtSecure = Read-Host 'JWT del administrador' -AsSecureString
$anonKeySecure = Read-Host 'Supabase anon key' -AsSecureString
$eventUuid = Read-Host 'uuid_notification_event manual y activo'
$functionUrl = "https://$projectRef.supabase.co/functions/v1/dispatch-notification-event"

try {
  $env:DISPATCH_NOTIFICATION_EVENT_FUNCTION_URL = $functionUrl
  $env:SUPABASE_ADMIN_JWT = [System.Net.NetworkCredential]::new('', $jwtSecure).Password
  $env:SUPABASE_ANON_KEY = [System.Net.NetworkCredential]::new('', $anonKeySecure).Password
  $env:UUID_NOTIFICATION_EVENT = $eventUuid

  deno test --allow-env --allow-net `
    .\supabase\functions\dispatch-notification-event\deployed_preview_integration_test.ts `
    -- --integration
} finally {
  Remove-Item Env:DISPATCH_NOTIFICATION_EVENT_FUNCTION_URL -ErrorAction SilentlyContinue
  Remove-Item Env:SUPABASE_ADMIN_JWT -ErrorAction SilentlyContinue
  Remove-Item Env:SUPABASE_ANON_KEY -ErrorAction SilentlyContinue
  Remove-Item Env:UUID_NOTIFICATION_EVENT -ErrorAction SilentlyContinue
  Remove-Variable jwtSecure, anonKeySecure -ErrorAction SilentlyContinue
}
```

La prueba sólo cubre autorización y contrato de respuesta de `preview`; no envía
notificaciones ni reemplaza la validación manual de `send` y FCM.

Después de registrar los secretos, conserva la clave JSON únicamente en un
almacén seguro o elimínala de forma controlada. Si alguna vez entra al repo,
rota la clave en Google Cloud; borrar el archivo de Git no revoca la credencial.
