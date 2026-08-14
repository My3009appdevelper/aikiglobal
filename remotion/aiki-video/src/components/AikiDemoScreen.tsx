import {
  Easing,
  Interactive,
  interpolate,
  useCurrentFrame,
  useVideoConfig,
} from "remotion";
import { aikiPalette, fontFamily } from "../theme";

export type AikiDemoScreenKind =
  | "explore"
  | "mySpace"
  | "adminCreate"
  | "adminEdit"
  | "subscriptions"
  | "streaks"
  | "adminNotification"
  | "notification";

type AikiDemoScreenProps = {
  kind: AikiDemoScreenKind;
  label: string;
  detail: string;
  side: "Usuario" | "Administrador";
  accentColor: string;
};

const ease = Easing.bezier(0.16, 1, 0.3, 1);

const DemoHeader: React.FC<{ eyebrow: string; title: string; accentColor: string }> = ({
  eyebrow,
  title,
  accentColor,
}) => (
  <div style={{ display: "flex", alignItems: "flex-start", justifyContent: "space-between", gap: 12 }}>
    <div>
      <div
        style={{
          color: accentColor,
          fontSize: 13,
          fontWeight: 700,
          letterSpacing: 1.1,
          textTransform: "uppercase",
        }}
      >
        {eyebrow}
      </div>
      <div style={{ marginTop: 5, color: aikiPalette.wine, fontSize: 25, fontWeight: 600, lineHeight: 1.12 }}>
        {title}
      </div>
    </div>
    <div
      style={{
        display: "flex",
        width: 30,
        height: 30,
        alignItems: "center",
        justifyContent: "center",
        borderRadius: "50%",
        backgroundColor: `${accentColor}22`,
        color: accentColor,
        fontSize: 13,
        fontWeight: 700,
      }}
    >
      A
    </div>
  </div>
);

const DemoPill: React.FC<{ children: React.ReactNode; active?: boolean; accentColor: string }> = ({
  children,
  active = false,
  accentColor,
}) => (
  <div
    style={{
      display: "inline-flex",
      alignItems: "center",
      minHeight: 30,
      padding: "0 12px",
      border: `1px solid ${active ? `${accentColor}55` : aikiPalette.stroke}`,
      borderRadius: 999,
      backgroundColor: active ? `${accentColor}16` : `${aikiPalette.white}AA`,
      color: active ? accentColor : aikiPalette.muted,
      fontSize: 12,
      fontWeight: 600,
      whiteSpace: "nowrap",
    }}
  >
    {children}
  </div>
);

const DemoSectionTitle: React.FC<{ title: string; action?: string }> = ({ title, action }) => (
  <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", marginBottom: 10 }}>
    <div style={{ color: aikiPalette.wine, fontSize: 15, fontWeight: 600 }}>{title}</div>
    {action ? <div style={{ color: aikiPalette.gold, fontSize: 12, fontWeight: 600 }}>{action}</div> : null}
  </div>
);

const DemoCard: React.FC<{ title: string; subtitle: string; accentColor: string; tone?: "wine" | "sand" }> = ({
  title,
  subtitle,
  accentColor,
  tone = "sand",
}) => (
  <div
    style={{
      minHeight: 86,
      padding: 13,
      borderRadius: 18,
      background:
        tone === "wine"
          ? `linear-gradient(135deg, ${aikiPalette.wine}, ${aikiPalette.darkWine})`
          : `linear-gradient(145deg, ${aikiPalette.white}, ${aikiPalette.sandLight})`,
      boxShadow: "0 12px 24px rgba(83, 38, 36, 0.08)",
      color: tone === "wine" ? aikiPalette.white : aikiPalette.wine,
    }}
  >
    <div style={{ width: 34, height: 5, borderRadius: 999, backgroundColor: tone === "wine" ? `${accentColor}CC` : accentColor }} />
    <div style={{ marginTop: 14, fontSize: 15, fontWeight: 600 }}>{title}</div>
    <div style={{ marginTop: 4, color: tone === "wine" ? `${aikiPalette.white}B8` : aikiPalette.muted, fontSize: 11, lineHeight: 1.35 }}>
      {subtitle}
    </div>
  </div>
);

const FormRow: React.FC<{ label: string; value: string; accentColor: string; active?: boolean }> = ({
  label,
  value,
  accentColor,
  active = false,
}) => (
  <div
    style={{
      display: "flex",
      flexDirection: "column",
      gap: 5,
      padding: "10px 12px",
      border: `1px solid ${active ? `${accentColor}66` : aikiPalette.stroke}`,
      borderRadius: 12,
      backgroundColor: active ? `${accentColor}0C` : aikiPalette.white,
    }}
  >
    <div style={{ color: aikiPalette.muted, fontSize: 10, fontWeight: 600, textTransform: "uppercase", letterSpacing: 0.7 }}>
      {label}
    </div>
    <div style={{ color: aikiPalette.wine, fontSize: 13, fontWeight: 500 }}>{value}</div>
  </div>
);

const CheckRow: React.FC<{ children: React.ReactNode; accentColor: string }> = ({ children, accentColor }) => (
  <div style={{ display: "flex", alignItems: "center", gap: 8, color: aikiPalette.wine, fontSize: 12 }}>
    <div
      style={{
        display: "flex",
        width: 18,
        height: 18,
        alignItems: "center",
        justifyContent: "center",
        borderRadius: "50%",
        backgroundColor: `${accentColor}22`,
        color: accentColor,
        fontSize: 11,
        fontWeight: 700,
      }}
    >
      ✓
    </div>
    {children}
  </div>
);

const DemoContent: React.FC<{ kind: AikiDemoScreenKind; accentColor: string; frame: number; durationInFrames: number }> = ({
  kind,
  accentColor,
  frame,
  durationInFrames,
}) => {
  const reveal = (start: number, distance = 14) => ({
    opacity: interpolate(frame, [start, start + 20], [0, 1], {
      extrapolateLeft: "clamp",
      extrapolateRight: "clamp",
      easing: ease,
    }),
    translate: interpolate(frame, [start, start + 20], [`0px ${distance}px`, "0px 0px"], {
      extrapolateLeft: "clamp",
      extrapolateRight: "clamp",
      easing: ease,
    }),
  });

  if (kind === "explore") {
    return (
      <>
        <div style={{ ...reveal(4), marginTop: 18 }}>
          <div
            style={{
              minHeight: 168,
              padding: 19,
              borderRadius: 24,
              background: `linear-gradient(135deg, ${aikiPalette.wine}, ${accentColor})`,
              boxShadow: "0 18px 32px rgba(83, 38, 36, 0.18)",
              color: aikiPalette.white,
            }}
          >
            <div style={{ fontSize: 12, fontWeight: 600, opacity: 0.72 }}>RECOMENDADO PARA TI</div>
            <div style={{ maxWidth: 230, marginTop: 13, fontSize: 25, fontWeight: 600, lineHeight: 1.12 }}>
              Respirar también es avanzar.
            </div>
            <div style={{ display: "inline-flex", marginTop: 18, padding: "8px 12px", borderRadius: 999, backgroundColor: `${aikiPalette.white}20`, fontSize: 11, fontWeight: 600 }}>
              Comenzar ahora
            </div>
          </div>
        </div>
        <div style={{ ...reveal(16), marginTop: 22 }}>
          <DemoSectionTitle title="Explorar" action="Ver todo" />
          <div style={{ display: "flex", gap: 7, overflow: "hidden" }}>
            <DemoPill active accentColor={accentColor}>Meditación</DemoPill>
            <DemoPill accentColor={accentColor}>Sueño</DemoPill>
            <DemoPill accentColor={accentColor}>Calma</DemoPill>
          </div>
        </div>
        <div style={{ ...reveal(28), display: "grid", gridTemplateColumns: "1fr 1fr", gap: 9, marginTop: 18 }}>
          <DemoCard title="Pausa de 5 min" subtitle="Una práctica breve" accentColor={accentColor} />
          <DemoCard title="Volver al centro" subtitle="Respiración guiada" accentColor={accentColor} tone="wine" />
        </div>
      </>
    );
  }

  if (kind === "mySpace") {
    const progress = interpolate(frame, [10, 46, durationInFrames], [0.58, 0.82, 0.74], {
      extrapolateLeft: "clamp",
      extrapolateRight: "clamp",
      easing: ease,
    });
    return (
      <>
        <div style={{ ...reveal(4), display: "flex", alignItems: "center", gap: 16, marginTop: 22, padding: 18, borderRadius: 22, backgroundColor: aikiPalette.white, boxShadow: "0 14px 30px rgba(83, 38, 36, 0.08)" }}>
          <div
            style={{
              display: "flex",
              width: 102,
              height: 102,
              alignItems: "center",
              justifyContent: "center",
              borderRadius: "50%",
              background: `conic-gradient(${accentColor} ${progress * 360}deg, ${aikiPalette.stroke} 0deg)`,
              rotate: `${interpolate(frame, [0, durationInFrames], [-8, 8], { extrapolateLeft: "clamp", extrapolateRight: "clamp" })}deg`,
            }}
          >
            <div style={{ display: "flex", width: 78, height: 78, alignItems: "center", justifyContent: "center", borderRadius: "50%", backgroundColor: aikiPalette.warmIvory, color: aikiPalette.wine, fontSize: 18, fontWeight: 600 }}>
              {Math.round(progress * 100)}%
            </div>
          </div>
          <div>
            <div style={{ color: aikiPalette.muted, fontSize: 12, fontWeight: 600 }}>MI ESPACIO</div>
            <div style={{ marginTop: 5, color: aikiPalette.wine, fontSize: 20, fontWeight: 600 }}>Tu práctica continúa</div>
            <div style={{ marginTop: 5, color: aikiPalette.muted, fontSize: 12, lineHeight: 1.35 }}>Un lugar para volver a lo que te hace bien.</div>
          </div>
        </div>
        <div style={{ ...reveal(24), marginTop: 22 }}>
          <DemoSectionTitle title="Retomar" action="Mis guardados" />
          <DemoCard title="Volver al centro" subtitle="12 min · En progreso" accentColor={accentColor} tone="wine" />
        </div>
        <div style={{ ...reveal(38), display: "flex", gap: 9, marginTop: 12 }}>
          <DemoCard title="Dormir mejor" subtitle="Guardado" accentColor={accentColor} />
          <DemoCard title="Respirar" subtitle="Guardado" accentColor={accentColor} />
        </div>
      </>
    );
  }

  if (kind === "adminCreate") {
    return (
      <>
        <div style={{ ...reveal(4), marginTop: 19, padding: 15, borderRadius: 21, backgroundColor: aikiPalette.white, boxShadow: "0 14px 30px rgba(83, 38, 36, 0.08)" }}>
          <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", marginBottom: 14 }}>
            <div style={{ color: aikiPalette.wine, fontSize: 17, fontWeight: 600 }}>Nuevo contenido</div>
            <DemoPill active accentColor={accentColor}>Borrador</DemoPill>
          </div>
          <FormRow label="Título" value="Respirar también es avanzar" accentColor={accentColor} active />
          <div style={{ height: 9 }} />
          <FormRow label="Descripción" value="Una práctica para volver al centro." accentColor={accentColor} />
          <div style={{ display: "flex", gap: 9, marginTop: 9 }}>
            <div style={{ flex: 1, height: 58, borderRadius: 14, background: `linear-gradient(135deg, ${aikiPalette.sand}, ${accentColor}99)` }} />
            <div style={{ display: "flex", flex: 1, height: 58, alignItems: "center", justifyContent: "center", border: `1px dashed ${accentColor}88`, borderRadius: 14, color: accentColor, fontSize: 12, fontWeight: 600 }}>+ Media</div>
          </div>
        </div>
        <div style={{ ...reveal(30), display: "flex", alignItems: "center", justifyContent: "space-between", marginTop: 18 }}>
          <div style={{ color: aikiPalette.muted, fontSize: 12 }}>FormPage · 1 de 3</div>
          <div style={{ padding: "10px 15px", borderRadius: 999, backgroundColor: accentColor, color: aikiPalette.white, fontSize: 12, fontWeight: 600 }}>Guardar</div>
        </div>
      </>
    );
  }

  if (kind === "adminEdit") {
    return (
      <>
        <div style={{ ...reveal(4), marginTop: 19 }}>
          <div style={{ height: 140, padding: 16, borderRadius: 22, background: `linear-gradient(135deg, ${aikiPalette.wine}, ${accentColor})`, color: aikiPalette.white }}>
            <div style={{ fontSize: 11, fontWeight: 600, opacity: 0.72 }}>FORMPAGES · EDITAR</div>
            <div style={{ maxWidth: 220, marginTop: 17, fontSize: 23, fontWeight: 600, lineHeight: 1.12 }}>Respirar también es avanzar</div>
          </div>
          <div style={{ display: "flex", gap: 7, marginTop: 12 }}>
            <DemoPill active accentColor={accentColor}>Contenido</DemoPill>
            <DemoPill accentColor={accentColor}>Media</DemoPill>
            <DemoPill accentColor={accentColor}>Visibilidad</DemoPill>
          </div>
        </div>
        <div style={{ ...reveal(25), marginTop: 18 }}>
          <FormRow label="Título" value="Respirar también es avanzar" accentColor={accentColor} active />
          <div style={{ height: 8 }} />
          <FormRow label="Duración" value="12 minutos" accentColor={accentColor} />
        </div>
        <div style={{ ...reveal(38), display: "flex", alignItems: "center", justifyContent: "space-between", marginTop: 16 }}>
          <div style={{ color: accentColor, fontSize: 12, fontWeight: 600 }}>Cambios guardados</div>
          <div style={{ width: 72, height: 6, borderRadius: 999, backgroundColor: accentColor }} />
        </div>
      </>
    );
  }

  if (kind === "subscriptions") {
    return (
      <>
        <div style={{ ...reveal(4), marginTop: 24 }}>
          <div style={{ color: aikiPalette.muted, fontSize: 13, fontWeight: 600 }}>TU PLAN</div>
          <div style={{ marginTop: 5, color: aikiPalette.wine, fontSize: 27, fontWeight: 600 }}>Aiki Esencial</div>
        </div>
        <div style={{ ...reveal(16), marginTop: 18, padding: 20, borderRadius: 25, background: `linear-gradient(145deg, ${aikiPalette.wine}, ${aikiPalette.darkWine})`, boxShadow: "0 18px 34px rgba(83, 38, 36, 0.2)", color: aikiPalette.white }}>
          <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between" }}>
            <div style={{ fontSize: 12, fontWeight: 600, opacity: 0.72 }}>SUSCRIPCIÓN ACTIVA</div>
            <div style={{ width: 8, height: 8, borderRadius: "50%", backgroundColor: accentColor }} />
          </div>
          <div style={{ marginTop: 20, fontSize: 34, fontWeight: 600 }}>$149 <span style={{ fontSize: 13, fontWeight: 400, opacity: 0.68 }}>/ mes</span></div>
          <div style={{ display: "flex", flexDirection: "column", gap: 10, marginTop: 20 }}>
            <CheckRow accentColor={accentColor}>Prácticas sin límites</CheckRow>
            <CheckRow accentColor={accentColor}>Contenido para cada momento</CheckRow>
            <CheckRow accentColor={accentColor}>Tu progreso siempre contigo</CheckRow>
          </div>
          <div style={{ marginTop: 22, padding: "11px 14px", borderRadius: 999, backgroundColor: accentColor, color: aikiPalette.white, textAlign: "center", fontSize: 12, fontWeight: 600 }}>Administrar suscripción</div>
        </div>
      </>
    );
  }

  if (kind === "streaks") {
    const count = Math.round(interpolate(frame, [5, 32], [4, 7], { extrapolateLeft: "clamp", extrapolateRight: "clamp", easing: ease }));
    const pulse = interpolate(frame, [0, durationInFrames * 0.45, durationInFrames], [1, 1.08, 1], { extrapolateLeft: "clamp", extrapolateRight: "clamp", easing: ease });
    return (
      <>
        <div style={{ ...reveal(4), display: "flex", flexDirection: "column", alignItems: "center", marginTop: 25, textAlign: "center" }}>
          <div style={{ display: "flex", width: 148, height: 148, alignItems: "center", justifyContent: "center", border: `10px solid ${accentColor}44`, borderTopColor: accentColor, borderRightColor: accentColor, borderRadius: "50%", scale: pulse }}>
            <div>
              <div style={{ color: aikiPalette.wine, fontSize: 45, fontWeight: 600, lineHeight: 1 }}>{count}</div>
              <div style={{ marginTop: 5, color: aikiPalette.muted, fontSize: 12, fontWeight: 600 }}>DÍAS</div>
            </div>
          </div>
          <div style={{ marginTop: 16, color: aikiPalette.wine, fontSize: 23, fontWeight: 600 }}>Tu racha continúa</div>
          <div style={{ marginTop: 5, color: aikiPalette.muted, fontSize: 12 }}>Un momento para ti, cada día.</div>
        </div>
        <div style={{ ...reveal(30), marginTop: 24, padding: 16, borderRadius: 20, backgroundColor: aikiPalette.white }}>
          <div style={{ color: aikiPalette.muted, fontSize: 11, fontWeight: 600, textTransform: "uppercase", letterSpacing: 0.9 }}>Esta semana</div>
          <div style={{ display: "flex", justifyContent: "space-between", marginTop: 14 }}>
            {["L", "M", "X", "J", "V", "S", "D"].map((day, index) => (
              <div key={day} style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 7 }}>
                <div style={{ display: "flex", width: 28, height: 28, alignItems: "center", justifyContent: "center", borderRadius: "50%", backgroundColor: index < 6 ? `${accentColor}22` : aikiPalette.sandLight, color: index < 6 ? accentColor : aikiPalette.muted, fontSize: 11, fontWeight: 700 }}>{index < 6 ? "✓" : "·"}</div>
                <div style={{ color: aikiPalette.muted, fontSize: 10 }}>{day}</div>
              </div>
            ))}
          </div>
        </div>
      </>
    );
  }

  if (kind === "adminNotification") {
    return (
      <>
        <div style={{ ...reveal(4), marginTop: 20, padding: 16, borderRadius: 22, backgroundColor: aikiPalette.white, boxShadow: "0 14px 30px rgba(83, 38, 36, 0.08)" }}>
          <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", marginBottom: 14 }}>
            <div style={{ color: aikiPalette.wine, fontSize: 17, fontWeight: 600 }}>Nueva notificación</div>
            <div style={{ color: accentColor, fontSize: 12, fontWeight: 600 }}>Vista previa</div>
          </div>
          <FormRow label="Título" value="Una nueva práctica te espera" accentColor={accentColor} active />
          <div style={{ height: 8 }} />
          <FormRow label="Audiencia" value="Personas con suscripción activa" accentColor={accentColor} />
          <div style={{ height: 8 }} />
          <FormRow label="Destino" value="Respirar también es avanzar" accentColor={accentColor} />
        </div>
        <div style={{ ...reveal(30), display: "flex", alignItems: "center", justifyContent: "space-between", marginTop: 18 }}>
          <div style={{ color: aikiPalette.muted, fontSize: 12 }}>Lista para enviar</div>
          <div style={{ display: "flex", alignItems: "center", gap: 7, padding: "10px 14px", borderRadius: 999, backgroundColor: accentColor, color: aikiPalette.white, fontSize: 12, fontWeight: 600 }}>Enviar <span style={{ fontSize: 15 }}>→</span></div>
        </div>
      </>
    );
  }

  return (
    <>
      <div style={{ ...reveal(4), marginTop: 22 }}>
        <DemoHeader eyebrow="Aviso nuevo" title="Una invitación para volver" accentColor={accentColor} />
      </div>
      <div style={{ ...reveal(20), marginTop: 22, padding: 18, border: `1px solid ${accentColor}44`, borderRadius: 22, backgroundColor: `${accentColor}12`, boxShadow: "0 14px 30px rgba(83, 38, 36, 0.08)" }}>
        <div style={{ display: "flex", alignItems: "flex-start", gap: 12 }}>
          <div style={{ display: "flex", width: 40, height: 40, alignItems: "center", justifyContent: "center", borderRadius: 14, backgroundColor: accentColor, color: aikiPalette.white, fontSize: 18, fontWeight: 600 }}>A</div>
          <div style={{ flex: 1 }}>
            <div style={{ color: aikiPalette.wine, fontSize: 16, fontWeight: 600 }}>Una nueva práctica te espera</div>
            <div style={{ marginTop: 6, color: aikiPalette.muted, fontSize: 12, lineHeight: 1.4 }}>Vuelve al centro con una experiencia breve para este momento.</div>
          </div>
        </div>
        <div style={{ marginTop: 18, padding: "10px 13px", borderRadius: 999, backgroundColor: aikiPalette.wine, color: aikiPalette.white, textAlign: "center", fontSize: 12, fontWeight: 600 }}>Abrir contenido</div>
      </div>
      <div style={{ ...reveal(38), marginTop: 20 }}>
        <DemoSectionTitle title="Tu inbox" action="1 nuevo" />
        <DemoCard title="Respirar también es avanzar" subtitle="Disponible ahora" accentColor={accentColor} tone="wine" />
      </div>
    </>
  );
};

export const AikiDemoScreen: React.FC<AikiDemoScreenProps> = ({
  kind,
  label,
  detail,
  side,
  accentColor,
}) => {
  const frame = useCurrentFrame();
  const { durationInFrames } = useVideoConfig();

  return (
    <Interactive.Div
      name={`Demo de contenido · ${label}`}
      style={{
        display: "flex",
        width: "100%",
        height: "100%",
        minHeight: 360,
        flexDirection: "column",
        overflow: "hidden",
        padding: "24px 20px 30px",
        boxSizing: "border-box",
        background: `linear-gradient(180deg, ${aikiPalette.warmIvory}, ${aikiPalette.sandLight})`,
        color: aikiPalette.wine,
        fontFamily,
      }}
    >
      <div style={{ opacity: interpolate(frame, [0, 18], [0, 1], { extrapolateLeft: "clamp", extrapolateRight: "clamp", easing: ease }) }}>
        <DemoHeader
          eyebrow={side === "Administrador" ? "Panel de administración" : "Buenos días"}
          title={label}
          accentColor={accentColor}
        />
      </div>
      <div style={{ display: "flex", minHeight: 0, flex: 1, flexDirection: "column" }}>
        <DemoContent kind={kind} accentColor={accentColor} frame={frame} durationInFrames={durationInFrames} />
      </div>
      <div style={{ marginTop: "auto", paddingTop: 18, color: aikiPalette.muted, fontSize: 10, lineHeight: 1.35, opacity: 0.82 }}>
        {detail}
      </div>
    </Interactive.Div>
  );
};
