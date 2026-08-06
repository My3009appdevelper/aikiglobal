import type { ReactNode } from "react";
import { scenePhoneStageCalloutHeight, scenePhoneStageGap } from "../notificationLayout";
import { ZenCallout, ZenCalloutConfig } from "./ZenVisuals";

type ScenePhoneStageProps = {
  phone: ReactNode;
  callouts?: ZenCalloutConfig[];
};

export const ScenePhoneStage: React.FC<ScenePhoneStageProps> = ({ phone, callouts = [] }) => (
  <div
    style={{
      position: "relative",
      display: "flex",
      width: "100%",
      height: "100%",
      alignItems: "center",
      justifyContent: "center",
    }}
  >
    <div
      style={{
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        justifyContent: "center",
        gap: callouts.length > 0 ? scenePhoneStageGap : 0,
      }}
    >
      <div style={{ position: "relative", flexShrink: 0 }}>{phone}</div>
      {callouts.length > 0 && (
        <div
          style={{
            position: "relative",
            width: "100%",
            height: scenePhoneStageCalloutHeight,
            flexShrink: 0,
          }}
        >
          {callouts.map((callout, index) => (
            <ZenCallout key={`${callout.text}-${index}`} {...callout} layout="slot" />
          ))}
        </div>
      )}
    </div>
  </div>
);
