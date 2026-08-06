import type { AikiVideoProps } from "../types";
import { useCurrentFrame, useVideoConfig } from "remotion";
import { SceneCanvas } from "../components/SceneCanvas";
import { NotificationScreenMask } from "../components/NotificationScreenMask";
import { PhoneMockup } from "../components/PhoneMockup";
import { ScenePhoneStage } from "../components/ScenePhoneStage";
import { ZenAmbientGlow } from "../components/ZenVisuals";
import { getPhoneMockupFrameSize } from "../phoneSpec";
import { notificationReframeAtSeconds } from "../notificationLayout";

export const UserNotificationScene: React.FC<AikiVideoProps> = (props) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const { width: phoneWidth, height: phoneHeight } = getPhoneMockupFrameSize(props.phoneScale);
  const reframe = notificationReframeAtSeconds(frame / fps);

  return (
    <SceneCanvas name="07 - Notificaciones" accentColor={props.accentColor} backgroundTone="gold31">
      <div style={{ position: "relative", display: "flex", flex: 1, alignItems: "center", justifyContent: "center" }}>
        <ZenAmbientGlow intensity={0.14} />
        <ScenePhoneStage
          phone={
            <PhoneMockup
              name="Pantalla de usuario - Notificaciones"
              label="Notificaciones"
              side="Usuario"
              detail="Cinco avisos de Aiki dentro de la bandeja real del teléfono."
              source={props.userNotificationRecording}
              sourceStartAtSeconds={0}
              width={phoneWidth}
              height={phoneHeight}
              accentColor={props.accentColor}
              objectFit="cover"
              contentFadeInOut={false}
              contentScale={reframe.scale}
              contentTranslateY={reframe.translateY}
              screenOverlay={<NotificationScreenMask />}
              centerVertically
            />
          }
        />
      </div>
    </SceneCanvas>
  );
};
