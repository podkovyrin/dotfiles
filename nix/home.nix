{
  lib,
  pkgs,
  user,
  ...
}:

let
  androidHome = "${user.home}/Library/Android/sdk";
in
{
  imports = [
    ./packages.nix
    ./links.nix
    ./shell.nix
  ];

  home.stateVersion = "26.05";

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    # A Nix dev shell or a project mise.toml with java replaces it in the project.
    JAVA_HOME = pkgs.zulu17.home;
    ANDROID_HOME = androidHome;

    # Global tool directories, in priority order. config/zsh/zprofile puts them
    # before the inherited PATH. darwin.nix gives them to GUI apps.
    DOTFILES_TOOL_PATH = lib.concatStringsSep ":" [
      "/etc/profiles/per-user/${user.name}/bin"
      "/run/current-system/sw/bin"
      "${user.home}/.local/bin"
      "${androidHome}/platform-tools"
      "${androidHome}/cmdline-tools/latest/bin"
      # Homebrew casks link their CLIs here, for example subl.
      "/opt/homebrew/bin"
      "/opt/homebrew/sbin"
      "${user.home}/.orbstack/bin"
    ];
  };

  # Projects opt in with `direnv allow`. nix/shell.nix adds the zsh hook,
  # because Home Manager does not generate the zsh files.
  programs.direnv = {
    enable = true;
    nix-direnv = {
      enable = true;
      # Use the system Nix from darwin.nix, not a second copy of pkgs.nix.
      package = pkgs.nix-direnv.override { nix = pkgs.nixVersions.latest; };
    };
  };

  # Native GUI apps are managed by nix-darwin and Homebrew.
  targets.darwin.copyApps.enable = false;
  targets.darwin.linkApps.enable = false;
}
