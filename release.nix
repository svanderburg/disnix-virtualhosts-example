{ nixpkgs ? <nixpkgs>
, disnix_virtualhosts_example ? {outPath = ./.; rev = 1234;}
, officialRelease ? false
, systems ? [ "i686-linux" "x86_64-linux" ]
}:

let
  pkgs = import nixpkgs {};

  disnixos = import "${pkgs.disnixos}/share/disnixos/testing.nix" {
    inherit nixpkgs;
  };

  version = builtins.readFile ./version;

  jobs = rec {
    tarball = disnixos.sourceTarball {
      name = "disnix-virtualhosts-example-tarball";
      src = disnix_virtualhosts_example;
      inherit officialRelease version;
    };

    build = pkgs.lib.genAttrs systems (system:
      let
        pkgs = import nixpkgs { inherit system; };

        disnixos = import "${pkgs.disnixos}/share/disnixos/testing.nix" {
          inherit nixpkgs system;
      };
      in
      disnixos.buildManifest {
        name = "disnix-virtualhosts-example";
        inherit tarball version;
        servicesFile = "deployment/DistributedDeployment/services.nix";
        networkFile = "deployment/DistributedDeployment/network.nix";
        distributionFile = "deployment/DistributedDeployment/distribution.nix";
      }
    );

    tests = disnixos.disnixTest {
      name = "disnix-virtualhosts-example-tests";
      inherit tarball;
      manifest = builtins.getAttr (builtins.currentSystem) build;
      networkFile = "deployment/DistributedDeployment/network.nix";
      testScript =
        ''
          # Wait for a while and capture the output of the entry page
          result = client.succeed("sleep 30; curl --fail -H 'Host: webapp2.local' http://test1")

          # The entry page should contain webapp2 :-)

          if "webapp2" in result:
              print("Entry page contains webapp2!")
          else:
              raise Exception("Entry page should contain webapp2!")
        '';
    };
  };
in
jobs
