using System;
using System.Linq;
using Godot.WorldGen;
using System.Collections.Generic;

namespace Godot.WorldGen
{
	public class RoomAtlasTest : WAT.Test
	{
		static private Random random = new Random();

		private RoomAtlas roomAtlas;

		public override void Pre() => roomAtlas = new RoomAtlas();

		[Test]
		public void RoomAtlasCreated() => Assert.IsTrue(roomAtlas != null);

		[Test]
		public void RoomsWithTransformNone()
		{
			Assert.IsEqual(new RoomAtlas.Room("test-n.map").Exits, Directions.North);
			Assert.IsEqual(new RoomAtlas.Room("test-s.map").Exits, Directions.South);
			Assert.IsEqual(new RoomAtlas.Room("test-e.map").Exits, Directions.East);
			Assert.IsEqual(new RoomAtlas.Room("test-w.map").Exits, Directions.West);
			Assert.IsEqual(new RoomAtlas.Room("test-u.map").Exits, Directions.Up);
			Assert.IsEqual(new RoomAtlas.Room("test-d.map").Exits, Directions.Down);
			Assert.IsEqual(new RoomAtlas.Room("test-x.map").Exits, Directions.None);
			Assert.IsEqual(new RoomAtlas.Room("test-nsewud.map").Exits, Directions.North | Directions.South | Directions.East | Directions.West | Directions.Up | Directions.Down);
		}

		[Test]
		public void RoomsWithTransformMirrorX()
		{
			Assert.IsEqual(new RoomAtlas.Room("test-x.map", Transforms.MirrorX).Exits, Directions.None);
			Assert.IsEqual(new RoomAtlas.Room("test-n.map", Transforms.MirrorX).Exits, Directions.South);
			Assert.IsEqual(new RoomAtlas.Room("test-su.map", Transforms.MirrorX).Exits, Directions.North | Directions.Up);
			Assert.IsEqual(new RoomAtlas.Room("test-e.map", Transforms.MirrorX).Exits, Directions.East);
			Assert.IsEqual(new RoomAtlas.Room("test-udn.map", Transforms.MirrorX).Exits, Directions.Up | Directions.Down | Directions.South);
			Assert.IsEqual(new RoomAtlas.Room("test-nsewud.map", Transforms.MirrorX).Exits, Directions.North | Directions.South | Directions.East | Directions.West | Directions.Up | Directions.Down);
		}

		[Test]
		public void RoomsWithTransformMirrorZ()
		{
			Assert.IsEqual(new RoomAtlas.Room("test-x.map", Transforms.MirrorZ).Exits, Directions.None);
			Assert.IsEqual(new RoomAtlas.Room("test-e.map", Transforms.MirrorZ).Exits, Directions.West);
			Assert.IsEqual(new RoomAtlas.Room("test-nw.map", Transforms.MirrorZ).Exits, Directions.North | Directions.East);
			Assert.IsEqual(new RoomAtlas.Room("test-ns.map", Transforms.MirrorZ).Exits, Directions.North | Directions.South);
			Assert.IsEqual(new RoomAtlas.Room("test-eud.map", Transforms.MirrorZ).Exits, Directions.West | Directions.Up | Directions.Down);
			Assert.IsEqual(new RoomAtlas.Room("test-ew.map", Transforms.MirrorZ).Exits, Directions.East | Directions.West);
			Assert.IsEqual(new RoomAtlas.Room("test-nsewud.map", Transforms.MirrorZ).Exits, Directions.North | Directions.South | Directions.East | Directions.West | Directions.Up | Directions.Down);
		}

		[Test]
		public void RoomsWithRotate90()
		{
			Assert.IsEqual(new RoomAtlas.Room("test-x.map", Transforms.Rotate90).Exits, Directions.None);
			Assert.IsEqual(new RoomAtlas.Room("test-e.map", Transforms.Rotate90).Exits, Directions.North);
			Assert.IsEqual(new RoomAtlas.Room("test-swu.map", Transforms.Rotate90).Exits, Directions.East | Directions.South | Directions.Up);
			Assert.IsEqual(new RoomAtlas.Room("test-nsewud.map", Transforms.Rotate90).Exits, Directions.North | Directions.South | Directions.East | Directions.West | Directions.Up | Directions.Down);
		}

		[Test]
		public void RoomsWithMirrorXMirrorZRotate90()
		{
			Assert.IsEqual(new RoomAtlas.Room("test-x.map", Transforms.MirrorX | Transforms.MirrorZ | Transforms.Rotate90).Exits, Directions.None);
			Assert.IsEqual(new RoomAtlas.Room("test-nwu.map", Transforms.MirrorX | Transforms.MirrorZ | Transforms.Rotate90).Exits, Directions.East | Directions.North | Directions.Up);
			Assert.IsEqual(new RoomAtlas.Room("test-nsewud.map", Transforms.MirrorX | Transforms.MirrorZ | Transforms.Rotate90).Exits, Directions.North | Directions.South | Directions.East | Directions.West | Directions.Up | Directions.Down);
		}
	}
}
