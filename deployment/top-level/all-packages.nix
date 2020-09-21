{ pkgs, system
, stateDir
, logDir
, runtimeDir
, tmpDir
, forceDisableUserChange
, processManager
, ids ? {}
}:

let
  createManagedProcess = import ../../../nix-processmgmt/nixproc/create-managed-process/agnostic/create-managed-process-universal.nix {
    inherit pkgs stateDir runtimeDir logDir tmpDir forceDisableUserChange processManager ids;
  };

  callPackage = pkgs.lib.callPackageWith (pkgs // self);

  self = {
    webapp = (import ../../services/webapp {
      inherit system pkgs;
    }).package;

    webappwrapper = callPackage ../pkgs/webapp/wrapper.nix {
      inherit createManagedProcess;
    };
  };
in
self
