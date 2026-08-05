import type { ReactNode } from "react";
import { AbsoluteFill } from "remotion";
import { aikiPalette, fontFamily } from "../theme";
import { TransitionBackdrop } from "./TransitionBackdrop";

type SceneCanvasProps = {
  name: string;
  accentColor: string;
  backgroundTone?: "default" | "gold31";
  fullBleed?: boolean;
  children: ReactNode;
};

export const SceneCanvas: React.FC<SceneCanvasProps> = ({
  name,
  fullBleed = false,
  children,
}) => {
  return (
    <AbsoluteFill
      name={name}
      style={{
        color: aikiPalette.wine,
        fontFamily,
      }}
    >
      <TransitionBackdrop />
      <div
        style={{
          position: "relative",
          zIndex: 1,
          display: "flex",
          flex: 1,
          flexDirection: "column",
          padding: fullBleed ? 0 : "70px 60px",
        }}
      >
        {children}
      </div>
    </AbsoluteFill>
  );
};
