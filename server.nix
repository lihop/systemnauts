{
  resources.sshKeyPairs.ssh-key = {};

  machine = { config, pkgs, ... }:
  let
    godot = pkgs.godot.override { server = true; };
  in
  {
    imports = [
      ./users.nix
    ];

    networking.hostName = "nix";

    networking.firewall.allowedTCPPorts = [ 80 ];
    networking.firewall.allowedUDPPorts = [ 45122 ];

    services.openssh.enable = true;

    environment.variables.TERM = "xterm";
    environment.systemPackages = with pkgs; [
      godot
      inotify-tools
      sshfs
    ];

    deployment = {
      targetEnv = "digitalOcean";
      digitalOcean = {
        enableIpv6 = false;
        region = "sgp1";
        size = "1gb";
      };
    };

    # Allow Godot to bind to port 80.
    security.wrappers.godot = {
      source = "${godot}/bin/godot";
      capabilities = "cap_net_bind_service=+eip";
    };
  };
}
