# Dos caras de Aiki Video Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build an editable Remotion composition that alternates real Aiki app footage with elegant explanatory overlays for users, administrators, FormPages, and notifications.

**Architecture:** Create a standalone `remotion/aiki-video` project inside the existing repository. Keep scene components separate and sequence them with `TransitionSeries`; keep every replaceable clip authored as an explicit JSX node. Use a Zod schema and inline composition metadata so Remotion Studio can edit copy, colors, visibility, and clip props without touching Flutter code.

**Tech Stack:** Remotion, React, TypeScript, `@remotion/media`, `@remotion/transitions`, Zod, existing Aiki PNG/MP4 assets.

## Global Constraints

- Preserve the existing dirty worktree; do not modify Flutter, Android, iOS, Supabase, or existing documentation.
- Use Spanish copy with correct accents and UTF-8.
- Keep the composition at 1080×1920 vertical 9:16, 30 fps, and 60 seconds.
- Use `useCurrentFrame()` and `interpolate()` for motion; do not use CSS transitions or animations.
- Keep interactive styles inline and use `scale`, `translate`, and `rotate` where possible.
- Do not render a final MP4 until real recordings and any approved audio are available; verify through Studio and a still render first.

---

### Task 1: Scaffold the isolated Remotion project

**Files:**
- Create: `remotion/aiki-video/package.json`
- Create: `remotion/aiki-video/src/`
- Create: `remotion/aiki-video/public/`

**Interfaces:**
- Produces a runnable Remotion project with the default scripts and dependencies.

- [ ] **Step 1: Verify Node.js, npm, and Git are available**

Run from `C:\Apps\aikiglobal`:

```powershell
node --version
npm --version
git --version
```

Expected: each command prints a version.

- [ ] **Step 2: Scaffold the project**

Run:

```powershell
npx create-video@latest --yes --blank --no-tailwind aiki-video
```

Move the generated directory into `remotion/aiki-video` only if the generator creates it at the repository root and the destination does not exist.

- [ ] **Step 3: Install the timeline and media packages**

From `remotion/aiki-video` run:

```powershell
npx remotion add @remotion/media @remotion/transitions @remotion/zod-types
npm install zod
```

- [ ] **Step 4: Verify the scaffold**

Run:

```powershell
npx remotion compositions
```

Expected: the scaffold composition is listed without TypeScript or bundler errors.

### Task 2: Add Aiki assets and editable video contract

**Files:**
- Create: `remotion/aiki-video/public/brand/`
- Create: `remotion/aiki-video/public/recordings/README.md`
- Create: `remotion/aiki-video/src/types.ts`
- Create: `remotion/aiki-video/src/theme.ts`

**Interfaces:**
- `VideoProps` contains `title`, `subtitle`, `showLabels`, `showCaptions`, `accentColor`, and named recording paths.
- `VideoProps` is validated by a top-level Zod object passed to `<Composition schema={...}>`.

- [ ] **Step 1: Copy only the existing brand assets needed by the composition**

Copy `assets/images/logo_completo_color.png`, `assets/images/logo_completo_blanco.png`, `assets/images/slogan.png`, and `assets/animations/aiki_logo_vertical_animacion.mp4` into the Remotion `public/brand` folder. Do not alter the source assets.

- [ ] **Step 2: Define the prop schema**

Use a Zod object with defaults for the title, subtitle, accent color, overlay visibility, and recording paths. Keep the default props inline when registering the composition so Studio can write edits back to code.

- [ ] **Step 3: Define visual tokens**

Create a small theme module for background, ink, muted ink, accent, card, and border colors. Keep the palette compatible with the current Aiki identity and allow the accent color to be overridden by the schema.

- [ ] **Step 4: Add recording instructions**

Document the exact expected filenames and capture requirements for user Explore, content detail/player, admin content form, admin notification form, notification inbox, and the final content destination.

### Task 3: Implement the reusable Remotion scene primitives

**Files:**
- Create: `remotion/aiki-video/src/components/ScreenFrame.tsx`
- Create: `remotion/aiki-video/src/components/SceneLabel.tsx`
- Create: `remotion/aiki-video/src/components/Callout.tsx`
- Create: `remotion/aiki-video/src/components/SoftBackground.tsx`
- Create: `remotion/aiki-video/src/components/RecordingPlaceholder.tsx`

**Interfaces:**
- Each component accepts explicit props and renders with `Interactive.*` elements where Studio editing is useful.
- `RecordingPlaceholder` accepts a `label`, `side`, and `detail` so missing recordings are visibly replaceable in preview.

- [ ] **Step 1: Build the phone/browser frame**

Render the footage inside a rounded frame with an explicit name, shadow, and optional side badge. Animate scale and opacity inline with clamped `interpolate()` calls.

- [ ] **Step 2: Build the calm label and callout**

Create label and callout layers with Spanish copy, soft contrast, and an optional connector line. Keep text inline or prop-driven and make the visibility controllable by props.

- [ ] **Step 3: Build the replacement layer**

Show a neutral Aiki-styled card when a recording file is absent. The layer must make it obvious which capture is needed without pretending to be a real product screen.

### Task 4: Implement the ten approved scenes

**Files:**
- Create: `remotion/aiki-video/src/scenes/IntroScene.tsx`
- Create: `remotion/aiki-video/src/scenes/UserExploreScene.tsx`
- Create: `remotion/aiki-video/src/scenes/AdminCreateContentScene.tsx`
- Create: `remotion/aiki-video/src/scenes/UserNewContentScene.tsx`
- Create: `remotion/aiki-video/src/scenes/AdminEditContentScene.tsx`
- Create: `remotion/aiki-video/src/scenes/UserProgressScene.tsx`
- Create: `remotion/aiki-video/src/scenes/AdminNotificationScene.tsx`
- Create: `remotion/aiki-video/src/scenes/UserNotificationScene.tsx`
- Create: `remotion/aiki-video/src/scenes/AlternatingValueScene.tsx`
- Create: `remotion/aiki-video/src/scenes/OutroScene.tsx`

**Interfaces:**
- Each scene accepts `VideoProps` or a focused subset and exposes its own explicit visual layers.
- Each scene remains independently previewable by keeping the scene component reusable.

- [ ] **Step 1: Implement the intro and outro**

Use the existing logo animation or logo image, calm background motion, and editable title/subtitle. Keep the primary headline within the vertical safe area at 68px for the 1080px-wide composition.

- [ ] **Step 2: Implement the paired user scenes**

Use explicit recording nodes for Explore, content detail/player, updated content, progress, notification inbox, and destination navigation. If a file is absent, render `RecordingPlaceholder` with the correct filename.

- [ ] **Step 3: Implement the paired admin scenes**

Highlight the actual flow: content list → new content → title/subtitle/description/media → publish; then notification form → audience/action → preview → send. Keep callouts outside the screen whenever possible.

- [ ] **Step 4: Implement the value bridge scene**

Alternate admin and user frames to show cause and effect. Use restrained connectors and timing, avoiding a dense dashboard montage.

### Task 5: Register the editable composition

**Files:**
- Modify: `remotion/aiki-video/src/Root.tsx`
- Modify: `remotion/aiki-video/src/index.ts`
- Create: `remotion/aiki-video/src/AikiVideo.tsx`

**Interfaces:**
- Register composition id `AikiDosCaras` with 1800 frames, 30 fps, 1080×1920, inline `defaultProps`, and the Zod schema.
- `AikiVideo` renders a `TransitionSeries` with ten explicit `TransitionSeries.Sequence` nodes and no generated editable clips.

- [ ] **Step 1: Compose the scenes with explicit durations**

Use the storyboard durations as inline frame counts: 360, 540, 540, 510, 600, 600, 690, 660, 600, and 300 frames. Add transitions only where they do not obscure the causal relationship between admin and user.

- [ ] **Step 2: Wire the default recordings**

Point each scene to the documented `public/recordings` filename. Do not fail the entire composition when a recording is absent; use the placeholder fallback.

- [ ] **Step 3: Register schema and defaults**

Keep metadata and `defaultProps` inline on `<Composition>` so Studio can edit the approved contract.

### Task 6: Verify the preview and handoff

**Files:**
- Create: `remotion/aiki-video/README.md`
- Create: `remotion/aiki-video/public/recordings/README.md`

- [ ] **Step 1: Run TypeScript and composition checks**

From `remotion/aiki-video` run:

```powershell
npm run lint
npx remotion compositions
```

Expected: no lint/type errors and `AikiDosCaras` is listed at 1080×1920, 30 fps, 1800 frames.

- [ ] **Step 2: Start Remotion Studio**

Run:

```powershell
npx remotion studio --no-open
```

Open the printed local URL and verify the full timeline, props editor, placeholders, scene labels, and light/dark contrast.

- [ ] **Step 3: Render a still sanity check**

Run:

```powershell
npx remotion still AikiDosCaras --scale=0.25 --frame=30
```

Expected: the intro renders without clipping or missing-module errors.

- [ ] **Step 4: Document the remaining capture dependency**

List the missing real recordings, the exact capture order, and the fact that final MP4 rendering remains pending until those recordings and approved audio are supplied.

## Execution status

Completed in the isolated `remotion/aiki-video` project:

- Remotion scaffold and media/timeline/Zod dependencies.
- Aiki brand assets, Poppins fonts, editable prop schema, and theme tokens.
- Ten scenes matching the approved 180-second storyboard.
- Remotion Studio preview, composition listing, lint/typecheck, and still-frame verification.
- Recording handoff documentation with exact filenames and capture requirements.

Pending by design:

- Add the real app recordings to `public/recordings`.
- Approve and add music or voiceover.
- Render the final MP4 after visual and notification-flow validation.

## Revision 2 — compact motion-first cut

The approved follow-up reduces the composition to 60 seconds and eight scenes. `src/AikiVideo.tsx` now uses 1800 frames with 120, 240, 300, 240, 240, 210, 240, and 210 frame sequences. User and administrator scenes use `PhoneMockup` for Rotato-style perspective, animated entry, camera scale, and a moving light sweep; administrative recordings use contained framing inside the phone.
