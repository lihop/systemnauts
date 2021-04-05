using System;
using System.Collections.Generic;
using System.Collections.Immutable;
using System.Linq;


namespace Godot.WorldGen
{
	public class Maze : Reference
	{
		private static Random random = new Random();
		public static Maze New(Vector3 size) => new Maze(size);

		public class MazeConfig : Reference
		{
		}

		private Vector3 size = new Vector3();
		public Vector3 Size { get => size; set => size = new Vector3((int)value.x, (int)value.y, (int)value.z); }
		public int SizeX { get => (int)Size.x; }
		public int SizeY { get => (int)Size.y; }
		public int SizeZ { get => (int)Size.z; }

		public float FollowLastNodeRatio { get; set; }
		public float HorizontalRatio { get; set; }
		public float OpenLoopsRatio { get; set; }

		bool Debug { get; set; } = false;

		private ImmutableDictionary<int, Room> rooms;
		public List<Room> Rooms { get => rooms.Values.ToList(); }

		protected Dictionary<int, Room> OpenRooms { get; } = new Dictionary<int, Room> { };
		protected Dictionary<int, Room> LockedRooms { get; }
		protected Dictionary<int, Room> ClosedRooms { get; private set; }

		private Room lastOpened = null;

		public Resource worldDefinition;

		public Maze() : this(new Vector3(1, 1, 1)) { }

		public Maze(Vector3 size)
		{
			Size = size;

			// Add all rooms to the map.
			var roomsBuilder = ImmutableDictionary.CreateBuilder<int, Room>();
			foreach (var i in Enumerable.Range(0, SizeX * SizeY * SizeZ))
				roomsBuilder.Add(i, new Room(this, i));
			rooms = roomsBuilder.ToImmutable();

			// All rooms start closed.
			ClosedRooms = new Dictionary<int, Room>(rooms);
		}

		public Error Generate()
		{
			// TODO: Add feature rooms.


			// We should have some open rooms by now from adding feature rooms, but in case we don't
			// choose a random room to open.
			if (OpenRooms.Count < 1)
			{
				var room = Enumerable.ToList(rooms.Values)[random.Next(rooms.Count)];
				OpenRooms.Add(room.Index, room);
			}

			while (OpenRooms.Count > 0)
			{
				// Pick an open room by random.
				var room = Enumerable.ToList(OpenRooms.Values)[random.Next(OpenRooms.Count)];

				var closedNeighbors = room.ClosedNeighbors;

				if (closedNeighbors.Count < 1)
				{
					// The room has no neigbors we can expand into.
					// Don't consider it in the future.
					OpenRooms.Remove(room.Index);
				}
				else
				{
					// Find all the neighbors we can expand into.
					var verticalNeighbors = closedNeighbors.Where(neighbor => (room.DirectionTo(neighbor) & (Directions.Up | Directions.Down)) != 0).ToList();
					var horizontalNeighbors = closedNeighbors.Except(verticalNeighbors).ToList();

					// Apply a bias towards horizontal neighbors or less vertical levels.
					var expandHorizontal = false;
					if (horizontalNeighbors.Count > 0 && verticalNeighbors.Count > 0)
						expandHorizontal = random.NextDouble() < HorizontalRatio;
					else
						expandHorizontal = horizontalNeighbors.Count > 0;

					var neighbor = expandHorizontal ? horizontalNeighbors[random.Next(horizontalNeighbors.Count)] : verticalNeighbors[random.Next(verticalNeighbors.Count)];

					// Open the maze to the selected neighbor and vice versa.
					rooms[room.Index].Exits |= room.DirectionTo(neighbor);
					rooms[neighbor.Index].Exits |= neighbor.DirectionTo(room);

					ClosedRooms.Remove(neighbor.Index);
					OpenRooms[neighbor.Index] = neighbor;
					lastOpened = neighbor;
				}
			}

			// Look for opportunities to create loops in the maze by opening eastern exits.
			var easternOpportunities = rooms.Values.ToList()
				.Where(room => (room.Exits & Directions.East) == 0)
				.Where(room => room.Coords.x < (Size.x - 1))
				.Where(room => !rooms[room.NeighborIndices[Directions.East]].Locked)
				.Select(room => (room, Directions.East))
				.ToList();

			// Look for opportunities to create loops in the maze by opening southern exits.
			var southernOpportunities = rooms.Values.ToList()
				.Where(room => (room.Exits & Directions.South) == 0)
				.Where(room => room.Coords.z < (Size.z - 1))
				.Where(room => !rooms[room.NeighborIndices[Directions.South]].Locked)
				.Select(room => (room, direction: Directions.South))
				.ToList();

			List<(Room room, Directions directions)> openLoopOpportunities = easternOpportunities.Concat(southernOpportunities).ToList();
			var opportunitiesToOpen = (int)((OpenLoopsRatio * openLoopOpportunities.Count) + 0.5f);

			foreach (var _ in Enumerable.Range(0, opportunitiesToOpen))
			{
				var opIndex = random.Next(openLoopOpportunities.Count);
				var opportunity = openLoopOpportunities[opIndex];
				var room = opportunity.room;
				var direction = opportunity.directions;
				var neighbor = rooms[opportunity.room.NeighborIndices[direction]];

				room.Exits |= direction;
				neighbor.Exits |= neighbor.DirectionTo(room);

				openLoopOpportunities.RemoveAt(opIndex);
			}

			if (Debug)
			{
				GD.Print($"Opened {opportunitiesToOpen} loops.");

				// Pretty print the final maze from top to bottom.
				foreach (var y in Enumerable.Range(0, SizeY).Reverse().ToList())
				{
					GD.Print($"Floor {y}");

					// From north to south.
					foreach (var z in Enumerable.Range(0, SizeZ))
					{
						List<string> rows = new List<string> { "", "", "" };

						// From west to east.
						foreach (var x in Enumerable.Range(0, SizeX))
						{
							var roomIndex = x + (y * SizeX * SizeZ) + (z * SizeX);
							var room = rooms[roomIndex];
							var prettyString = room.PrettyString();
							rows[0] += prettyString[0];
							rows[1] += prettyString[1];
							rows[2] += prettyString[2];
						}

						foreach (var row in rows)
							GD.Print(row);
					}
				}
			}

			return Error.Ok;
		}

		public class Room : Reference
		{
			public Maze Maze;
			public int Index;

			public ImmutableDictionary<Directions, int> NeighborIndices { get; private set; }

			public Vector3 Coords { get; private set; }

			private Directions exits;
			public Directions Exits
			{
				set
				{
					if (!locked)
						exits = value;
					else
						GD.PushWarning("Cannot set Exits of a locked room!");
				}
				get => exits;
			}

			private bool locked = false;
			public bool Locked
			{
				set
				{
					locked = value;

					if (locked)
						Maze.LockedRooms[Index] = this;
					else
						Maze.LockedRooms.Remove(Index);
				}
				get => locked;
			}

			public List<Room> ClosedNeighbors
			{
				get => NeighborIndices.Values
					.Where(index => index != -1)
					.Where(index => Maze.ClosedRooms.ContainsKey(index))
					.Select(index => Maze.ClosedRooms[index])
					.ToList();
			}

			public Room(Maze maze, int index)
			{
				Maze = maze;
				Index = index;

				// Calculate Coords of room with this index.
				var x = Index % Maze.SizeX;
				var y = ((Index / Maze.SizeX) / Maze.SizeZ) % Maze.SizeY;
				var z = (Index / Maze.SizeX) % Maze.SizeZ;

				Coords = new Vector3(x, y, z);

				// Calculate the indices of neighboring rooms.
				// Directions without a neighbor (i.e. on the edges of the map) will use -1 for the room index.
				NeighborIndices = new Dictionary<Directions, int> {
					{Directions.None, -1},
					{Directions.North, Coords.z > 0 ? index - Maze.SizeX : -1},
					{Directions.South, Coords.z < Maze.SizeZ - 1 ? index + Maze.SizeX : -1},
					{Directions.East, Coords.x < Maze.SizeX - 1 ? index + 1 : -1},
					{Directions.West, Coords.x > 0 ? index - 1 : -1},
					{Directions.Up, Coords.y < Maze.SizeY - 1 ? index + Maze.SizeX * Maze.SizeZ : -1},
					{Directions.Down, Coords.y > 0 ? index - Maze.SizeX * Maze.SizeZ : -1},
				}.ToImmutableDictionary();
			}

			public Directions DirectionTo(Room room)
			{
				foreach (var item in NeighborIndices)
				{
					if (item.Value == room.Index)
						return item.Key;
				}

				return Directions.None;
			}

			public List<string> PrettyString()
			{
				// Create a string representation of a standard room with no exits.
				var room = new string[3][] {
				new string[7] {"", "+", "-", "-", "-", "+", ""},
				new string[7] {"", "|", " ", " ", " ", "|", ""},
				new string[7] {"", "+", "-", "-", "-", "+", ""},
			};

				// If the room is locked, mark it with an L. 
				if (Locked)
					room[1][3] = "L";

				// Add exits.
				if (Exits != Directions.None)
				{
					if ((Exits & Directions.North) != 0)
					{
						room[0][2] = " ";
						room[0][3] = " ";
						room[0][4] = " ";
					}

					if ((Exits & Directions.South) != 0)
					{
						room[2][2] = " ";
						room[2][3] = " ";
						room[2][4] = " ";
					}

					if ((Exits & Directions.East) != 0)
						room[1][5] = " ";

					if ((Exits & Directions.West) != 0)
						room[1][1] = " ";

					if ((Exits & Directions.Up) != 0)
						room[1][2] = "^";

					if ((Exits & Directions.Down) != 0)
						room[1][4] = "v";
				}

				return new List<string> {
					string.Join("", room[0]),
					string.Join("", room[1]),
					string.Join("", room[2])
				};
			}
		}
	}
}
