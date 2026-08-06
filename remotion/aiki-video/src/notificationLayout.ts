export const notificationRecordingDurationInSeconds = 5.561778;
// The notification scene starts at frame 2654. At 30 fps, 0.20 s later is
// frame 2660, which is the requested absolute cue at 01:28:20.
export const notificationSoundStartInSeconds = 0.2;
export const notificationSoundAbsoluteFrame = 2660;
export const notificationFocusStartInSeconds = 1.15;
export const notificationFocusEndInSeconds = 1.65;
export const notificationFocusScale = 1.3;
export const notificationFocusTranslateY = -26;
export const scenePhoneStageGap = 40;
export const scenePhoneStageCalloutHeight = 150;
export const notificationTrayOpenDurationInSeconds = 2.32;
export const notificationTrayMaxHeightPercent = 49;

export type NotificationCardTiming = {
  startInSeconds: number;
  endInSeconds: number;
};

export const notificationCardTimings: NotificationCardTiming[] = [
  { startInSeconds: 0.72, endInSeconds: 1.42 },
  { startInSeconds: 1.12, endInSeconds: 1.82 },
  { startInSeconds: 1.52, endInSeconds: 2.22 },
  { startInSeconds: 1.92, endInSeconds: 2.62 },
  { startInSeconds: 2.32, endInSeconds: 3.02 },
];

const trayHeightKeyframes = [
  { seconds: 0, heightPercent: 0 },
  { seconds: 0.56, heightPercent: 0 },
  { seconds: 0.66, heightPercent: 8 },
  { seconds: 0.94, heightPercent: 13 },
  { seconds: 1.06, heightPercent: 13 },
  { seconds: 1.34, heightPercent: 22 },
  { seconds: 1.46, heightPercent: 22 },
  { seconds: 1.74, heightPercent: 31 },
  { seconds: 1.86, heightPercent: 31 },
  { seconds: 2.14, heightPercent: 40 },
  { seconds: 2.26, heightPercent: 40 },
  { seconds: notificationTrayOpenDurationInSeconds, heightPercent: notificationTrayMaxHeightPercent },
] as const;

export const notificationTrayHeightAtSeconds = (seconds: number) => {
  const clampedSeconds = Math.max(0, seconds);
  for (let index = 1; index < trayHeightKeyframes.length; index += 1) {
    const previous = trayHeightKeyframes[index - 1];
    const current = trayHeightKeyframes[index];
    if (clampedSeconds <= current.seconds) {
      const progress = (clampedSeconds - previous.seconds) / (current.seconds - previous.seconds);
      return previous.heightPercent + (current.heightPercent - previous.heightPercent) * progress;
    }
  }
  return notificationTrayMaxHeightPercent;
};

export const notificationReframeAtSeconds = (seconds: number) => {
  const progress = Math.min(
    1,
    Math.max(
      0,
      (seconds - notificationFocusStartInSeconds) /
        (notificationFocusEndInSeconds - notificationFocusStartInSeconds),
    ),
  );

  return {
    scale: 1 + (notificationFocusScale - 1) * progress,
    translateY: progress === 0 ? 0 : notificationFocusTranslateY * progress,
  };
};
