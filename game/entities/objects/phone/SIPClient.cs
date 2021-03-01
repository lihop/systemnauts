using System.Net;
using Godot;
using SIPSorcery.Media;
using SIPSorcery.SIP;
using SIPSorcery.SIP.App;

public class SIPClient : Node
{
	[Signal]
	public delegate void CallIncoming();
	[Signal]
	public delegate void CallCancelled();
	// Declare member variables here. Examples:
	// private int a = 2;
	// private string b = "text";
	private string destination = "sip:100@192.168.56.127";
	private string domain = "192.168.56.127";
	private string username = "6001";
	private string password = "6001";
	private int expiry = 120;
	private int sipListenPort = 5060;

	private SIPServerUserAgent serverUserAgent;

	private SIPTransport sipTransport = new SIPTransport();
	private SIPUserAgent userAgent;
	private SIPRegistrationUserAgent regUserAgent;

	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		sipTransport.AddSIPChannel(new SIPUDPChannel(new IPEndPoint(IPAddress.Any, sipListenPort)));

		userAgent = new SIPUserAgent(sipTransport, null, true);

		userAgent.ServerCallCancelled += (uas) =>
		{
			GD.Print("Incoming call cancelled by remote party.");

			EmitSignal(nameof(CallCancelled));

			serverUserAgent = null;
		};
		userAgent.OnCallHungup += (dialog) => GD.Print("Call was hungup.");
		userAgent.OnIncomingCall += (ua, req) =>
		{
			GD.Print("Call incoming!");

			EmitSignal(nameof(CallIncoming));

			serverUserAgent = userAgent.AcceptCall(req);
		};

		// Answer
		//await userAgent.Answer(uas, mediaSession);

		RegisterUserAgent();
		//MakeCall();
	}

	public async void Answer()
	{
		await userAgent.Answer(serverUserAgent, null);
	}

	public void RegisterUserAgent()
	{
		GD.Print("Registering user agent...");

		//sipTransport = new SIPTransport();

		EnableVerboseLogs(sipTransport);

		regUserAgent = new SIPRegistrationUserAgent(sipTransport, username, password, domain, expiry);

		regUserAgent.RegistrationFailed += (uri, err) => GD.PushError($"{uri.ToString()}: {err}");
		regUserAgent.RegistrationTemporaryFailure += (uri, msg) => GD.PushWarning($"{uri.ToString()}: {msg}");
		regUserAgent.RegistrationRemoved += (uri) => GD.PushError($"{uri.ToString()} registration failed.");
		regUserAgent.RegistrationSuccessful += (uri) => GD.Print($"{uri.ToString()} registration succeeded.");

		regUserAgent.Start();
	}

	public async void MakeCall()
	{
		GD.Print("Attempting to make call...");

		var sipTransport = new SIPTransport();
		var userAgent = new SIPUserAgent(sipTransport, null);

		EnableVerboseLogs(sipTransport);

		//userAgent.OnIncomingCall += async (ua, req) =>
		//{
		//    var uas = userAgent.AcceptCall(req);
		//    await userAgent.Answer(uas, null);
		//};

		var mediaSession = new AudioSendOnlyMediaSession();

		bool callResult = await userAgent.Call(destination, username, password, mediaSession);

		if (callResult)
		{
			await mediaSession.Start();
			GD.Print("Call attempt successful.");
		}
		else
		{
			GD.Print("Call attempt failed.");
		}
	}

	private void EnableVerboseLogs(SIPTransport sipTransport)
	{
	}

	//  // Called every frame. 'delta' is the elapsed time since the previous frame.
	//  public override void _Process(float delta)
	//  {
	//      
	//  }

	public override void _ExitTree()
	{
		regUserAgent.Stop();
		sipTransport.Shutdown();
	}
}
