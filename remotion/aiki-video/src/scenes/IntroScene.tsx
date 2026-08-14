import { Video } from "@remotion/media";
import type { AikiVideoProps } from "../types";
import {
  Easing,
  interpolate,
  interpolateColors,
  Sequence,
  staticFile,
  useCurrentFrame,
  useVideoConfig,
} from "remotion";
import { aikiPalette, begumSansFamily, fontFamily } from "../theme";
import { SceneCanvas } from "../components/SceneCanvas";
import { getPhoneMockupFrameSize } from "../phoneSpec";

export const IntroScene: React.FC<AikiVideoProps> = (props) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const { width: phoneWidth, height: phoneHeight } = getPhoneMockupFrameSize(
    props.phoneScale,
    props.phoneWidthScale,
    props.phoneHeightScale,
  );
  const logoStart = Math.round(fps * 2.1);
  const revealStart = Math.round(fps * 2.5);
  const revealEnd = Math.round(fps * 3.8);
  const textFadeOutStart = Math.round(fps * 2.1);
  const textFadeOutEnd = Math.round(fps * 2.55);
  const introTextOpacity = interpolate(frame, [0, 3, textFadeOutStart, textFadeOutEnd], [1, 1, 1, 0], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
    easing: Easing.bezier(0.16, 1, 0.3, 1),
  });
  const whiteBackgroundOpacity = interpolate(frame, [revealStart, revealEnd], [1, 0], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
    easing: Easing.bezier(0.16, 1, 0.3, 1),
  });
  const screenWidth = interpolate(frame, [revealStart, revealEnd], [1080, phoneWidth], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
    easing: Easing.bezier(0.16, 1, 0.3, 1),
  });
  const screenHeight = interpolate(frame, [revealStart, revealEnd], [1920, phoneHeight], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
    easing: Easing.bezier(0.16, 1, 0.3, 1),
  });
  const frameRadius = interpolate(frame, [revealStart, revealEnd], [0, 58], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
    easing: Easing.bezier(0.16, 1, 0.3, 1),
  });
  const shellBorderWidth = interpolate(frame, [revealStart, revealEnd], [0, 2], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  const shellColor = interpolateColors(
    frame,
    [revealStart, revealEnd],
    [aikiPalette.white, "#241716"],
  );
  const phoneChromeOpacity = interpolate(frame, [revealStart + 10, revealEnd], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  const logoOpacity = interpolate(frame, [logoStart, logoStart + 12], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
    easing: Easing.bezier(0.16, 1, 0.3, 1),
  });

  const introText = (
    <div
      style={{
        position: "absolute",
        inset: 0,
        zIndex: 2,
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        flexDirection: "column",
        padding: "0 60px",
        boxSizing: "border-box",
        backgroundColor: aikiPalette.white,
        color: aikiPalette.wine,
        fontFamily,
        opacity: introTextOpacity,
        textAlign: "center",
        transform: "scale(1.08)",
        transformOrigin: "50% 50%",
      }}
    >
      <div
        style={{
          display: "flex",
          alignItems: "flex-start",
          justifyContent: "center",
          gap: 30,
          transform: "scale(1.14)",
          transformOrigin: "50% 50%",
        }}
      >
        <div style={{ minWidth: 92, textAlign: "center" }}>
          <div style={{ color: aikiPalette.muted, fontSize: 11, fontWeight: 600, letterSpacing: 1.6 }}>AMOR</div>
          <div style={{ marginTop: 3, color: aikiPalette.gold, fontSize: 58, fontWeight: 500, lineHeight: 1 }}>愛</div>
          <div style={{ marginTop: 7, color: aikiPalette.wine, fontSize: 13, fontWeight: 600, letterSpacing: 3 }}>AI</div>
        </div>
        <div style={{ paddingTop: 35, color: `${aikiPalette.gold}AA`, fontSize: 22, fontWeight: 300 }}>+</div>
        <div style={{ minWidth: 92, textAlign: "center" }}>
          <div style={{ color: aikiPalette.muted, fontSize: 11, fontWeight: 600, letterSpacing: 1.6 }}>ENERGÍA</div>
          <div style={{ marginTop: 3, color: aikiPalette.gold, fontSize: 58, fontWeight: 500, lineHeight: 1 }}>気</div>
          <div style={{ marginTop: 7, color: aikiPalette.wine, fontSize: 13, fontWeight: 600, letterSpacing: 3 }}>KI</div>
        </div>
      </div>
      <div style={{ marginTop: 16, color: aikiPalette.muted, fontSize: 13, fontWeight: 600, letterSpacing: 3 }}>AI + KI</div>
      <div style={{ width: 76, height: 2, margin: "14px auto 0", borderRadius: 999, backgroundColor: aikiPalette.gold }} />
      <div style={{ marginTop: 14, color: aikiPalette.wine, fontFamily: begumSansFamily, fontSize: 34, letterSpacing: 1.2 }}>
        LA ENERGÍA DEL AMOR
      </div>
    </div>
  );

  return (
    <SceneCanvas name="01 - Introduccion" accentColor={props.accentColor} backgroundTone="gold31" fullBleed>
      <div style={{ position: "relative", display: "flex", flex: 1, alignItems: "center", justifyContent: "center" }}>
        <div
          style={{
            position: "absolute",
            inset: 0,
            zIndex: 0,
            backgroundColor: aikiPalette.white,
            opacity: whiteBackgroundOpacity,
          }}
        />
        {introText}
        <div
          style={{
            position: "absolute",
            top: "50%",
            left: "50%",
            zIndex: 1,
            display: "flex",
            width: screenWidth,
            height: screenHeight,
            alignItems: "center",
            justifyContent: "center",
            overflow: "hidden",
            border: `${shellBorderWidth}px solid ${shellColor}`,
            borderRadius: frameRadius,
            backgroundColor: shellColor,
            boxShadow: `0 ${interpolate(frame, [revealStart, revealEnd], [0, 32], { extrapolateLeft: "clamp", extrapolateRight: "clamp" })}px ${interpolate(frame, [revealStart, revealEnd], [0, 68], { extrapolateLeft: "clamp", extrapolateRight: "clamp" })}px rgba(83, 38, 36, ${0.28 * phoneChromeOpacity})`,
            translate: "-50% -50%",
          }}
        >
          <div
            style={{
              position: "absolute",
              inset: 11,
              overflow: "hidden",
              borderRadius: Math.max(0, frameRadius - 11),
              backgroundColor: aikiPalette.white,
            }}
          >
            <Sequence from={logoStart} layout="none">
              <Video
                name="Animacion de logo Aiki"
                src={staticFile("brand/aiki_logo_vertical_animacion.mp4")}
                muted
                playbackRate={2.5}
                objectFit="contain"
                style={{ width: "100%", height: "100%", opacity: logoOpacity, backgroundColor: aikiPalette.white }}
              />
            </Sequence>
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
              opacity: phoneChromeOpacity,
              translate: "-50% 0px",
            }}
          />
        </div>
      </div>
    </SceneCanvas>
  );
};
