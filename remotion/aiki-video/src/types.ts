import { z } from "zod";
import { zColor } from "@remotion/zod-types";

export const AikiVideoSchema = z.object({
  title: z.string(),
  subtitle: z.string(),
  introKicker: z.string(),
  accentColor: zColor(),
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
