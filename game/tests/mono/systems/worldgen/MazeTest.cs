using System;
using Godot;
using System.Linq;
using Godot.WorldGen;

public class MazeTest : WAT.Test
{
	static private Random random = new Random();

	[Test]
	public void TestMazeCreated()
	{
		var maze = new Maze();
		Assert.IsTrue(maze != null);
	}

	[Test]
	public void TestNumberOfRooms()
	{
		Assert.IsEqual(new Maze().Rooms.Count, 1, "A 1x1x1 maze has 1 room");

		foreach (var i in Enumerable.Range(0, 5))
		{
			var x = random.Next(1, 10);
			var y = random.Next(1, 10);
			var z = random.Next(1, 10);
			var expected = x * y * z;

			Assert.IsEqual(new Maze(new Vector3(x, y, z)).Rooms.Count, expected, $"A {x}x{y}x{z} maze has {expected} rooms");
		}
	}

	[Test]
	public void TestRoomNeighborIndicesOfSingleRoomMap()
	{
		var maze = new Maze(new Vector3(1, 1, 1));
		var room = maze.Rooms[0];

		Assert.IsEqual(room.NeighborIndices[Directions.North], -1, "No northern neighbor");
		Assert.IsEqual(room.NeighborIndices[Directions.South], -1, "No southern neighbor");
		Assert.IsEqual(room.NeighborIndices[Directions.East], -1, "No eastern neighbor");
		Assert.IsEqual(room.NeighborIndices[Directions.West], -1, "No western neighbor");
		Assert.IsEqual(room.NeighborIndices[Directions.Up], -1, "No neighbor above");
		Assert.IsEqual(room.NeighborIndices[Directions.Down], -1, "No neighbor below");
	}

	[Test]
	public void TestCenterRoomNeighborIndicesOfSingleStoreyMap()
	{
		var maze = new Maze(new Vector3(3, 1, 3));
		var room = maze.Rooms[4];

		Assert.IsEqual(room.NeighborIndices[Directions.North], 1, "Northern neighbor index");
		Assert.IsEqual(room.NeighborIndices[Directions.South], 7, "Southern neighbor index");
		Assert.IsEqual(room.NeighborIndices[Directions.East], 5, "Eastern neighbor index");
		Assert.IsEqual(room.NeighborIndices[Directions.West], 3, "Western neighbor index");
		Assert.IsEqual(room.NeighborIndices[Directions.Up], -1, "No neighbor above");
		Assert.IsEqual(room.NeighborIndices[Directions.Down], -1, "No neighbor below");
	}

	[Test]
	public void TestRoomDirectionTo()
	{
		var maze = new Maze(new Vector3(2, 1, 2));

		Assert.IsEqual(maze.Rooms[0].DirectionTo(maze.Rooms[1]), Directions.East, "Room 1 is east of room 0");
		Assert.IsEqual(maze.Rooms[0].DirectionTo(maze.Rooms[2]), Directions.South, "Room 2 is south of room 0");
		Assert.IsEqual(maze.Rooms[0].DirectionTo(maze.Rooms[3]), Directions.None, "Room 3 is not adjacent to room 0");

		Assert.IsEqual(maze.Rooms[2].DirectionTo(maze.Rooms[0]), Directions.North, "Room 0 is north of room 2");
		Assert.IsEqual(maze.Rooms[2].DirectionTo(maze.Rooms[1]), Directions.None, "Room 1 is not adjacent to room 2");
		Assert.IsEqual(maze.Rooms[2].DirectionTo(maze.Rooms[3]), Directions.East, "Room 3 is east of room 2");

		Assert.IsEqual(maze.Rooms[3].DirectionTo(maze.Rooms[0]), Directions.None, "Room 0 is not adjacent to room 3");
		Assert.IsEqual(maze.Rooms[3].DirectionTo(maze.Rooms[1]), Directions.North, "Room 1 is north of room 3");
		Assert.IsEqual(maze.Rooms[3].DirectionTo(maze.Rooms[2]), Directions.West, "Room 2 is west of room 3");
	}
}
