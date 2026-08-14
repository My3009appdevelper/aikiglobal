import { Easing, Interactive, interpolate, useCurrentFrame } from "remotion";
import { aikiPalette, fontFamily } from "../theme";

type CalloutProps = {
  title: string;
  detail: string;
  accentColor: string;
  align?: "left" | "right" | "center";
};

export const Callout: React.FC<CalloutProps> = ({
  title,
  detail,
  accentColor,
  align = "left",
}) => {
  const frame = useCurrentFrame();

  return (
    <Interactive.Div
      name={`Callout · ${title}`}
      style={{
        display: "flex",
        flexDirection: "column",
        gap: 8,
        maxWidth: 500,
        padding: "20px 24px",
        border: `1px solid ${aikiPalette.stroke}`,
        borderRadius: 22,
        backgroundColor: `${aikiPalette.warmIvory}E8`,
        boxShadow: "0 18px 42px rgba(83, 38, 36, 0.10)",
        textAlign: align,
        opacity: interpolate(frame, [10, 30], [0, 1], {
          extrapolateLeft: "clamp",
          extrapolateRight: "clamp",
          easing: Easing.bezier(0.16, 1, 0.3, 1),
        }),
        translate: interpolate(frame, [10, 30], ["0px 18px", "0px 0px"], {
          extrapolateLeft: "clamp",
          extrapolateRight: "clamp",
          easing: Easing.bezier(0.16, 1, 0.3, 1),
        }),
      }}
    >
      <div
        style={{
          color: accentColor,
          fontFamily,
          fontSize: 19,
          fontWeight: 600,
        }}
      >
        {title}
      </div>
      <div
        style={{
          color: aikiPalette.wine,
          fontFamily,
          fontSize: 22,
          lineHeight: 1.35,
        }}
      >
        {detail}
      </div>
    </Interactive.Div>
  );
};
