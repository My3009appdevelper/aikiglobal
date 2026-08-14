import { AbsoluteFill } from "remotion";
import { aikiPalette } from "../theme";

export const SoftBackground: React.FC = () => (
  <AbsoluteFill
    name="Fondo sereno"
    style={{
      backgroundColor: aikiPalette.warmIvory,
      backgroundImage: `
        radial-gradient(circle at 50% -12%, ${aikiPalette.gold}35 0%, transparent 52%),
        linear-gradient(180deg, ${aikiPalette.gold31Surface} 0%, ${aikiPalette.sandLight} 58%, ${aikiPalette.warmIvory} 100%)
      `,
      overflow: "hidden",
    }}
  />
);
