import type { AikiVideoProps } from "../types";
import { Easing, interpolate, useCurrentFrame } from "remotion";
import { SceneCanvas } from "../components/SceneCanvas";
import { PhoneMockup } from "../components/PhoneMockup";
import { ZenAmbientGlow, ZenCallout } from "../components/ZenVisuals";
import { phoneMockupSize } from "../phoneSpec";

export const ContentScene: React.FC<AikiVideoProps> = (props) => {
  const frame = useCurrentFrame();
  const contentPhoneWidth = phoneMockupSize.width + 50;
  const contentPhoneHeight = Math.round((contentPhoneWidth / phoneMockupSize.width) * phoneMockupSize.height);
  const phoneScale = interpolate(frame, [0, 45, 126, 170, 255], [1, 1.045, 1.045, 1.015, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
    easing: Easing.bezier(0.16, 1, 0.3, 1),
  });
  const phoneTranslateY = interpolate(frame, [0, 45, 130, 200, 255], [0, -5, -6, 0, 0], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
    easing: Easing.bezier(0.16, 1, 0.3, 1),
  });

  return (
    <SceneCanvas name="03 Â· Contenido" accentColor={props.accentColor} backgroundTone="gold31">
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
            name="Pantalla de usuario Â· Contenido"
            label="Contenido"
            side="Usuario"
            detail="Contenido de bienestar dentro de la aplicaciÃ³n."
            source={props.userNewContentRecording}
            width={contentPhoneWidth}
            height={contentPhoneHeight}
            accentColor={props.accentColor}
            objectFit="cover"
            sourceStartAtSeconds={1}
            centerVertically
          />
        </div>
        <ZenCallout text="Una pausa para volver a ti" startFrame={18} endFrame={105} />
      </div>
    </SceneCanvas>
  );
};
