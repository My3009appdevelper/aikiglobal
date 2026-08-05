import type { AikiVideoProps } from "../types";
import { Easing, interpolate, useCurrentFrame } from "remotion";
import { SceneCanvas } from "../components/SceneCanvas";
import { PhoneMockup } from "../components/PhoneMockup";
import { ZenAmbientGlow, ZenCallout } from "../components/ZenVisuals";
import { phoneMockupSize } from "../phoneSpec";

export const UserMySpaceScene: React.FC<AikiVideoProps> = (props) => {
  const frame = useCurrentFrame();
  const phoneWidth = phoneMockupSize.width + 50;
  const phoneHeight = Math.round((phoneWidth / phoneMockupSize.width) * phoneMockupSize.height);
  const phoneScale = interpolate(frame, [0, 300, 330, 420, 480, 600], [1, 1, 1.045, 1.045, 1.01, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
    easing: Easing.bezier(0.16, 1, 0.3, 1),
  });
  const phoneTranslateY = interpolate(frame, [0, 300, 420, 540, 600], [0, 0, -8, 0, 0], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
    easing: Easing.bezier(0.16, 1, 0.3, 1),
  });

  return (
    <SceneCanvas name="04 - Mi espacio" accentColor={props.accentColor} backgroundTone="gold31">
      <div style={{ position: "relative", display: "flex", flex: 1, alignItems: "center", justifyContent: "center" }}>
        <ZenAmbientGlow intensity={0.17} />
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
            name="Pantalla de usuario - Mi espacio"
            label="Mi espacio"
            side="Usuario"
            detail="Progreso, practicas guardadas y contenidos para retomar."
            source={props.userMySpaceRecording}
            sourceSegments={[
              { fromSeconds: 0, sourceStartAtSeconds: 2.5 },
              { fromSeconds: 3.8, sourceStartAtSeconds: 6.7, playbackRate: 1.18 },
              { fromSeconds: 11.1, sourceStartAtSeconds: 28 },
            ]}
            width={phoneWidth}
            height={phoneHeight}
            accentColor={props.accentColor}
            objectFit="cover"
            centerVertically
          />
        </div>
        <ZenCallout text="Registra tu energía" startFrame={315} endFrame={435} />
      </div>
    </SceneCanvas>
  );
};
