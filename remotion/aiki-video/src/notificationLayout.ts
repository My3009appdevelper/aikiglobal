export const notificationRecordingDurationInSeconds = 5.561778;
export const notificationFocusStartInSeconds = 1.15;
export const notificationFocusEndInSeconds = 1.65;
export const notificationFocusScale = 1.3;
export const notificationFocusTranslateY = -26;
export const scenePhoneStageGap = 40;
export const scenePhoneStageCalloutHeight = 150;

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
