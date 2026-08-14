import type { AikiVideoProps } from "../types";
import { useVideoConfig } from "remotion";
import { SceneCanvas } from "../components/SceneCanvas";
import { PhoneMockup } from "../components/PhoneMockup";
import { ScenePhoneStage } from "../components/ScenePhoneStage";
import { ZenAmbientGlow } from "../components/ZenVisuals";
import { getPhoneMockupFrameSize } from "../phoneSpec";

export const UserProfileScene: React.FC<AikiVideoProps> = (props) => {
  const { fps } = useVideoConfig();
  const { width: phoneWidth, height: phoneHeight } = getPhoneMockupFrameSize(
    props.phoneScale,
    props.phoneWidthScale,
    props.phoneHeightScale,
  );
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
  const adminCallout = props.callouts.adminPanel;
  const adminCalloutStartFrame = Math.round(adminCallout.startAtSeconds * fps);
  const adminCalloutEndFrame = Math.round(
    (adminCallout.startAtSeconds + adminCallout.durationInSeconds) * fps,
  );
  const adminModule2Callout = props.callouts.adminPanelModule2;
  const adminModule2StartFrame = Math.round(adminModule2Callout.startAtSeconds * fps);
  const adminModule2EndFrame = Math.round(
    (adminModule2Callout.startAtSeconds + adminModule2Callout.durationInSeconds) * fps,
  );

  return (
    <SceneCanvas name="06 - Perfil y Panel Admin" accentColor={props.accentColor} backgroundTone="gold31">
      <div style={{ position: "relative", display: "flex", flex: 1, alignItems: "center", justifyContent: "center" }}>
        <ZenAmbientGlow intensity={0.16} />
        <ScenePhoneStage
          phone={
            <div style={{ position: "relative", zIndex: 1, display: "flex", alignItems: "center", justifyContent: "center" }}>
              <PhoneMockup
                name="Pantalla de usuario y administrador - Perfil y Panel Admin"
                label="Perfil y Panel Admin"
                side="Administrador"
                detail="Perfil, empresa, usuarios y avisos en una sola grabación continua."
                source={props.userProfileRecording || props.adminPanelRecording}
                sourceStartAtSeconds={0}
                width={phoneWidth}
                height={phoneHeight}
                accentColor={props.accentColor}
                objectFit={props.phoneContentFit}
                contentScale={props.phoneContentScale}
                contentTranslateY={props.phoneContentOffsetY}
                contentFadeInOut={false}
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
              text: module2Callout.text,
              position: module2Callout.position,
              side: module2Callout.side,
              startFrame: module2StartFrame,
              endFrame: module2EndFrame,
            },
            {
              text: module3Callout.text,
              position: module3Callout.position,
              side: module3Callout.side,
              startFrame: module3StartFrame,
              endFrame: module3EndFrame,
            },
            {
              text: adminCallout.text,
              position: adminCallout.position,
              side: adminCallout.side,
              startFrame: adminCalloutStartFrame,
              endFrame: adminCalloutEndFrame,
            },
            {
              text: adminModule2Callout.text,
              position: adminModule2Callout.position,
              side: adminModule2Callout.side,
              startFrame: adminModule2StartFrame,
              endFrame: adminModule2EndFrame,
            },
          ]}
        />
      </div>
    </SceneCanvas>
  );
};
