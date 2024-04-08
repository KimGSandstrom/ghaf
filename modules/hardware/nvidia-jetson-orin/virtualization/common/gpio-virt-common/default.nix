# Copyright 2022-2023 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
{
  lib,
  config,
  ...
}: let
  cfg = config.ghaf.hardware.nvidia.virtualization;
in {
  config = lib.mkIf cfg.enable {
    boot.kernelPatches = [
      {
        name = "Added Configurations to Support GPIO passthrough";
        patch = null;
        /* do this in modules/hardware/nvidia-jetson-orin/virtualization/default.nix for all virtualisation
        extraStructuredConfig = {
          PCI_STUB = lib.mkDefault lib.kernel.yes;
          HOTPLUG_PCI = lib.mkDefault lib.kernel.yes;
          HOTPLUG_PCI_ACPI = lib.mkDefault lib.kernel.yes;
          PCI_DEBUG = lib.mkDefault lib.kernel.yes;
          PCI_HOST_GENERIC = lib.mkDefault lib.kernel.yes;
          PCI_HOST_COMMON = lib.mkDefault lib.kernel.yes;
          VFIO = lib.mkDefault lib.kernel.yes;
          VFIO_IOMMU_TYPE1 = lib.mkDefault lib.kernel.yes;
          VFIO_PLATFORM = lib.mkDefault lib.kernel.yes;
          VIRTIO_PCI = lib.mkDefault lib.kernel.yes;
          VIRTIO_MMIO = lib.mkDefault lib.kernel.yes;
          CONFIG_GPIO_TEGRA = lib.mkDefault lib.kernel.yes;
          CONFIG_GPIO_TEGRA186 = lib.mkDefault lib.kernel.yes;
          TEGRA_GPIO_GUEST_PROXY = lib.mkDefault lib.kernel.no;
          TEGRA_GPIO_HOST_PROXY = lib.mkDefault lib.kernel.no;
        };
        */ 
      }
      {
        name = "Vfio_platform Reset Required False";
        patch = ./patches/0002-vfio_platform-reset-required-false.patch;
      }
      {
        name = "GPIO Support Virtualization";
        patch = ./patches/0003-gpio-virt-kernel.patch;
      }
      {
        name = "GPIO Virt Drivers";
        patch = ./patches/0004-gpio-virt-drivers.patch;
      }
      /*
      # the driver is implemeted as an overlay file not a patch file -- remove patch file
      {
        name = "GPIO Overlay";
        patch = ./patches/0005-gpio-overlay.patch;       # source file patch
      }
      # gpio PT works with this defconfig. Remove to use extraStructuredConfig instead
      {  
        name = "GPIO defconfig";
        patch = ./patches/0006-defconfig-kernel.patch;
      }
      */
    ];

    boot.kernelParams = [ 
      "iommu=pt"
      "vfio.enable_unsafe_noiommu_mode=0"
      "vfio_iommu_type1.allow_unsafe_interrupts=1"
      "vfio_platform.reset_required=0"
    ];
  };
}
