import { AikiVideoProps } from "../types";
import { SceneCanvas } from "../components/SceneCanvas";
import { PhoneMockup } from "../components/PhoneMockup";
import { SceneLabel } from "../components/SceneLabel";
import { Callout } from "../components/Callout";
import { phoneReference } from "../phoneSpec";

export const AlternatingValueScene: React.FC<AikiVideoProps> = (props) => (
  <SceneCanvas name="09 · Dos caras de Aiki" accentColor={props.accentColor}>
    <SceneLabel text="Dos caras de Aiki" accentColor={props.accentColor} visible={props.showLabels} />
    <div style={{ display: "flex", flex: 1, alignItems: "center", justifyContent: "center", flexDirection: "column", gap: 28 }}>
      <div style={{ display: "flex", alignItems: "center", justifyContent: "center", gap: 22 }}>
      <PhoneMockup
        name="Resumen · Usuario"
        label="La experiencia"
        side="Usuario"
        detail="El usuario descubre, practica y vuelve."
        source={props.userDestinationRecording}
        demoKind="mySpace"
        width={320}
        height={Math.round(320 * (phoneReference.iphone17.heightMm / phoneReference.iphone17.widthMm))}
        accentColor={props.accentColor}
      />
      <PhoneMockup
        name="Resumen · Administrador"
        label="El control"
        side="Administrador"
        detail="El administrador publica, ajusta y comunica."
        source={props.adminEditContentRecording}
        demoKind="adminEdit"
        width={320}
        height={Math.round(320 * (phoneReference.galaxyS26.heightMm / phoneReference.galaxyS26.widthMm))}
        accentColor={props.accentColor}
        objectFit="contain"
      />
      </div>
      <div style={{ width: 720, textAlign: "center" }}>
        <Callout title="Un mismo ecosistema" detail="Administrar con claridad para acompañar mejor." accentColor={props.accentColor} align="center" />
      </div>
    </div>
  </SceneCanvas>
);
