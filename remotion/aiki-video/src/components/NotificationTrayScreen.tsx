import { Audio } from "@remotion/media";
import {
  Easing,
  Interactive,
  interpolate,
  staticFile,
  useCurrentFrame,
  useVideoConfig,
} from "remotion";
import { aikiPalette, begumSansFamily, fontFamily } from "../theme";
import {
  notificationCardTimings,
  notificationSoundStartInSeconds,
} from "../notificationLayout";
import { SoftBackground } from "./SoftBackground";

type NotificationTrayScreenProps = {
  source?: string;
};

type NotificationCard = {
  title: string;
  body: string;
  time: string;
  badge?: string;
};

const notificationCards: NotificationCard[] = [
  {
    title: "Un respiro entre todo",
    body: "No tienes que detener el mundo; solo necesitas regalarte unos minutos.",
    time: "21:39",
    badge: "5",
  },
  {
    title: "Algo cambió para acompa...",
    body: 'Actualizamos "Cuencos tibetanos" para que tu experiencia en Aiki sea todavía más especial.',
    time: "21:34",
  },
  {
    title: "Tu progreso sigue",
    body: "Llevas 2 días trabajando en ti, Mau. Sigue así con tu camino.",
    time: "21:30",
  },
  {
    title: "Una pausa para meditar r...",
    body: "Tómate un momento para respirar, Mau.",
    time: "21:25",
  },
  {
    title: "9:20 pm, una pausa consc...",
    body: "Haz espacio para respirar durante tu día, Mau.",
    time: "21:23",
  },
];

const notificationEasing = Easing.bezier(0.16, 1, 0.3, 1);

export const NotificationTrayScreen: React.FC<NotificationTrayScreenProps> = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const seconds = frame / fps;
  const soundFrame = Math.round(notificationSoundStartInSeconds * fps);
  const trayStartInSeconds = 0.72;
  const trayOpenEndInSeconds = trayStartInSeconds + 1.65;
  const trayProgress = interpolate(seconds, [trayStartInSeconds, trayOpenEndInSeconds], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
    easing: notificationEasing,
  });
  const trayOpacity = interpolate(seconds, [trayStartInSeconds, trayStartInSeconds + 0.28], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
    easing: notificationEasing,
  });
  const toastOpacity = interpolate(seconds, [0.2, 0.45, 0.95, 1.15], [0, 1, 1, 0], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
    easing: notificationEasing,
  });
  const toastTranslateY = interpolate(seconds, [0.2, 0.45, 1.15], [-24, 0, -10], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
    easing: notificationEasing,
  });
  const pulseOpacity = interpolate(
    seconds,
    [notificationSoundStartInSeconds - 0.12, notificationSoundStartInSeconds, notificationSoundStartInSeconds + 0.42],
    [0, 0.72, 0],
    {
      extrapolateLeft: "clamp",
      extrapolateRight: "clamp",
      easing: Easing.out(Easing.cubic),
    },
  );
  const pulseScale = interpolate(
    seconds,
    [notificationSoundStartInSeconds - 0.12, notificationSoundStartInSeconds + 0.42],
    [0.72, 1.8],
    {
      extrapolateLeft: "clamp",
      extrapolateRight: "clamp",
      easing: Easing.out(Easing.cubic),
    },
  );

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
      <Audio
        name="Sonido de notificación Aiki"
        src={staticFile("audio/aiki-notification-chime.wav")}
        from={soundFrame}
        volume={0.65}
      />
      <div
        aria-hidden="true"
        style={{
          position: "absolute",
          top: "3%",
          left: "50%",
          width: "56%",
          height: "19%",
          borderRadius: "50%",
          background: `radial-gradient(circle, ${aikiPalette.gold}70 0%, ${aikiPalette.gold31} 32%, transparent 72%)`,
          opacity: pulseOpacity,
          scale: pulseScale,
          translate: "-50% 0px",
          pointerEvents: "none",
        }}
      />
      <Interactive.Div
        name="Primera notificación Aiki"
        style={{
          position: "absolute",
          top: "8%",
          right: "6%",
          left: "6%",
          zIndex: 3,
          display: "flex",
          alignItems: "center",
          gap: 14,
          minHeight: 84,
          padding: "16px 18px",
          boxSizing: "border-box",
          border: `1px solid ${aikiPalette.gold}88`,
          borderRadius: 26,
          backgroundColor: aikiPalette.white,
          boxShadow: "0 18px 38px rgba(182, 129, 78, 0.18)",
          color: aikiPalette.wine,
          fontFamily,
          opacity: toastOpacity,
          translate: `0px ${toastTranslateY}px`,
          pointerEvents: "none",
        }}
      >
        <AikiNotificationIcon />
        <div style={{ minWidth: 0, flex: 1 }}>
          <div style={{ display: "flex", alignItems: "baseline", gap: 8 }}>
            <span style={{ fontSize: 20, fontWeight: 700 }}>Un respiro entre todo</span>
            <span style={{ color: aikiPalette.muted, fontSize: 13 }}>21:39</span>
          </div>
          <div style={{ marginTop: 5, color: aikiPalette.muted, fontSize: 15, lineHeight: 1.2 }}>
            No tienes que detener el mundo; respira.
          </div>
        </div>
      </Interactive.Div>
      <Interactive.Div
        name="Bandeja Aiki"
        style={{
          position: "absolute",
          top: 0,
          right: 0,
          left: 0,
          zIndex: 2,
          display: "flex",
          height: "86%",
          flexDirection: "column",
          gap: 14,
          padding: "28px 18px 24px",
          boxSizing: "border-box",
          overflow: "hidden",
          border: `1px solid ${aikiPalette.stroke}`,
          borderTop: 0,
          borderRadius: "0 0 38px 38px",
          backgroundColor: aikiPalette.warmIvory,
          boxShadow: "0 24px 42px rgba(182, 129, 78, 0.2)",
          color: aikiPalette.wine,
          fontFamily,
          opacity: trayOpacity,
          translate: `0px ${interpolate(trayProgress, [0, 1], [-100, 0])}%`,
          pointerEvents: "none",
        }}
      >
        <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", padding: "0 6px 8px" }}>
          <div>
            <div style={{ color: aikiPalette.gold, fontFamily: begumSansFamily, fontSize: 18, letterSpacing: 0.4 }}>
              Aiki
            </div>
            <div style={{ marginTop: 3, fontSize: 24, fontWeight: 700 }}>Notificaciones</div>
          </div>
          <div
            style={{
              display: "flex",
              width: 46,
              height: 46,
              alignItems: "center",
              justifyContent: "center",
              borderRadius: "50%",
              backgroundColor: aikiPalette.gold31Surface,
              color: aikiPalette.wine,
              fontSize: 18,
              fontWeight: 700,
            }}
          >
            5
          </div>
        </div>
        <div style={{ width: 56, height: 3, margin: "0 auto 3px", borderRadius: 999, backgroundColor: aikiPalette.gold }} />
        {notificationCards.map((card, index) => {
          const timing = notificationCardTimings[index];
          const cardOpacity = interpolate(seconds, [timing.startInSeconds, timing.startInSeconds + 0.26], [0, 1], {
            extrapolateLeft: "clamp",
            extrapolateRight: "clamp",
            easing: notificationEasing,
          });
          const cardTranslateY = interpolate(seconds, [timing.startInSeconds, timing.startInSeconds + 0.26], [22, 0], {
            extrapolateLeft: "clamp",
            extrapolateRight: "clamp",
            easing: notificationEasing,
          });
          const cardScale = interpolate(seconds, [timing.startInSeconds, timing.endInSeconds], [0.97, 1], {
            extrapolateLeft: "clamp",
            extrapolateRight: "clamp",
            easing: notificationEasing,
          });

          return (
            <Interactive.Div
              key={card.title}
              name={`Notificación ${index + 1} - ${card.title}`}
              style={{
                display: "flex",
                alignItems: "flex-start",
                gap: 13,
                minHeight: 102,
                padding: "14px 15px",
                boxSizing: "border-box",
                border: `1px solid ${aikiPalette.stroke}`,
                borderRadius: 24,
                backgroundColor: aikiPalette.white,
                boxShadow: "0 10px 22px rgba(182, 129, 78, 0.1)",
                opacity: cardOpacity,
                scale: cardScale,
                translate: `0px ${cardTranslateY}px`,
              }}
            >
              <AikiNotificationIcon />
              <div style={{ minWidth: 0, flex: 1 }}>
                <div style={{ display: "flex", alignItems: "baseline", gap: 7 }}>
                  <span style={{ minWidth: 0, flex: 1, overflow: "hidden", color: aikiPalette.wine, fontSize: 18, fontWeight: 700, lineHeight: 1.05, textOverflow: "ellipsis", whiteSpace: "nowrap" }}>
                    {card.title}
                  </span>
                  <span style={{ color: aikiPalette.muted, fontSize: 12 }}>{card.time}</span>
                </div>
                <div style={{ marginTop: 6, color: aikiPalette.muted, fontSize: 14, lineHeight: 1.2 }}>
                  {card.body}
                </div>
              </div>
              {card.badge && (
                <div style={{ alignSelf: "flex-start", color: aikiPalette.gold, fontSize: 15, fontWeight: 700 }}>
                  {card.badge}
                </div>
              )}
            </Interactive.Div>
          );
        })}
      </Interactive.Div>
      <div
        aria-hidden="true"
        style={{
          position: "absolute",
          right: "13%",
          bottom: "5%",
          left: "13%",
          height: 2,
          borderRadius: 999,
          backgroundColor: aikiPalette.gold,
          opacity: interpolate(seconds, [2.35, 2.7], [0, 0.55], {
            extrapolateLeft: "clamp",
            extrapolateRight: "clamp",
          }),
        }}
      />
    </div>
  );
};

const AikiNotificationIcon: React.FC = () => (
  <div
    aria-hidden="true"
    style={{
      display: "flex",
      width: 48,
      height: 48,
      flexShrink: 0,
      alignItems: "center",
      justifyContent: "center",
      border: `1px solid ${aikiPalette.gold}66`,
      borderRadius: "50%",
      background: `radial-gradient(circle at 35% 30%, ${aikiPalette.white} 0%, ${aikiPalette.gold31Surface} 54%, ${aikiPalette.gold} 100%)`,
      color: aikiPalette.wine,
      fontFamily: begumSansFamily,
      fontSize: 19,
      fontWeight: 700,
    }}
  >
    A
  </div>
);
