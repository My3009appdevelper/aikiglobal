import { Easing, interpolate, useCurrentFrame, useVideoConfig } from "remotion";
import { aikiPalette, begumSansFamily } from "../theme";

type ZenAmbientGlowProps = {
  intensity?: number;
  scale?: number;
};

type ZenCalloutProps = {
  text: string;
  startFrame: number;
  endFrame: number;
  align?: "left" | "center" | "right";
  bottom?: number;
};

export const ZenAmbientGlow: React.FC<ZenAmbientGlowProps> = ({ intensity = 0.22, scale = 1 }) => {
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
        opacity: intensity,
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
  align = "center",
  bottom = 32,
}) => {
  const frame = useCurrentFrame();
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

  return (
    <div
      aria-hidden="true"
      style={{
        position: "absolute",
        right: 40,
        bottom,
        left: 40,
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
        textAlign: align,
        transform: `translateY(${translateY}px)`,
      }}
    >
      <div style={{ width: 54, height: 2, borderRadius: 999, backgroundColor: aikiPalette.gold }} />
      <div>{text}</div>
    </div>
  );
};
