import { interpolate, useCurrentFrame, useVideoConfig } from "remotion";
import { aikiPalette } from "../theme";

export const NotificationScreenMask: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const seconds = frame / fps;
  const recordingMaskTop = interpolate(seconds, [0.75, 1.2, 1.65], [23, 23, 79], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  const recordingMaskOpacity = interpolate(seconds, [0.75, 1.05], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  const topMaskHeight = interpolate(seconds, [0, 1.45, 1.85], [16, 16, 8], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });

  return (
    <div
      aria-hidden="true"
      style={{
        position: "absolute",
        inset: 0,
        zIndex: 3,
        pointerEvents: "none",
      }}
    >
      <div
        style={{
          position: "absolute",
          top: 0,
          right: 0,
          left: 0,
          height: `${topMaskHeight}%`,
          background: `linear-gradient(180deg, ${aikiPalette.warmIvory} 0%, ${aikiPalette.warmIvory}F8 72%, ${aikiPalette.warmIvory}00 100%)`,
        }}
      />
      <div
        style={{
          position: "absolute",
          top: `${recordingMaskTop}%`,
          right: 0,
          left: 0,
          height: "22%",
          borderRadius: 28,
          background: "linear-gradient(90deg, rgba(29, 21, 21, 1) 0%, rgba(67, 42, 40, 1) 50%, rgba(29, 21, 21, 1) 100%)",
          opacity: recordingMaskOpacity,
        }}
      />
      <div
        style={{
          position: "absolute",
          right: 0,
          bottom: 0,
          left: 0,
          height: "10%",
          background: `linear-gradient(0deg, ${aikiPalette.warmIvory} 0%, ${aikiPalette.warmIvory}F8 62%, ${aikiPalette.warmIvory}00 100%)`,
        }}
      />
    </div>
  );
};
