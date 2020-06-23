{

  training = { config, pkgs, ... }:
  let
    godot = (pkgs.godot.overrideAttrs (oldAttrs: {
      src = pkgs.fetchFromGitHub {
        owner = "lihop";
        repo = "godot";
        rev = "v3.2.2-systemnauts";
        sha256 = "09xqjijm64dil2l74wji6wgbvpac49zcjvcwyzvfza51hqzcdcgr";
        fetchSubmodules = true;
      };
      patches = [];
    })).override({
      server = true;
    });
  in
  {
    nixpkgs.overlays = [ (import ../../overlay.nix) ];

    imports = [ ./users.nix ];

    networking.hostName = "nix";

    networking.firewall.allowedTCPPorts = [ 80 ];
    networking.firewall.allowedUDPPorts = [ 7154 ];

    services.openssh.enable = true;

    environment.variables.TERM = "xterm";
    environment.systemPackages = with pkgs; [
      # Important libs for modules
      libaudit
      libtsm

      godot
      inotify-tools
      socat
      sshfs

      # Terminal testing stuff
      cmatrix
      htop
      lolcat
      nyancat
      sl
      vttest
    ];

    # Allow Godot to bind to port 80.
    #security.wrappers.godot = {
    #  source = "${godot}/bin/godot";
    #  capabilities = "cap_net_bind_service=+eip";
    #};

    # Setup autdit for monitoring files.
    security.auditd.enable = true;
    security.audit = {
      enable = true;
      rules = [
        "-w /root/tmp -p rwxa -k monitor-tmp"
      ];
    };

    environment.etc."audit-config/auditd.conf".text = let
      audit = pkgs.audit.overrideAttrs (oldAttrs: {
        #patches = [ ./auditd-config.patch ] ++ oldAttrs.patches;
      });
    in ''
      write_logs = no
      dispatcher = ${audit}/bin/audispd
      space_left = 1
    '';

    environment.etc."audisp-config/audispd.conf".text = ''
      q_depth = 80
      overflow_action = ignore
      priority_boost = 4
      max_restarts = 10
      name_format = hostname
    '';

    # audispd looks for /etc/localtime that file is created by the following:
    time.timeZone = "Asia/Ho_Chi_Minh";
  };
}
