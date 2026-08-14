import type { AikiVideoProps } from "../types";
import { useVideoConfig } from "remotion";
import { SceneCanvas } from "../components/SceneCanvas";
import { PhoneMockup } from "../components/PhoneMockup";
import { ScenePhoneStage } from "../components/ScenePhoneStage";
import { ZenAmbientGlow } from "../components/ZenVisuals";
import { getPhoneMockupFrameSize } from "../phoneSpec";

export const UserExploreScene: React.FC<AikiVideoProps> = (props) => {
  const { fps } = useVideoConfig();
  const { width: phoneWidth, height: phoneHeight } = getPhoneMockupFrameSize(
    props.phoneScale,
    props.phoneWidthScale,
    props.phoneHeightScale,
  );
  const callout = props.callouts.explore;
  const calloutStartFrame = Math.round(callout.startAtSeconds * fps);
  const calloutEndFrame = Math.round((callout.startAtSeconds + callout.durationInSeconds) * fps);
  const exploreIntroPlaybackRate = 1.35;

  return (
    <SceneCanvas name="02 Â· Usuario explora" accentColor={props.accentColor} backgroundTone="gold31">
      <div style={{ position: "relative", display: "flex", flex: 1, alignItems: "center", justifyContent: "center" }}>
        <ZenAmbientGlow intensity={0.18} startFrame={calloutStartFrame} />
        <ScenePhoneStage
          phone={
            <div style={{ position: "relative", zIndex: 1, display: "flex", alignItems: "center", justifyContent: "center" }}>
              <PhoneMockup
                name="Pantalla de usuario Â· Explorar"
                label="Explorar contenido"
                side="Usuario"
                detail="GrabaciÃ³n de Explorar y selecciÃ³n de una meditaciÃ³n."
                source={props.userExploreRecording}
                demoKind="explore"
                width={phoneWidth}
                height={phoneHeight}
                accentColor={props.accentColor}
                objectFit={props.phoneContentFit}
                contentScale={props.phoneContentScale}
                contentTranslateY={props.phoneContentOffsetY}
                sourceSegments={[
                  { fromSeconds: 0, sourceStartAtSeconds: 4, playbackRate: exploreIntroPlaybackRate },
                  { fromSeconds: 2, sourceStartAtSeconds: 4 + 2 * exploreIntroPlaybackRate },
                ]}
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
