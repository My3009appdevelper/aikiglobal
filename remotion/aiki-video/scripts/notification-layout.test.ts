import assert from "node:assert/strict";
import {
  notificationRecordingDurationInSeconds,
  notificationReframeAtSeconds,
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
