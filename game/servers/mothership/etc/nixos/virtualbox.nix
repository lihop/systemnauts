{
  vbox = { config, pkgs, ... }: {
    deployment.targetEnv = "virtualbox";
    deployment.virtualbox.vcpu = 2;
    deployment.virtualbox.memorySize = 2048;
    deployment.virtualbox.headless = true;
  };
}
