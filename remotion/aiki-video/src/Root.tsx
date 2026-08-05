import "./index.css";
import { Composition } from "remotion";
import { AikiVideo, aikiVideoDurationInFrames } from "./AikiVideo";
import { AikiVideoSchema } from "./types";

export const RemotionRoot: React.FC = () => {
  return (
    <>
      <Composition
        id="AikiDosCaras"
        component={AikiVideo}
        durationInFrames={aikiVideoDurationInFrames}
        fps={30}
        width={1080}
        height={1920}
        defaultProps={{
          title: "Encontrar la paz, acompañar el proceso",
          subtitle: "Un refugio donde el cuerpo, la mente y el espíritu encuentran su equilibrio perfecto.",
          introKicker: "La energía del amor",
          accentColor: "#B6814E",
          showLabels: true,
          showCaptions: false,
          userExploreRecording: "recordings/user-explore.mp4",
          userMySpaceRecording: "recordings/mi-espacio.mp4",
          userProfileRecording: "recordings/perfil-y-panel-admin.mp4",
          adminPanelRecording: "recordings/perfil-y-panel-admin.mp4",
          adminCreateContentRecording: "",
          userNewContentRecording: "recordings/contenido.mp4",
          adminEditContentRecording: "",
          userProgressRecording: "",
          userSubscriptionsRecording: "",
          userStreaksRecording: "",
          adminNotificationRecording: "",
          userNotificationRecording: "",
          userDestinationRecording: "",
        }}
        schema={AikiVideoSchema}
      />
    </>
  );
};
