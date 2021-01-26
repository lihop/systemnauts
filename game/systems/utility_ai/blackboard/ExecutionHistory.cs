using System.Collections.Immutable;
using Godot;

/// <summary>
/// Keeps track of actions executed by actors.
/// <summary/>
///
/// Consider: Maybe we should set a TTL for records.
/// Also, maybe some records are more imporntant (i.e. memorable) than others.
/// There will be many actions happening every second, so this history might
/// become big and slow quickly if we don't curate it.
public class ExecutionHistory : Reference
{
	private ImmutableQueue<Record> history = ImmutableQueue.Create<Record>();

	public readonly struct Record
	{
		readonly Node Action; // The action executed.
		readonly Node Actor; // Who executed the action.
		readonly uint Time; // When the action was executed.

		public Record(Node action, Node actor)
		{
			Action = action;
			Actor = actor;
			Time = OS.GetTicksMsec(); // TODO: Account for saved games.
		}
	}

	public void AppendAction(Node action, Node actor)
	{
		var record = new Record(action, actor);
		history.Enqueue(record);
	}

	public ExecutionHistory() { }
}
