export MAKEOPTS="-j12"
flake='.#nvidia-jetson-orin-agx-debug'
echo "Do you want to build only or switch to a new nix flake? (b/s/t/r/n)"
if [ $# == '0' ]
  then read ans
  else ans=$1
fi
export MAKEOPTS="-j12"
case $ans in
  b|B)
    echo "Building a nix derivation..."
    nixos-rebuild --flake ${flake} build
    ;;
  s|S)
    echo "Switchng a nix derivation..."
    sudo nixos-rebuild --flake ${flake} switch
    ;;
  t|T)
    echo "Building a nix derivation..."
    nixos-rebuild --flake ${flake} build --show-trace
    ;;
  r|R)
    echo "Evaluating to eval_${flake}.tmp"
    nix derivation show --recursive ${flake} > eval_${flake}.tmp 
    ;;
  n|N)
    echo "Exiting..."
    exit 1
    ;;
  *)
    echo "Invalid input. Exiting..."
    exit 1
    ;;
esac

