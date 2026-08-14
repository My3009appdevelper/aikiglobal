import type { AdminIdentity } from "./handler.ts";
import { HttpError } from "./handler.ts";

export interface AdminProfileRow {
  uuid_profile: string;
  role: string;
  activo: boolean;
  deleted_at: string | null;
}

export interface AdminAuthGateway {
  getProfile(authUserId: string): Promise<AdminProfileRow | null>;
}

export async function authenticateAdmin(
  authUserId: string,
  gateway: AdminAuthGateway,
): Promise<AdminIdentity> {
  const cleanAuthUserId = authUserId.trim();
  if (cleanAuthUserId.length === 0) {
    throw new HttpError(401, "El JWT no es válido.");
  }

  const profile = await gateway.getProfile(cleanAuthUserId);
  if (
    profile === null || profile.uuid_profile.trim().length === 0 ||
    profile.role !== "admin" || !profile.activo || profile.deleted_at !== null
  ) {
    throw new HttpError(403, "El perfil no tiene acceso administrativo.");
  }

  return { uuidProfile: profile.uuid_profile };
}
