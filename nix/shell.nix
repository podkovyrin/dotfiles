# My settings for the zsh setup in nix/modules/zsh. The rest of my zsh
# config is in config/zsh/zshrc, which needs no rebuild.
{
  imports = [ ./modules/zsh ];

  dotfiles.zsh = {
    enable = true;
    keymap = "vi";
    title = "%~";

    integrations = {
      fzf.enable = true;
      zoxide.enable = true;
      starship.enable = true;
      mise.enable = true;
      direnv.enable = true;
    };

    # Expanded with Space or Enter. The name can have several words.
    abbreviations = {
      ".." = "z ..";

      "y" = "yazi";
      "zd" = "zed .";

      "localsrv" = "python3 -m http.server";

      "g" = "git";
      "t" = "tig";
      "ta" = "tig --all";
      "gg" = "lazygit";

      "git b" = "git branch";
      "git branch m" = "git branch --move";
      "git branch d" = "git branch --delete";
      "git branch df" = "git branch --delete --force";
      "git a" = "git add";
      "git co" = "git checkout";
      "git c" = "git commit";
      "git cm" = "git commit -m";
      "git ca" = "git commit -am";
      "git ci" = "git commit -anm";
      "git sw" = "git switch";
      "git re" = "git restore";
      "git commit a" = "git commit --amend";
      "git d" = "git diff";
      "git diff c" = "git diff --cached";
      "git diff no" = "git diff --name-only";
      "git f" = "git fetch";
      "git fa" = "git fetch --all";
      "git l" = "git log";
      "git m" = "git merge";
      "git merge nff" = "git merge --no-ff";
      "git merge ffo" = "git merge --ff-only";
      "git pl" = "git pull";
      "git ps" = "git push";
      "git r" = "git remote -v";
      "git rb" = "git rebase";
      "git rc" = "git rebase --continue";
      "git rs" = "git rebase --skip";
      "git rebase i" = "git rebase --interactive";
      "git cp" = "git cherry-pick -x";
      "git stash p" = "git stash pop";
      "git stash s" = "git stash show";
      "git stash d" = "git stash drop";
      "git s" = "git status";
      "git ss" = "git stash";
      "git t" = "git tag";
      "git tag d" = "git tag --delete";
    };
  };
}
