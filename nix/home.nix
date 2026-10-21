# My Home Manager settings, on top of the dotkit base.
{ lib, user, ... }:

let
  androidHome = "${user.home}/Library/Android/sdk";
in
{
  imports = [
    ./links.nix
    ./shell.nix
  ];

  # The base config files link to my dotkit checkout, so edits apply without
  # a rebuild. config/zsh/zprofile sets DOTKIT_DIR for dotkit to the same path.
  dotkit.liveDir = "${user.home}/.dotkit";

  dotkit.toolPath = lib.mkMerge [
    # After ~/.local/bin, before Homebrew.
    [
      "${androidHome}/platform-tools"
      "${androidHome}/cmdline-tools/latest/bin"
    ]
    # After Homebrew.
    (lib.mkAfter [ "${user.home}/.orbstack/bin" ])
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    ANDROID_HOME = androidHome;
  };

  # Packages that need a Nix expression. Plain names go in nix/packages.txt.
  # home.packages = [ (pkgs.python3.withPackages (ps: [ ps.requests ])) ];
}
