import { AikiVideoProps } from "../types";
import { SceneCanvas } from "../components/SceneCanvas";
import { PhoneMockup } from "../components/PhoneMockup";
import { SceneLabel } from "../components/SceneLabel";
import { Callout } from "../components/Callout";
import { phoneMockupSize } from "../phoneSpec";

export const AdminCreateContentScene: React.FC<AikiVideoProps> = (props) => (
  <SceneCanvas name="03 · Administrador crea contenido" accentColor={props.accentColor}>
    <SceneLabel text="Vista del administrador" accentColor={props.accentColor} visible={props.showLabels} align="right" />
    <div style={{ display: "flex", flex: 1, alignItems: "center", justifyContent: "center", flexDirection: "column", gap: 70 }}>
      <PhoneMockup
        name="Pantalla de administrador · Nuevo contenido"
        label="Nuevo contenido"
        side="Administrador"
        detail="Grabación del listado de contenido y apertura de la FormPage."
        source={props.adminCreateContentRecording}
        demoKind="adminCreate"
        width={phoneMockupSize.width}
        height={phoneMockupSize.height}
        accentColor={props.accentColor}
        objectFit="contain"
      />
      <div style={{ width: 720, textAlign: "center" }}>
        <Callout title="Crear sin fricción" detail="El administrador organiza una nueva experiencia desde un formulario claro y guiado." accentColor={props.accentColor} align="center" />
      </div>
    </div>
  </SceneCanvas>
);
