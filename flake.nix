{
  description = ''
    Dev Shell with custom Terraform version, Flake example
      
    Use it with `nix develop` to get a shell with nixfmt and a custom terraform version.
    Make sure flakes and experimental-features are enabled in your nix.conf.

    ❯ nix develop
      bash-5.2$ terraform -v
      Terraform v1.6.4
      on linux_amd64

  '';

  # this flake will output one attribute called "devShell.x86_64-linux". It takes two arguments: self and nixpkgs. self is a reference to itself for recursive interpolation, and nixpkgs is a reference to the nix channel configured by the nix package manager on this machine.
  outputs = { self, nixpkgs }:

    # "let" us define a variable called "pkgs" which is is just nixpkgs, but with the system architecture set and the permission to build unfree software enabled.
    let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };

      # those variables are only available within this "in" block
    in {

      # this is the attribute that will be output by this flake. "nix develop" expects this name by default, so we use it here.
      # in order to not have to prefix every package with "pkgs." we can use the "with" keyword to make the pkgs variable the default namespace for this block. Otherwise we would need to write "pkgs.mkShell", "pkgs.mkTerraform", "pkgs.nixfmt" etc.
      devShell.x86_64-linux = with pkgs;
        let

          # We use mkTerraform to create our own terraform package. The output of this function is a derivation that will be built by nix when we run "nix develop". The function takes a set of arguments to control which terraform will be checked out by git. Because it's just a typical package, we can use it later in the buildInputs of mkShell.
          mein-liebstes-terraform = mkTerraform {
            version = "1.6.4";
            hash = "sha256-kA0H+JxyMV6RKRr20enTOzfwj2Lk2IP4vivfHv02+w8=";
            vendorHash = "sha256-cxnvEwtZLXYZzCITJgYk8hDRndLLC8YTD+RvgcNska0=";
          };

          # mkShell is a function that creates a the shell. Remember, this is what actually will be assigned to the "devShell.x86_64-linux" from above. We are still within those curly braces.
        in mkShell {

          # buildInputs is a list of packages that will be available in the shell. You know this already from our shell.nix files.
          buildInputs = [ nixfmt mein-liebstes-terraform ];
        };
    };
}
