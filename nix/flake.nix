{
  description = "Apple Silicon Mac configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # zsh plugins for nix/modules/zsh. Each URL has a commit, so `nix flake
    # update` does not change them. To update a plugin, review the new commits,
    # put the new commit here, and run ./n apply. The comment is the release
    # that `git describe --tags` shows for the commit.
    zsh-completions = {
      # 0.35.0-418
      url = "github:zsh-users/zsh-completions/4c84ebad534bdac3d2061db69082960c50856538";
      flake = false;
    };
    zsh-history-substring-search = {
      # v1.1.0-14
      url = "github:zsh-users/zsh-history-substring-search/14c8d2e0ffaee98f2df9850b19944f32546fdea5";
      flake = false;
    };
    zsh-syntax-highlighting = {
      # 0.8.0-4
      url = "github:zsh-users/zsh-syntax-highlighting/1d85c692615a25fe2293bdd44b34c217d5d2bf04";
      flake = false;
    };
    zsh-autosuggestions = {
      # v0.7.1-6
      url = "github:zsh-users/zsh-autosuggestions/85919cd1ffa7d2d5412f6d3fe437ebdbeeec4fc5";
      flake = false;
    };
    zsh-abbr = {
      # v6.5.2-4. The zsh-job-queue submodule is not used, see nix/modules/zsh.
      url = "github:olets/zsh-abbr/2de4a08c5e0d9dbe8447e11e0a177b59b5b6d6ea";
      flake = false;
    };
    zsh-autosuggestions-abbreviations-strategy = {
      # v1.1.2
      url = "github:olets/zsh-autosuggestions-abbreviations-strategy/3ce24713e4a49f9a5060d9016d35f3cd048d1c74";
      flake = false;
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      nix-darwin,
      home-manager,
      ...
    }:
    let
      user = import ./user.nix;
      system = "aarch64-darwin";
    in
    {
      darwinConfigurations.mac = nix-darwin.lib.darwinSystem {
        specialArgs = { inherit inputs user; };
        modules = [
          ./darwin.nix
          home-manager.darwinModules.home-manager
          {
            nixpkgs.hostPlatform = system;

            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = { inherit inputs user; };
              users.${user.name} = import ./home.nix;
            };
          }
        ];
      };

      formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt;
    };
}
