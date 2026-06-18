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
    
    public int TimeFrames => _stft.Segments?.Length ?? 0;
    public int FrequencyBins => _stft.Segments is { Length: > 0 } ? _stft.Segments[0].Spectrum.Length : 0;
    public int SampleRate => Signal?.SampleRate ?? 0;

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
                float normalized = amplitude / MaxAmplitude;
                
                int index = (height - 1 - frequency) * width + time;
                pixels[index] = normalized;
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
                if (bin.Amplitude > max) max = bin.Amplitude;
            }
        return max;
    }
    /// <summary>
    /// Converts normalized texture coordinates [0,1] to STFT array indices.
    /// </summary>
    /// <param name="textureCoord">Normalized UV coordinates (0,0 = top-left)</param>
    /// <returns>Vector2I(timeIndex, frequencyIndex) clamped to valid bounds</returns>
    public Vector2I TextureToStftIndex(Vector2 textureCord)
    {
        if (_stft.Segments is not { Length: > 0})
            return Vector2I.Zero;
        
        // X maps directly to time
        int timeIndex = Mathf.FloorToInt(textureCord.X * TimeFrames);

        // Y is inverted: texture Y=0 (top) = highest frequency, Y=1 (bottom) = DC
        int frequencyIndex = Mathf.FloorToInt((1f - textureCord.Y) * FrequencyBins);

        // Clamp to valid array bounds
        timeIndex = Mathf.Clamp(timeIndex, 0, TimeFrames - 1);
        frequencyIndex = Mathf.Clamp(frequencyIndex, 0, FrequencyBins - 1);

        return new Vector2I(timeIndex, frequencyIndex);
    }
    /// <summary>
    /// Converts STFT array indices to normalized texture coordinates.
    /// </summary>
    /// <param name="timeIndex">Time frame index [0, TimeFrames-1]</param>
    /// <param name="freqIndex">Frequency bin index [0, FrequencyBins-1]</param>
    /// <returns>Normalized UV coordinates [0,1]</returns>
    public Vector2 StftIndexToTexture(int timeIndex, int frequencyIndex)
    {
        if (TimeFrames == 0 || FrequencyBins == 0)
            return Vector2.Zero;
        
        float x = timeIndex / (float)(TimeFrames - 1);
        float y = 1f - (frequencyIndex / (float)(FrequencyBins - 1));

        return new Vector2(x, y);
    }
    ///<summary>
    /// Gets the amplitude value at the specified STFT indices.
    /// </summary>
    public float GetAmplitude(int timeIndex, int frequencyIndex)
    {
        if (_stft.Segments is not { Length: > 0})
            return 0f;
        
        if (timeIndex < 0 || timeIndex >= TimeFrames ||
            frequencyIndex < 0 || frequencyIndex >= FrequencyBins)
                return 0f;
        
        return _stft.Segments[timeIndex].Spectrum[frequencyIndex].Amplitude;
    }
    ///<summary>
    /// Gets the frequency in Hz for a given frequency bin index.
    public float GetFrequency(int frequencyIndex)
    {
        if (_stft.Segments is not { Length: > 0})
            return 0f;
        
        if (frequencyIndex < 0 || frequencyIndex >= FrequencyBins)
            return 0f;
        
        return _stft.Segments[0].Spectrum[frequencyIndex].Frequency;
    }
    ///<summary>
    /// Gets the time in seconds for a given time index.
    public float GetTime(int timeIndex)
    {
        if (_stft.Segments is not { Length: > 0})
            return 0f;
        
        if (timeIndex < 0 || timeIndex >= TimeFrames)
            return 0f;

        return Duration * (timeIndex / TimeFrames);
    }
    /// <summary>
    /// Reconstructs the full signal from the stored STFT data.
    /// </summary>
    public SignalResource ReconstructSignal()
    {
        if (_stft.Segments is not { Length: > 0 })
        {
            GD.PushError("Cannot reconstruct: STFT data is empty.");
            return null;
        }
        
        var reconstructed = Stft.ReconstructSignal(_stft);
        return ResourceMapper.ToResource(reconstructed);
    }
    /// <summary>
    /// Reconstructs a region of the signal specified by STFT indices.
    /// </summary>
    /// <param name="timeStart">Starting time frame index (inclusive)</param>
    /// <param name="timeEnd">Ending time frame index (exclusive)</param>
    /// <param name="freqStart">Starting frequency bin index (inclusive)</param>
    /// <param name="freqEnd">Ending frequency bin index (exclusive)</param>
    public SignalResource ReconstructRegion(int timeStart, int timeEnd, int freqStart, int freqEnd)
    {
        if (_stft.Segments is not { Length: > 0 })
        {
            GD.PushError("Cannot reconstruct: STFT data is empty.");
            return null;
        }

        // Clamp to valid bounds
        timeStart = Mathf.Clamp(timeStart, 0, TimeFrames - 1);
        timeEnd = Mathf.Clamp(timeEnd, timeStart, TimeFrames - 1);
        freqStart = Mathf.Clamp(freqStart, 0, FrequencyBins - 1);
        freqEnd = Mathf.Clamp(freqEnd, freqStart, FrequencyBins - 1);

        int regionTimeFrames = timeEnd - timeStart;
        if (regionTimeFrames <= 0)
        {
            GD.PushWarning("Reconstruction region has zero time frames.");
            return ResourceMapper.ToResource(new DSP.Signal([], SampleRate));
        }

        // Create filtered STFT with only selected region
        var filteredSegments = new StftSegment[regionTimeFrames];

        for (int t = 0; t < regionTimeFrames; t++)
        {
            int sourceTimeIndex = timeStart + t;
            var originalSegment = _stft.Segments[sourceTimeIndex];

            var filteredSpectrum = new FrequencyData[FrequencyBins];

            for (int f = 0; f < FrequencyBins; f++)
            {
                if (f >= freqStart && f < freqEnd)
                {
                    // Keep this frequency bin
                    filteredSpectrum[f] = originalSegment.Spectrum[f];
                }
                else
                {
                    filteredSpectrum[f] = new FrequencyData(
                        originalSegment.Spectrum[f].Frequency,
                        0f,
                        0f
                    );
                }
            }
            filteredSegments[t] = new StftSegment(
                filteredSpectrum,
                originalSegment.StartIndex,
                originalSegment.SampleCount
            );
        }
        var filteredStft = new StftResult(filteredSegments, SampleRate, _stft.SampleCount);
        var reconstructed = Stft.ReconstructSignal(filteredStft);

        return ResourceMapper.ToResource(reconstructed);
    }
    /// <summary>
    /// Reconstructs a region specified by normalized texture coordinates.
    /// </summary>
    public SignalResource ReconstructTextureRegion(Vector2 topLeft, Vector2 bottomRight)
    {
        var startIndex = TextureToStftIndex(topLeft);
        var endIndex = TextureToStftIndex(bottomRight);

        // Ensure proper ordering
        int timeStart = Mathf.Min(startIndex.X, endIndex.X);
        var timeEnd = Mathf.Max(startIndex.X, endIndex.X) + 1;  // +1 for exclusive end

        // Y is inverted: top of texture = high freq, bottom = low freq
        int freqStart = Mathf.Min(startIndex.Y, endIndex.Y);
        int freqEnd = Mathf.Max(startIndex.Y, endIndex.Y) + 1;

        return ReconstructRegion(timeStart, timeEnd, freqStart, freqEnd);
    }
    /// <summary>
    /// Modifies amplitude at a specific STFT point (for editing features).
    /// </summary>
    public void SetAmplitude(int timeIndex, int freqIndex, float newAmplitude)
    {
        if (_stft.Segments is not { Length: > 0})
            return;
        
        if (timeIndex < 0 || timeIndex >= TimeFrames ||
            freqIndex < 0 || freqIndex >= FrequencyBins)
            return;
        
        // Update the Spectrum directly (phase is preserved)
        var spectrum = _stft.Segments[timeIndex].Spectrum;
        spectrum[freqIndex] = new FrequencyData(
            spectrum[freqIndex].Frequency,
            newAmplitude,
            spectrum[freqIndex].Phase   // Keep existing phase
        );
    }
}