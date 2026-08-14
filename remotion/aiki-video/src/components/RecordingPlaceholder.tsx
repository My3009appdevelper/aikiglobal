import { Interactive } from "remotion";
import { aikiPalette, fontFamily } from "../theme";

type RecordingPlaceholderProps = {
  label: string;
  side: "Usuario" | "Administrador";
  detail: string;
};

export const RecordingPlaceholder: React.FC<RecordingPlaceholderProps> = ({
  label,
  side,
  detail,
}) => {
  return (
    <Interactive.Div
      name={`Grabación pendiente · ${label}`}
      style={{
        display: "flex",
        width: "100%",
        height: "100%",
        minHeight: 360,
        alignItems: "center",
        justifyContent: "center",
        padding: 42,
        boxSizing: "border-box",
        background: `linear-gradient(145deg, ${aikiPalette.sandLight}, ${aikiPalette.sand})`,
        color: aikiPalette.wine,
        fontFamily,
        textAlign: "center",
      }}
    >
      <div style={{ maxWidth: 430 }}>
        <div
          style={{
            marginBottom: 14,
            color: aikiPalette.gold,
            fontSize: 18,
            fontWeight: 600,
            letterSpacing: 1.2,
            textTransform: "uppercase",
          }}
        >
          {side}
        </div>
        <div style={{ fontSize: 31, fontWeight: 600 }}>{label}</div>
        <div
          style={{
            marginTop: 12,
            color: aikiPalette.muted,
            fontSize: 19,
            lineHeight: 1.45,
          }}
        >
          {detail}
        </div>
      </div>
    </Interactive.Div>
  );
};
