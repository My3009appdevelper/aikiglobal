import type { AikiVideoProps } from "../types";
import { SceneCanvas } from "../components/SceneCanvas";
import { NotificationTrayScreen } from "../components/NotificationTrayScreen";
import { PhoneMockup } from "../components/PhoneMockup";
import { ScenePhoneStage } from "../components/ScenePhoneStage";
import { ZenAmbientGlow } from "../components/ZenVisuals";
import { getPhoneMockupFrameSize } from "../phoneSpec";

export const UserNotificationScene: React.FC<AikiVideoProps> = (props) => {
  const { width: phoneWidth, height: phoneHeight } = getPhoneMockupFrameSize(props.phoneScale);

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
              width={phoneWidth}
              height={phoneHeight}
              accentColor={props.accentColor}
              contentFadeInOut={false}
              screenContent={<NotificationTrayScreen source={props.userNotificationRecording ?? ""} />}
            />
          }
        />
      </div>
    </SceneCanvas>
  );
};
