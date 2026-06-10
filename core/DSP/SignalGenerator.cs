using Godot;
using System;
using System.Threading.Tasks;

namespace DSP;

[GlobalClass]
public partial class SignalGenerator : RefCounted
{
    public static float[] GenerateSignal(float[] data, int sampleRate, float duration)
    {
        FrequencyData[] frequencies = SpectrumParser.Parse(data);

        int totalSamples = (int)(sampleRate * duration);
        float[] samples = new float[totalSamples];

        float tau = Mathf.Tau;
        float invSampleRate = 1f / sampleRate;

        Parallel.For(0, totalSamples, i =>
        {
            float time = i * invSampleRate;
            float value = 0f;

            foreach (var freq in frequencies)
            {
                float angle = tau * freq.Frequency * time + freq.Phase;
                value += freq.Amplitude * Mathf.Cos(angle);
            }

            samples[i] = value;
        });

        return samples;
    }
}
