import { AbsoluteFill } from "remotion";
import { SoftBackground } from "./SoftBackground";

export const TransitionBackdrop: React.FC = () => (
  <AbsoluteFill name="Fondo persistente de Aiki" style={{ pointerEvents: "none" }}>
    <SoftBackground />
  </AbsoluteFill>
);
