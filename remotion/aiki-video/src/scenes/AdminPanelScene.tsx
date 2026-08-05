import type { AikiVideoProps } from "../types";
import { Easing, interpolate, useCurrentFrame } from "remotion";
import { SceneCanvas } from "../components/SceneCanvas";
import { PhoneMockup } from "../components/PhoneMockup";
import { ZenAmbientGlow, ZenCallout } from "../components/ZenVisuals";
import { phoneMockupSize } from "../phoneSpec";

export const AdminPanelScene: React.FC<AikiVideoProps> = (props) => {
  const frame = useCurrentFrame();
  const phoneWidth = phoneMockupSize.width + 50;
  const phoneHeight = Math.round((phoneWidth / phoneMockupSize.width) * phoneMockupSize.height);
  const phoneScale = interpolate(frame, [0, 42, 165, 240, 420], [1, 1.04, 1.04, 1.015, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
    easing: Easing.bezier(0.16, 1, 0.3, 1),
  });
  const phoneTranslateY = interpolate(frame, [0, 42, 180, 290, 420], [0, -4, -4, 0, 0], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
    easing: Easing.bezier(0.16, 1, 0.3, 1),
  });

  return (
    <SceneCanvas name="07 - Panel Admin" accentColor={props.accentColor} backgroundTone="gold31">
      <div style={{ position: "relative", display: "flex", flex: 1, alignItems: "center", justifyContent: "center" }}>
        <ZenAmbientGlow intensity={0.16} />
        <div
          style={{
            position: "relative",
            zIndex: 1,
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            transform: `translateY(${phoneTranslateY}px) scale(${phoneScale})`,
            transformOrigin: "50% 50%",
          }}
        >
          <PhoneMockup
            name="Pantalla de administrador - Panel Admin"
            label="Panel Admin"
            side="Administrador"
            detail="La plataforma permite administrar contenido y operación desde un flujo claro."
            source={props.adminPanelRecording}
            sourceStartAtSeconds={17}
            playbackRate={1.05}
            width={phoneWidth}
            height={phoneHeight}
            accentColor={props.accentColor}
            objectFit="cover"
            centerVertically
          />
        </div>
        <ZenCallout text="Gestión que fluye" startFrame={42} endFrame={210} />
      </div>
    </SceneCanvas>
  );
};
