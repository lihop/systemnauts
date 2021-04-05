using System;

namespace Godot.WorldGen
{
    [Flags]
    public enum Transforms
    {
        None = 0,
        MirrorX = 1 << 0,
        MirrorZ = 1 << 1,
        Rotate90 = 1 << 2,
    }
}
