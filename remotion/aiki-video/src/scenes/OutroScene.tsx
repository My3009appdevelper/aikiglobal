import { Img, Interactive, staticFile, useCurrentFrame, interpolate } from "remotion";
import { AikiVideoProps } from "../types";
import { aikiPalette, fontFamily } from "../theme";
import { SceneCanvas } from "../components/SceneCanvas";

export const OutroScene: React.FC<AikiVideoProps> = ({ title, accentColor }) => {
  const frame = useCurrentFrame();

  return (
    <SceneCanvas name="10 · Cierre" accentColor={accentColor}>
      <div style={{ display: "flex", flex: 1, alignItems: "center", justifyContent: "center", flexDirection: "column", textAlign: "center" }}>
        <Img
          name="Logotipo Aiki · Cierre"
          src={staticFile("brand/logo_completo_blanco.png")}
          style={{
            width: 260,
            marginBottom: 40,
            padding: 20,
            borderRadius: 28,
            backgroundColor: aikiPalette.wine,
            opacity: interpolate(frame, [0, 30], [0, 1], { extrapolateLeft: "clamp", extrapolateRight: "clamp" }),
          }}
        />
        <Interactive.Div
          name="Cierre principal"
          style={{ maxWidth: 860, color: aikiPalette.wine, fontFamily, fontSize: 58, fontWeight: 600, lineHeight: 1.08 }}
        >
          {title}
        </Interactive.Div>
        <Interactive.Div
          name="Cierre secundario"
          style={{ maxWidth: 860, marginTop: 24, color: aikiPalette.muted, fontFamily, fontSize: 28, lineHeight: 1.4 }}
        >
          Una plataforma para crear experiencias de bienestar con claridad, calma y propósito.
        </Interactive.Div>
      </div>
    </SceneCanvas>
  );
};
