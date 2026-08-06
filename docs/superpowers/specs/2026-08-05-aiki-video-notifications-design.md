# Aiki — escena de notificaciones del usuario

## Objetivo

Agregar, después de la escena continua de Perfil y Panel Admin, la grabación real `Notificaciones.mp4` dentro del mismo lenguaje visual de Aiki: un solo teléfono, fondo persistente gold31 y transición luminosa editable.

## Alcance aprobado

- La grabación real se reproduce desde su inicio para conservar el gesto de deslizar la bandeja de notificaciones.
- Se muestran únicamente las cinco notificaciones de Aiki que aparecen en la grabación.
- Se ocultan visualmente la notificación roja de grabación de pantalla, la palabra `aikiglobal`, la hora, la fecha, los datos de red y los controles inferiores del sistema.
- No se recrean las notificaciones con texto sintético ni se agregan pantallas que no existan en el video original.
- El teléfono permanece único, centrado verticalmente y con el mismo tamaño estable que el resto del video.
- La escena entra mediante el mismo halo/luz usado entre escenas y conserva el fondo Aiki sin flashes negros o blancos.

## Diseño visual

### Entrada

La escena actual de Perfil y Panel Admin termina sin cambiar de teléfono. A continuación se coloca una transición `AikiLightTransition` de un segundo y comienza la escena de Notificaciones. La transición funciona como capa del timeline; no monta un segundo mockup.

### Tratamiento de la grabación

El MP4 se coloca dentro de `PhoneMockup` con `contentFadeInOut={false}` para que el mockup permanezca estable. El contenido de la pantalla usa un reencuadre editable por tiempo:

1. al inicio se conserva el slide original para que se entienda la acción;
2. al desplegarse la bandeja se ajusta el encuadre hacia la lista de avisos;
3. el recorte deja dentro las cinco notificaciones de Aiki y fuera los elementos de sistema indicados;
4. el video termina con las cinco notificaciones visibles, sin inventar un cierre.

La redacción visual se implementa como una máscara/reencuadre dentro de la pantalla del teléfono, no como una edición destructiva del archivo original. Así el video fuente sigue siendo reemplazable y los límites pueden corregirse desde el componente.

## Arquitectura

- Copiar `assets/screenshots/Notificaciones.mp4` a `remotion/aiki-video/public/recordings/notificaciones.mp4` para servirlo con `staticFile()`.
- Conectar `UserNotificationScene` al final de `AikiVideo.tsx` como `07 - Notificaciones`.
- Reutilizar `SceneCanvas`, `TransitionBackdrop`, `ZenAmbientGlow` y `PhoneMockup`.
- Extender `PhoneMockup` solo si hace falta una propiedad específica de reencuadre; mantener la API compatible con las escenas existentes.
- Agregar `userNotificationRecording` al `defaultProps` de `Root.tsx` sin modificar las etiquetas actuales del usuario.
- Calcular la duración de la nueva escena a partir de la duración validada del MP4 (aprox. 5.56 s, redondeada a frames a 30 fps).

## Validación

- `npm run lint` debe pasar sin errores.
- La preview debe mostrar un único mockup en la transición y en la escena nueva.
- Revisar los puntos de entrada, despliegue completo y cierre del MP4.
- Confirmar visualmente que no aparecen `aikiglobal`, hora/fecha, la alerta roja ni los botones del sistema.
- Confirmar que el fondo permanece continuo y que las cinco notificaciones reales siguen legibles.

## Fuera de alcance

- No cambiar el audio Bosques ni los primeros segundos ya aprobados.
- No añadir texto externo, subtítulos ni una segunda grabación de administrador en esta escena.
- No renderizar un archivo final hasta validar primero la preview, salvo que el usuario lo solicite.
