using System;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Threading.Tasks;
using Godot;
using CommandLine;

public class CLIThing : Node
{
    // Declare member variables here. Examples:
    // private int a = 2;
    // private string b = "text";

    private bool quit_requested = false;

    // Called when the node enters the scene tree for the first time.
    public override void _Ready()
    {
        RunREPL();
    }

    class AutoCompletionHandler : IAutoCompleteHandler
    {
        public char[] Separators { get; set; } = new char[] { ' ', '.', '/' };

        public string[] GetSuggestions(string text, int index)
        {
            if (text.StartsWith("s"))
                return new string[] { "shutdown" };
            else
                return null;
        }
    }

    [Verb("shutdown", HelpText = "Shutdown the server. State will be saved.")]
    class ShutdownOptions
    {
    }

    [Verb("list", HelpText = "List players currently in the server.")]
    class ListPlayerOptions
    {
    }

    private static Type[] LoadVerbs()
    {
        return Assembly.GetExecutingAssembly().GetTypes()
            .Where(t => t.GetCustomAttribute<VerbAttribute>() != null).ToArray();
    }

    public async void RunREPL()
    {
        ReadLine.AutoCompletionHandler = new AutoCompletionHandler();
        ReadLine.HistoryEnabled = true;

        var types = LoadVerbs();

        while (!quit_requested)
        {
            var line = await Task.Run(() => ReadLine.Read("> "));

            string[] args = line.Split(null);

            Parser.Default.ParseArguments(args, types)
                .WithParsed(Run);
        }

        Console.WriteLine("Bye Bye");
        GetTree().Quit();
    }

    private void Run(object obj)
    {
        switch (obj)
        {
            case ShutdownOptions s:
                GD.Print("Server shutting down...");
                quit_requested = true;
                break;
            case ListPlayerOptions lp:
                var players = GetTree().GetNodesInGroup("players");

                GD.Print($"Number of players in server: {players.Count}");

                foreach (var player in GetTree().GetNodesInGroup("players"))
                {
                    GD.Print(player);
                }
                break;
        }
    }

    //  // Called every frame. 'delta' is the elapsed time since the previous frame.
    //  public override void _Process(float delta)
    //  {
    //      
    //  }
}
