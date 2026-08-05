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
  const module2Callout = props.callouts.profileModule2;
  const module2StartFrame = Math.round(module2Callout.startAtSeconds * fps);
  const module2EndFrame = Math.round(
    (module2Callout.startAtSeconds + module2Callout.durationInSeconds) * fps,
  );
  const module3Callout = props.callouts.profileModule3;
  const module3StartFrame = Math.round(module3Callout.startAtSeconds * fps);
  const module3EndFrame = Math.round(
    (module3Callout.startAtSeconds + module3Callout.durationInSeconds) * fps,
  );

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
            contentFadeInOut={false}
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
        <ZenCallout
          text={module2Callout.text}
          position={module2Callout.position}
          side={module2Callout.side}
          startFrame={module2StartFrame}
          endFrame={module2EndFrame}
        />
        <ZenCallout
          text={module3Callout.text}
          position={module3Callout.position}
          side={module3Callout.side}
          startFrame={module3StartFrame}
          endFrame={module3EndFrame}
        />
      </div>
    </SceneCanvas>
  );
};
