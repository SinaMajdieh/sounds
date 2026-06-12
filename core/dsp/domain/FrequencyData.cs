namespace DSP;

public readonly record struct FrequencyData(
    float Frequency,
    float Amplitude,
    float Phase)
{
    public override string ToString() =>
        $"Frequency: {Frequency}, Amplitude: {Amplitude}, Phase: {Phase}";
}
