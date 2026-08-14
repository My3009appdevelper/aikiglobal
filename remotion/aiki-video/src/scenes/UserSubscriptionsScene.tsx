import type { AikiVideoProps } from "../types";
import { SceneCanvas } from "../components/SceneCanvas";
import { PhoneMockup } from "../components/PhoneMockup";
import { SceneLabel } from "../components/SceneLabel";
import { Callout } from "../components/Callout";
import { phoneMockupSize } from "../phoneSpec";

export const UserSubscriptionsScene: React.FC<AikiVideoProps> = (props) => (
  <SceneCanvas name="06 · Usuario consulta suscripciones" accentColor={props.accentColor}>
    <SceneLabel text="Una experiencia que acompaña" accentColor={props.accentColor} visible={props.showLabels} />
    <div style={{ display: "flex", flex: 1, alignItems: "center", justifyContent: "center", flexDirection: "column", gap: 58 }}>
      <PhoneMockup
        name="Pantalla de usuario · Suscripciones"
        label="Suscripciones"
        side="Usuario"
        detail="Plan activo, beneficios y administración de la suscripción."
        source={props.userSubscriptionsRecording}
        demoKind="subscriptions"
        width={phoneMockupSize.width}
        height={phoneMockupSize.height}
        accentColor={props.accentColor}
      />
      <div style={{ width: 720, textAlign: "center" }}>
        <Callout title="Más posibilidades para cada momento" detail="La suscripción convierte el bienestar en una experiencia continua y clara." accentColor={props.accentColor} align="center" />
      </div>
    </div>
  </SceneCanvas>
);
