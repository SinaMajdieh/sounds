namespace DSP;

public readonly record struct StftResult(
    StftSegment[] Segments,
    int SampleRate,
    int SampleCount
)
{
    public int FrequencyCount => Segments[0].Spectrum.Length;
    public float FrequencySpacing => Segments[0].Spectrum[1].Frequency - Segments[0].Spectrum[0].Frequency;
    public float SegmentDuration => Segments[0].SampleCount / (float)SampleRate;
}
