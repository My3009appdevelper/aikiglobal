import { AikiVideoProps } from "../types";
import { SceneCanvas } from "../components/SceneCanvas";
import { PhoneMockup } from "../components/PhoneMockup";
import { SceneLabel } from "../components/SceneLabel";
import { Callout } from "../components/Callout";
import { phoneMockupSize } from "../phoneSpec";

export const AdminNotificationScene: React.FC<AikiVideoProps> = (props) => (
  <SceneCanvas name="07 · Administrador configura aviso" accentColor={props.accentColor}>
    <SceneLabel text="Comunicar en el momento correcto" accentColor={props.accentColor} visible={props.showLabels} align="right" />
    <div style={{ display: "flex", flex: 1, alignItems: "center", justifyContent: "center", flexDirection: "column", gap: 70 }}>
      <PhoneMockup
        name="Pantalla de administrador · Notificación"
        label="Crear notificación"
        side="Administrador"
        detail="Grabación de título, mensaje, audiencia, destino, vista previa y envío."
        source={props.adminNotificationRecording}
        demoKind="adminNotification"
        width={phoneMockupSize.width}
        height={phoneMockupSize.height}
        accentColor={props.accentColor}
        objectFit="contain"
      />
      <div style={{ width: 720, textAlign: "center" }}>
        <Callout title="Notificaciones con intención" detail="El administrador define el mensaje y el destino antes de enviarlo." accentColor={props.accentColor} align="center" />
      </div>
    </div>
  </SceneCanvas>
);
