{
  system = { config, pkgs, ... }:
  let
    godot = (pkgs.godot.overrideAttrs (oldAttrs: {
      # Git repo custom build.
      src = pkgs.fetchFromGitHub {
        owner = "lihop";
        repo = "godot";
        rev = "734694e2be490161296ca93e02b3dd25eb0f996f";
        sha256 = "1w2shqwhz27n02d95djcr3w1kchbaihshbw185c2nxgcxx2h1l57";
        fetchSubmodules = true;
      };

      # Local sources custom build.
      #src = /home/leroy/projects/godot;
      #patches = []; # Already applied.
      #installPhase = ''
      #  mkdir -p "$out/bin"
      #  cp bin/godot_server.*.64 $out/bin/godot

      #  mkdir "$dev"
      #  cp -r modules/gdnative/include $dev

      #  mkdir -p "$man/share/man/man6"
      #  cp misc/dist/linux/godot.6 "$man/share/man/man6/"
  
      #  mkdir -p "$out"/share/{applications,icons/hicolor/scalable/apps}
      #  cp misc/dist/linux/org.godotengine.Godot.desktop "$out/share/applications/"
      #  cp icon.svg "$out/share/icons/hicolor/scalable/apps/godot.svg"
      #  cp icon.png "$out/share/icons/godot.png"
      #  substituteInPlace "$out/share/applications/org.godotengine.Godot.desktop" \
      #    --replace "Exec=godot" "Exec=$out/bin/godot"
      #'';
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

    # Set the pid_max param so we can safely represent all processes on a 256m cube.
    # Each pid will have a 16x16 room.
    # Note: The minimum pid_max is 301.
    #boot.kernel.sysctl."pid_max" = 8820;
    boot.kernel.sysctl."kernel.pid_max" = 1536;

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
