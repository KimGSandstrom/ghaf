# Copyright 2022-2024 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.ghaf.virtualization.microvm.gpiovm;
  configHost = config;
  vmName = "gpiovm";
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
