using DSP;
using Godot;
using System;
using System.Threading.Tasks;
using static Godot.Mathf;

[GlobalClass]
public partial class DFT : RefCounted
{
    public static float[] Compute(float[] samples, int sampleRate)
    {
        int numSamples = samples.Length;
        int numFrequencies = numSamples / 2 + 1;
        float frequencyStepSize = (float)sampleRate / numSamples;

        FrequencyData[] spectrum = new FrequencyData[numFrequencies];

        Parallel.For(0, numFrequencies, freqIndex =>
        {
            Vector2 sampleSum = Vector2.Zero;

            for (int i = 0; i < numSamples; i++)
            {
                // Logic from your image
                float angle = 2f * Pi * freqIndex * i /numSamples;
                Vector2 testPoint = new(Cos(angle), Sin(angle));
                sampleSum += testPoint * samples[i];
            }

            Vector2 sampleCentre = sampleSum / numSamples;
            
            // Multiply magnitude by 2 because we are only looking at the positive half of the spectrum
            float amplitude = sampleCentre.Length() * 2f;
            float phase = -Atan2(sampleCentre.Y, sampleCentre.X);
            float frequency = freqIndex * frequencyStepSize;

            spectrum[freqIndex] = new FrequencyData(
                frequency,
                amplitude,
                phase
            );

        });

        return SpectrumParser.ToInterleaved(spectrum);
    }
}
