using Godot;
using System;
using DSP;
using System.Runtime.InteropServices;

namespace Spectrogram;

[GlobalClass]
public partial class Spectrogram: RefCounted
{
    public SignalResource Signal {get; private set;}
    
    private StftResult _stft;
    private float _maxAmplitude;

    public float Duration => Signal?.Duration ?? 0f;
    public float MaxFrequency => _stft.Segments is { Length: > 0 } ? _stft.Segments[0].Spectrum[^1].Frequency : 0f;
    public float MaxAmplitude => MathF.Max(_maxAmplitude, 0f);
    
    public Spectrogram() {}
    
    public void LoadSignal(SignalResource signal, int samplesPerSegment)
    {
        Signal = signal;
        _stft = Stft.Compute(ResourceMapper.ToDomain(signal), samplesPerSegment);
        _maxAmplitude = ComputeMaxAmplitude();
    }
    
    public Texture2D GenerateTexture()
    {
        if (_stft.Segments is not { Length: > 0 })
        {
            GD.PushError("GenerateTexture called before LoadSignal or STFT is empty.");
            return null;
        }
        int width = _stft.Segments.Length;
        int height = _stft.Segments[0].Spectrum.Length;
        int pixelCount = width * height;

        byte[] buffer = new byte[pixelCount * sizeof(float)];

        Span<float> pixels = MemoryMarshal.Cast<byte, float>(buffer);

        for (int time = 0; time < width; time++)
        {
            var spectrum = _stft.Segments[time].Spectrum;

            for (int frequency = 0; frequency < spectrum.Length; frequency++)
            {
                float amplitude = spectrum[frequency].Amplitude;
                amplitude = LogTransform(amplitude);
                
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

    private float ComputeMaxAmplitude()
    {
        float max = 0f;
        foreach (var segment in _stft.Segments)
            foreach (var bin in segment.Spectrum)
            {
                float v = LogTransform(bin.Amplitude);
                if (v > max) max = v;
            }
        return max;
    }

    private static float LogTransform(float amplitude) => MathF.Log10(1f + amplitude * 100f);
}