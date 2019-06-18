     _     _           _
    | |   | |         | |
    | |___| |_____  __| | ____
    |_____  (____ |/ _  |/ ___)
     _____| / ___ ( (_| | |
    (_______\_____|\____|_|

    # Yet Another Dotfile Repo v1.1-podkovyrin
    # Now with Prezto!

# Podkovyrin’s dotfiles

## Based on

* [https://github.com/skwp/dotfiles](https://github.com/skwp/dotfiles)
* [https://github.com/mathiasbynens/dotfiles](https://github.com/mathiasbynens/dotfiles)

**Always be sure to run `rake update` after pulling to ensure plugins are updated**

## What is YADR?

**YADR is an opinionated dotfile repo that will make your heart sing**

  * The best bits of all the top dotfile repos, zsh plugins curated in one place, into a simple and cohesive way of working.
  * Many zsh plugins, starting with the wonderful Prezto base, and adding a few niceties on top.
  * All things are vimized: command line, etc.

*Linux/Ubuntu is not supported! If it works, great. If it doesn't, please don't complain. You may need to install zsh if you don't already have it.*

## Installation

To get started please run:

```bash
sh -c "`curl -fsSL https://raw.githubusercontent.com/podkovyrin/dotfiles/zsh/install.sh`"
```

**Note:** YADR will automatically install all of its subcomponents. If you want to customize anything - fork the repo

### Sensible macOS defaults

When setting up a new Mac, you may want to set some sensible macOS defaults:

```bash
./macos.sh
```

### Install Homebrew formulae

When setting up a new Mac, you may want to install some common [Homebrew](https://brew.sh/) formulae (after installing Homebrew, of course):

```bash
./install_tools.sh
```

Some of the functionality of these dotfiles depends on formulae installed by `install_tools.sh`. If you don’t plan to run `install_tools.sh`, you should look carefully through the script and manually install any particularly important ones.

### Upgrading

Upgrading is easy.

```bash
cd ~/.yadr
git pull --rebase
rake update
```

Update all plugins to latest versions from github:

```bash
yup
```

Initialize all submodules. Run this every time you pull a new yadr version:

```bash
yip
```

## What's included, and how to customize?

Read on to learn what YADR provides!

### [Homebrew](https://brew.sh/)

Homebrew is _the missing package manager for macOS_. Installed automatically.

We automatically install a few useful packages including ctags, git, macvim, hub, and the silver searcher ('ag')
Note that our autocomplete plugin requires a MacVim that supports Lua. The installer knows how to install it, but if you had one installed before, you may need to manually remove your old MacVim.

### ZSH

Think of Zsh as a more awesome bash without having to learn anything new.
Automatic spell correction for your commands, syntax highlighting, and more.
We've also provided lots of enhancements:

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

* [Credits & Thanks](doc/credits.md)
* [Yan's Blog](https://yanpritzker.com)

## Feedback

Suggestions/improvements [welcome](https://github.com/podkovyrin/dotfiles/issues)!
