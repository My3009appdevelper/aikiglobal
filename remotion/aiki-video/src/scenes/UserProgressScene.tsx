import { AikiVideoProps } from "../types";
import { SceneCanvas } from "../components/SceneCanvas";
import { PhoneMockup } from "../components/PhoneMockup";
import { SceneLabel } from "../components/SceneLabel";
import { Callout } from "../components/Callout";

export const UserProgressScene: React.FC<AikiVideoProps> = (props) => (
  <SceneCanvas name="06 · Usuario reproduce y progresa" accentColor={props.accentColor}>
    <SceneLabel text="Volver a encontrar la paz" accentColor={props.accentColor} visible={props.showLabels} />
    <div style={{ display: "flex", flex: 1, alignItems: "center", justifyContent: "center", flexDirection: "column", gap: 70 }}>
      <div style={{ width: 720, textAlign: "center" }}>
        <Callout title="Acompañar el proceso" detail="La reproducción y el progreso convierten cada contenido en una experiencia continua." accentColor={props.accentColor} />
      </div>
      <PhoneMockup
        name="Pantalla de usuario · Reproducción"
        label="Reproducción y progreso"
        side="Usuario"
        detail="Grabación del reproductor y del avance de la experiencia."
        source={props.userProgressRecording}
        demoKind="mySpace"
        width={570}
        height={1080}
        accentColor={props.accentColor}
      />
    </div>
  </SceneCanvas>
);
