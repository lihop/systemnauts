using System.Threading;
using CliWrap;
using Godot;

public class SSHD : Node
{
	[Signal]
	public delegate void SSHDStopped();

	[Signal]
	public delegate void SSHDStarted();

	[Signal]
	public delegate void HostConnected(string ipAddress);

	public override async void _Ready()
	{
		if (!OS.HasFeature("Server"))
			return;

		void StdOutHandler(string line)
		{
			if (line.EndsWith("Started SSH Daemon."))
				Rpc(nameof(EmitSSHDStarted));
			else if (line.EndsWith("Stopped SSH Daemon."))
				Rpc(nameof(EmitSSHDStopped));
			else if (line.Contains("Connection from"))
			{
				var ipAddress = line.Split(" ")[7];
				Rpc(nameof(EmitHostConnected), ipAddress);
			}
		}

		var cmd = Cli.Wrap("journalctl").WithArguments(new[] { "-u", "sshd.service", "-f" }) | (StdOutHandler);

		await cmd.ExecuteAsync();
	}

	[RemoteSync]
	public void EmitSSHDStarted() => EmitSignal(nameof(SSHDStarted));

	[RemoteSync]
	public void EmitSSHDStopped() => EmitSignal(nameof(SSHDStopped));

	[RemoteSync]
	public void EmitHostConnected(string ipAddress) => EmitSignal(nameof(HostConnected), ipAddress);
};
