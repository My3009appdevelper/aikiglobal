import { Video } from "@remotion/media";
import { interpolate, staticFile, useCurrentFrame, useVideoConfig } from "remotion";
import { aikiPalette } from "../theme";
import {
  notificationTrayHeightAtSeconds,
  notificationTrayMaxHeightPercent,
} from "../notificationLayout";
import { SoftBackground } from "./SoftBackground";

type NotificationTrayScreenProps = {
  source: string;
  sourceStartAtSeconds?: number;
};

type NotificationWindowProps = {
  source: string;
  topPercent: number;
  bottomPercent: number;
  opacity?: number;
  sourceStartAtSeconds: number;
};

const NotificationWindow: React.FC<NotificationWindowProps> = ({
  source,
  topPercent,
  bottomPercent,
  opacity = 1,
  sourceStartAtSeconds,
}) => {
  const { fps } = useVideoConfig();

  return (
    <div
      aria-hidden="true"
      style={{
        position: "absolute",
        inset: 0,
        overflow: "hidden",
        clipPath: `inset(${topPercent}% 0 ${100 - bottomPercent}% 0 round 30px)`,
        opacity,
      }}
    >
      <Video
        src={staticFile(source)}
        muted
        trimBefore={sourceStartAtSeconds > 0 ? Math.round(sourceStartAtSeconds * fps) : undefined}
        objectFit="cover"
        style={{
          position: "absolute",
          inset: 0,
          width: "100%",
          height: "100%",
          objectPosition: "top center",
        }}
      />
    </div>
  );
};

export const NotificationTrayScreen: React.FC<NotificationTrayScreenProps> = ({
  source,
  sourceStartAtSeconds = 0,
}) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const seconds = frame / fps + sourceStartAtSeconds;
  const trayHeightPercent = notificationTrayHeightAtSeconds(seconds);
  const expandedCardsOpacity = interpolate(seconds, [1.9, 2.1], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  const firstCardTopPercent = interpolate(seconds, [0.6, 1.4, 1.8], [15, 15, 22], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  const firstCardBottomPercent = interpolate(seconds, [0, 0.85, 1.7], [0, 22, 29], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  const usableSource = source.trim();

  return (
    <div
      style={{
        position: "relative",
        width: "100%",
        height: "100%",
        overflow: "hidden",
        backgroundColor: aikiPalette.warmIvory,
      }}
    >
      <SoftBackground />
      <div
        aria-hidden="true"
        style={{
          position: "absolute",
          top: 0,
          right: 0,
          left: 0,
          height: `${trayHeightPercent}%`,
          overflow: "hidden",
          borderRadius: "0 0 36px 36px",
          background: "linear-gradient(180deg, rgba(45, 34, 32, 0.88) 0%, rgba(65, 45, 42, 0.8) 100%)",
          boxShadow: trayHeightPercent > 0 ? "0 18px 30px rgba(48, 25, 22, 0.16)" : "none",
        }}
      />
      {usableSource && trayHeightPercent > 0 && (
        <>
          <NotificationWindow
            source={usableSource}
            topPercent={firstCardTopPercent}
            bottomPercent={firstCardBottomPercent}
            sourceStartAtSeconds={sourceStartAtSeconds}
          />
          <NotificationWindow
            source={usableSource}
            topPercent={27}
            bottomPercent={41}
            opacity={expandedCardsOpacity}
            sourceStartAtSeconds={sourceStartAtSeconds}
          />
          <NotificationWindow
            source={usableSource}
            topPercent={39}
            bottomPercent={51}
            opacity={expandedCardsOpacity}
            sourceStartAtSeconds={sourceStartAtSeconds}
          />
          <NotificationWindow
            source={usableSource}
            topPercent={50}
            bottomPercent={61}
            opacity={expandedCardsOpacity}
            sourceStartAtSeconds={sourceStartAtSeconds}
          />
          <NotificationWindow
            source={usableSource}
            topPercent={60}
            bottomPercent={70}
            opacity={expandedCardsOpacity}
            sourceStartAtSeconds={sourceStartAtSeconds}
          />
        </>
      )}
      <div
        aria-hidden="true"
        style={{
          position: "absolute",
          right: 18,
          bottom: 18,
          left: 18,
          height: 2,
          borderRadius: 999,
          backgroundColor: aikiPalette.gold31Surface,
          opacity: trayHeightPercent === notificationTrayMaxHeightPercent ? 0.65 : 0,
        }}
      />
    </div>
  );
};
