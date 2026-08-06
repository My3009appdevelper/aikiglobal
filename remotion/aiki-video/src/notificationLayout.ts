export const notificationRecordingDurationInSeconds = 5.561778;
export const notificationFocusStartInSeconds = 1.15;
export const notificationFocusEndInSeconds = 1.65;
export const notificationFocusScale = 1.3;
export const notificationFocusTranslateY = -26;
export const scenePhoneStageGap = 40;
export const scenePhoneStageCalloutHeight = 150;
export const notificationTrayOpenDurationInSeconds = 1.8;
export const notificationTrayMaxHeightPercent = 74;

const trayHeightKeyframes = [
  { seconds: 0, heightPercent: 0 },
  { seconds: 0.35, heightPercent: 10 },
  { seconds: 0.75, heightPercent: 28 },
  { seconds: 1.25, heightPercent: 58 },
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
