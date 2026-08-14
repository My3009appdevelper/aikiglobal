# Aiki Dynamic Demo Content Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Convert the vertical Aiki video into a more energetic 60-second product trailer that shows representative app content inside every phone mockup when recordings are unavailable.

**Architecture:** Keep `PhoneMockup` as the replaceable media boundary. Add one animated `AikiDemoScreen` renderer selected by a small screen-kind union; real recordings continue to win whenever a recording prop is present. Add focused feature scenes for Mi espacio, Suscripciones and Rachas, then reorder the existing `TransitionSeries` around the approved user/admin narrative.

**Tech Stack:** Remotion 4.0.506, React 19, TypeScript, `@remotion/media`, `@remotion/transitions`, Zod props schema, Poppins and existing Aiki theme tokens.

## Global Constraints

- Keep the composition vertical at 1080×1920, 30 fps and exactly 1800 frames.
- Keep all user-facing copy in Spanish with correct accents and preserve the existing Aiki palette and assets.
- Do not modify Flutter files or Supabase code.
- Keep recordings optional and replaceable through `public/recordings` and the Remotion props panel.
- Drive all motion with Remotion frame interpolation; do not use CSS transitions or CSS animations.

---

### Task 1: Build the animated Aiki demo screen

**Files:**
- Create: `remotion/aiki-video/src/components/AikiDemoScreen.tsx`
- Modify: `remotion/aiki-video/src/components/PhoneMockup.tsx`

**Interfaces:**
- `AikiDemoScreenKind = "explore" | "mySpace" | "adminCreate" | "adminEdit" | "subscriptions" | "streaks" | "adminNotification" | "notification"`.
- `PhoneMockup` accepts optional `demoKind?: AikiDemoScreenKind` and renders the demo only when `source` is empty.

- [ ] **Step 1: Add the screen-kind type and demo visual primitives.**
- [ ] **Step 2: Implement animated cards, progress, streak, subscription and notification states with `useCurrentFrame()` and `interpolate()`.**
- [ ] **Step 3: Replace the generic recording placeholder fallback in `PhoneMockup` with the selected demo screen.**
- [ ] **Step 4: Run `npm run lint` and confirm the new component type-checks.**

### Task 2: Add the missing feature scenes and recording props

**Files:**
- Create: `remotion/aiki-video/src/scenes/UserMySpaceScene.tsx`
- Create: `remotion/aiki-video/src/scenes/UserSubscriptionsScene.tsx`
- Create: `remotion/aiki-video/src/scenes/UserStreaksScene.tsx`
- Modify: `remotion/aiki-video/src/types.ts`
- Modify: `remotion/aiki-video/src/Root.tsx`

**Interfaces:**
- New recording props: `userMySpaceRecording`, `userSubscriptionsRecording`, `userStreaksRecording`.
- Each scene uses `PhoneMockup` with its matching `demoKind`, a concise `Callout`, and the existing `SceneCanvas`/`SceneLabel` contract.

- [ ] **Step 1: Extend the Zod schema and default props with the three optional recording paths.**
- [ ] **Step 2: Implement Mi espacio with animated saved-content and progress UI.**
- [ ] **Step 3: Implement Suscripciones with animated plan card and CTA state.**
- [ ] **Step 4: Implement Rachas with animated counter, calendar and accent pulse.**
- [ ] **Step 5: Run `npm run lint`.**

### Task 3: Rebuild the timeline as a fast product trailer

**Files:**
- Modify: `remotion/aiki-video/src/AikiVideo.tsx`
- Modify: `remotion/aiki-video/src/scenes/UserExploreScene.tsx`
- Modify: `remotion/aiki-video/src/scenes/AdminCreateContentScene.tsx`
- Modify: `remotion/aiki-video/src/scenes/AdminEditContentScene.tsx`
- Modify: `remotion/aiki-video/src/scenes/AdminNotificationScene.tsx`
- Modify: `remotion/aiki-video/src/scenes/UserNotificationScene.tsx`

**Interfaces:**
- Keep `AikiVideo` at 1800 frames, with sequence lengths `120, 180, 180, 210, 180, 180, 180, 210, 210, 150`.
- The active flow is Intro → Explorar → Mi espacio → Agregar contenido → Editar contenido → Suscripciones → Rachas → Admin notification → User notification → Outro.

- [ ] **Step 1: Wire each existing scene to its `demoKind` while preserving real-recording props.**
- [ ] **Step 2: Add the three new scenes in the approved order.**
- [ ] **Step 3: Update labels and callouts to short kinetic-product copy.**
- [ ] **Step 4: Run `npx remotion compositions` and confirm 1080×1920, 1800 frames and 60 seconds.**

### Task 4: Verify the visual trailer without external recordings

**Files:**
- Modify: `remotion/aiki-video/public/recordings/README.md`

- [ ] **Step 1: Render intro, Explore, Mi espacio, admin/FormPages, Rachas and notification stills.**
- [ ] **Step 2: Inspect the stills for clipping, empty phone bodies, unreadable text and excessive overlap.**
- [ ] **Step 3: Run `npm run lint` and `git diff --check`.**
- [ ] **Step 4: Confirm the Remotion Studio endpoint returns HTTP 200 and report the remaining manual check: replace demos with real recordings when available.**
