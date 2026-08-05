import type { AikiVideoProps } from "../types";
import { useVideoConfig } from "remotion";
import { SceneCanvas } from "../components/SceneCanvas";
import { PhoneMockup } from "../components/PhoneMockup";
import { ZenAmbientGlow, ZenCallout } from "../components/ZenVisuals";
import { getPhoneMockupFrameSize } from "../phoneSpec";

export const AdminPanelScene: React.FC<AikiVideoProps> = (props) => {
  const { fps } = useVideoConfig();
  const { width: phoneWidth, height: phoneHeight } = getPhoneMockupFrameSize(props.phoneScale);
  const callout = props.callouts.adminPanel;
  const calloutStartFrame = Math.round(callout.startAtSeconds * fps);
  const calloutEndFrame = Math.round((callout.startAtSeconds + callout.durationInSeconds) * fps);
  const module2Callout = props.callouts.adminPanelModule2;
  const module2StartFrame = Math.round(module2Callout.startAtSeconds * fps);
  const module2EndFrame = Math.round(
    (module2Callout.startAtSeconds + module2Callout.durationInSeconds) * fps,
  );

  return (
    <SceneCanvas name="07 - Panel Admin" accentColor={props.accentColor} backgroundTone="gold31">
      <div style={{ position: "relative", display: "flex", flex: 1, alignItems: "center", justifyContent: "center" }}>
        <ZenAmbientGlow intensity={0.16} />
        <div style={{ position: "relative", zIndex: 1, display: "flex", alignItems: "center", justifyContent: "center" }}>
          <PhoneMockup
            name="Pantalla de administrador - Panel Admin"
            label="Panel Admin"
            side="Administrador"
            detail="La plataforma permite administrar contenido y operación desde un flujo claro."
            source={props.adminPanelRecording}
            sourceStartAtSeconds={17}
            playbackRate={1}
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
      </div>
    </SceneCanvas>
  );
};
