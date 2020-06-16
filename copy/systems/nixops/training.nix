{
  training = { config, pkgs, ... }:
  let
    godot = (pkgs.godot.overrideAttrs (oldAttrs: {
      src = pkgs.fetchFromGitHub {
        owner = "lihop";
        repo = "godot";
        rev = "734694e2be490161296ca93e02b3dd25eb0f996f";
        sha256 = "1w2shqwhz27n02d95djcr3w1kchbaihshbw185c2nxgcxx2h1l57";
        fetchSubmodules = true;
      };
    })).override({
      server = true;
    });
  in
  {
    imports = [
      ./users.nix
    ];

    networking.hostName = "nix";

    networking.firewall.allowedTCPPorts = [ 80 ];
    networking.firewall.allowedUDPPorts = [ 7154 ];

    services.openssh.enable = true;

    environment.variables.TERM = "xterm";
    environment.systemPackages = with pkgs; [
      godot
      inotify-tools
      socat
      sshfs
    ];

    # Allow Godot to bind to port 80.
    #security.wrappers.godot = {
    #  source = "${godot}/bin/godot";
    #  capabilities = "cap_net_bind_service=+eip";
    #};
  };
}
