import { Easing, interpolate, useCurrentFrame, useVideoConfig } from "remotion";
import { aikiPalette, begumSansFamily } from "../theme";

type ZenAmbientGlowProps = {
  intensity?: number;
  scale?: number;
  startFrame?: number;
  endFrame?: number;
};

export type ZenCalloutConfig = {
  text: string;
  startFrame: number;
  endFrame: number;
  position?: "top" | "middle" | "bottom";
  side?: "left" | "center" | "right";
};

type ZenCalloutProps = ZenCalloutConfig & {
  layout?: "overlay" | "slot";
};

export const ZenAmbientGlow: React.FC<ZenAmbientGlowProps> = ({
  intensity = 0.22,
  scale = 1,
  startFrame = 0,
  endFrame,
}) => {
  const frame = useCurrentFrame();
  const { durationInFrames } = useVideoConfig();
  const breathScale = interpolate(
    frame,
    [0, durationInFrames * 0.45, durationInFrames],
    [1, 1.035, 1],
    {
      extrapolateLeft: "clamp",
      extrapolateRight: "clamp",
      easing: Easing.inOut(Easing.sin),
    },
  );
  const glowEndFrame = endFrame ?? durationInFrames;
  const opacity = interpolate(frame, [startFrame, startFrame + 12, glowEndFrame - 12, glowEndFrame], [0, intensity, intensity, 0], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
    easing: Easing.bezier(0.16, 1, 0.3, 1),
  });

  return (
    <div
      aria-hidden="true"
      style={{
        position: "absolute",
        inset: "12% 5% 18%",
        zIndex: 0,
        borderRadius: "50%",
        background: `radial-gradient(ellipse at 50% 48%, ${aikiPalette.gold}28 0%, ${aikiPalette.gold31Surface}14 38%, transparent 72%)`,
        filter: "blur(24px)",
        opacity,
        pointerEvents: "none",
        transform: `scale(${breathScale * scale})`,
      }}
    />
  );
};

export const ZenCallout: React.FC<ZenCalloutProps> = ({
  text,
  startFrame,
  endFrame,
  position = "bottom",
  side = "center",
  layout = "overlay",
}) => {
  const frame = useCurrentFrame();
  if (!text.trim()) {
    return null;
  }
  const enterEnd = Math.min(startFrame + 12, endFrame);
  const exitStart = Math.max(startFrame, endFrame - 12);
  const opacity = interpolate(frame, [startFrame, enterEnd, exitStart, endFrame], [0, 1, 1, 0], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
    easing: Easing.bezier(0.16, 1, 0.3, 1),
  });
  const translateY = interpolate(frame, [startFrame, enterEnd, exitStart, endFrame], [12, 0, 0, -8], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
    easing: Easing.bezier(0.16, 1, 0.3, 1),
  });
  const horizontalStyle =
    layout === "slot"
      ? { left: 0, right: 0 }
      : side === "left"
        ? { left: 40, width: "38%" }
        : side === "right"
          ? { right: 40, width: "38%" }
          : { right: 40, left: 40 };
  const verticalStyle =
    layout === "slot"
      ? { top: 0, bottom: 0, transform: `translateY(${translateY}px)` }
      : position === "top"
      ? { top: 84, transform: `translateY(${translateY}px)` }
      : position === "middle"
        ? { top: "50%", transform: `translateY(calc(-50% + ${translateY}px))` }
        : { bottom: 32, transform: `translateY(${translateY}px)` };

  return (
    <div
      aria-hidden="true"
      style={{
        position: "absolute",
        ...horizontalStyle,
        ...verticalStyle,
        zIndex: 2,
        display: "flex",
        alignItems: "center",
        flexDirection: "column",
        gap: 11,
        color: aikiPalette.wine,
        fontFamily: begumSansFamily,
        fontSize: 31,
        letterSpacing: 0.4,
        lineHeight: 1.08,
        opacity,
        pointerEvents: "none",
        textAlign: side,
      }}
    >
      <div style={{ width: 54, height: 2, borderRadius: 999, backgroundColor: aikiPalette.gold }} />
      <div>{text}</div>
    </div>
  );
};
