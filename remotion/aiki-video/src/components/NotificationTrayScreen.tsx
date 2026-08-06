import { Audio } from "@remotion/media";
import {
  Easing,
  Img,
  Interactive,
  interpolate,
  staticFile,
  useCurrentFrame,
  useVideoConfig,
} from "remotion";
import { aikiPalette, fontFamily } from "../theme";
import {
  notificationCardTimings,
  notificationSoundStartInSeconds,
  notificationTrayHeightAtSeconds,
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
  inlineBadge?: string;
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
    inlineBadge: "17",
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
  const trayHeightPercent = notificationTrayHeightAtSeconds(seconds);
  const trayOpacity = interpolate(seconds, [0.48, 0.68], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
    easing: notificationEasing,
  });
  const toastOpacity = interpolate(seconds, [0.2, 0.34, 0.64, 0.78], [0, 1, 1, 0], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
    easing: notificationEasing,
  });
  const toastTranslateY = interpolate(seconds, [0.2, 0.34, 0.78], [-24, 0, -10], {
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
      <AikiPatternBackground />
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
            <span style={{ minWidth: 0, flex: 1, overflow: "hidden", fontSize: 20, fontWeight: 700, textOverflow: "ellipsis", whiteSpace: "nowrap" }}>
              Un respiro entre todo
            </span>
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
          height: `${trayHeightPercent}%`,
          minHeight: 0,
          flexDirection: "column",
          gap: 12,
          padding: "20px 16px 18px",
          boxSizing: "border-box",
          overflow: "hidden",
          border: `1px solid ${aikiPalette.stroke}`,
          borderTop: 0,
          borderRadius: "0 0 38px 38px",
          backgroundColor: aikiPalette.sandLight,
          boxShadow: "0 24px 42px rgba(182, 129, 78, 0.2)",
          color: aikiPalette.wine,
          fontFamily,
          opacity: trayOpacity,
          translate: "0px 0px",
          pointerEvents: "none",
        }}
      >
        <div
          aria-hidden="true"
          style={{
            width: 54,
            height: 5,
            flexShrink: 0,
            margin: "0 auto 2px",
            borderRadius: 999,
            backgroundColor: `${aikiPalette.wine}55`,
          }}
        />
        {notificationCards.map((card, index) => {
          const timing = notificationCardTimings[index];
          const cardVisible = seconds >= timing.startInSeconds;
          const cardOpacity = interpolate(seconds, [timing.startInSeconds, timing.startInSeconds + 0.22], [0, 1], {
            extrapolateLeft: "clamp",
            extrapolateRight: "clamp",
            easing: notificationEasing,
          });
          const cardTranslateY = interpolate(seconds, [timing.startInSeconds, timing.startInSeconds + 0.22], [20, 0], {
            extrapolateLeft: "clamp",
            extrapolateRight: "clamp",
            easing: notificationEasing,
          });

          return (
            <Interactive.Div
              key={card.title}
              name={`Notificación ${index + 1} - ${card.title}`}
              style={{
                display: cardVisible ? "flex" : "none",
                position: "relative",
                width: "100%",
                minHeight: 132,
                flexShrink: 0,
                alignItems: "flex-start",
                gap: 14,
                padding: "16px 16px 15px",
                boxSizing: "border-box",
                border: `1px solid ${aikiPalette.gold31Surface}`,
                borderRadius: 32,
                backgroundColor: aikiPalette.darkWine,
                boxShadow: "0 12px 24px rgba(62, 28, 26, 0.2)",
                color: aikiPalette.white,
                opacity: cardOpacity,
                translate: `0px ${cardTranslateY}px`,
              }}
            >
              <AikiNotificationIcon />
              <div style={{ minWidth: 0, flex: 1 }}>
                <div style={{ display: "flex", minWidth: 0, alignItems: "center", gap: 7 }}>
                  <span style={{ minWidth: 0, flex: 1, overflow: "hidden", color: aikiPalette.white, fontSize: 18, fontWeight: 700, lineHeight: 1.08, textOverflow: "ellipsis", whiteSpace: "nowrap" }}>
                    {card.title}
                  </span>
                  {card.inlineBadge && <CalendarBadge value={card.inlineBadge} />}
                  <span style={{ flexShrink: 0, color: aikiPalette.sandLight, fontSize: 13 }}>{card.time}</span>
                </div>
                <div style={{ marginTop: 8, color: `${aikiPalette.sandLight}E6`, fontSize: 15, lineHeight: 1.22 }}>
                  {card.body}
                </div>
              </div>
              <AikiChevron />
              {card.badge && (
                <div
                  style={{
                    position: "absolute",
                    top: 12,
                    right: 44,
                    display: "flex",
                    width: 22,
                    height: 22,
                    alignItems: "center",
                    justifyContent: "center",
                    borderRadius: "50%",
                    backgroundColor: aikiPalette.gold,
                    color: aikiPalette.white,
                    fontSize: 12,
                    fontWeight: 700,
                  }}
                >
                  {card.badge}
                </div>
              )}
            </Interactive.Div>
          );
        })}
      </Interactive.Div>
    </div>
  );
};

const AikiPatternBackground: React.FC = () => (
  <div
    aria-hidden="true"
    style={{
      position: "absolute",
      inset: 0,
      zIndex: 0,
      pointerEvents: "none",
      opacity: 0.68,
      backgroundImage: `
        radial-gradient(circle at 84% 8%, transparent 0 15%, ${aikiPalette.gold}22 15.2% 15.45%, transparent 15.7% 24%, ${aikiPalette.gold}18 24.2% 24.45%, transparent 24.7% 33%, ${aikiPalette.gold}12 33.2% 33.45%, transparent 33.7%),
        radial-gradient(circle at 5% 78%, transparent 0 14%, ${aikiPalette.gold}18 14.2% 14.45%, transparent 14.7% 23%, ${aikiPalette.gold}14 23.2% 23.45%, transparent 23.7% 32%, ${aikiPalette.gold}10 32.2% 32.45%, transparent 32.7%),
        radial-gradient(ellipse at 64% 84%, ${aikiPalette.white}55 0%, transparent 38%)
      `,
    }}
  />
);

const CalendarBadge: React.FC<{ value: string }> = ({ value }) => (
  <span
    style={{
      display: "inline-flex",
      width: 22,
      height: 22,
      flexShrink: 0,
      alignItems: "center",
      justifyContent: "center",
      borderRadius: 5,
      backgroundColor: aikiPalette.gold,
      color: aikiPalette.white,
      fontSize: 11,
      fontWeight: 700,
    }}
  >
    {value}
  </span>
);

const AikiChevron: React.FC = () => (
  <div
    aria-hidden="true"
    style={{
      width: 13,
      height: 13,
      flexShrink: 0,
      marginTop: 12,
      borderRight: `3px solid ${aikiPalette.sandLight}`,
      borderBottom: `3px solid ${aikiPalette.sandLight}`,
      opacity: 0.84,
      rotate: "-45deg",
    }}
  />
);

const AikiNotificationIcon: React.FC = () => (
  <div
    aria-hidden="true"
    style={{
      position: "relative",
      display: "flex",
      width: 54,
      height: 54,
      flexShrink: 0,
      alignItems: "center",
      justifyContent: "center",
      border: `1px solid ${aikiPalette.gold}88`,
      borderRadius: "50%",
      backgroundColor: aikiPalette.white,
      overflow: "hidden",
      boxShadow: `inset 0 0 0 3px ${aikiPalette.gold31Surface}`,
    }}
  >
    <Img
      src={staticFile("brand/logo_completo_color.png")}
      style={{
        position: "absolute",
        top: "50%",
        left: -10,
        width: "300%",
        height: "auto",
        translate: "0px -50%",
      }}
    />
  </div>
);
