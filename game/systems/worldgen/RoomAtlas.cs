using System;
using System.Collections.Generic;
using System.Collections.Immutable;
using System.Linq;
using System.Text.RegularExpressions;

namespace Godot.WorldGen
{
	class InvalidRoomFilenameException : Exception
	{
		public InvalidRoomFilenameException() { }
		public InvalidRoomFilenameException(string filename)
			: base($"Could not determine exits from room with filename '{filename}'. Did you name the file correctly?") { }
	}

	public class RoomAtlas : Reference
	{
		static public Random random = new Random();
		static int allTransforms = (int)(Transforms.MirrorX | Transforms.MirrorZ | Transforms.Rotate90);
		static public RoomAtlas New(List<string> filenames) => new RoomAtlas(filenames);

		static ImmutableDictionary<char, Directions> CharDirectionMap = new Dictionary<char, Directions>
		{
			{'n', Directions.North},
			{'s', Directions.South},
			{'e', Directions.East},
			{'w', Directions.West},
			{'u', Directions.Up},
			{'d', Directions.Down},
			{'x', Directions.None},
		}.ToImmutableDictionary();

		public List<Room> Rooms = new List<Room> { };

		public RoomAtlas()
		{
		}

		public RoomAtlas(List<string> filenames = default(List<string>))
		{
			foreach (var filename in filenames)
				AddRoom(filename);
		}

		public void AddRoom(string filename)
		{
			foreach (Transforms transform in Enumerable.Range(0, allTransforms + 1).Cast<Transforms>())
			{
				try
				{
					var room = new Room(filename, transform);
					Rooms.Add(room);
				}
				catch (InvalidRoomFilenameException ex)
				{
					GD.PushWarning($"Skipping room: {ex.Message}");
					break;
				}
			}
		}

		public void RemoveRoom(string filename)
		{
			foreach (var room in Rooms.Where(room => room.Filename == filename).ToList())
				Rooms.Remove(room);
		}

		public Room GetRandomRoomWithExits(Directions exits)
		{
			var rooms = Rooms.Where(room => room.Exits == exits).ToList();

			if (rooms.Count < 1)
			{
				GD.PushWarning($"Cannot find room fitting exits {exits}.");
				return null;
			}
			else
			{
				return rooms.ElementAt(random.Next(rooms.Count));
			}
		}

		public class Room : Reference
		{
			private static Regex ExitsRegex = new Regex(@"(?<exit_chars>[nsewudx]{1,6})(-\d+)*\.(map|tscn)", RegexOptions.Compiled);

			public Directions Exits { get; private set; } = Directions.None;
			public Transforms Transforms { get; private set; } = Transforms.None;
			public string Filename { get; private set; }

			public Room(string filename) : this(filename, Transforms.None) { }

			public Room(string filename, Transforms transforms = Transforms.None)
			{
				Filename = filename;
				Transforms = transforms;

				// Determine the rooms exits based on its filename. 
				var exits = Directions.None;
				var exitChars = ExitsRegex.Match(filename).Groups["exit_chars"].Value;

				if (exitChars.Empty())
					throw new InvalidRoomFilenameException(filename);

				foreach (char c in exitChars)
					exits |= CharDirectionMap[c];

				// Apply transforms.
				Exits = exits & (Directions.Up | Directions.Down);

				if ((Transforms & Transforms.MirrorX) != 0)
				{
					if ((exits & Directions.North) != 0) Exits |= Directions.South;
					if ((exits & Directions.South) != 0) Exits |= Directions.North;
				}
				else
				{
					Exits |= exits & (Directions.North | Directions.South);
				}

				if ((Transforms & Transforms.MirrorZ) != 0)
				{
					if ((exits & Directions.East) != 0) Exits |= Directions.West;
					if ((exits & Directions.West) != 0) Exits |= Directions.East;
				}
				else
				{
					Exits |= exits & (Directions.East | Directions.West);
				}

				if ((Transforms & Transforms.Rotate90) != 0)
				{
					var tmp = Exits;
					Exits &= (Directions.Up | Directions.Down);

					if ((tmp & Directions.East) != 0) Exits |= Directions.North;
					if ((tmp & Directions.West) != 0) Exits |= Directions.South;
					if ((tmp & Directions.North) != 0) Exits |= Directions.West;
					if ((tmp & Directions.South) != 0) Exits |= Directions.East;
				}
			}
		}
	}
}
