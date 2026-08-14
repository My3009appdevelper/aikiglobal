import type { AikiVideoProps } from "../types";
import { SceneCanvas } from "../components/SceneCanvas";
import { PhoneMockup } from "../components/PhoneMockup";
import { SceneLabel } from "../components/SceneLabel";
import { Callout } from "../components/Callout";
import { phoneMockupSize } from "../phoneSpec";

export const UserStreaksScene: React.FC<AikiVideoProps> = (props) => (
  <SceneCanvas name="07 · Usuario mantiene su racha" accentColor={props.accentColor}>
    <SceneLabel text="Pequeños pasos, constancia real" accentColor={props.accentColor} visible={props.showLabels} />
    <div style={{ display: "flex", flex: 1, alignItems: "center", justifyContent: "center", flexDirection: "column", gap: 58 }}>
      <PhoneMockup
        name="Pantalla de usuario · Rachas"
        label="Rachas"
        side="Usuario"
        detail="Contador de días, calendario semanal y continuidad de la práctica."
        source={props.userStreaksRecording}
        demoKind="streaks"
        width={phoneMockupSize.width}
        height={phoneMockupSize.height}
        accentColor={props.accentColor}
      />
      <div style={{ width: 720, textAlign: "center" }}>
        <Callout title="La motivación también se diseña" detail="Cada día se convierte en una señal visible para seguir avanzando." accentColor={props.accentColor} align="center" />
      </div>
    </div>
  </SceneCanvas>
);
