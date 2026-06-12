using System;
using Godot;

namespace DSP;

[GlobalClass]
public partial class Fft: RefCounted
{
    public static FrequencyData[] Compute(ReadOnlySpan<float> samples, int sampleRate)
    {
        float[] padded = PadToPowerOfTwo(samples);

        int n = padded.Length;

        float[] real = new float[n];
        float[] imaginary = new float[n];

        padded.AsSpan().CopyTo(real);

        FFT(real, imaginary);

        int bins = n / 2 + 1;
        var spectrum = new FrequencyData[bins];

        float frequencyStep = (float)sampleRate / n;

        for (int i = 0; i < bins; i++)
        {
            float magnitude = MathF.Sqrt(real[i] * real[i] + imaginary[i] * imaginary[i]) / n;

            bool isDc = i == 0;
            bool isNyquist = i == n / 2;

            if (!isDc && !isNyquist)
                magnitude *= 2;
            
            //? - or +
            float phase = MathF.Atan2(imaginary[i], real[i]);
            float frequency = i * frequencyStep;

            spectrum[i] = new FrequencyData(frequency, magnitude, phase);
        }

        return spectrum;

    }

    static float[] PadToPowerOfTwo(ReadOnlySpan<float> input)
    {
        int n = input.Length;
        int pow2 = 1;

        while (pow2 < n)
            pow2 <<= 1;
        
        float[] result = new float[pow2];
        input.CopyTo(result);

        return result;
    }

    static void FFT(float[] real, float[] imaginary)
    {
        int n = real.Length;

        BitReverse(real, imaginary);

        for (int size = 2; size <= n; size <<= 1)
        {
            int half = size / 2;
            float theta = -2f * MathF.PI / size;

            for (int start = 0; start < n; start += size)
            {
                for (int k = 0; k < half; k++)
                {
                    float angle = theta * k;

                    float cos = MathF.Cos(angle);
                    float sin = MathF.Sin(angle);

                    int even = start + k;
                    int odd = even + half;

                    float tr = cos * real[odd] - sin  * imaginary[odd];
                    float ti = cos * imaginary[odd] + sin * real[odd];

                    real[odd] = real[even] - tr;
                    imaginary[odd] = imaginary[even] - ti;

                    real[even] += tr;
                    imaginary[even] += ti;
                }
            }
        }
    }

    static void BitReverse(float[] real, float[] imaginary)
    {
        int n = real.Length;
        int j = 0;

        for (int i = 1; i < n; i++)
        {
            int bit = n >> 1;

            while ((j & bit) != 0)
            {
                j ^= bit;
                bit >>= 1;
            }

            j |= bit;

            if (i < j)
            {
                (real[i], real[j]) = (real[j], real[i]);
                (imaginary[i], imaginary[j]) = (imaginary[j], imaginary[i]);

            }
        }
    }
}