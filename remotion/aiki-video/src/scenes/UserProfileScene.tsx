import type { AikiVideoProps } from "../types";
import { useVideoConfig } from "remotion";
import { SceneCanvas } from "../components/SceneCanvas";
import { PhoneMockup } from "../components/PhoneMockup";
import { ZenAmbientGlow, ZenCallout } from "../components/ZenVisuals";
import { getPhoneMockupFrameSize } from "../phoneSpec";

export const UserProfileScene: React.FC<AikiVideoProps> = (props) => {
  const { fps } = useVideoConfig();
  const { width: phoneWidth, height: phoneHeight } = getPhoneMockupFrameSize(props.phoneScale);
  const callout = props.callouts.profile;
  const calloutStartFrame = Math.round(callout.startAtSeconds * fps);
  const calloutEndFrame = Math.round((callout.startAtSeconds + callout.durationInSeconds) * fps);

  return (
    <SceneCanvas name="06 - Perfil" accentColor={props.accentColor} backgroundTone="gold31">
      <div style={{ position: "relative", display: "flex", flex: 1, alignItems: "center", justifyContent: "center" }}>
        <ZenAmbientGlow intensity={0.16} />
        <div style={{ position: "relative", zIndex: 1, display: "flex", alignItems: "center", justifyContent: "center" }}>
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
        <ZenCallout
          text={callout.text}
          position={callout.position}
          side={callout.side}
          startFrame={calloutStartFrame}
          endFrame={calloutEndFrame}
        />
      </div>
    </SceneCanvas>
  );
};
