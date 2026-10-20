{ lib, ... }:

{
  homebrew = {
    enable = true;
    global.brewfile = true;

    # Activation installs and removes, but does not upgrade. Run `./n upgrade brew` to upgrade.
    onActivation = {
      cleanup = "uninstall";
      autoUpdate = false;
      upgrade = false;
      extraEnv.HOMEBREW_NO_INSTALL_CLEANUP = "1";
    };

    # The lists are in nix/brews.txt and nix/casks.txt (`./n add` edits them).
    brews = import ./read-list.nix lib ./brews.txt;
    casks = import ./read-list.nix lib ./casks.txt;

    masApps = {
      Keynote = 361285480;
      Numbers = 409203825;
      Pages = 409201541;
      "Pixelmator Pro" = 1289583905;
    };
  };
}
