namespace DSP;

public readonly record struct StftSegment(
    FrequencyData[] Spectrum,
    int StartIndex,
    int SampleCount
);
