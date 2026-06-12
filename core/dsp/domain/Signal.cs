namespace DSP;

public readonly record struct Signal(
    float[] Samples,
    int SampleRate)
{
    public readonly int SampleCount => Samples.Length;
    public override string ToString() =>
        $"Samples: {Samples}, SampleRate: {SampleRate}, SampleCount: {SampleCount}";
}
