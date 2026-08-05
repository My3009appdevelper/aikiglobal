import type { AikiVideoProps } from "../types";
import { Easing, interpolate, useCurrentFrame } from "remotion";
import { SceneCanvas } from "../components/SceneCanvas";
import { PhoneMockup } from "../components/PhoneMockup";
import { ZenAmbientGlow, ZenCallout } from "../components/ZenVisuals";
import { phoneMockupSize } from "../phoneSpec";

export const UserProfileScene: React.FC<AikiVideoProps> = (props) => {
  const frame = useCurrentFrame();
  const phoneWidth = phoneMockupSize.width + 50;
  const phoneHeight = Math.round((phoneWidth / phoneMockupSize.width) * phoneMockupSize.height);
  const phoneScale = interpolate(frame, [0, 45, 150, 210, 360], [1, 1.035, 1.035, 1.015, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
    easing: Easing.bezier(0.16, 1, 0.3, 1),
  });
  const phoneTranslateY = interpolate(frame, [0, 45, 180, 270, 360], [0, -4, -4, 0, 0], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
    easing: Easing.bezier(0.16, 1, 0.3, 1),
  });

  return (
    <SceneCanvas name="06 - Perfil" accentColor={props.accentColor} backgroundTone="gold31">
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
            name="Pantalla de usuario - Perfil"
            label="Perfil"
            side="Usuario"
            detail="La persona reconoce su recorrido y ajusta su experiencia en Aiki."
            source={props.userProfileRecording}
            sourceStartAtSeconds={0}
            width={phoneWidth}
            height={phoneHeight}
            accentColor={props.accentColor}
            objectFit="cover"
            centerVertically
          />
        </div>
        <ZenCallout text="Tu espacio, a tu medida" startFrame={36} endFrame={186} />
      </div>
    </SceneCanvas>
  );
};
