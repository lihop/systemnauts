using CliWrap;
using Godot;

public class ZMap : Node
{
	[Signal]
	public delegate void HostFound(string ip_address);
	
	public async void Scan()
	{
		void StdOutHandler(string ip_address) => EmitSignal(nameof(HostFound), ip_address);

		var cmd = Cli.Wrap("zmap").WithArguments(new[] {"-p", "80", "-q", "-v0", "-n", "256"}) | (StdOutHandler);

		var result = await cmd.ExecuteAsync();
	}
}
