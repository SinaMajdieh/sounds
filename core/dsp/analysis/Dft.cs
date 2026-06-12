using Godot;
using System;
using System.Threading.Tasks;
using static Godot.Mathf;

namespace DSP;

[GlobalClass]
public partial class Dft : RefCounted
{
    public static FrequencyData[] Compute(float[] samples, int sampleRate)
    {
        ArgumentNullException.ThrowIfNull(samples);

        if (sampleRate <= 0)
            throw new ArgumentOutOfRangeException(nameof(sampleRate));

        if (samples.Length == 0)
            return Array.Empty<FrequencyData>();

        int numSamples = samples.Length;
        int numFrequencies = numSamples / 2 + 1;
        float frequencyStepSize = (float)sampleRate / numSamples;

        var spectrum = new FrequencyData[numFrequencies];

        Parallel.For(0, numFrequencies, freqIndex =>
        {
            Vector2 sampleSum = Vector2.Zero;

            for (int i = 0; i < numSamples; i++)
            {
                float angle = 2f * Pi * freqIndex * i / numSamples;
                Vector2 testPoint = new(Cos(angle), Sin(angle));
                sampleSum += testPoint * samples[i];
            }

            Vector2 sampleCentre = sampleSum / numSamples;
            float amplitude = sampleCentre.Length();

            // Multiply magnitude by 2 because we are only looking at the positive half of the spectrum
            bool isDc = freqIndex == 0;
            bool isNyquist = numSamples % 2 == 0 && freqIndex == numSamples / 2;

            if (!isDc && !isNyquist)
                amplitude *= 2f;

            float phase = -Atan2(sampleCentre.Y, sampleCentre.X);
            float frequency = freqIndex * frequencyStepSize;

            spectrum[freqIndex] = new FrequencyData(frequency, amplitude, phase);
        });

        return spectrum;
    }

    public static FrequencyDataResource[] ComputeResource(float[] samples, int sampleRate) =>
        ResourceMapper.ToResource(Compute(samples, sampleRate));
}
