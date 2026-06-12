namespace DSP;

public readonly record struct StftResult(
    StftSegment[] Segments,
    int SampleRate,
    int SampleCount
);
