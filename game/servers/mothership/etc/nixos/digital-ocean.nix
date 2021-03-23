{
  resources.sshKeyPairs.ssh-key = {
    publicKey = builtins.readFile ~/.ssh/id_rsa.pub;
    privateKey = builtins.readFile ~/.ssh/id_rsa;
  };

  do = { config, pkgs, ... }: {
    imports = [
      ./systemd-digitalocean/module.nix
    ];
    
    deployment.targetEnv = "droplet";
    deployment.droplet.enableIpv6 = true;
    deployment.droplet.region = "sgp1";
    deployment.droplet.size = "s-1vcpu-1gb-intel";

    services.do-agent.enable = true;
  };
}
