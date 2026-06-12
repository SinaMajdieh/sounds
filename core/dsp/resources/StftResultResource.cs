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

    public StftResultResource() { }

    public StftResultResource(StftSegmentResource[] segments, int sampleRate, int sampleCount)
    {
        Segments = segments;
        SampleRate = sampleRate;
        SampleCount = sampleCount;
    }
}
