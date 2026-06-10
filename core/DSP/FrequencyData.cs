namespace DSP;

public readonly record struct FrequencyData(
    float Frequency,
    float Amplitude,
    float Phase
)
{
    public override string ToString()
    {
        return $"Frequency: {Frequency}, Amplitude: {Amplitude}, Phase: {Phase}";
    }

}
