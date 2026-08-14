export const compositionFps = 30;

export const introDurationInFrames = 180;
export const timerZoomEndAtSeconds = 13.1;
export const timerFadeOutEndAtSeconds = 14.1;
export const timerDurationInFrames =
  Math.round(timerFadeOutEndAtSeconds * compositionFps) - introDurationInFrames;

export const sceneTransitionDurationInFrames = 30;
export const timerExploreTransitionDurationInFrames = 60;
