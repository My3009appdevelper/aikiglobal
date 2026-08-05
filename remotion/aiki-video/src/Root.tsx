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
          subtitle:
            "Un refugio donde el cuerpo, la mente y el espíritu encuentran su equilibrio perfecto.",
          introKicker: "La energía del amor",
          accentColor: "#B6814E",
          phoneScale: 1.12,
          callouts: {
            explore: {
              text: "Explora meditaciones, audios y sonidos para relajarte",
              position: "bottom" as const,
              side: "center" as const,
              startAtSeconds: 2,
              durationInSeconds: 11,
            },
            content: {
              text: "Reproduce y disfruta; descarga y ve en cualquier momento",
              position: "bottom" as const,
              side: "center" as const,
              startAtSeconds: 1,
              durationInSeconds: 8,
            },
            mySpace: {
              text: "Encuentra tu espacio de paz y registra diariamente",
              position: "bottom" as const,
              side: "center" as const,
              startAtSeconds: 1,
              durationInSeconds: 13.5,
            },
            mySpaceStreak: {
              text: "Tu progreso crece por cada día que te preocupes por ti",
              position: "bottom" as const,
              side: "center" as const,
              startAtSeconds: 15.2,
              durationInSeconds: 4,
            },
            profile: {
              text: "Cambia al panel de control para administrar la aplicación",
              position: "bottom" as const,
              side: "center" as const,
              startAtSeconds: 1,
              durationInSeconds: 2,
            },
            profileModule2: {
              text: "Ajusta tu experiencia a tu ritmo",
              position: "bottom" as const,
              side: "center" as const,
              startAtSeconds: 3.4,
              durationInSeconds: 2.8,
            },
            profileModule3: {
              text: "Mantén tu perfil siempre al día",
              position: "bottom" as const,
              side: "center" as const,
              startAtSeconds: 9.4,
              durationInSeconds: 2.3,
            },
            adminPanel: {
              text: "Gestión que fluye",
              position: "bottom" as const,
              side: "center" as const,
              startAtSeconds: 0.4,
              durationInSeconds: 3,
            },
            adminPanelModule2: {
              text: "Administra cada módulo desde un solo lugar",
              position: "bottom" as const,
              side: "center" as const,
              startAtSeconds: 7.4,
              durationInSeconds: 3,
            },
          },
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
