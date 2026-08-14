export interface NotificationTemplateProfile {
  nombre?: string | null;
  email?: string | null;
}

export function profileTemplateVariables(
  profile: NotificationTemplateProfile,
): Record<string, unknown> {
  const email = clean(profile.email);
  const name = clean(profile.nombre) ?? email?.split("@")[0] ?? "tú";
  return {
    profile_name: name,
    profile_email: email ?? "",
  };
}

export function sampleTemplateVariables(): Record<string, unknown> {
  return {
    profile_name: "Ana",
    profile_email: "ana@aiki.com",
  };
}

export function renderNotificationText(
  template: string,
  variables: Record<string, unknown>,
): string {
  return template.replace(/\{([a-z][a-z0-9_]*)\}/g, (_match, key) => {
    const value = variables[key];
    return value === null || value === undefined ? "" : String(value);
  }).trim();
}

export function renderNotificationObject(
  value: unknown,
  variables: Record<string, unknown>,
): unknown {
  if (typeof value === "string") {
    return renderNotificationText(value, variables);
  }
  if (Array.isArray(value)) {
    return value.map((entry) => renderNotificationObject(entry, variables));
  }
  if (isRecord(value)) {
    return Object.fromEntries(
      Object.entries(value).map(([key, entry]) => [
        key,
        renderNotificationObject(entry, variables),
      ]),
    );
  }
  return value;
}

function clean(value: string | null | undefined): string | null {
  const trimmed = value?.trim();
  return trimmed === undefined || trimmed.length === 0 ? null : trimmed;
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}
