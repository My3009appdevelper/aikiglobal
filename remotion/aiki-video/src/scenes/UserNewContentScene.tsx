import { AikiVideoProps } from "../types";
import { SceneCanvas } from "../components/SceneCanvas";
import { PhoneMockup } from "../components/PhoneMockup";
import { SceneLabel } from "../components/SceneLabel";
import { Callout } from "../components/Callout";

export const UserNewContentScene: React.FC<AikiVideoProps> = (props) => (
  <SceneCanvas name="04 · Usuario encuentra contenido" accentColor={props.accentColor}>
    <SceneLabel text="La experiencia se actualiza" accentColor={props.accentColor} visible={props.showLabels} />
    <div style={{ display: "flex", flex: 1, alignItems: "center", justifyContent: "center", flexDirection: "column", gap: 70 }}>
      <div style={{ width: 720, textAlign: "center" }}>
        <Callout title="Publicar y llegar" detail="Lo que se administra en un lugar aparece de forma natural en la experiencia del usuario." accentColor={props.accentColor} />
      </div>
      <PhoneMockup
        name="Pantalla de usuario · Contenido publicado"
        label="Contenido publicado"
        side="Usuario"
        detail="Grabación del contenido recién publicado y su pantalla de detalle."
        source={props.userNewContentRecording}
        demoKind="explore"
        width={570}
        height={1080}
        accentColor={props.accentColor}
      />
    </div>
  </SceneCanvas>
);
