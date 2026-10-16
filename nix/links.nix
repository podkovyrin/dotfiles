{
  config,
  lib,
  user,
  ...
}:

let
  repository = user.dotfiles;
  live = relative: config.lib.file.mkOutOfStoreSymlink "${repository}/${relative}";

  # Link files. Link a directory only if it holds config and no state or secrets.
  # For example, link ~/.pi/agent/extensions, not ~/.pi/agent.
  files = {
    ".bunfig.toml" = "config/bunfig.toml";
    ".editorconfig" = "config/editorconfig";
    ".editrc" = "config/editrc";
    ".gemrc" = "config/gemrc";
    ".gitconfig" = "config/gitconfig";
    ".gitignore" = "config/gitignore";
    ".npmrc" = "config/npmrc";

    ".zshenv" = "config/zsh/zshenv";
    ".zprofile" = "config/zsh/zprofile";
    ".zshrc" = "config/zsh/zshrc";
    ".zimrc" = "config/zsh/zimrc";
    ".config/zsh-abbr/user-abbreviations" = "config/zsh/abbreviations";

    ".config/btop/btop.conf" = "config/btop.conf";
    ".config/ghostty/config" = "config/ghostty.conf";
    ".config/herdr/config.toml" = "config/herdr.toml";
    ".config/karabiner/karabiner.json" = "config/karabiner.json";
    ".config/lazygit/config.yml" = "config/lazygit.yml";
    ".config/mise/config.toml" = "config/mise.toml";
    ".config/omniwm/settings.toml" = "config/omniwm.toml";
    ".config/starship.toml" = "config/starship.toml";
    ".config/uv/uv.toml" = "config/uv.toml";
    ".config/zed/settings.json" = "config/zed.json";
    ".config/zed/tasks.json" = "config/zed-tasks.json";

    # pnpm reads its global config here on macOS unless XDG_CONFIG_HOME is set.
    "Library/Preferences/pnpm/config.yaml" = "config/pnpm.yaml";

    ".local/bin/audio-toggle" = "scripts/audio-toggle";
    ".local/bin/omniwm-browser" = "scripts/omniwm-browser";
    ".config/herdr/git-status.py" = "scripts/herdr/git-status.py";
    ".config/herdr/git-status.sh" = "scripts/herdr/git-status.sh";
    ".config/herdr/process-name.bash" = "scripts/herdr/process-name.bash";
    ".config/herdr/process-name.sh" = "scripts/herdr/process-name.sh";
    ".config/herdr/process-name.zsh" = "scripts/herdr/process-name.zsh";

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
  copies = {
    ".pi/agent/subagent-manager/settings.json" = "config/pi/subagent-manager/settings.json";
  };

in
{
  home.file = lib.mapAttrs (_target: source: { source = live source; }) files;

  home.activation = {
    # Out-of-store links do not fail on a missing source. Stop before linking instead.
    checkLiveSources = lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
      for source in ${
        lib.escapeShellArgs (map (source: "${repository}/${source}") (lib.attrValues (files // copies)))
      }; do
        if [[ ! -e $source ]]; then
          errorEcho "Missing live config source: $source"
          exit 1
        fi
      done
    '';

    copyLiveSources = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      copyLiveSource() {
        local source=$1 target=$2
        cmp -s "$source" "$target" && return
        if [[ -f $target ]]; then
          run cp -p "$target" "$target.bak"
          warnEcho "Backed up $target to $target.bak"
        fi
        run mkdir -p "$(dirname "$target")"
        run install -m 600 "$source" "$target"
      }
      ${lib.concatLines (
        lib.mapAttrsToList (
          target: source:
          "copyLiveSource ${
            lib.escapeShellArgs [
              "${repository}/${source}"
              "${config.home.homeDirectory}/${target}"
            ]
          }"
        ) copies
      )}
    '';
  };
}
