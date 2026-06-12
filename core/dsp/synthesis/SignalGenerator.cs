using Godot;
using System;
using System.Threading.Tasks;

namespace DSP;

[GlobalClass]
public partial class SignalGenerator : RefCounted
{
    public static float[] GenerateSignal(FrequencyData[] frequencies, int sampleRate, int numSamples) => GenerateSignal(frequencies, sampleRate, (float)numSamples / sampleRate);
    
    public static float[] GenerateSignal(FrequencyData[] frequencies, int sampleRate, float duration)
    {
        ArgumentNullException.ThrowIfNull(frequencies);

        if (sampleRate <= 0)
            throw new ArgumentOutOfRangeException(nameof(sampleRate));

        if (duration < 0f)
            throw new ArgumentOutOfRangeException(nameof(duration));

        int totalSamples = (int)(sampleRate * duration);
        var samples = new float[totalSamples];

        float tau = Mathf.Tau;
        float invSampleRate = 1f / sampleRate;

        Parallel.For(0, totalSamples, i =>
        {
            float time = i * invSampleRate;
            float value = 0f;

            foreach (FrequencyData frequency in frequencies)
            {
                float angle = tau * frequency.Frequency * time + frequency.Phase;
                value += frequency.Amplitude * Mathf.Cos(angle);
            }

            samples[i] = value;
        });

        return samples;
    }

    public static float[] GenerateSignalResource(FrequencyDataResource[] frequencies, int sampleRate, float duration)
    {
        ArgumentNullException.ThrowIfNull(frequencies);
        return GenerateSignal(ResourceMapper.ToDomain(frequencies), sampleRate, duration);
    }
}
