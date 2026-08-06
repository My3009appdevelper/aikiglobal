import assert from "node:assert/strict";
import {
  notificationRecordingDurationInSeconds,
  notificationReframeAtSeconds,
  notificationCardTimings,
  notificationSoundStartInSeconds,
  notificationTrayOpenDurationInSeconds,
  notificationTrayHeightAtSeconds,
  notificationTrayMaxHeightPercent,
  scenePhoneStageCalloutHeight,
  scenePhoneStageGap,
} from "../src/notificationLayout.ts";

const start = notificationReframeAtSeconds(0);
assert.equal(start.scale, 1);
assert.equal(start.translateY, 0);

const focused = notificationReframeAtSeconds(2);
assert.ok(focused.scale > 1);
assert.ok(focused.translateY < 0);

const finished = notificationReframeAtSeconds(5.5);
assert.equal(finished.scale, focused.scale);
assert.equal(finished.translateY, focused.translateY);

assert.equal(scenePhoneStageGap, 40);
assert.equal(scenePhoneStageCalloutHeight, 150);
assert.equal(notificationRecordingDurationInSeconds, 5.561778);
assert.equal(notificationTrayHeightAtSeconds(0), 0);
assert.ok(notificationTrayHeightAtSeconds(0.8) > notificationTrayHeightAtSeconds(0.4));
assert.equal(notificationTrayHeightAtSeconds(2), notificationTrayMaxHeightPercent);
assert.equal(notificationSoundStartInSeconds, 0.55);
assert.equal(notificationTrayOpenDurationInSeconds, 1.65);
assert.equal(notificationCardTimings.length, 5);
assert.deepEqual(
  notificationCardTimings.map((timing) => timing.startInSeconds),
  [0.75, 1.15, 1.55, 1.95, 2.35],
);
assert.ok(notificationCardTimings.every((timing, index) =>
  timing.endInSeconds > timing.startInSeconds &&
  (index === 0 || timing.startInSeconds > notificationCardTimings[index - 1].startInSeconds),
));
