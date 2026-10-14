{
  config,
  pkgs,
  lib,
  user,
  ...
}:

let
  hmVariables = config.home-manager.users.${user.name}.home.sessionVariables;

  # GUI processes do not read the shell profile. Give them the same tools and SDKs.
  guiEnvironment = {
    inherit (hmVariables) JAVA_HOME ANDROID_HOME;
    PATH = "${hmVariables.DOTFILES_TOOL_PATH}:/usr/bin:/bin:/usr/sbin:/sbin";
  };
in
{
  imports = [
    ./macos-defaults.nix
    ./homebrew.nix
  ];

  system = {
    primaryUser = user.name;
    stateVersion = 6;
    # The check looks for <darwin-config>, which a flake configuration does not have.
    checks.verifyNixPath = false;
  };
  users.users.${user.name}.home = user.home;

  # Touch ID for sudo. reattach makes it work in terminal multiplexers too.
  security.pam.services.sudo_local = {
    touchIdAuth = true;
    reattach = true;
  };

  nix = {
    enable = true;
    package = pkgs.nixVersions.latest;
    channel.enable = false;
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

    # Weekly, as root. Integrated Home Manager generations belong to the system
    # profile. Separate user profiles need manual pruning.
    gc = {
      automatic = true;
      options = "--delete-older-than 14d";
    };
    optimise.automatic = true;
  };

  nixpkgs.config.allowUnfreePredicate =
    package: lib.elem (lib.getName package) [ "google-cloud-sdk" ];

  # Zim runs compinit and Starship draws the prompt. /etc/zshrc keeps only the
  # Nix completion paths in fpath.
  programs.zsh = {
    enable = true;
    enableGlobalCompInit = false;
    enableBashCompletion = false;
    promptInit = "";
  };

  # launchd.user.envVariables sets these only during activation, and a reboot clears
  # them. This agent sets them again at each login.
  launchd.user.agents.gui-environment = {
    script = lib.concatLines (
      lib.mapAttrsToList (
        name: value: "/bin/launchctl setenv ${name} ${lib.escapeShellArg value}"
      ) guiEnvironment
    );
    serviceConfig.RunAtLoad = true;
  };

  fonts.packages = with pkgs; [
    montserrat
    jetbrains-mono
    nerd-fonts.jetbrains-mono
  ];
}
