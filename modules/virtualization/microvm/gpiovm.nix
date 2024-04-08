# Copyright 2022-2024 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
{
  config,
  lib,
  pkgs,
  ...
} : with pkgs; let
  cfg = config.ghaf.virtualization.microvm.gpiovm;
  configHost = config;
  vmName = "gpio-vm";

  /*
  utils = pkgs.env.system.posix.utilities;

  # with utils {
    #script = pkgs.buildPackages.bashPackages.devtools.mkDerivation rec {
    script = pkgs.env.system.posix.utilitiesmkDerivation rec {
      name = "simple-chardev-test";
      src = "./simple-chardev-test.sh"; # bash script testing some gpio pins
      buildInputs = ["sysfsutils"];
      phases = {
        install = (args) => {
          self.installPhase = super.install();
          runCommand "/usr/bin/chmod +x ${self.prefix}/${self.name}";
        };
      };
    # };
  };
  scriptPath = "${script.out}/${script.name}"; # path to nix store
  */
  /*
  script = pkgs.readFile ./simple-chardev-test.sh;
  scriptPath = "${pkgs.writeText "script" script}";
  */
  # Import the service's nix script definition
  script = import ./script.nix { pkgs = pkgs; };

  gpiovmBaseConfiguration = {
    imports = [
      # (import ./common/vm-networking.nix {inherit vmName macAddress;})
      ({lib, ...}: {
        ghaf = {
          users.accounts.enable = lib.mkDefault configHost.ghaf.users.accounts.enable;
          development = {
            debug.tools.enable = lib.mkDefault configHost.ghaf.development.debug.tools.enable;
          };
        };

        system.stateVersion = lib.trivial.release;

        nixpkgs.buildPlatform.system = configHost.nixpkgs.buildPlatform.system;
        nixpkgs.hostPlatform.system = configHost.nixpkgs.hostPlatform.system;

        microvm.hypervisor = "qemu";

        microvm.services."gpiotest" = {
          description = "A simple Nix-built service";
          enable = true;
          executeAs = "root";
          startPrecondition = [ "networking" ];
          startCommand = "bash ${script.gpioScript}";
          restart = {
            failuresBeforeAction = 3;
            delaySec = 5;
          };
        };
        /*
        services.xxx = {
          enable = true;
        };
        */
        microvm = {
          optimize.enable = true;
          shares = [
            {
              tag = "ro-store";
              source = "/nix/store";
              mountPoint = "/nix/.ro-store";
            }
          ];
          writableStoreOverlay = lib.mkIf config.ghaf.development.debug.tools.enable "/nix/.rw-store";
        };

        imports = import ../../module-list.nix;
      })
    ];
  };
in {
  options.ghaf.virtualization.microvm.gpiovm = {
    enable = lib.mkEnableOption "GPIO-VM";

    extraModules = lib.mkOption {
      description = ''
        List of additional modules to be imported and evaluated as part of
        GPIO-VM's NixOS configuration.
      '';
      default = [];
    };
  };

  config = lib.mkIf cfg.enable {
    microvm.vms."${vmName}" = {
      autostart = true;
      config =
        gpiovmBaseConfiguration
        // {
          imports =
            gpiovmBaseConfiguration.imports
            ++ cfg.extraModules;
        };
      specialArgs = {inherit lib;};
    };
  };
}
