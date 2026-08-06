import { aikiPalette } from "../theme";

export const NotificationScreenMask: React.FC = () => (
  <div
    aria-hidden="true"
    style={{
      position: "absolute",
      inset: 0,
      zIndex: 3,
      pointerEvents: "none",
    }}
  >
    <div
      style={{
        position: "absolute",
        top: 0,
        right: 0,
        left: 0,
        height: "16%",
        background: `linear-gradient(180deg, ${aikiPalette.warmIvory} 0%, ${aikiPalette.warmIvory}F5 64%, ${aikiPalette.warmIvory}00 100%)`,
      }}
    />
    <div
      style={{
        position: "absolute",
        right: 0,
        bottom: 0,
        left: 0,
        height: "18%",
        background: `linear-gradient(0deg, ${aikiPalette.warmIvory} 0%, ${aikiPalette.warmIvory}F5 62%, ${aikiPalette.warmIvory}00 100%)`,
      }}
    />
  </div>
);
