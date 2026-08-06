# Aiki Custom Notification Tray Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Replace the failed cropped notification recording with a polished Remotion-built notification sequence inside one centered Aiki phone.

**Architecture:** The existing scene transition and `PhoneMockup` remain the outer composition. The notification scene will render a custom `NotificationTrayScreen` containing the Aiki background, a warm ivory notification tray, five editable notification cards, a gold light pulse, and a short notification chime. The source recording remains available as reference but is no longer rendered.

**Tech Stack:** Remotion 4, React, TypeScript, `@remotion/media` Audio, existing Aiki palette and phone mockup components.

## Global Constraints

- Keep exactly one centered phone; do not duplicate, spin, zoom, or move the mockup during this scene.
- Keep the existing Aiki background and project palette; no dark translucent notification tray.
- Render only the five Aiki notifications; omit system status, date, time, `aikiglobal`, screen-recording controls, photo wallpaper, and Android controls.
- Animate with `useCurrentFrame()` and `interpolate()`; do not use CSS transitions or CSS animations.
- Preserve user-owned Flutter and `Root.tsx` changes; stage only focused Remotion files and the generated chime asset.

---

### Task 1: Define the editable notification timing contract

**Files:**
- Modify: `remotion/aiki-video/src/notificationLayout.ts`
- Modify: `remotion/aiki-video/scripts/notification-layout.test.ts`

**Interfaces:**
- Produce `notificationSoundStartInSeconds`, `notificationTrayOpenDurationInSeconds`, and an ordered `notificationCardTimings` contract consumed by the custom tray.
- Each card timing must expose `startInSeconds` and `endInSeconds`, with five entries in chronological order.

- [ ] **Step 1: Add failing assertions** for the sound start, five-card order, monotonic start times, and tray-open duration.
- [ ] **Step 2: Run** `node --experimental-strip-types scripts/notification-layout.test.ts` and confirm the new assertions fail.
- [ ] **Step 3: Implement** the constants and typed timing array in `notificationLayout.ts`, using a first-notification cue at `0.55` seconds, card starts at `0.75`, `1.15`, `1.55`, `1.95`, and `2.35` seconds, and a tray-open duration of `1.65` seconds.
- [ ] **Step 4: Run** the same test and confirm it passes.
- [ ] **Step 5: Commit** with `test(video): define custom notification timing contract`.

### Task 2: Create the Aiki notification chime asset

**Files:**
- Create: `remotion/aiki-video/public/audio/aiki-notification-chime.wav`

**Interfaces:**
- Produce a short mono WAV notification sound with two soft ascending tones, approximately `0.55` seconds, suitable for a calm Aiki presentation.

- [ ] **Step 1: Generate** the WAV with the bundled FFmpeg using two sine tones, a short overlap, and a fade-out; do not modify `Bosques.mp3`.
- [ ] **Step 2: Verify** the asset with FFprobe for duration, sample rate, and audio stream presence.
- [ ] **Step 3: Commit** with `feat(video): add aiki notification chime`.

### Task 3: Rebuild the notification tray as native Remotion markup

**Files:**
- Modify: `remotion/aiki-video/src/components/NotificationTrayScreen.tsx`
- Modify: `remotion/aiki-video/src/theme.ts` only if an existing palette token is genuinely missing

**Interfaces:**
- `NotificationTrayScreen({ source?: string })` continues to be accepted by the scene for editor compatibility, but `source` is not rendered.
- The component owns the five notification copy records, card layout, entry animation, tray opening, light burst, and `<Audio src={staticFile("audio/aiki-notification-chime.wav")} />`.

- [ ] **Step 1: Replace** the video-window implementation with a full-screen `SoftBackground` base and a warm ivory tray using `gold`, `gold31Surface`, `sandLight`, `warmIvory`, `wine`, and `stroke` tokens.
- [ ] **Step 2: Add** the five records in recording order:
  `Un respiro entre todo`; `Algo cambió para acompa...`; `Tu progreso sigue`; `Una pausa para meditar r...`; `9:20 pm, una pausa consc...`.
- [ ] **Step 3: Animate** the tray from the top with a spring-like eased `translate` and opacity; animate each card with a staggered `translate`/opacity based on `notificationCardTimings`.
- [ ] **Step 4: Add** a gold radial light pulse and thin gold line when the first notification arrives, synchronized with the chime start frame.
- [ ] **Step 5: Render** cards as editable React markup so copy, colors, positions, and timings remain directly changeable in Studio.

### Task 4: Connect the native tray to the final scene

**Files:**
- Modify: `remotion/aiki-video/src/scenes/UserNotificationScene.tsx`
- Inspect only: `remotion/aiki-video/src/AikiVideo.tsx`

**Interfaces:**
- `UserNotificationScene` uses the existing `ScenePhoneStage` and `PhoneMockup` with `screenContent={<NotificationTrayScreen />}`.
- The scene keeps the existing transition from `06 - Perfil y Panel Admin` and the current notification scene duration.

- [ ] **Step 1: Remove** the notification scene’s dependency on the source recording and legacy crop/reframe behavior.
- [ ] **Step 2: Keep** the phone dimensions, scale, centered positioning, and outer Aiki background unchanged.
- [ ] **Step 3: Preserve** the existing timeline sequence and light transition in `AikiVideo.tsx`; do not add a second phone or a second scene transition.
- [ ] **Step 4: Commit** with `feat(video): recreate aiki notification tray`.

### Task 5: Verify the motion and live editor

**Files:**
- Inspect: `remotion/aiki-video/src/components/NotificationTrayScreen.tsx`
- Inspect: `remotion/aiki-video/src/scenes/UserNotificationScene.tsx`

- [ ] **Step 1: Run** `node --experimental-strip-types scripts/notification-layout.test.ts`.
- [ ] **Step 2: Run** `npm run lint` from `remotion/aiki-video`.
- [ ] **Step 3: Render** stills at notification-scene start, first cue, first card, third card, and final card frames with `npx remotion still AikiDosCaras --scale=0.25 --frame=<frame>`.
- [ ] **Step 4: Confirm visually** one phone, Aiki background, no dark tray, five cards in order, no system UI, and no cropped recording imagery.
- [ ] **Step 5: Confirm** `http://192.168.1.39:3000/AikiDosCaras` returns HTTP 200 and the Studio refreshes to the new scene.
