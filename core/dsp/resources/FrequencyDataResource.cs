using Godot;

namespace DSP;

[GlobalClass]
public partial class FrequencyDataResource : Resource
{
    [Export]
    public float Frequency { get; set; }

    [Export]
    public float Amplitude { get; set; }

    [Export]
    public float Phase { get; set; }

    public FrequencyDataResource() { }

    public FrequencyDataResource(float frequency, float amplitude, float phase)
    {
        Frequency = frequency;
        Amplitude = amplitude;
        Phase = phase;
    }
    public static FrequencyDataResource Create(float frequency, float amplitude, float phase)
    {
        return new FrequencyDataResource
        {
            Frequency = frequency,
            Amplitude = amplitude,
            Phase = phase
        };
    }

}
