{
  network.description = "training network";

  training =
    { config, pkgs, ... }:
    { environment.systemPackages = with pkgs; [
        socat
      ];
    };
}
