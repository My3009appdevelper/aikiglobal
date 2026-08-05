export const phoneReference = {
  iphone17: {
    heightMm: 149.6,
    widthMm: 71.5,
    depthMm: 7.95,
  },
  galaxyS26: {
    heightMm: 149.6,
    widthMm: 71.7,
    depthMm: 7.2,
  },
} as const;

// Shared visual ratio between iPhone 17 and Galaxy S26, rounded for a clean composition.
export const phoneMockupSize = {
  width: 500,
  height: 1046,
} as const;

export const phoneMockupFrameSize = {
  width: phoneMockupSize.width + 50,
  height: Math.round(((phoneMockupSize.width + 50) / phoneMockupSize.width) * phoneMockupSize.height),
} as const;

export const getPhoneMockupFrameSize = (scale: number) => ({
  width: Math.round(phoneMockupFrameSize.width * scale),
  height: Math.round(phoneMockupFrameSize.height * scale),
});
