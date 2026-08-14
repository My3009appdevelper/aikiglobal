import { Easing, Interactive, interpolate, useCurrentFrame } from "remotion";
import { aikiPalette, fontFamily } from "../theme";

type SceneLabelProps = {
  text: string;
  accentColor: string;
  visible: boolean;
  align?: "left" | "right";
};

export const SceneLabel: React.FC<SceneLabelProps> = ({
  text,
  accentColor,
  visible,
  align = "left",
}) => {
  const frame = useCurrentFrame();

  if (!visible) return null;

  return (
    <Interactive.Div
      name={`Etiqueta · ${text}`}
      style={{
        alignSelf: align === "right" ? "flex-end" : "flex-start",
        display: "inline-flex",
        alignItems: "center",
        gap: 10,
        padding: "10px 16px",
        borderRadius: 999,
        backgroundColor: `${accentColor}18`,
        color: aikiPalette.wine,
        fontFamily,
        fontSize: 20,
        fontWeight: 600,
        letterSpacing: 0.4,
        opacity: interpolate(frame, [0, 18], [0, 1], {
          extrapolateLeft: "clamp",
          extrapolateRight: "clamp",
          easing: Easing.bezier(0.16, 1, 0.3, 1),
        }),
        translate: interpolate(frame, [0, 18], ["0px 12px", "0px 0px"], {
          extrapolateLeft: "clamp",
          extrapolateRight: "clamp",
          easing: Easing.bezier(0.16, 1, 0.3, 1),
        }),
      }}
    >
      <span
        style={{
          width: 9,
          height: 9,
          borderRadius: "50%",
          backgroundColor: accentColor,
        }}
      />
      {text}
    </Interactive.Div>
  );
};
