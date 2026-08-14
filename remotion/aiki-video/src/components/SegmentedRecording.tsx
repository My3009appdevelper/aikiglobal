import { Video } from "@remotion/media";
import { Sequence, staticFile, useCurrentFrame } from "remotion";

export type RecordingSegment = {
  /** Time in the composed scene where this segment begins. */
  fromSeconds: number;
  /** Time in the original recording where this segment begins. */
  sourceStartAtSeconds: number;
  /** Playback speed for this segment. */
  playbackRate?: number;
};

type SegmentedRecordingProps = {
  name: string;
  source: string;
  segments: RecordingSegment[];
  durationInFrames: number;
  fps: number;
  objectFit: "cover" | "contain";
};

export const SegmentedRecording: React.FC<SegmentedRecordingProps> = ({
  name,
  source,
  segments,
  durationInFrames,
  fps,
  objectFit,
}) => {
  const frame = useCurrentFrame();
  const orderedSegments = [...segments].sort((a, b) => a.fromSeconds - b.fromSeconds);

  return (
    <>
      {orderedSegments.map((segment, index) => {
        const fromFrame = Math.max(0, Math.round(segment.fromSeconds * fps));
        const nextFromFrame = orderedSegments[index + 1]
          ? Math.round(orderedSegments[index + 1].fromSeconds * fps)
          : durationInFrames;
        const segmentDurationInFrames = Math.min(durationInFrames - fromFrame, nextFromFrame - fromFrame);
        const playbackRate = segment.playbackRate ?? 1;
        const preloadDurationInFrames = index === 0 ? 0 : Math.min(Math.round(fps * 0.5), fromFrame);
        const renderFromFrame = fromFrame - preloadDurationInFrames;
        const renderDurationInFrames = Math.min(
          durationInFrames - renderFromFrame,
          nextFromFrame - renderFromFrame,
        );
        const renderSourceStartAtSeconds =
          segment.sourceStartAtSeconds - (preloadDurationInFrames / fps) * playbackRate;

        if (segmentDurationInFrames <= 0 || renderDurationInFrames <= 0 || fromFrame >= durationInFrames) {
          return null;
        }

        return (
          <Sequence
            key={`${name}-${segment.fromSeconds}-${segment.sourceStartAtSeconds}`}
            from={renderFromFrame}
            durationInFrames={renderDurationInFrames}
            layout="none"
          >
            <div
              style={{
                position: "absolute",
                inset: 0,
                opacity: frame < fromFrame ? 0 : 1,
              }}
            >
              <Video
                name={`${name} · segmento ${index + 1}`}
                src={staticFile(source)}
                muted
                playbackRate={playbackRate}
                trimBefore={Math.max(0, Math.round(renderSourceStartAtSeconds * fps))}
                objectFit={objectFit}
                style={{
                  width: "100%",
                  height: "100%",
                  backgroundColor: "#F7F0E7",
                }}
              />
            </div>
          </Sequence>
        );
      })}
    </>
  );
};
