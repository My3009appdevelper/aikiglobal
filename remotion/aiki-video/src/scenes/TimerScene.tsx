import type { AikiVideoProps } from "../types";
import { useVideoConfig } from "remotion";
import { SceneCanvas } from "../components/SceneCanvas";
import { PhoneMockup } from "../components/PhoneMockup";
import { phoneMockupSize } from "../phoneSpec";
import { introDurationInFrames, timerFadeOutEndAtSeconds, timerZoomEndAtSeconds } from "../timeline";

export const TimerScene: React.FC<AikiVideoProps> = (props) => {
  const { fps } = useVideoConfig();
  const phoneWidth = Math.round((phoneMockupSize.width + 50) * props.phoneScale);
  const phoneHeight = Math.round((phoneWidth / phoneMockupSize.width) * phoneMockupSize.height);
  const timerStartAtSeconds = introDurationInFrames / fps;
  const timerLocalZoomEndAtSeconds = timerZoomEndAtSeconds - timerStartAtSeconds;
  const timerLocalFadeOutEndAtSeconds = timerFadeOutEndAtSeconds - timerStartAtSeconds;

  return (
    <SceneCanvas name="02 - Timer de meditacion" accentColor={props.accentColor} backgroundTone="gold31">
      <div style={{ display: "flex", flex: 1, alignItems: "center", justifyContent: "center", flexDirection: "column" }}>
        <PhoneMockup
          name="Pantalla de usuario - Timer de meditacion"
          label="Timer de meditacion"
          side="Usuario"
          detail="Una pausa guiada para volver al centro."
          source="recordings/timer-de-meditacion.mp4"
          sourceStartAtSeconds={2.2}
          contentFadeOutStartAtSeconds={timerLocalZoomEndAtSeconds}
          contentFadeOutEndAtSeconds={timerLocalFadeOutEndAtSeconds}
          width={phoneWidth}
          height={phoneHeight}
          accentColor={props.accentColor}
          objectFit="cover"
          centerVertically
        />
      </div>
    </SceneCanvas>
  );
};
