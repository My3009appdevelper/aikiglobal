import { AikiVideoProps } from "../types";
import { Easing, interpolate, useCurrentFrame, useVideoConfig } from "remotion";
import { SceneCanvas } from "../components/SceneCanvas";
import { PhoneMockup } from "../components/PhoneMockup";
import { ZenAmbientGlow, ZenCallout } from "../components/ZenVisuals";
import { phoneMockupSize } from "../phoneSpec";

export const UserExploreScene: React.FC<AikiVideoProps> = (props) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const explorePhoneWidth = phoneMockupSize.width + 50;
  const explorePhoneHeight = Math.round((explorePhoneWidth / phoneMockupSize.width) * phoneMockupSize.height);
  const exploreIntroPlaybackRate = 1.35;
  const focusStart = Math.round(1.9 * fps);
  const focusEnd = Math.round(4.2 * fps);
  const phoneScale = interpolate(
    frame,
    [focusStart, focusStart + 18, focusEnd, focusEnd + 18],
    [1, 1.055, 1.055, 1],
    {
      extrapolateLeft: "clamp",
      extrapolateRight: "clamp",
      easing: Easing.bezier(0.16, 1, 0.3, 1),
    },
  );
  const phoneTranslateY = interpolate(
    frame,
    [focusStart, focusStart + 18, focusEnd, focusEnd + 18],
    [0, -8, -8, 0],
    {
      extrapolateLeft: "clamp",
      extrapolateRight: "clamp",
      easing: Easing.bezier(0.16, 1, 0.3, 1),
    },
  );

  return (
    <SceneCanvas name="02 Â· Usuario explora" accentColor={props.accentColor} backgroundTone="gold31">
      <div style={{ position: "relative", display: "flex", flex: 1, alignItems: "center", justifyContent: "center" }}>
        <ZenAmbientGlow intensity={0.18} />
        <div
          style={{
            position: "relative",
            zIndex: 1,
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            transform: `translateY(${phoneTranslateY}px) scale(${phoneScale})`,
            transformOrigin: "50% 50%",
          }}
        >
          <PhoneMockup
            name="Pantalla de usuario Â· Explorar"
            label="Explorar contenido"
            side="Usuario"
            detail="GrabaciÃ³n de Explorar y selecciÃ³n de una meditaciÃ³n."
            source={props.userExploreRecording}
            demoKind="explore"
            width={explorePhoneWidth}
            height={explorePhoneHeight}
            accentColor={props.accentColor}
            objectFit="cover"
            sourceSegments={[
              { fromSeconds: 0, sourceStartAtSeconds: 4, playbackRate: exploreIntroPlaybackRate },
              { fromSeconds: 2, sourceStartAtSeconds: 4 + 2 * exploreIntroPlaybackRate },
            ]}
            centerVertically
          />
        </div>
        <ZenCallout text="Descubre tu momento" startFrame={60} endFrame={150} />
      </div>
    </SceneCanvas>
  );
};
