using Godot;
using System;

namespace DSP;

[GlobalClass]
public partial class StftResultResource : Resource
{
    [Export]
    public StftSegmentResource[] Segments { get; set; } = [];

    [Export]
    public int SampleRate { get; set; }

    [Export]
    public int SampleCount { get; set; }
    public int FrequencyCount => Segments[0].Spectrum.Length;
    public float FrequencySpacing => Segments[0].Spectrum[1].Frequency - Segments[0].Spectrum[0].Frequency;
    public float SegmentDuration => Segments[0].SampleCount / (float)SampleRate;

    public StftResultResource() { }

    public StftResultResource(StftSegmentResource[] segments, int sampleRate, int sampleCount)
    {
        Segments = segments;
        SampleRate = sampleRate;
        SampleCount = sampleCount;
    }
}
