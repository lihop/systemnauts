using Godot;
using System;

public class Node : Godot.Node
{   
	[Signal]
	public delegate void Hah();
	// Declare member variables here. Examples:
	// private int a = 2;
	// private string b = "text";

	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		
	}
	
	public void Emit()
	{
		EmitSignal(nameof(Hah));
	}
//  // Called every frame. 'delta' is the elapsed time since the previous frame.
//  public override void _Process(float delta)
//  {
//      
//  }
}
