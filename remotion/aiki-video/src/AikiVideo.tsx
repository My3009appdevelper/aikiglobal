import { Audio } from "@remotion/media";
import { TransitionSeries } from "@remotion/transitions";
import { AbsoluteFill, Easing, interpolate, Sequence, staticFile, useCurrentFrame, useVideoConfig } from "remotion";
import type { AikiVideoProps } from "./types";
import { IntroScene } from "./scenes/IntroScene";
import { TimerScene } from "./scenes/TimerScene";
import { UserExploreScene } from "./scenes/UserExploreScene";
import { ContentScene } from "./scenes/ContentScene";
import { UserMySpaceScene } from "./scenes/UserMySpaceScene";
import { UserProfileScene } from "./scenes/UserProfileScene";
import { AdminPanelScene } from "./scenes/AdminPanelScene";
import { aikiPalette } from "./theme";
import {
  compositionFps,
  introDurationInFrames,
  sceneTransitionDurationInFrames,
  timerDurationInFrames,
  timerExploreTransitionDurationInFrames,
} from "./timeline";

const userExploreDurationInFrames = 390;
const contentDurationInFrames = 255;
const userMySpaceDurationInFrames = 570;
const userProfileDurationInFrames = 360;
const profileAdminRecordingDurationInSeconds = 33.8625;
const adminPanelRecordingStartAtSeconds = 17;
const adminPanelDurationInFrames = Math.round(
  (profileAdminRecordingDurationInSeconds - adminPanelRecordingStartAtSeconds) * compositionFps,
);
const bosquesStartAtSeconds = 12.5;

export const aikiVideoDurationInFrames =
  introDurationInFrames +
  timerDurationInFrames +
  userExploreDurationInFrames +
  contentDurationInFrames +
  userMySpaceDurationInFrames +
  userProfileDurationInFrames +
  adminPanelDurationInFrames;

const AikiLightTransition: React.FC<{ name: string }> = ({ name }) => {
  const frame = useCurrentFrame();
  const { durationInFrames } = useVideoConfig();
  const washOpacity = interpolate(frame, [0, durationInFrames / 2, durationInFrames], [0, 0.86, 0], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
    easing: Easing.inOut(Easing.cubic),
  });
  const glowX = interpolate(frame, [0, durationInFrames], [28, 72], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  const glowY = interpolate(frame, [0, durationInFrames], [28, 68], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });

  return (
    <AbsoluteFill
      name={name}
      style={{
        pointerEvents: "none",
        opacity: washOpacity,
        background: `radial-gradient(circle at ${glowX}% ${glowY}%, ${aikiPalette.white} 0%, ${aikiPalette.sandLight}CC 34%, ${aikiPalette.gold31Surface}00 72%)`,
        mixBlendMode: "screen",
      }}
    />
  );
};

const BosquesAudio: React.FC = () => {
  const { fps } = useVideoConfig();
  const startFrame = Math.round(bosquesStartAtSeconds * fps);
  const durationInFrames = Math.max(1, aikiVideoDurationInFrames - startFrame);

  return (
    <Sequence name="Audio - Bosques" from={startFrame} durationInFrames={durationInFrames} layout="none">
      <Audio
        src={staticFile("audio/Bosques.mp3")}
        volume={(frame) => {
          const fadeIn = interpolate(frame, [0, fps], [0, 0.55], {
            extrapolateLeft: "clamp",
            extrapolateRight: "clamp",
          });
          const fadeOut = interpolate(frame, [durationInFrames - fps * 2, durationInFrames], [0.55, 0], {
            extrapolateLeft: "clamp",
            extrapolateRight: "clamp",
          });
          return Math.min(fadeIn, fadeOut);
        }}
      />
    </Sequence>
  );
};

export const AikiVideo: React.FC<AikiVideoProps> = (props) => (
  <>
    <TransitionSeries name="Dos caras de Aiki - Timeline">
      <TransitionSeries.Sequence
        name="01 - Introduccion"
        durationInFrames={introDurationInFrames}
      >
        <IntroScene {...props} />
      </TransitionSeries.Sequence>
      <TransitionSeries.Overlay durationInFrames={sceneTransitionDurationInFrames}>
        <AikiLightTransition name="Transicion luz Intro - Timer" />
      </TransitionSeries.Overlay>
      <TransitionSeries.Sequence
        name="02 - Timer de meditacion"
        durationInFrames={timerDurationInFrames}
      >
        <TimerScene {...props} />
      </TransitionSeries.Sequence>
      <TransitionSeries.Overlay durationInFrames={timerExploreTransitionDurationInFrames}>
        <AikiLightTransition name="Transicion luz Timer - Explorar" />
      </TransitionSeries.Overlay>
      <TransitionSeries.Sequence
        name="03 - Explorar"
        durationInFrames={userExploreDurationInFrames}
      >
        <UserExploreScene {...props} />
      </TransitionSeries.Sequence>
      <TransitionSeries.Overlay durationInFrames={sceneTransitionDurationInFrames}>
        <AikiLightTransition name="Transicion luz Explorar - Contenido" />
      </TransitionSeries.Overlay>
      <TransitionSeries.Sequence
        name="04 - Contenido"
        durationInFrames={contentDurationInFrames}
      >
        <ContentScene {...props} />
      </TransitionSeries.Sequence>
      <TransitionSeries.Overlay durationInFrames={sceneTransitionDurationInFrames}>
        <AikiLightTransition name="Transicion luz Contenido - Mi espacio" />
      </TransitionSeries.Overlay>
      <TransitionSeries.Sequence
        name="05 - Mi espacio"
        durationInFrames={userMySpaceDurationInFrames}
      >
        <UserMySpaceScene {...props} />
      </TransitionSeries.Sequence>
      <TransitionSeries.Overlay durationInFrames={sceneTransitionDurationInFrames}>
        <AikiLightTransition name="Transicion luz Mi espacio - Perfil" />
      </TransitionSeries.Overlay>
      <TransitionSeries.Sequence
        name="06 - Perfil"
        durationInFrames={userProfileDurationInFrames}
      >
        <UserProfileScene {...props} />
      </TransitionSeries.Sequence>
      <TransitionSeries.Sequence
        name="07 - Panel Admin"
        durationInFrames={adminPanelDurationInFrames}
      >
        <AdminPanelScene {...props} />
      </TransitionSeries.Sequence>
    </TransitionSeries>
    <BosquesAudio />
  </>
);
