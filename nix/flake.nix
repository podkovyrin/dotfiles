{
  description = "Andrei's Mac, on top of dotkit";

  inputs = {
    # My dotkit checkout. dotkit pins Nixpkgs, nix-darwin, and Home Manager.
    # The lock has its last commit (`dotkit upgrade dotkit`). With DOTKIT_DIR
    # (set in config/zsh/zprofile), dotkit uses its working tree instead.
    dotkit.url = "git+file:///Users/andrei/.dotkit";
    # For tools that look for the Nixpkgs of this flake: nixd in config/zed.json.
    nixpkgs.follows = "dotkit/nixpkgs";
  };

  outputs =
    { dotkit, ... }:
    let
      user = import ./user.nix;
    in
    {
      darwinConfigurations.mac = dotkit.inputs.nix-darwin.lib.darwinSystem {
        specialArgs = { inherit user; };
        modules = [
          dotkit.darwinModules.default
          ./darwin.nix
          { home-manager.users.${user.name} = import ./home.nix; }
        ];
      };

      inherit (dotkit) formatter;
    };
}
