{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";
    process-compose-flake.url = "github:Platonic-Systems/process-compose-flake";
    services-flake.url = "github:juspay/services-flake";
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];
      imports = [
        inputs.process-compose-flake.flakeModule
      ];
      perSystem =
        {
          self',
          pkgs,
          config,
          lib,
          ...
        }:
        {
          process-compose."default-service" =
            { config, ... }:
            {
              imports = [
                inputs.services-flake.processComposeModules.default
              ];

              services = { };
            };

          devShells.default = pkgs.mkShell {
            inputsFrom = [
              config.process-compose."default-service".services.outputs.devShell
            ];
            buildInputs = with pkgs; [ hello ];
          };
        };
    };
}
