# Podkovyrin’s dotfiles

## Installation

```bash
sh -c "`curl -fsSL https://raw.githubusercontent.com/podkovyrin/dotfiles/master/install.sh`"
```

**Always be sure to run `rake update` after pulling to ensure plugins are updated**

### Sensible macOS defaults

```bash
./macos.sh
```

### Install Apps / Tools

```bash
./install_brew_tools.sh
```

```bash
./install_gem_tools.sh
```

```bash
./install_appstore.sh
```

### Updating

Update everything to latest versions from github:

```bash
yup
```

https://developer.apple.com/fonts/

## What's included, and how to customize?

### ZSH Customizations:

* Vim mode and bash style `Ctrl-R` for reverse history finder
* `Ctrl-x,Ctrl-l` to insert output of last command
* Fuzzy matching - if you mistype a directory name, tab completion will fix it
* [fasd](https://github.com/clvv/fasd) integration - hit `z` and partial match for recently used directory. Tab completion enabled.
* [Prezto - the power behind YADR's zsh](https://github.com/sorin-ionescu/prezto)
* [How to add your own ZSH theme](doc/zsh/themes.md)

### Aliases

Lots of things we do every day are done with two or three character
mnemonic aliases. Please feel free to edit them:

    ae # alias edit
    ar # alias reload


### Git Customizations:

YADR will take over your `~/.gitconfig`, so if you want to store your usernames, please put them into `~/.gitconfig.user`

It is recommended to use this file to set your user info. Alternately, you can set the appropriate environment variables in your `~/.secrets`.

  * `git l`- a much more usable git log
  * `git b`- a list of branches with summary of last commit
  * `git r` - a list of remotes with info
  * `git t`- a list of tags with info
  * `git nb`- a (n)ew (b)ranch - like checkout -b
  * `git cp`- cherry-pick -x (showing what was cherrypicked)
  * `git simple` - a clean format for creating changelogs
  * `git recent-branches` - if you forgot what you've been working on
  * `git unstage` (remove from index) and `git uncommit` (revert to the time prior to the last commit - dangerous if already pushed) aliases
  * Some sensible default configs, such as improving merge messages, push only pushes the current branch, removing status hints, and using mnemonic prefixes in diff: (i)ndex, (w)ork tree, (c)ommit and (o)bject
  * Slightly improved colors for diff


### RubyGems

A .gemrc is included. Never again type `gem install whatever --no-ri --no-rdoc`. `--no-ri --no-rdoc` is done by default.

### Vimization of everything

The provided inputrc and editrc will turn your various command line tools like mysql and irb into vim prompts. There's
also an included Ctrl-R reverse history search feature in editrc, very useful in irb, postgres command line, and etc.

## Misc

* [https://github.com/skwp/dotfiles](https://github.com/skwp/dotfiles)
* [https://github.com/mathiasbynens/dotfiles](https://github.com/mathiasbynens/dotfiles)
* [Credits & Thanks](doc/credits.md)
* [Yan's Blog](https://yanpritzker.com)

## Feedback

Suggestions/improvements [welcome](https://github.com/podkovyrin/dotfiles/issues)!
