import { JWT } from "npm:google-auth-library@10.9.0";

import {
  type FcmRequest,
  type FcmSendResult,
  sendFcmWithRetry,
} from "./fcm.ts";

export interface FirebaseCredentials {
  projectId: string;
  clientEmail: string;
  privateKey: string;
}

const firebaseMessagingScope =
  "https://www.googleapis.com/auth/firebase.messaging";

export function loadFirebaseCredentials(): FirebaseCredentials {
  return {
    projectId: requiredEnv("FIREBASE_PROJECT_ID"),
    clientEmail: requiredEnv("FIREBASE_CLIENT_EMAIL"),
    privateKey: requiredEnv("FIREBASE_PRIVATE_KEY").replaceAll("\\n", "\n"),
  };
}

export async function getFirebaseAccessToken(
  credentials: FirebaseCredentials,
): Promise<string> {
  const client = new JWT({
    email: credentials.clientEmail,
    key: credentials.privateKey,
    scopes: [firebaseMessagingScope],
  });
  const result = await client.getAccessToken();
  const token = result.token?.trim();
  if (token === undefined || token.length === 0) {
    throw new Error("Google OAuth no devolvió un access token.");
  }
  return token;
}

export async function sendFirebaseMessage(
  credentials: FirebaseCredentials,
  request: FcmRequest,
  accessToken: string,
): Promise<FcmSendResult> {
  const endpoint = `https://fcm.googleapis.com/v1/projects/${
    encodeURIComponent(credentials.projectId)
  }/messages:send`;
  return await sendFcmWithRetry(() =>
    fetch(endpoint, {
      method: "POST",
      headers: {
        authorization: `Bearer ${accessToken}`,
        "content-type": "application/json; charset=utf-8",
      },
      body: JSON.stringify(request),
    })
  );
}

function requiredEnv(name: string): string {
  const value = Deno.env.get(name)?.trim() ?? "";
  if (value.length === 0) {
    throw new Error(`Falta el secreto ${name}.`);
  }
  return value;
}
