# Dos caras de Aiki — diseño del video

## Objetivo

Crear un video promocional editable de aproximadamente 60 segundos para inversionistas y administradores de la plataforma. Debe mostrar con evidencia real la experiencia del usuario y, en paralelo, la capacidad del administrador para publicar contenido, editarlo mediante FormPages y enviar notificaciones.

## Dirección creativa aprobada

La narrativa será **Dos caras de Aiki**: cada capacidad administrativa tendrá una consecuencia visible en la experiencia del usuario. El tono será relajado, elegante, minimalista y profesional, alineado con bienestar, meditación y encontrar la paz.

## Storyboard aprobado para la versión dinámica

| Tiempo | Vista | Acción |
| --- | --- | --- |
| 0–4 s | Aiki | Logo, atmósfera serena y propósito |
| 4–10 s | Usuario | Explora contenido y entra a una meditación |
| 10–16 s | Usuario | Consulta Mi espacio, progreso y contenidos guardados |
| 16–26 s | Administrador | Agrega y edita contenido mediante FormPages |
| 26–32 s | Usuario | Revisa suscripciones y el plan activo |
| 32–38 s | Usuario | Visualiza una racha y su avance |
| 38–46 s | Administrador | Configura y envía una notificación |
| 46–53 s | Usuario | Recibe la notificación y llega al contenido |
| 53–60 s | Aiki | Cierre con publicación, acompañamiento y crecimiento |

## Tratamiento visual

- Composición vertical 9:16, 1080×1920, 30 fps y 1800 frames.
- La intro comienza en blanco, reproduce la animación vertical del logo y se aleja para revelar el teléfono sobre el color `gold31`.
- El mockup usa una proporción física aproximada de 2.09:1, alineada con iPhone 17 y Galaxy S26, para evitar que parezca tableta.
- Mockups 3D de celular tipo Rotato para las vistas de usuario y administrador.
- El contenido administrativo panorámico se muestra con encuadre contenido dentro del teléfono para evitar recortes.
- Cortes de 2–4 segundos dentro de cada bloque, entradas laterales, giros de perspectiva, acercamientos agresivos pero elegantes y zooms sincronizados con acciones importantes.
- Los textos aparecen como tipografía cinética y etiquetas breves; no se mantienen tarjetas explicativas estáticas durante toda la escena.
- Cuando no haya grabaciones, cada teléfono mostrará una interfaz demo de Aiki con contenido visual representativo, no una tarjeta de “grabación pendiente”.
- Fondos claros y amplios, color tomado de la identidad existente, bordes suaves y sombras discretas.
- Tipografía Poppins y logotipos existentes cuando sean compatibles con el formato de video.
- Overlays de una idea breve; no se mantienen tarjetas explicativas durante toda la escena.

## Arquitectura editable

- Proyecto Remotion independiente en `remotion/aiki-video`.
- Diez escenas separadas dentro de un `TransitionSeries` para cubrir Mi espacio, Suscripciones y Rachas sin alargar los planos.
- Cada grabación será un nodo multimedia independiente y reemplazable; no se generarán clips editables con `.map()`.
- Textos, colores, logotipo, títulos de capítulos, clips, duración visible y activación de overlays se expondrán mediante props y esquema Zod.
- Las grabaciones reales se colocarán en `public/recordings`; mientras no estén disponibles, cada escena conservará su interfaz demo y podrá cambiar a `<Video>` sin modificar la narrativa.

## Evidencia y límites

- El video no alterará la aplicación Flutter.
- Una captura o grabación real solo puede editarse como clip: recorte, posición, escala y duración. Su contenido interno no se modifica desde Remotion.
- La entrega push debe grabarse únicamente después de validarla en el entorno de demostración. Si no está disponible, se mostrará el flujo verificable de preview, inbox y navegación, sin afirmar entrega end-to-end.

## Criterio de aceptación

- El preview abre en Remotion Studio.
- Las diez escenas aparecen con el orden y la duración del storyboard.
- Todos los mockups de usuario y administrador tienen entrada, perspectiva, giro, zoom y barrido de luz animados.
- El panel de props permite modificar al menos título, subtítulos, colores y visibilidad de overlays.
- La composición funciona aunque falten las grabaciones reales, mostrando contenido visual representativo dentro de cada teléfono.
- No se modifican archivos Flutter ni se sobrescriben cambios preexistentes del worktree.

## Revisión 3 — contenido demo y ritmo de tráiler

La versión aprobada prioriza emoción visual sin depender de grabaciones externas. `AikiDemoScreen` genera interfaces representativas para Explorar, Mi espacio, Suscripciones, Rachas, FormPages y notificaciones. `PhoneMockup` seguirá prefiriendo una grabación real cuando exista, pero usará el demo correspondiente cuando el prop esté vacío.
