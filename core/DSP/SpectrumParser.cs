using System;

namespace DSP;

public static class SpectrumParser
{
    public static FrequencyData[] Parse(ReadOnlySpan<float> rawData)
    {
        if (rawData.Length % 3 != 0)
            throw new ArgumentException("Spectrum data must be groups of 3: frequency, amplitude, phase.");

        int count = rawData.Length / 3;
        FrequencyData[] result = new FrequencyData[count];

        for (int i = 0; i < count; i++)
        {
            int baseIndex = i * 3;

            result[i] = new FrequencyData(
                rawData[baseIndex],
                rawData[baseIndex + 1],
                rawData[baseIndex + 2]
            );
        }

        return result;
    }

    public static FrequencyData[] Parse(float[] data)
    {
        return Parse(new ReadOnlySpan<float>(data));
    }

    public static float[] ToInterleaved(ReadOnlySpan<FrequencyData> spectrum)
    {
        float[] result = new float[spectrum.Length * 3];

        for (int i = 0; i < spectrum.Length; i++)
        {
            int baseIndex = i * 3;

            result[baseIndex] = spectrum[i].Frequency;
            result[baseIndex + 1] = spectrum[i].Amplitude;
            result[baseIndex + 2] = spectrum[i].Phase;

        }
        
        return result;
    }

    public static float[] ToInterleaved(FrequencyData[] spectrum)
    {
        return ToInterleaved(new ReadOnlySpan<FrequencyData>(spectrum));
    }
}
