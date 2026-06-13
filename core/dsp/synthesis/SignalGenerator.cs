using Godot;
using System;
using System.Threading.Tasks;

namespace DSP;

[GlobalClass]
public partial class SignalGenerator : RefCounted
{
    public static float[] GenerateSignal(
    FrequencyData[] frequencies,
    int sampleRate,
    int numSamples)
    {
        ArgumentNullException.ThrowIfNull(frequencies);
        ArgumentOutOfRangeException.ThrowIfNegativeOrZero(sampleRate);
        ArgumentOutOfRangeException.ThrowIfNegative(numSamples);

        var samples = new float[numSamples];

        float tau = MathF.Tau;
        float invSampleRate = 1f / sampleRate;

        Parallel.For(0, numSamples, i =>
        {
            float time = i * invSampleRate;
            float value = 0f;

            foreach (FrequencyData frequency in frequencies)
            {
                float angle = tau * frequency.Frequency * time + frequency.Phase;
                value += frequency.Amplitude * MathF.Cos(angle);
            }

            samples[i] = value;
        });

        return samples;
    }

    
    public static float[] GenerateSignal(
    FrequencyData[] frequencies,
    int sampleRate,
    float duration)
    {
        ArgumentOutOfRangeException.ThrowIfLessThan(duration, 0f);

        int totalSamples = (int)MathF.Round(sampleRate * duration);
        return GenerateSignal(frequencies, sampleRate, totalSamples);
    }

    public static float[] GenerateSignalResource(FrequencyDataResource[] frequencies, int sampleRate, float duration)
    {
        ArgumentNullException.ThrowIfNull(frequencies);
        return GenerateSignal(ResourceMapper.ToDomain(frequencies), sampleRate, duration);
    }
}
