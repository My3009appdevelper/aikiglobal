# Aiki Video Second Half Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Mejorar visualmente el video de Aiki desde el segundo 16 con movimiento editorial, callouts BegumSans y reproducción optimizada, preservando intactos el audio y los primeros 16 segundos.

**Architecture:** Se conservarán las escenas y el `PhoneMockup` existentes. Se añadirá una capa visual reutilizable para halo y textos externos, mientras cada escena controla sus propios intervalos de movimiento con el frame local de Remotion. La selección de segmentos seguirá ocurriendo dentro del único video del teléfono; no se usarán crossfades que rendericen dos mockups.

**Tech Stack:** Remotion 4.0.506, React 19, TypeScript, `@remotion/media`, `interpolate`, `Easing`, grabaciones MP4 locales y fuente BegumSans incluida en `public/fonts`.

## Global Constraints

- El degradado dorado/ivory de Aiki permanece visible durante todo el video.
- Solo existe un mockup de teléfono en pantalla; nunca se cruzan ni duplican teléfonos.
- Las pantallas mostradas dentro del teléfono provienen de las grabaciones reales entregadas.
- Los textos externos son mínimos y usan `begumSansFamily`.
- No se modifica el audio ni la composición visual aprobada antes del segundo 16.
- Se validan lint, TypeScript y preview antes de considerar terminado el cambio.

---

### Task 1: Crear visuales zen reutilizables

**Files:**
- Create: `remotion/aiki-video/src/components/ZenVisuals.tsx`
- Test: validación estática mediante `npm run lint` en `remotion/aiki-video`

**Interfaces:**
- Consumes: `aikiPalette`, `begumSansFamily`, `useCurrentFrame`, `interpolate` y `Easing` de Remotion.
- Produces: `ZenAmbientGlow` y `ZenCallout` para las escenas posteriores al segundo 16.

- [ ] **Step 1: Crear `ZenVisuals.tsx`**

Implementar dos componentes puros de presentación:

```tsx
type ZenAmbientGlowProps = {
  intensity?: number;
  scale?: number;
};

type ZenCalloutProps = {
  text: string;
  startFrame: number;
  endFrame: number;
  align?: "left" | "center" | "right";
  bottom?: number;
};
```

`ZenAmbientGlow` debe ocupar el canvas completo detrás del teléfono, usar un `radial-gradient` con `aikiPalette.gold` y una respiración lenta entre escala `1` y `1.035`, con opacidad máxima de `intensity` (por defecto `0.22`).

`ZenCallout` debe:

- usar `begumSansFamily`;
- aparecer entre `startFrame` y `endFrame` con 12 frames de entrada y salida;
- entrar desde 12 px hacia abajo;
- mostrar una línea dorada de 54 px y el texto en `aikiPalette.wine`;
- estar en `position: absolute`, debajo del teléfono, sin bloquear la interacción;
- ocultarse fuera de su intervalo con opacidad `0`.

- [ ] **Step 2: Ejecutar lint**

Run: `npm run lint`

Expected: termina sin errores de ESLint ni TypeScript.

- [ ] **Step 3: Commit focalizado**

```bash
git add remotion/aiki-video/src/components/ZenVisuals.tsx
git commit -m "feat(video): add zen visual overlays"
```

---

### Task 2: Pulir Explorar y Contenido desde el segundo 16

**Files:**
- Modify: `remotion/aiki-video/src/scenes/UserExploreScene.tsx`
- Modify: `remotion/aiki-video/src/scenes/ContentScene.tsx`

**Interfaces:**
- Consumes: `ZenAmbientGlow` y `ZenCallout` de `../components/ZenVisuals`.
- Produces: un teléfono único, centrado y con movimiento sutil dentro de ambas escenas.

- [ ] **Step 1: Añadir el halo sin cambiar el fondo**

Renderizar `<ZenAmbientGlow />` antes del wrapper del teléfono, con `zIndex: 0`; el teléfono debe quedar en `zIndex: 1` y el callout en `zIndex: 2`.

- [ ] **Step 2: Añadir movimiento local a Explorar**

En `UserExploreScene`, calcular el frame local con `useCurrentFrame()` y comenzar el movimiento nuevo en `Math.round(1.9 * fps)`, equivalente al segundo absoluto 16. Aplicar al único wrapper del teléfono:

```tsx
const focusStart = Math.round(1.9 * fps);
const focusEnd = Math.round(4.2 * fps);
const phoneScale = interpolate(frame, [focusStart, focusStart + 18, focusEnd, focusEnd + 18], [1, 1.055, 1.055, 1], {
  extrapolateLeft: "clamp",
  extrapolateRight: "clamp",
  easing: Easing.bezier(0.16, 1, 0.3, 1),
});
```

No mover el teléfono más de 10 px verticales. Añadir `<ZenCallout text="Descubre tu momento" ... />` debajo del teléfono entre los frames locales 60 y 150.

- [ ] **Step 3: Añadir movimiento local a Contenido**

En `ContentScene`, mantener el teléfono centrado y aplicar una respiración corta desde el inicio de la escena: escala `1` → `1.045` → `1.015` durante los primeros 4.2 segundos locales. Añadir `<ZenCallout text="Una pausa para volver a ti" ... />` entre los frames locales 18 y 105.

Mantener `sourceStartAtSeconds={1}` y `objectFit="cover"`. No añadir contenido sintetizado.

- [ ] **Step 4: Ejecutar lint y comprobar el arranque**

Run: `npm run lint`

Expected: sin errores; las escenas conservan un solo `PhoneMockup` cada una y no se toca el audio.

- [ ] **Step 5: Commit focalizado**

```bash
git add remotion/aiki-video/src/scenes/UserExploreScene.tsx remotion/aiki-video/src/scenes/ContentScene.tsx
git commit -m "feat(video): add calm explore and content motion"
```

---

### Task 3: Optimizar Mi espacio y enfatizar el registro

**Files:**
- Modify: `remotion/aiki-video/src/scenes/UserMySpaceScene.tsx`

**Interfaces:**
- Consumes: `ZenAmbientGlow`, `ZenCallout` y `RecordingSegment` existente.
- Produces: segmentos reales con pausas compactadas, énfasis moderado del bottom sheet y retorno a vista completa.

- [ ] **Step 1: Ajustar segmentos de grabación**

Conservar la entrada desde `sourceStartAtSeconds: 2.5` y el corte real hacia `sourceStartAtSeconds: 28`, pero compactar el desplazamiento intermedio con una velocidad de `1.18` sin inventar frames:

```tsx
sourceSegments={[
  { fromSeconds: 0, sourceStartAtSeconds: 2.5 },
  { fromSeconds: 3.8, sourceStartAtSeconds: 6.7, playbackRate: 1.18 },
  { fromSeconds: 11.1, sourceStartAtSeconds: 28 },
]}
```

Verificar que el corte de `SegmentedRecording` siga pre-cargando segmentos y no produzca tirones.

- [ ] **Step 2: Animar el énfasis del formulario**

Usar el frame local para una escala máxima de `1.045` entre los frames locales `300` y `420` (10–14 s), con desplazamiento vertical máximo de `-8 px`. Después volver progresivamente a escala `1` para que el final muestre el teléfono completo.

- [ ] **Step 3: Añadir callout de registro**

Añadir `<ZenCallout text="Registra tu energía" ... />` entre los frames locales `315` y `435`, colocado debajo del teléfono y con opacidad baja. El contenido de la grabación permanece visible y el callout nunca entra dentro del mockup.

- [ ] **Step 4: Ejecutar lint y comprobar continuidad**

Run: `npm run lint`

Expected: sin errores; la escena usa un solo `PhoneMockup`, el formulario proviene exclusivamente del MP4 y el último segmento continúa mostrando el progreso real.

- [ ] **Step 5: Commit focalizado**

```bash
git add remotion/aiki-video/src/scenes/UserMySpaceScene.tsx
git commit -m "feat(video): refine my space rhythm"
```

---

### Task 4: Validación visual y de reproducción

**Files:**
- Modify: ninguno salvo correcciones puntuales derivadas de la validación.
- Inspect: `remotion/aiki-video/src/AikiVideo.tsx`, `remotion/aiki-video/src/timeline.ts`, escenas modificadas y `remotion/aiki-video/out`.

- [ ] **Step 1: Ejecutar lint completo**

Run: `npm run lint`

Expected: PASS.

- [ ] **Step 2: Abrir la preview de Remotion**

Run: `npm run dev -- --host 0.0.0.0`

Expected: la composición `AikiDosCaras` abre sin errores en Studio y mantiene el canvas vertical.

- [ ] **Step 3: Revisar frames clave**

Revisar en Studio los segundos `15.0`, `16.0`, `18.0`, `27.1`, `30.0`, `35.6`, `39.5`, `46.0` y `53.0`.

Expected:

- no hay duplicación del teléfono;
- el degradado permanece continuo;
- los callouts usan BegumSans;
- el teléfono se mantiene centrado y los zooms son moderados;
- no aparecen pantallas inventadas;
- los puntos de corte de grabación no presentan congelamientos visibles.

- [ ] **Step 4: Comparar los primeros 16 segundos**

Confirmar que `AikiVideo.tsx`, `BosquesAudio` y las escenas de Intro/Timer no fueron modificados por esta implementación.

- [ ] **Step 5: Documentar el resultado de la validación**

Si lint y Studio están correctos, reportar la preview disponible. No ejecutar un render completo hasta que el usuario lo solicite, porque el render anterior tardó más de un minuto.
