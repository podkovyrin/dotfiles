# My config files, as links: target in ~ = file in this repository. The dotkit
# base links the shared files (see nix/home.nix in dotkit). A target here that
# the base also links replaces the base file.
{
  dotkit.links = {
    # Replace base files.
    ".config/git/ignore" = "config/gitignore";
    ".npmrc" = "config/npmrc";

    # Read after the base files, which source or include them.
    ".zprofile.local" = "config/zsh/zprofile";
    ".zshrc.local" = "config/zsh/zshrc";
    ".gitconfig" = "config/gitconfig";
    ".config/ghostty/config.local" = "config/ghostty.conf";

    ".editrc" = "config/editrc";

    ".config/btop/btop.conf" = "config/btop.conf";
    ".config/karabiner/karabiner.json" = "config/karabiner.json";
    ".config/omniwm/settings.toml" = "config/omniwm.toml";
    ".config/zed/settings.json" = "config/zed.json";
    ".config/zed/tasks.json" = "config/zed-tasks.json";

    ".local/bin/audio-toggle" = "scripts/audio-toggle";
    ".local/bin/omniwm-browser" = "scripts/omniwm-browser";

    # LazyVim keeps plugins and state in ~/.local, so the config directory can be live.
    ".config/nvim" = "config/nvim";

    # Skill and extension installers write into these directories. The changes
    # show up in Git; .gitignore lists the ones to keep out.
    ".agents/skills" = "config/agents/skills";
    ".agents/.skill-lock.json" = "config/agents/.skill-lock.json";
    ".pi/agent/extensions" = "config/pi/extensions";
    ".pi/agent/settings.json" = "config/pi/settings.json";
    ".pi/agent/cloak.json" = "config/pi/cloak.json";
    ".pi/agent/open-tui.json" = "config/pi/open-tui.json";
  };

  # pi-subagent-manager rejects symlinked settings, so copy them. A differing
  # local copy, for example one saved from /agents, is kept as .bak.
  dotkit.copies = {
    ".pi/agent/subagent-manager/settings.json" = "config/pi/subagent-manager/settings.json";
  };
}
