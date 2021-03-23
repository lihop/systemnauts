{
  vultr = { config, pkgs, ... }: {
    networking.firewall.allowedTCPPorts = [ 80 443 ];
    services.nginx = {
      enable = true;
      virtualHosts."ss.nix.nz" = {
        forceSSL = true;
        enableACME = true;
        locations."/git/".proxyPass = "http://localhost:3000/";
        extraConfig = ''
            client_max_body_size 200M;
        '';
      };
    };

    security.acme = {
      acceptTerms = true;
      email = "webmaster@leroy.geek.nz";
    };

    services.gitea = {
      enable = true;
      lfs.enable = true;
      rootUrl = "https://ss.nix.nz/git/";
      disableRegistration = true;
    };
  };
}
