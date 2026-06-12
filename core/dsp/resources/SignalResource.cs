using Godot;

namespace DSP;

[GlobalClass]
public partial class SignalResource : Resource
{
    [Export]
    public float[] Samples { get; set; }

    [Export]
    public int SampleRate { get; set; }

    [Export]
    public int SampleCount { get; set; }

    public SignalResource() { }

    public SignalResource(float[] samples, int sampleRate)
    {
        Samples = samples;
        SampleRate = sampleRate;
        SampleCount = samples.Length;
    }
    public static SignalResource Create(float[] samples, int sampleRate)
    {
        return new SignalResource
        {
            Samples = samples,
            SampleRate = sampleRate,
            SampleCount = samples.Length
        };
    }

}
