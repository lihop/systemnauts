using System;

namespace Godot.WorldGen
{
	[Flags]
	public enum Directions
	{
		None = 0,
		North = 1 << 0,
		South = 1 << 1,
		East = 1 << 2,
		West = 1 << 3,
		Up = 1 << 4,
		Down = 1 << 5,
	}
}
