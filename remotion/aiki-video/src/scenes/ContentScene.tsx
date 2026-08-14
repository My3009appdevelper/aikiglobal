import type { AikiVideoProps } from "../types";
import { useVideoConfig } from "remotion";
import { SceneCanvas } from "../components/SceneCanvas";
import { PhoneMockup } from "../components/PhoneMockup";
import { ScenePhoneStage } from "../components/ScenePhoneStage";
import { ZenAmbientGlow } from "../components/ZenVisuals";
import { getPhoneMockupFrameSize } from "../phoneSpec";

export const ContentScene: React.FC<AikiVideoProps> = (props) => {
  const { fps } = useVideoConfig();
  const { width: phoneWidth, height: phoneHeight } = getPhoneMockupFrameSize(
    props.phoneScale,
    props.phoneWidthScale,
    props.phoneHeightScale,
  );
  const callout = props.callouts.content;
  const calloutStartFrame = Math.round(callout.startAtSeconds * fps);
  const calloutEndFrame = Math.round((callout.startAtSeconds + callout.durationInSeconds) * fps);

  return (
    <SceneCanvas name="03 Â· Contenido" accentColor={props.accentColor} backgroundTone="gold31">
      <div style={{ position: "relative", display: "flex", flex: 1, alignItems: "center", justifyContent: "center" }}>
        <ZenAmbientGlow intensity={0.16} />
        <ScenePhoneStage
          phone={
            <div style={{ position: "relative", zIndex: 1, display: "flex", alignItems: "center", justifyContent: "center" }}>
              <PhoneMockup
                name="Pantalla de usuario Â· Contenido"
                label="Contenido"
                side="Usuario"
                detail="Contenido de bienestar dentro de la aplicaciÃ³n."
                source={props.userNewContentRecording}
                width={phoneWidth}
                height={phoneHeight}
                accentColor={props.accentColor}
                objectFit={props.phoneContentFit}
                contentScale={props.phoneContentScale}
                contentTranslateY={props.phoneContentOffsetY}
                sourceStartAtSeconds={1}
                centerVertically
              />
            </div>
          }
          callouts={[{
            text: callout.text,
            position: callout.position,
            side: callout.side,
            startFrame: calloutStartFrame,
            endFrame: calloutEndFrame,
          }]}
        />
      </div>
    </SceneCanvas>
  );
};
