import { Video } from "@remotion/media";
import type { ReactNode } from "react";
import { Easing, Interactive, interpolate, Sequence, staticFile, useCurrentFrame, useVideoConfig } from "remotion";
import { aikiPalette, fontFamily } from "../theme";
import { AikiDemoScreen, AikiDemoScreenKind } from "./AikiDemoScreen";
import { RecordingPlaceholder } from "./RecordingPlaceholder";
import { RecordingSegment, SegmentedRecording } from "./SegmentedRecording";

type PhoneMockupProps = {
  name: string;
  label: string;
  detail: string;
  side?: "Usuario" | "Administrador";
  source?: string;
  sourceStartAtSeconds?: number;
  sourceFromSeconds?: number;
  playbackRate?: number;
  sourceSegments?: RecordingSegment[];
  zoomStartAtSeconds?: number;
  zoomDurationInSeconds?: number;
  zoomScale?: number;
  spinStartAtSeconds?: number;
  spinDurationInSeconds?: number;
  spinDegrees?: number;
  centerVertically?: boolean;
  focusStartAtSeconds?: number;
  focusEndAtSeconds?: number;
  focusDurationInSeconds?: number;
  focusScale?: number;
  focusTranslateY?: number;
  width: number;
  height: number;
  accentColor: string;
  objectFit?: "cover" | "contain";
  demoKind?: AikiDemoScreenKind;
  screenOverlay?: ReactNode;
  phoneOpacity?: number;
  contentFadeInOut?: boolean;
  contentFadeOutStartAtSeconds?: number;
  contentFadeOutEndAtSeconds?: number;
  contentScale?: number;
  contentTranslateY?: number;
};

export const PhoneMockup: React.FC<PhoneMockupProps> = ({
  name,
  label,
  detail,
  side = "Usuario",
  source,
  sourceStartAtSeconds,
  sourceFromSeconds,
  playbackRate = 1,
  sourceSegments,
  width,
  height,
  accentColor,
  objectFit = "cover",
  demoKind,
  screenOverlay,
  phoneOpacity = 1,
  contentFadeInOut = true,
  contentFadeOutStartAtSeconds,
  contentFadeOutEndAtSeconds,
  contentScale = 1,
  contentTranslateY = 0,
}) => {
  const frame = useCurrentFrame();
  const { durationInFrames, fps } = useVideoConfig();
  const usableSource = source?.trim();
  const baseContentOpacity = contentFadeInOut
    ? interpolate(frame, [0, 18, durationInFrames - 18, durationInFrames], [0, 1, 1, 0], {
        extrapolateLeft: "clamp",
        extrapolateRight: "clamp",
      })
    : 1;
  const explicitFadeOutOpacity =
    contentFadeOutStartAtSeconds === undefined || contentFadeOutEndAtSeconds === undefined
      ? 1
      : interpolate(
          frame,
          [
            Math.round(contentFadeOutStartAtSeconds * fps),
            Math.round(contentFadeOutEndAtSeconds * fps),
          ],
          [1, 0],
          {
            extrapolateLeft: "clamp",
            extrapolateRight: "clamp",
            easing: Easing.inOut(Easing.cubic),
          },
        );
  const contentOpacity = Math.min(baseContentOpacity, explicitFadeOutOpacity);

  const sourceVideo = usableSource ? (
    <Video
      name={`Clip - ${label}`}
      src={staticFile(usableSource)}
      muted
      playbackRate={playbackRate}
      trimBefore={sourceStartAtSeconds === undefined ? undefined : Math.round(sourceStartAtSeconds * fps)}
      objectFit={objectFit}
      style={{
        width: "100%",
        height: "100%",
        backgroundColor: aikiPalette.background,
        scale: contentScale,
        translate: `0px ${contentTranslateY}px`,
        transformOrigin: "50% 50%",
      }}
    />
  ) : null;

  return (
    <div
      style={{
        display: "flex",
        width,
        height,
        alignItems: "center",
        justifyContent: "center",
      }}
    >
      <Interactive.Div
        name={name}
        style={{
          position: "relative",
          display: "flex",
          width: "100%",
          height: "100%",
          overflow: "hidden",
          boxSizing: "border-box",
          border: "2px solid #160E0D",
          borderRadius: 58,
          backgroundColor: "#241716",
          boxShadow: "0 36px 80px rgba(48, 25, 22, 0.28)",
          opacity: phoneOpacity,
        }}
      >
        <div
          style={{
            position: "absolute",
            inset: 11,
            zIndex: 0,
            borderRadius: 47,
            backgroundColor: aikiPalette.warmIvory,
          }}
        />
        <div
          style={{
            position: "absolute",
            inset: 11,
            zIndex: 1,
            overflow: "hidden",
            borderRadius: 47,
            backgroundColor: aikiPalette.warmIvory,
            opacity: contentOpacity,
          }}
        >
          {!usableSource && (
            <div
              style={{
                display: "flex",
                height: 64,
                alignItems: "center",
                justifyContent: "space-between",
                padding: "0 24px",
                color: aikiPalette.wine,
                fontFamily,
                fontSize: 15,
                fontWeight: 600,
              }}
            >
              <span>{label}</span>
              <span style={{ color: accentColor }}>Aiki</span>
            </div>
          )}
          <div
            style={{
              position: "relative",
              display: "flex",
              minHeight: 0,
              height: usableSource ? "100%" : "calc(100% - 64px)",
            }}
          >
            {usableSource ? (
              sourceSegments && sourceSegments.length > 0 ? (
                <SegmentedRecording
                  name={`Grabacion real - ${label}`}
                  source={usableSource}
                  segments={sourceSegments}
                  durationInFrames={durationInFrames}
                  fps={fps}
                  objectFit={objectFit}
                />
              ) : sourceFromSeconds === undefined ? (
                sourceVideo
              ) : (
                <Sequence from={Math.round(sourceFromSeconds * fps)} layout="none">
                  {sourceVideo}
                </Sequence>
              )
            ) : demoKind ? (
              <AikiDemoScreen kind={demoKind} label={label} detail={detail} side={side} accentColor={accentColor} />
            ) : (
              <RecordingPlaceholder label={label} side={side} detail={detail} />
            )}
          </div>
          {screenOverlay && (
            <div style={{ position: "absolute", inset: 0, zIndex: 2 }}>{screenOverlay}</div>
          )}
        </div>
        <div
          style={{
            position: "absolute",
            zIndex: 3,
            top: 19,
            left: "50%",
            width: 94,
            height: 22,
            borderRadius: 999,
            backgroundColor: "#160E0D",
            translate: "-50% 0px",
          }}
        />
      </Interactive.Div>
    </div>
  );
};
