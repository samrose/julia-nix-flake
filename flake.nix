{
  description = "A Julia program packaged with Nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        
        # Create a derivation for your Julia project
        juliaProject = pkgs.stdenv.mkDerivation {
          name = "julia-hello";
          src = ./src;
          
          nativeBuildInputs = [ pkgs.makeWrapper pkgs.julia-bin ];
          
          # Install phase: create the Julia depot and install dependencies
          installPhase = ''
            # Set up Julia depot in the build directory
            export JULIA_DEPOT_PATH="$out/share/julia"
            mkdir -p $JULIA_DEPOT_PATH
            
            # Install dependencies from Project.toml
            julia --project="$src" -e '
              using Pkg
              Pkg.instantiate()
              Pkg.precompile()
            '
            
            # Install the main script
            mkdir -p $out/bin
            cp $src/hello.jl $out/bin/
            
            # Create wrapper
            makeWrapper ${pkgs.julia}/bin/julia $out/bin/hello-julia \
              --set JULIA_DEPOT_PATH "$JULIA_DEPOT_PATH" \
              --set JULIA_PROJECT "$src" \
              --add-flags "$out/bin/hello.jl"
          '';
        };

      in
      {
        packages.default = juliaProject;

        apps.default = {
          type = "app";
          program = "${juliaProject}/bin/hello-julia";
        };

        devShells.default = pkgs.mkShell {
          buildInputs = [
            pkgs.julia-bin
          ];
          
          shellHook = ''
            export JULIA_PROJECT="$(pwd)/src"
          '';
        };
      });
}
