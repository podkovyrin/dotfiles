# My nix-darwin settings, on top of the dotkit base (Nix, the login shell,
# Touch ID for sudo, fonts, Homebrew).
{ pkgs, ... }:

{
  imports = [ ./macos-defaults.nix ];

  # After the dotkit base lists. `dotkit add` and `dotkit remove` edit them.
  dotkit.lists = {
    packages = [ ./packages.txt ];
    brews = [ ./brews.txt ];
    casks = [ ./casks.txt ];
  };

  # nix/home.nix sets it.
  dotkit.guiVariables = [ "ANDROID_HOME" ];

  # My lists are the complete set: an apply uninstalls what they do not have.
  # The dotkit default keeps everything that was installed by hand.
  homebrew.onActivation.cleanup = "uninstall";

  homebrew.masApps = {
    Keynote = 361285480;
    Numbers = 409203825;
    Pages = 409201541;
    "Pixelmator Pro" = 1289583905;
  };

  fonts.packages = [ pkgs.montserrat ];
}
