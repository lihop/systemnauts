{
  training =
    { config, pkgs, ... }:
    { deployment.targetEnv = "virtualbox";
      deployment.virtualbox.headless = true;
      deployment.virtualbox.vcpu = 1; # number of cpus
      deployment.virtualbox.memorySize = 1024; # megabytes
    };
}
