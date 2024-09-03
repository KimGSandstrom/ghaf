# Copyright 2022-2023 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
let
  qemu_version = prev.qemu_kvm.version;
  qemu_major = final.lib.versions.major qemu_version;
  qemu_minor = final.lib.versions.minor qemu_version;
in
(_final: prev: {
  qemu_patch_gpio = if (qemu_major == "8" && qemu_minor == "0")
    then [ ./patches/0001-qemu-v8.1.3_gpio-virt.patch ]
    else prev.patches;
  qemu_patch_bpmp = if (qemu_major == "8" && qemu_minor == "0")
    then [ ./patches/0001-qemu-v8.1.3_bpmp-virt.patch ]
    else prev.patches;
  qemu_kvm = prev.qemu.overrideAttrs (_final: prev: {
    patches =
      prev.patches ++ qemu_patch_gpio
  });
  /*
  qemu_kvm = prev.qemu_kvm.overrideAttrs (
    patches =
      prev.patches ++ qemu_patch_bpmp
  );
  */
})
