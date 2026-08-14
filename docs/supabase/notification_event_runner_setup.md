# Configuracion del runner automatico de notificaciones

La Edge Function ya desplegada es `run-notification-events`. Aun falta registrar el secreto que autoriza al Cron y crear el unico trabajo de un minuto.

## 1. Crear el secreto de la funcion

En PowerShell, con la CLI autenticada:

```powershell
npx --yes supabase login

$bytes = New-Object byte[] 32
$rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
try {
  $rng.GetBytes($bytes)
} finally {
  $rng.Dispose()
}
$runnerSecret = [Convert]::ToBase64String($bytes)

npx --yes supabase secrets set `
  --project-ref hpysbnoaaallpbjfyafy `
  "NOTIFICATION_RUNNER_SECRET=$runnerSecret"
```

Conserva `runnerSecret` temporalmente para guardarlo en Vault. No lo subas al repositorio ni lo compartas en el chat.

## 2. Guardar secretos en Vault

En Supabase SQL Editor ejecuta cada secreto una sola vez. `project_url` ya fue creado por Codex; la instruccion es idempotente si se deja el `where`.

```sql
select vault.create_secret(
  'https://hpysbnoaaallpbjfyafy.supabase.co',
  'project_url'
)
where not exists (
  select 1 from vault.decrypted_secrets where name = 'project_url'
);

select vault.create_secret('PEGA_AQUI_RUNNER_SECRET', 'runner_secret');
```

No guardes la clave `service_role` en Vault para este runner. La Edge Function ya usa su variable interna `SUPABASE_SERVICE_ROLE_KEY`; Cron sólo necesita enviar el secreto privado `x-notification-runner-secret`.

## 3. Crear el Cron

```sql
select cron.unschedule(jobid)
from cron.job
where jobname = 'run-notification-events-every-minute';

select cron.schedule(
  'run-notification-events-every-minute',
  '* * * * *',
  $$
  select net.http_post(
    url := (select decrypted_secret
            from vault.decrypted_secrets
            where name = 'project_url')
      || '/functions/v1/run-notification-events',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'x-notification-runner-secret',
        (select decrypted_secret
         from vault.decrypted_secrets
         where name = 'runner_secret'),
    ),
    body := '{"source":"pg_cron"}'::jsonb
  ) as request_id;
  $$
);
```

## 4. Verificar

```sql
select jobid, jobname, schedule
from cron.job
where jobname = 'run-notification-events-every-minute';

select jobid, status, return_message, start_time, end_time
from cron.job_run_details
where jobid = (
  select jobid from cron.job
  where jobname = 'run-notification-events-every-minute'
)
order by start_time desc
limit 10;
```

Primero prueba una regla automatica con `dry_run` desde una invocacion autenticada. Despues activa una regla `schedule.at_time` o `schedule.interval` y verifica que aparezca un dispatch y sus filas de inbox. El formulario conservara el bloqueo de activacion hasta que esta comprobacion sea satisfactoria.
