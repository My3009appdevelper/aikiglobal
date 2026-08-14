import type { AikiVideoProps } from "../types";
import { useVideoConfig } from "remotion";
import { SceneCanvas } from "../components/SceneCanvas";
import { PhoneMockup } from "../components/PhoneMockup";
import { ScenePhoneStage } from "../components/ScenePhoneStage";
import { ZenAmbientGlow } from "../components/ZenVisuals";
import { getPhoneMockupFrameSize } from "../phoneSpec";

export const UserMySpaceScene: React.FC<AikiVideoProps> = (props) => {
  const { fps } = useVideoConfig();
  const { width: phoneWidth, height: phoneHeight } = getPhoneMockupFrameSize(
    props.phoneScale,
    props.phoneWidthScale,
    props.phoneHeightScale,
  );
  const callout = props.callouts.mySpace;
  const calloutStartFrame = Math.round(callout.startAtSeconds * fps);
  const calloutEndFrame = Math.round((callout.startAtSeconds + callout.durationInSeconds) * fps);
  const streakCallout = props.callouts.mySpaceStreak;
  const streakCalloutStartFrame = Math.round(streakCallout.startAtSeconds * fps);
  const streakCalloutEndFrame = Math.round(
    (streakCallout.startAtSeconds + streakCallout.durationInSeconds) * fps,
  );

  return (
    <SceneCanvas name="04 - Mi espacio" accentColor={props.accentColor} backgroundTone="gold31">
      <div style={{ position: "relative", display: "flex", flex: 1, alignItems: "center", justifyContent: "center" }}>
        <ZenAmbientGlow intensity={0.17} />
        <ScenePhoneStage
          phone={
            <div style={{ position: "relative", zIndex: 1, display: "flex", alignItems: "center", justifyContent: "center" }}>
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
                objectFit={props.phoneContentFit}
                contentScale={props.phoneContentScale}
                contentTranslateY={props.phoneContentOffsetY}
                centerVertically
              />
            </div>
          }
          callouts={[
            {
              text: callout.text,
              position: callout.position,
              side: callout.side,
              startFrame: calloutStartFrame,
              endFrame: calloutEndFrame,
            },
            {
              text: streakCallout.text,
              position: streakCallout.position,
              side: streakCallout.side,
              startFrame: streakCalloutStartFrame,
              endFrame: streakCalloutEndFrame,
            },
          ]}
        />
      </div>
    </SceneCanvas>
  );
};
