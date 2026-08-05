import { z } from "zod";
import { zColor } from "@remotion/zod-types";

const calloutSchema = z.object({
  text: z.string(),
  position: z.enum(["top", "middle", "bottom"]),
  side: z.enum(["left", "center", "right"]),
  startAtSeconds: z.number().min(0).max(60),
  durationInSeconds: z.number().min(0.1).max(60),
});

export const AikiVideoSchema = z.object({
  title: z.string(),
  subtitle: z.string(),
  introKicker: z.string(),
  accentColor: zColor(),
  phoneScale: z.number().min(0.8).max(1.35),
  callouts: z.object({
    explore: calloutSchema,
    content: calloutSchema,
    mySpace: calloutSchema,
    mySpaceStreak: calloutSchema,
    profile: calloutSchema,
    adminPanel: calloutSchema,
  }),
  showLabels: z.boolean(),
  showCaptions: z.boolean(),
  userExploreRecording: z.string().optional(),
  userMySpaceRecording: z.string().optional(),
  userProfileRecording: z.string().optional(),
  adminPanelRecording: z.string().optional(),
  adminCreateContentRecording: z.string().optional(),
  userNewContentRecording: z.string().optional(),
  adminEditContentRecording: z.string().optional(),
  userProgressRecording: z.string().optional(),
  userSubscriptionsRecording: z.string().optional(),
  userStreaksRecording: z.string().optional(),
  adminNotificationRecording: z.string().optional(),
  userNotificationRecording: z.string().optional(),
  userDestinationRecording: z.string().optional(),
});

export type AikiVideoProps = z.infer<typeof AikiVideoSchema>;
