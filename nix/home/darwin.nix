{ ... }:
{
  imports = [ ./common.nix ];

  xdg.configFile."karabiner/karabiner.json".source = ../../os-macos/karabiner/karabiner.json;
  xdg.configFile."karabiner/assets/complex_modifications" = {
    source = ../../os-macos/karabiner/assets/complex_modifications;
    recursive = true;
  };
}
