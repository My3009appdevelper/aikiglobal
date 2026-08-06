# Aiki Video Notifications Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Integrar la grabación real de Notificaciones después de Perfil y Panel Admin, ocultar los elementos del sistema y mantener el teléfono y los textos correctamente centrados con la escala 1.35.

**Architecture:** Se conservará `PhoneMockup` como único dispositivo. Una propiedad de transformación solo para el contenido permitirá reencuadrar la bandeja de notificaciones sin mover el chasis; una máscara visual interna cubrirá los elementos no deseados. Los textos externos pasarán a un escenario vertical reutilizable con un espacio reservado debajo del teléfono, para que teléfono + texto formen un grupo centrado.

**Tech Stack:** Remotion 4.0.506, React 19, TypeScript, `@remotion/media`, `useCurrentFrame`, `interpolate`, `Easing` y MP4 local servido desde `public/`.

## Global Constraints

- El degradado dorado/ivory de Aiki permanece visible durante todo el video.
- Solo existe un mockup de teléfono en pantalla; nunca se cruzan ni duplican teléfonos.
- Las pantallas mostradas dentro del teléfono provienen de las grabaciones reales entregadas.
- Los textos externos son mínimos y usan `begumSansFamily`.
- La escala base del teléfono se conserva en `phoneScale: 1.35`.
- No se modifica el audio Bosques ni los primeros segundos ya aprobados.
- Las etiquetas actuales de `Root.tsx` se conservan exactamente.

---

### Task 1: Probar y centralizar el reencuadre de Notificaciones

**Files:**
- Create: `remotion/aiki-video/src/notificationLayout.ts`
- Create: `remotion/aiki-video/scripts/notification-layout.test.ts`

**Interfaces:**
- Produces `notificationRecordingDurationInSeconds`, `notificationFocusStartInSeconds`, `notificationFocusEndInSeconds`, `notificationFocusScale`, `notificationFocusTranslateY` y `notificationReframeAtSeconds(seconds)`.
- The test runs directly with Node 24 using `node --experimental-strip-types`.

- [ ] **Step 1: Write the failing test**

```ts
import assert from "node:assert/strict";
import { notificationReframeAtSeconds } from "../src/notificationLayout.ts";

const start = notificationReframeAtSeconds(0);
assert.equal(start.scale, 1);
assert.equal(start.translateY, 0);

const focused = notificationReframeAtSeconds(2);
assert.ok(focused.scale > 1);
assert.ok(focused.translateY < 0);

const finished = notificationReframeAtSeconds(5.5);
assert.equal(finished.scale, focused.scale);
assert.equal(finished.translateY, focused.translateY);
```

- [ ] **Step 2: Run the test and verify the expected failure**

Run: `node --experimental-strip-types scripts/notification-layout.test.ts`

Expected: FAIL because `src/notificationLayout.ts` does not exist yet.

- [ ] **Step 3: Add the minimal timing helper**

Implement the helper with a clamped linear progress between 1.15 s and 1.65 s. Return `{scale: 1, translateY: 0}` before the focus window and `{scale: 1.18, translateY: -26}` after it. Export the validated recording duration `5.561778` seconds.

- [ ] **Step 4: Run the test and verify it passes**

Run: `node --experimental-strip-types scripts/notification-layout.test.ts`

Expected: PASS with no assertion errors.

- [ ] **Step 5: Commit the timing contract**

```powershell
git add remotion/aiki-video/src/notificationLayout.ts remotion/aiki-video/scripts/notification-layout.test.ts
git commit -m "test(video): define notification reframe timing"
```

### Task 2: Add a centered phone-and-callout stage

**Files:**
- Modify: `remotion/aiki-video/src/components/ZenVisuals.tsx`
- Create: `remotion/aiki-video/src/components/ScenePhoneStage.tsx`
- Modify: `remotion/aiki-video/src/scenes/UserExploreScene.tsx`
- Modify: `remotion/aiki-video/src/scenes/ContentScene.tsx`
- Modify: `remotion/aiki-video/src/scenes/UserMySpaceScene.tsx`
- Modify: `remotion/aiki-video/src/scenes/UserProfileScene.tsx`

**Interfaces:**
- `ScenePhoneStage` accepts `phone: ReactNode` and `callouts: ZenCalloutConfig[]` and renders a vertically centered group with a 40 px gap and a 150 px callout slot.
- `ZenCallout` gains `layout?: "overlay" | "slot"`; existing callers default to `"overlay"`, while the active scenes use `"slot"`.

- [ ] **Step 1: Write the failing layout assertion**

Add a small assertion to `scripts/notification-layout.test.ts` for the stage constants:

```ts
import { scenePhoneStageGap, scenePhoneStageCalloutHeight } from "../src/notificationLayout.ts";

assert.equal(scenePhoneStageGap, 40);
assert.equal(scenePhoneStageCalloutHeight, 150);
```

- [ ] **Step 2: Run the test and verify the expected failure**

Run: `node --experimental-strip-types scripts/notification-layout.test.ts`

Expected: FAIL because the stage constants are not exported yet.

- [ ] **Step 3: Implement the centered stage and slot layout**

Use a flex column with `alignItems: "center"`, `justifyContent: "center"`, `gap: 40`, and a fixed `minHeight: 150` slot below the phone. Render each `ZenCallout` absolutely inside that slot so only opacity/translate changes, not the group geometry. Keep `BegumSans`, the existing line, colors and 12-frame entry/exit interpolation.

- [ ] **Step 4: Replace the absolute bottom callouts in active scenes**

Pass each scene's existing `PhoneMockup` as `phone` and its existing callouts as `callouts`. Do not alter their text, timings, source segments, or phone scale. This moves the group together and leaves more space between phone and text.

- [ ] **Step 5: Run the test and lint**

Run: `node --experimental-strip-types scripts/notification-layout.test.ts; npm run lint`

Expected: the test passes and ESLint/TypeScript exit with code 0.

- [ ] **Step 6: Commit the stage layout**

```powershell
git add remotion/aiki-video/src/notificationLayout.ts remotion/aiki-video/scripts/notification-layout.test.ts remotion/aiki-video/src/components/ZenVisuals.tsx remotion/aiki-video/src/components/ScenePhoneStage.tsx remotion/aiki-video/src/scenes/UserExploreScene.tsx remotion/aiki-video/src/scenes/ContentScene.tsx remotion/aiki-video/src/scenes/UserMySpaceScene.tsx remotion/aiki-video/src/scenes/UserProfileScene.tsx
git commit -m "feat(video): center phone and callouts as one stage"
```

### Task 3: Add the real notification recording and system redaction

**Files:**
- Create binary asset: `remotion/aiki-video/public/recordings/notificaciones.mp4` copied from `assets/screenshots/Notificaciones.mp4`
- Modify: `remotion/aiki-video/src/components/PhoneMockup.tsx`
- Create: `remotion/aiki-video/src/components/NotificationScreenMask.tsx`
- Modify: `remotion/aiki-video/src/scenes/UserNotificationScene.tsx`

**Interfaces:**
- `PhoneMockup` gains optional `contentScale?: number` and `contentTranslateY?: number` applied only to the inner screen content, never to the phone shell.
- `NotificationScreenMask` renders editable top/bottom screen masks and receives the current reframe values from `UserNotificationScene`.

- [ ] **Step 1: Write the failing source-contract test**

Extend `scripts/notification-layout.test.ts`:

```ts
import { notificationRecordingDurationInSeconds } from "../src/notificationLayout.ts";

assert.equal(notificationRecordingDurationInSeconds, 5.561778);
```

The test must fail before the duration export is implemented.

- [ ] **Step 2: Run the test and verify the expected failure**

Run: `node --experimental-strip-types scripts/notification-layout.test.ts`

Expected: FAIL only because the duration contract is not exported.

- [ ] **Step 3: Copy the delivered recording into `public/recordings`**

Use PowerShell `Copy-Item` from the exact asset path to the exact public path. Do not alter the source recording.

- [ ] **Step 4: Implement content-only reframe and mask**

In `PhoneMockup`, apply `scale` and `translate` to the content layer after its `inset: 11` bounds, keeping `border`, `borderRadius`, notch and shadow unchanged. In `UserNotificationScene`, use `notificationReframeAtSeconds(frame / fps)` and render the original video from `sourceStartAtSeconds={0}` with `contentFadeInOut={false}`. The mask must hide the status area, `aikiglobal`, the recording alert and bottom system controls without adding replacement notification text.

- [ ] **Step 5: Run lint and the timing test**

Run: `node --experimental-strip-types scripts/notification-layout.test.ts; npm run lint`

Expected: PASS; only one `PhoneMockup` is rendered by the scene.

- [ ] **Step 6: Commit the notification scene**

```powershell
git add remotion/aiki-video/public/recordings/notificaciones.mp4 remotion/aiki-video/src/components/PhoneMockup.tsx remotion/aiki-video/src/components/NotificationScreenMask.tsx remotion/aiki-video/src/scenes/UserNotificationScene.tsx remotion/aiki-video/src/notificationLayout.ts remotion/aiki-video/scripts/notification-layout.test.ts
git commit -m "feat(video): add real notification recording"
```

### Task 4: Connect the scene to the composition and validate the timeline

**Files:**
- Modify: `remotion/aiki-video/src/AikiVideo.tsx`
- Modify: `remotion/aiki-video/src/Root.tsx`

**Interfaces:**
- The new sequence is appended after `06 - Perfil y Panel Admin` with one existing `AikiLightTransition` overlay.
- `userNotificationRecording` becomes `recordings/notificaciones.mp4`.

- [ ] **Step 1: Add the duration and sequence**

Use `Math.ceil(notificationRecordingDurationInSeconds * compositionFps)` for `notificationDurationInFrames`, add it to `aikiVideoDurationInFrames`, then append `07 - Notificaciones` after the current final scene. Keep the existing Bosques audio duration tied to the updated total.

- [ ] **Step 2: Set the recording prop without changing user labels**

Change only `userNotificationRecording` in `Root.tsx` from an empty string to `recordings/notificaciones.mp4`.

- [ ] **Step 3: Run lint and a one-frame composition check**

Run: `npm run lint; npx remotion still AikiDosCaras --scale=0.25 --frame=2654`

Expected: lint passes and the still command exits 0 with the new scene starting after the previous 88.47-second section.

- [ ] **Step 4: Commit the timeline connection**

```powershell
git add remotion/aiki-video/src/AikiVideo.tsx remotion/aiki-video/src/Root.tsx
git commit -m "feat(video): connect notification scene to timeline"
```

### Task 5: Preview and verify the user-visible result

**Files:**
- Inspect: `remotion/aiki-video/src/AikiVideo.tsx`, active scenes, `PhoneMockup`, `NotificationScreenMask`, `out/` only if a render is requested.

- [ ] **Step 1: Confirm the editor responds**

Check `http://192.168.1.39:3000/AikiDosCaras` and navigate to the last scene.

- [ ] **Step 2: Review frames at the scene boundaries**

Review the final frame of Perfil y Panel Admin, the light transition, the first slide frame, the fully expanded list, and the last frame of Notificaciones.

- [ ] **Step 3: Verify the acceptance checklist**

Confirm: one phone only; phone + active text centered horizontally and vertically; phone scale 1.35; text separated by the stage gap; five Aiki notifications visible; no `aikiglobal`, time/date, carrier/status icons, red recording alert or system controls; persistent Aiki background; no black/white flash.

- [ ] **Step 4: Do not render the full MP4 unless requested**

The preview is the validation path. A final render remains available through the existing render player when the user asks for it.
