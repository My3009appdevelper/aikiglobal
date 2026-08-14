import { Video } from "@remotion/media";
import {
  Easing,
  Interactive,
  interpolate,
  staticFile,
  useCurrentFrame,
  useVideoConfig,
} from "remotion";
import { aikiPalette, fontFamily } from "../theme";
import { RecordingPlaceholder } from "./RecordingPlaceholder";

type ScreenFrameProps = {
  name: string;
  label: string;
  side: "Usuario" | "Administrador";
  detail: string;
  source?: string;
  width: number;
  height: number;
  accentColor: string;
};

export const ScreenFrame: React.FC<ScreenFrameProps> = ({
  name,
  label,
  side,
  detail,
  source,
  width,
  height,
  accentColor,
}) => {
  const frame = useCurrentFrame();
  const { durationInFrames } = useVideoConfig();
  const usableSource = source?.trim();

  return (
    <Interactive.Div
      name={name}
      style={{
        display: "flex",
        width,
        height,
        overflow: "hidden",
        flexDirection: "column",
        border: `1px solid ${aikiPalette.stroke}`,
        borderRadius: side === "Usuario" ? 38 : 24,
        backgroundColor: aikiPalette.warmIvory,
        boxShadow: "0 30px 70px rgba(83, 38, 36, 0.16)",
        transformOrigin: side === "Administrador" ? "35% 60%" : "65% 60%",
        transform: `perspective(1500px) rotateY(${interpolate(
          frame,
          [0, durationInFrames * 0.45, durationInFrames],
          [side === "Administrador" ? -7 : 7, 0, side === "Administrador" ? 3 : -3],
          {
            extrapolateLeft: "clamp",
            extrapolateRight: "clamp",
            easing: Easing.bezier(0.16, 1, 0.3, 1),
          },
        )}deg) translateY(${interpolate(frame, [0, 24, durationInFrames], [48, 0, -10], {
          extrapolateLeft: "clamp",
          extrapolateRight: "clamp",
          easing: Easing.bezier(0.16, 1, 0.3, 1),
        })}px) scale(${interpolate(frame, [0, 24, durationInFrames], [0.88, 1, 1.025], {
          extrapolateLeft: "clamp",
          extrapolateRight: "clamp",
          easing: Easing.bezier(0.16, 1, 0.3, 1),
        })})`,
      }}
    >
      <div
        style={{
          display: "flex",
          height: 54,
          alignItems: "center",
          justifyContent: "space-between",
          padding: "0 20px",
          borderBottom: `1px solid ${aikiPalette.stroke}`,
          backgroundColor: aikiPalette.warmIvory,
          color: aikiPalette.wine,
          fontFamily,
          fontSize: 16,
          fontWeight: 600,
        }}
      >
        <span>{side}</span>
        <span style={{ color: accentColor }}>Aiki</span>
      </div>
      <div style={{ display: "flex", minHeight: 0, flex: 1 }}>
        {usableSource ? (
          <Video
            name={`Clip · ${label}`}
            src={staticFile(usableSource)}
            muted
            objectFit="cover"
            style={{
              width: "100%",
              height: "100%",
              backgroundColor: aikiPalette.background,
            }}
          />
        ) : (
          <RecordingPlaceholder label={label} side={side} detail={detail} />
        )}
      </div>
    </Interactive.Div>
  );
};
