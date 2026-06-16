using Godot;
using System;
using DSP;
using System.Runtime.InteropServices;

namespace Spectrogram;

[GlobalClass]
public partial class Spectrogram: RefCounted
{
    static public Texture2D GenerateTexture(DSP.StftResult stft)
    {
        int width = stft.Segments.Length;
        int height = stft.Segments[0].Spectrum.Length;

        float maxAmplitude = 0f;
        float maxFrequency = stft.Segments[0].Spectrum[height - 1].Frequency;

        int pixelCount = width * height;

        byte[] buffer = new byte[pixelCount * sizeof(float)];

        Span<float> pixels = MemoryMarshal.Cast<byte, float>(buffer);

        for (int time = 0; time < width; time++)
        {
            var spectrum = stft.Segments[time].Spectrum;

            for (int frequency = 0; frequency < spectrum.Length; frequency++)
            {
                float amplitude = spectrum[frequency].Amplitude;
                amplitude = MathF.Log10(1f + amplitude * 100f);
                
                if (amplitude > maxAmplitude)
                    maxAmplitude = amplitude;
                
                int index = (height - 1 - frequency) * width + time;
                pixels[index] = amplitude;
            }
        }

        Image image = Image.CreateFromData(
            width,
            height,
            false,
            Image.Format.Rf,
            buffer
        );

        return ImageTexture.CreateFromImage(image);
    }
    public static Texture2D GenerateTexture(StftResultResource stft)
    {
        return GenerateTexture(DSP.ResourceMapper.ToDomain(stft));
    }
}