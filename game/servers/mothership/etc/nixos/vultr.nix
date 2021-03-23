{
  resources.vultrSSHKeys.sshKey = { };

  vultr = { resources, ... }: {
    deployment.targetEnv = "vultr";
    deployment.vultr = {
      sshKey = resources.vultrSSHKeys.sshKey;
      region = "sgp";
      plan = "vhf-1c-1gb";
    };
  };
}
