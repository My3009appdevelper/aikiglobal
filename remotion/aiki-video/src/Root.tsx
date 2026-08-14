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
          phoneScale: 1.35,
          phoneWidthScale: 0.985,
          phoneHeightScale: 1,
          phoneContentScale: 1,
          phoneContentOffsetY: 0,
          phoneContentFit: "cover" as const,
          callouts: {
            explore: {
              text: "Explora meditaciones, audios y sonidos para relajarte",
              position: "bottom" as const,
              side: "center" as const,
              startAtSeconds: 1,
              durationInSeconds: 12,
            },
            content: {
              text: "Reproduce y disfruta; descarga y ve en cualquier momento",
              position: "bottom" as const,
              side: "center" as const,
              startAtSeconds: 0,
              durationInSeconds: 8.5,
            },
            mySpace: {
              text: "Encuentra tu espacio de paz y registra diariamente",
              position: "bottom" as const,
              side: "center" as const,
              startAtSeconds: 0,
              durationInSeconds: 15,
            },
            mySpaceStreak: {
              text: "Tu progreso crece por cada día que te preocupas por ti",
              position: "bottom" as const,
              side: "center" as const,
              startAtSeconds: 15.2,
              durationInSeconds: 4,
            },
            profile: {
              text: "Cambia al panel de control para administrar la aplicación",
              position: "bottom" as const,
              side: "center" as const,
              startAtSeconds: 0,
              durationInSeconds: 4,
            },
            profileModule2: {
              text: "Agrega y edita el contenido",
              position: "bottom" as const,
              side: "center" as const,
              startAtSeconds: 4,
              durationInSeconds: 5,
            },
            profileModule3: {
              text: "Establece la información que verán los usuarios acerca de Aiki",
              position: "bottom" as const,
              side: "center" as const,
              startAtSeconds: 9,
              durationInSeconds: 7,
            },
            adminPanel: {
              text: "Observa a los usuarios, sus progresos y suscripciones",
              position: "bottom" as const,
              side: "center" as const,
              startAtSeconds: 16,
              durationInSeconds: 9,
            },
            adminPanelModule2: {
              text: "Envía notificaciones personalizadas, define los horarios o las acciones, así como el mensaje para los usuarios",
              position: "bottom" as const,
              side: "center" as const,
              startAtSeconds: 25,
              durationInSeconds: 9,
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
          userNotificationRecording: "recordings/notificaciones.mp4",
          userDestinationRecording: "",
        }}
        schema={AikiVideoSchema}
      />
    </>
  );
};
