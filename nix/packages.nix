{ pkgs, inputs, ... }:

let
  system = pkgs.stdenv.hostPlatform.system;
in
{
  home.packages = with pkgs; [
    # Projects pin their own runtimes through mise or a Nix dev shell.
    # Xcode supplies the compiler, linker, and SDK.
    nodejs_24
    ruby_3_4
    python314
    jdk17

    mise
    pnpm
    uv

    bat
    eza
    fd
    ripgrep
    jq
    fzf
    zoxide
    starship
    btop
    fastfetch
    yazi
    gitmux # scripts/herdr/git-status.py reads Git status from gitmux.
    hyperfine
    tealdeer

    git
    git-lfs
    git-secret
    gh
    tig
    lazygit
    neovim
    gnupg

    watchman

    p7zip
    imagemagick
    ghostscript
    poppler-utils
    vhs

    google-cloud-sdk
    gogcli

    duti
    switchaudio-osx
    inputs.mole.packages.${system}.default

    # Herdr and Pi come from overlays in flake.nix; Hunk and Mole have no overlay.
    herdr
    inputs.hunk.packages.${system}.default
    # Pi puts its Node first in PATH for every command it runs. Use the global
    # Node 24 there too, not a second Node 22.
    (pi.override { nodejs_22 = nodejs_24; })
  ];
}
