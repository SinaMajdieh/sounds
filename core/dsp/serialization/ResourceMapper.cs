using System;

namespace DSP;

public static class ResourceMapper
{
    // --- Domain -> Resource ---

    public static SignalResource ToResource(Signal signal) =>
        new(signal.Samples, signal.SampleRate);

    public static FrequencyDataResource ToResource(FrequencyData data) =>
        new(data.Frequency, data.Amplitude, data.Phase);

    public static FrequencyDataResource[] ToResource(FrequencyData[] data)
    {
        ArgumentNullException.ThrowIfNull(data);

        var result = new FrequencyDataResource[data.Length];
        for (int i = 0; i < data.Length; i++)
        {
            result[i] = ToResource(data[i]);
        }

        return result;
    }

    public static StftSegmentResource ToResource(StftSegment segment) =>
        new(ToResource(segment.Spectrum), segment.StartIndex, segment.SampleCount);

    public static StftSegmentResource[] ToResource(StftSegment[] segments)
    {
        ArgumentNullException.ThrowIfNull(segments);

        var result = new StftSegmentResource[segments.Length];
        for (int i = 0; i < segments.Length; i++)
        {
            result[i] = ToResource(segments[i]);
        }

        return result;
    }

    public static StftResultResource ToResource(StftResult result) =>
        new(ToResource(result.Segments), result.SampleRate, result.SampleCount);

    // --- Resource -> Domain ---

    public static Signal ToDomain(SignalResource resource)
    {
        ArgumentNullException.ThrowIfNull(resource);
        return new(resource.Samples, resource.SampleRate);
    }

    public static StftSegment ToDomain(StftSegmentResource resource) =>
        new(ToDomain(resource.Spectrum), resource.StartIndex, resource.SampleCount);

    public static StftSegment[] ToDomain(StftSegmentResource[] segments)
    {
        ArgumentNullException.ThrowIfNull(segments);

        var result = new StftSegment[segments.Length];
        for (int i = 0; i < segments.Length; i++)
        {
            result[i] = ToDomain(segments[i]);
        }

        return result;
    }

    public static StftResult ToDomain(StftResultResource resource) =>
        new(ToDomain(resource.Segments), resource.SampleRate, resource.SampleCount);

    public static FrequencyData ToDomain(FrequencyDataResource resource)
    {
        ArgumentNullException.ThrowIfNull(resource);
        return new FrequencyData(resource.Frequency, resource.Amplitude, resource.Phase);
    }

    public static FrequencyData[] ToDomain(FrequencyDataResource[] resources)
    {
        ArgumentNullException.ThrowIfNull(resources);

        var result = new FrequencyData[resources.Length];
        for (int i = 0; i < resources.Length; i++)
        {
            result[i] = ToDomain(resources[i]);
        }

        return result;
    }
}
