{
  resources.sshKeyPairs.ssh-key = {};

  machine = { config, pkgs, ... }: {
    networking.hostName = "nix";

    imports = [
      ./users.nix
    ];

    services.openssh.enable = true;

    environment.variables.TERM = "xterm";
    environment.systemPackages = with pkgs; [
      (godot.override { server = true; })
      sshfs
    ];

    deployment = {
      targetEnv = "digitalOcean";
      digitalOcean = {
        enableIpv6 = false;
        region = "sgp1";
        size = "512mb";
      };
    };
  };
}
