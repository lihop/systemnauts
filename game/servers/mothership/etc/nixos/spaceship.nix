let
  mothership = { config, pkgs, ... }: {
    services.openssh = {
      enable = true;
      passwordAuthentication = true;
    };

    # Web server
    networking.firewall.allowedTCPPorts = [ 22 443 80 ];
    networking.firewall.allowedUDPPorts = [ 1970 ];
    services.nginx = {
      enable = true;
      virtualHosts."ss.nix.nz" = {
        root = "/var/www/html";
      };
    };

    environment = {
      variables = {
        TERM = "xterm";
      };
      systemPackages = with pkgs; [
        # Game.
        zmap

        # Development.
        busybox
        git
        git-lfs
        htop
        sshfs
        vim
      ];
    };

    users.users.root.openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC8tOhj726PYsM2w46IPRc+v/NgEhHJjw+VjmEmOHEX3+XhYU8DKvomNWajggpWC9sDhpBDey028Vv25hCY1tin31dwCM6KWeKJ0HIeM4iUbB1w6CwJz+Xee9wmkqRVLd0mH9CgJ9auanY9XWGYiJisG6dR1xVkoF2fDXe+j4VQ4s4Ai5hVCiC1nGq4fxroTOEzUol/mEtmuGZOiYrXj84HycASf1yACu1EhZa9cj6QsEajAT4NKf9+6lnRK6z2UeUvrpeabgJ5JdBTjg454IwfIAtJ5ZQ3h17Zco3uZ6ZGlEjOfPqAssuBTW1tDCNEQVUPFB6zUiXD0N1WvPQ0DtKqmwCpIITKt6jX+BV+hrtB7gp9itByEOFDJqziZjd6EDj8l7O4D/YzSGuPz1xS9NJnb0I7S7WG6ABNm3usDb1ta+ZW5olN+66Wj7aOK+ELDysXLJEKOVLmNtyxNriR7vUxEDsJ7R8PF9KUk9f7RuqLcS4dCKh9V635T6NKHCO3Ru9HdyvHMLhzvAzWdOBkRqIJ8u9wPhDRYdIAHICZdYE3LpY4RcZ2wui8+dt5KplbUbpaOhEc41wfuCaanOXN4HgBuLBcuGBqnAHKmCz5+7x5ePlfokiCLxvOoR3nYywdHKXfhU8Vhw1vpwSyg2j0meL1mI4rdZvm55E3XIgdnU+pXw== leroy@laptop"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCn9tdOR33GVq+T708WDwsNm0BDH9uAl2MwqGCBU+mHlPTJiToJr8NI2MFO8K7i85HNfG+jXu5nFY10myXRGY/5Mz3qc3jXMt2VTd25q5i7mn1lgTw9YiWcCEoIsn/FGBH2OU7FthfCBKY/vnqBzSK5viVFCFhhHAFWcrrcYjaryu1iVuYWQgw6QCyY4YxU7niDhRoC+ep94Qgsvrof2/pnRJkOVFRKTakqdcUNVfx2VDufFgDgni79fvuSvOMUliiHGEzTb0O95aVjpS0KfRoJTunMYl+kvrFCtLIs4eFPRiChnNkRuECffyFmX2u5ORN9RYoaMCu/1uX0tjbyWNP/bU6YEihofGV+3PiJzgsjb4B7rpNZyxFZAOuL5dONU4ZFNvfSeSNA7pPj8bzoRjfT9DeofAmiJEFcDEywi7+ArSziUKLeU79NHkGDqnIyavxnEerHX8MpcKnDHU9qAU2A/UhbsqqhogGEUgbA713b94ecaaGABl3ZuvxssthHtKar6YIFgfTiwoMjlY72m691xHYRkwUJyjOOgkT5ZdrYzb7zZ3tcPkQSrt6dRVcwvqOnGYDudSTaj/2uAPJeG+YSTbp2qIZaJtgNXRIQqKLgSjUnh1VWxPYy/5Hre1k+GRX+yXg4MfMkP2qsfXoRhb9+AnKQnkAKvmAWk4wvZ6KwrQ== root@ss.nix.nz"
    ];

    nix = {
      package = pkgs.nixFlakes;
    };

    nix.extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
in
{
  network.description = "Systemnauts dev";
  vbox = mothership;
  do = mothership;
}
