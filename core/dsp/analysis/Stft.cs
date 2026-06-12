using Godot;
using System;

namespace DSP;

[GlobalClass]
public partial class Stft : RefCounted
{
    public static StftResult Compute(Signal signal, int samplesPerSegment, bool useFft = true)
    {
        ArgumentNullException.ThrowIfNull(signal.Samples);

        if (signal.SampleRate <= 0)
            throw new ArgumentOutOfRangeException(nameof(signal.SampleRate));

        if (samplesPerSegment <= 0)
            throw new ArgumentOutOfRangeException(nameof(samplesPerSegment));

        if (signal.Samples.Length == 0)
            return new StftResult([], signal.SampleRate, 0);

        int segmentCount = (signal.Samples.Length + samplesPerSegment - 1) / samplesPerSegment;
        var segments = new StftSegment[segmentCount];
        var paddedSegmentBuffer = new float[samplesPerSegment];

        for (int segmentIndex = 0; segmentIndex < segmentCount; segmentIndex++)
        {
            int offset = segmentIndex * samplesPerSegment;
            int segmentLength = Math.Min(samplesPerSegment, signal.SampleCount - offset);

            Array.Clear(paddedSegmentBuffer, 0, paddedSegmentBuffer.Length);
            signal.Samples.AsSpan(offset, segmentLength).CopyTo(paddedSegmentBuffer);
            
            FrequencyData[] waves;
            if (useFft) waves = Fft.Compute(paddedSegmentBuffer, signal.SampleRate);
            else waves = Dft.Compute(paddedSegmentBuffer, signal.SampleRate);
            
            segments[segmentIndex] = new StftSegment(waves, offset, segmentLength);
        }

        return new StftResult(segments, signal.SampleRate, signal.SampleCount);
    }

    public static StftResultResource ComputeResource(SignalResource signal, int samplesPerSegment) =>
        ResourceMapper.ToResource(Compute(ResourceMapper.ToDomain(signal), samplesPerSegment));
    
    public static Signal ReconstructSignal(StftResult stft)
    {
        float[] allSamples = new float[stft.SampleCount];

        foreach (StftSegment segment in stft.Segments)
        {
            float[] segmentSamples = SignalGenerator.GenerateSignal(segment.Spectrum, stft.SampleRate, segment.SampleCount);

            // Add reconstructed segment into full reconstruction
            for (int i = 0; i < segment.SampleCount; i++)
            {
                allSamples[i + segment.StartIndex] += segmentSamples[i];
            }
        }

        return new Signal(allSamples, stft.SampleRate);
    }
    
    public static SignalResource ReconstructSignalResource(StftResultResource stftResource)
    {
        StftResult stftResult = ResourceMapper.ToDomain(stftResource);
        return ResourceMapper.ToResource(ReconstructSignal(stftResult));
        
    }
}
