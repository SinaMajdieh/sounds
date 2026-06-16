namespace DSP;

public readonly record struct Signal(
    float[] Samples,
    int SampleRate)
{
    public readonly int SampleCount => Samples.Length;
    public float Duration => SampleCount <= 0 ? 0f : SampleCount / SampleRate;
    public override string ToString() =>
        $"Samples: {Samples}, SampleRate: {SampleRate}, SampleCount: {SampleCount}";
}
