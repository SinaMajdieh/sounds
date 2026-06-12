using Godot;
using System;

namespace DSP;

[GlobalClass]
public partial class StftSegmentResource : Resource
{
    [Export]
    public FrequencyDataResource[] Spectrum { get; set; } = [];

    [Export]
    public int StartIndex { get; set; }

    [Export]
    public int SampleCount { get; set; }

    public StftSegmentResource() { }

    public StftSegmentResource(FrequencyDataResource[] spectrum, int startIndex, int sampleCount)
    {
        Spectrum = spectrum;
        StartIndex = startIndex;
        SampleCount = sampleCount;
    }
}
