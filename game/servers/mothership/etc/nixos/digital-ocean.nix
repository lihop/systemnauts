{
  resources.sshKeyPairs.ssh-key = {
    publicKey = builtins.readFile /home/leroy/.ssh/id_rsa.pub;
    privateKey = builtins.readFile /home/leroy/.ssh/id_rsa;
  };

  mothership = { config, pkgs, ... }: {
    imports = [
      ./systemd-digitalocean/module.nix
    ];
    
    deployment.targetEnv = "droplet";
    deployment.droplet.enableIpv6 = true;
    deployment.droplet.region = "sgp1";
    deployment.droplet.size = "s-2vcpu-2gb";
  };
}
