import { assertEquals, assertRejects } from "jsr:@std/assert@1.0.14";

import { type AdminAuthGateway, authenticateAdmin } from "./auth.ts";
import { HttpError } from "./handler.ts";

Deno.test("authenticateAdmin validates JWT and active admin profile", async () => {
  const calls: string[] = [];
  const gateway: AdminAuthGateway = {
    getProfile: (authUserId: string) => {
      calls.push(`profile:${authUserId}`);
      return Promise.resolve({
        uuid_profile: "admin-1",
        role: "admin",
        activo: true,
        deleted_at: null,
      });
    },
  };

  const identity = await authenticateAdmin("auth-user-1", gateway);

  assertEquals(identity, { uuidProfile: "admin-1" });
  assertEquals(calls, ["profile:auth-user-1"]);
});

Deno.test("authenticateAdmin rejects a missing verified user before reading a profile", async () => {
  let profileRead = false;
  const gateway: AdminAuthGateway = {
    getProfile: () => {
      profileRead = true;
      return Promise.resolve(null);
    },
  };

  const error = await assertRejects(
    () => authenticateAdmin("", gateway),
    HttpError,
  ) as HttpError;

  assertEquals(error.status, 401);
  assertEquals(profileRead, false);
});

Deno.test("authenticateAdmin rejects inactive, deleted or non-admin profiles", async () => {
  const profiles = [
    { uuid_profile: "p1", role: "user", activo: true, deleted_at: null },
    { uuid_profile: "p2", role: "admin", activo: false, deleted_at: null },
    {
      uuid_profile: "p3",
      role: "admin",
      activo: true,
      deleted_at: "2026-07-16T00:00:00.000Z",
    },
  ];

  for (const profile of profiles) {
    const error = await assertRejects(
      () =>
        authenticateAdmin("auth-user-1", {
          getProfile: () => Promise.resolve(profile),
        }),
      HttpError,
    ) as HttpError;
    assertEquals(error.status, 403);
  }
});
