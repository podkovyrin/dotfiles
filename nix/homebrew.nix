{
  homebrew = {
    enable = true;
    global.brewfile = true;

    onActivation = {
      cleanup = "uninstall";
      autoUpdate = true;
      upgrade = true;
      extraEnv.HOMEBREW_NO_INSTALL_CLEANUP = "1";
    };

    casks = [
      "ghostty"
      "sublime-text"
      "fork"
      "zed"
      "android-studio"

      "google-chrome"
      "helium-browser"
      "telegram"
      "slack"
      "zoom"

      "spotify"
      "the-unarchiver"
      "vlc"
      "macmediakeyforwarder"
      "sf-symbols"
      "db-browser-for-sqlite"
      "steermouse"
      "raycast"
      "google-drive"
      "notunes"
      "monitorcontrol"
      "1password"
      "chatgpt"
      "codexbar"
      "opencode-desktop"
      "orbstack"
      "omniwm"
      "karabiner-elements"

      # Apple fonts are not in Nixpkgs.
      "font-sf-mono"
      "font-sf-pro"
    ];

    masApps = {
      Keynote = 361285480;
      Numbers = 409203825;
      Pages = 409201541;
      "Pixelmator Pro" = 1289583905;
    };
  };
}
