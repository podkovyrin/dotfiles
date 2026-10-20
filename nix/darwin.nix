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
  # They do not run `mise activate`, so the mise shims supply the global runtimes.
  guiEnvironment = {
    inherit (hmVariables) JAVA_HOME ANDROID_HOME;
    PATH = "${hmVariables.DOTFILES_TOOL_PATH}:${user.home}/.local/share/mise/shims:/usr/bin:/bin:/usr/sbin:/sbin";
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

  # nix/modules/zsh runs compinit and Starship draws the prompt. /etc/zshrc
  # keeps only the Nix completion paths in fpath.
  programs.zsh = {
    enable = true;
    enableGlobalCompInit = false;
    enableBashCompletion = false;
    promptInit = "";
  };

  # The login shell is the Nix zsh, the version that nix/modules/zsh compiles
  # its files with. environment.shells adds it to /etc/shells. nix-darwin sets
  # users.users.<name>.shell only for knownUsers, which must not include the
  # admin user, so set it here.
  # postActivation runs before /run/current-system points to this generation.
  # On a new Mac the link does not exist yet, and a later failure would leave
  # a login shell that does not exist. Change the shell only when the path
  # works now and in this generation; on a new Mac, the second switch sets it.
  # If the Nix volume does not mount, use `/bin/zsh -l` as the Terminal command.
  environment.shells = [ pkgs.zsh ];
  system.activationScripts.postActivation.text = ''
    loginShell=/run/current-system/sw${pkgs.zsh.shellPath}
    if [[ ! -x $loginShell || ! -x $systemConfig/sw${pkgs.zsh.shellPath} ]]; then
      echo "not changing the login shell of ${user.name}: $loginShell is not there yet. Switch again." >&2
    elif [[ $(dscl . -read ${lib.escapeShellArg "/Users/${user.name}"} UserShell) != "UserShell: $loginShell" ]]; then
      echo "setting the login shell of ${user.name} to $loginShell..." >&2
      dscl . -create ${lib.escapeShellArg "/Users/${user.name}"} UserShell "$loginShell"
    fi
  '';

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
